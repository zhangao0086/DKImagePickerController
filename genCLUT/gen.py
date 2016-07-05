import time
import os
import subprocess
import sys
import re
import uuid
import json
import colorsys
import filecmp
import argparse

from PIL import Image
from PIL import ImageDraw

from subprocess import call

if len(sys.argv) == 1:
    print 'usage : python gen.py [target dir]'
    sys.exit(0)

#
# define scheme
#
__DELIMETER__ = '_'
__INDEX_FORMAT__ = '{:0=5}'
__PROVIDER__ = 'starpretprism'

__FILTER_DIR_FLAG_DELIMETER__ = '_f#'
__FILTER_DIR_TAGNAME_DELIMETER__ = '_t#'

__DELETE_FILE_HEAD__ = '_d#'
__META_FILE_HEAD__ = 'prismeta'
__META_FILE_EXT__ = 'json'

# format : {index}_{hexcolor}_{uid}_{flag}_{provider}.png
__FILTER_FILE_REG_EX__ = '^([0-9]{5})_([A-Za-z0-9]{6})_([0-9a-z]{32})_([0-9]{1,})(_.+){0,}\.(png|jpg)$'
__FILTER_DIR_REG_EX__ = '^([A-Za-z0-9]{6})_([0-9a-z]{32})_([0-9]{1,})(_(.+))?$'
__FILTER_FILE_REG__ = re.compile(__FILTER_FILE_REG_EX__)
__FILTER_DIR_REG__ = re.compile(__FILTER_DIR_REG_EX__)

#
# define flag
#
__FLAG_TEST_UNDEFINED__ = 0
__FLAG_DEFAULT__ = 1 << 0
__FLAG_LOCK_COMMERCIAL__ = 1 << 1
__FLAG_LOCK_SHARE_DEFAULT__ = 1 << 2
__FLAG_LOCK_SHARE_TWT__ = 1 << 3
__FLAG_LOCK_SHARE_FCB__ = 1 << 4
__FLAG_LOCK_SHARE_RVW__ = 1 << 5
__FLAG_REPRESENT__ = 1 << 6
__FLAG_FORCE_AVG_COLOR__ = 1 << 7
# define macro flag
__FLAG_INITIAL_DIR__ =  __FLAG_DEFAULT__ | __FLAG_REPRESENT__ | __FLAG_FORCE_AVG_COLOR__

#
# define func
#
def gen_preview(rgbs, file, width, height):
    img = Image.new("RGB", (width, height))
    canvas = ImageDraw.Draw(img)
    dx = width / float(len(rgbs))
    x = 0
    y = height / 2.0
    for rgb in rgbs:
        canvas.line((x, y, x + dx, y), width=height, fill=rgb)
        x += dx
        #temp save
    img.save(file)
    #get avg
    avg_hex = get_average(file).get('hex')
    return avg_hex

def get_splited_first(str, delimeter):
    s_arr = str.split(delimeter)
    if not len(s_arr) > 1: return None
    return s_arr[-1].split(__DELIMETER__)[0]

def get_flag_none_exists_filter_dir(dirname):
    return get_splited_first(dirname, __FILTER_DIR_FLAG_DELIMETER__)

def get_tagname_none_exists_filter_dir(dirname):
    return get_splited_first(dirname, __FILTER_DIR_TAGNAME_DELIMETER__)


def get_average(file):
    image = Image.open(file)
    pixels = image.load()
    r = g = b = 0
    for x in xrange(0, image.size[0]):
        for y in xrange(0, image.size[1]):
            colour = pixels[x, y]
            r += colour[0]
            g += colour[1]
            b += colour[2]
    area = image.size[0] * image.size[1]
    r /= area
    g /= area
    b /= area
    return {'hex': '%02x%02x%02x' % (r, g, b), 'rgb': (r, g, b), 'rgba': (r, g, b, 255),
            'yiq': colorsys.rgb_to_yiq(r, g, b), 'int': int('%02x%02x%02x' % (r, g, b), 16), 'file': file}


def get_hsv(dic):
    hexrgb = dic.get('hex').lstrip("#")
    r, g, b = (int(hexrgb[i:i + 2], 16) / 255.0 for i in xrange(0, 5, 2))
    return colorsys.rgb_to_hsv(r, g, b)


def get_hsl(dic):
    x = dic.get('rgb')
    to_float = lambda x: x / 255.0
    (r, g, b) = map(to_float, x)
    h, s, l = colorsys.rgb_to_hsv(r, g, b)
    h = h if 0 < h else 1 # 0 -> 1
    return h, s, l


def get_colours(files):
    colours = []
    for file in files:
        # uncrush_file(file)

        try:
            colours.append(get_average(file))
        except:
            print "(!) error get_average", file
            continue

    colours.sort(key=get_hsl, reverse=False)
    return colours

def truncate_file(file):
    if os.path.getsize(file)>0:
        open(file, 'w').close()
    reset_name_after_truncate_ifneeds(file)

def reset_name_after_truncate_ifneeds(file):
    name = os.path.basename(file)
    if name.find(__DELETE_FILE_HEAD__) == 0 and len(name) > len(__DELETE_FILE_HEAD__):
        os.rename(file, os.path.join(os.path.dirname(file), name[len(__DELETE_FILE_HEAD__):]))

def check_truncate(file, patt):
    name = os.path.basename(file)
    return name and name.find(__DELETE_FILE_HEAD__) == 0 and (patt.match(name[len(__DELETE_FILE_HEAD__):]) is not None) and os.path.getsize(file)>0

def check_ignore(file):
    return os.path.basename(file).startswith('.') or not os.path.isfile(file) or 1 > os.path.getsize(file)

def resolve_flags_before_json_write(target_json_arr_ref):
    for dir_obj in target_json_arr_ref[:]:
        matched =  __FILTER_DIR_REG__.match(dir_obj.keys()[0])

        # resolve __FLAG_REPRESENT__
        if matched is not None and bool(int(matched.group(3)) & __FLAG_REPRESENT__ != 0):
            target_json_arr_ref.remove(dir_obj)
            target_json_arr_ref.insert(0, dir_obj)

    return target_json_arr_ref

def check_force_color_from_file(file):
    return bool(get_int_flag_from_file(file) & __FLAG_FORCE_AVG_COLOR__ != 0)

def check_flag_force_color(flag):
    return bool(flag & __FLAG_FORCE_AVG_COLOR__ != 0)

def get_macher(file):
    return __FILTER_DIR_REG__ if os.path.isdir(file) else __FILTER_FILE_REG__

def get_int_flag_from_file(file):
    mat = get_macher(file).match(file)
    return int(mat.group(2 if os.path.isdir(file) else 3)) if mat else __FLAG_DEFAULT__

def get_str_hex_from_file(file):
    mat = get_macher(file).match(file)
    return mat.group(1 if os.path.isdir(file) else 2) if mat else None

def crush_file(refile):
  try:
      print '@ process fix pngcrush..... ->', refile
      crush_file = refile+'.crushed'
      call('xcrun -sdk iphoneos pngcrush -iphone-optimizations -q '+refile+' '+crush_file, shell=True)
      call('mv '+crush_file+' '+refile, shell=True)
      return True

  except BaseException, ex:
      print >> sys.stderr, "(!) Error pngcrush fixing process '%s': %s" % (refile, ex)
      return False

def uncrush_file(refile):
  try:
      print '@ process fix pngcrush..... ->', refile
      uncrush_file = refile+'.uncrushed'
      call('xcrun -sdk iphoneos pngcrush -revert-iphone-optimizations -q '+refile+' '+uncrush_file, shell=True)
      call('mv '+uncrush_file+' '+refile, shell=True)
      return True

  except BaseException, ex:
      print >> sys.stderr, "(!) Error uncrush process '%s': %s" % (refile, ex)
      return False

#
# start main job
#
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='LUT gen.')
    parser.add_argument('path', type=str, help='path')
    parser.add_argument('-f','--force', type=bool, help='force gen', required=False, nargs='*')
    args = parser.parse_args()
    __PATH__ = args.path
    __GEN_FORCE__ = args.force is not None

    start = time.time()

    # get avg color
    dirpath = (__PATH__ or 'test_bundle') + '/'
    resource_path = os.path.join(os.path.abspath(dirpath), os.pardir)

    # open metafile
    meta_json = []
    warning_files = []

    indexnum = 0
    for root, dirs, files in os.walk(dirpath):

        cur_dir = os.path.basename(root)
        if not cur_dir:
            continue

        target_files = []

        # proc truncate or check valid
        if check_truncate(root, __FILTER_DIR_REG__):
            [truncate_file(os.path.join(root, file_name)) for file_name in files]
            reset_name_after_truncate_ifneeds(root)
            print '#deleted dir -> ' + root
            continue
        for file_name in files:
            file = os.path.join(root, file_name)
            if check_ignore(file):
                continue
            if check_truncate(file, __FILTER_FILE_REG__):
                truncate_file(file)
                continue
                print '#deleted file -> ' + file_name
            target_files.append(file)

        #
        # start gen
        #
        print '\n[gen now. plz waiting...] -> ' + root

        avgs = get_colours(target_files)
        if not avgs:
            print 'empty dir. \n'
            continue

        files_indexed = []

        for index, rs in enumerate(avgs):
            try:
                file = rs.get('file')
                filename = os.path.basename(file)
                ext = os.path.splitext(filename)[1][1:].strip().lower()
                path = os.path.dirname(file)

                newfilename = filename
                newfileindex = '{:0=5}'.format(indexnum)

                hexstr = rs.get('hex')

                # new created
                if __FILTER_FILE_REG__.match(filename) is None or __GEN_FORCE__:
                    # 0 : index - int (5) - 00001
                    fsheme = [newfileindex]
                    # 1 : hex color - int (16) - adaab6
                    fsheme.append(hexstr)
                    # 2 : uuid - string (32) - a985e9c60ce11e3a261129add353c74
                    fsheme.append(uuid.uuid4().hex)
                    # 3 : flag - int (left shift must) - 1(1<<0)~x
                    ## 1<<0 : none-commercial
                    ## 1<<1 : commercial
                    ## x: anything else...
                    fsheme.append(str(__FLAG_DEFAULT__))
                    # 4 : provider - string (1~x) - starpretprism
                    fsheme.append(__PROVIDER__)
                    
                    newfilename = __DELIMETER__.join(fsheme) + '.' + ext

                #else:
                    # newfilename = __DELIMETER__.join([newfileindex] + filename.split(__DELIMETER__)[1:])
                    # force locking

                refile = os.path.join(path, newfilename)
                os.rename(file, refile)

                files_indexed.append(refile)
                
                if ext != 'png':
                  warning_files.append(refile)
                  
                print '#indexed : ', file, '\n->', refile

                #crush_file(refile)

            except OSError, ex:
                print >> sys.stderr, "Error renaming '%s': %s" % (file, ex.strerror)
                continue

            indexnum += 1

        # gen preview
        preview_file = os.path.join(resource_path, cur_dir + '.preview.png')
        rgbs_arr = [obj.get('rgb') for obj in avgs]

        previews_avg_hex = gen_preview(rgbs_arr, preview_file, 400, 30)

        dsheme = []
        newdirname = ''

        match_dir = __FILTER_DIR_REG__.match(cur_dir)
        if match_dir is None:
            # 0 : hex
            dsheme.append(previews_avg_hex)
            # 1 : uuid
            dsheme.append(uuid.uuid4().hex)
            # 2 : flag
            flagneeds = get_flag_none_exists_filter_dir(cur_dir)
            dsheme.append(flagneeds or str(__FLAG_DEFAULT__))
            # 3 : tagname
            _tagname = get_tagname_none_exists_filter_dir(cur_dir)
            if not _tagname is None:
                dsheme.append(_tagname)

            newdirname = __DELIMETER__.join(dsheme)
        else:
            # 0 : hex
            # dsheme.append(match_dir.group(1) if check_flag_force_color(int(match_dir.group(3))) else previews_avg_hex)
            # force locking
            dsheme.append(match_dir.group(1))
            # 1 : exist uuid
            dsheme.append(match_dir.group(2))
            # 2 : exist flag
            dsheme.append(match_dir.group(3))
            # 3 : tagname
            _tagname = match_dir.group(4)
            if not _tagname is None:
                dsheme.append(match_dir.group(5))

            newdirname = __DELIMETER__.join(dsheme)

        os.rename(root, os.path.join(os.path.join(root, os.pardir), newdirname))

        meta_json.append({
            newdirname: map(lambda f: os.path.basename(f), files_indexed)
        })

        new_preview_file = os.path.join(resource_path, newdirname + '.preview.png')
        print 'gen preview.... ' + os.path.basename(new_preview_file)

        os.rename(preview_file, new_preview_file)

        print str(len(target_files))+ ' ok. \n'

    print resource_path
    metaf = open(os.path.join(resource_path, __META_FILE_HEAD__ + '.' + __META_FILE_EXT__), 'w')
    metaf.write(json.dumps(resolve_flags_before_json_write(meta_json), indent=4))
    metaf.close()

if warning_files:
  print "[!] warning files :", [f for f in warning_files]
  
print 'all done.', (time.time() - start)
