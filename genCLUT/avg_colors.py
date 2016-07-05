import Image, colorsys
import os

def get_average(filename):
    image = Image.open(filename)
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
    return {'hex':'%02x%02x%02x'%(r, g, b), 'rgb': (r, g, b), 'rgba': (r, g, b, 255), 'yiq' : colorsys.rgb_to_yiq(r, g, b), 'int':int('%02x%02x%02x' % (r, g, b), 16), 'file': filename}

def get_hsv(dic):
    hexrgb = dic.get('hex').lstrip("#")
    r, g, b = (int(hexrgb[i:i+2], 16) / 255.0 for i in xrange(0,5,2))
    return colorsys.rgb_to_hsv(r, g, b)

def get_hsl(dic):
    x = dic.get('rgb')
    to_float = lambda x : x / 255.0
    (r, g, b) = map(to_float, x)
    h, s, l = colorsys.rgb_to_hsv(r,g,b)
    h = h if 0 < h else 1 # 0 -> 1
    return h, s, l    

def get_colours(images):
    colours = []
    for image in images:
        try:
            colours.append(get_average(image))
        except:
            continue
    colours.sort(key=get_hsl,reverse=False)
    return colours

if __name__ == "__main__":
    
    imgs = get_images('test_bundle/')
    
    ####
    
    import time
    start = time.time()
    #
    avgs = get_colours(imgs)
    #
    es = (time.time() - start)
    
    for rs in avgs:
        print rs
    
    print 'proctime : %d'%es