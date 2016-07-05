from PIL import Image, ImageDraw
import colorsys
import hilbertlib
from operator import itemgetter

def make_rainbow_rgb(colors, width, height):
    img = Image.new("RGBA", (width, height))
    canvas = ImageDraw.Draw(img)

    def hsl(x):
        to_float = lambda x : x / 255.0
        (r, g, b) = map(to_float, x)
        h, s, l = colorsys.rgb_to_hsv(r,g,b)
        h = h if 0 < h else 1 # 0 -> 1
        return h, s, l

    rainbow = sorted(colors, key=hsl)

    dx = width / float(len(colors)) 
    x = 0
    y = height / 2.0
    for rgb in rainbow:
        canvas.line((x, y, x + dx, y), width=height, fill=rgb)
        x += dx
    img.save("./spectrum_preview.png")


def make_rainbow_hilbert(colors, width, height):
    img = Image.new("RGB", (width, height))
    canvas = ImageDraw.Draw(img)

    #colors.sort(key=lambda rgb: colorsys.rgb_to_hsv(*rgb))
    colors.sort(key=hilbertlib.Hilbert_to_int)


    # rainbow = sorted(rainbow, key=hilbertlib.Hilbert_to_int)
    dx = width / float(len(colors)) 
    x = 0
    y = height / 2.0
    for rgb in colors:
        canvas.line((x, y, x + dx, y), width=height, fill=rgb)
        x += dx
    img.save("./spectrum_preview.png")

import avg_colors, colorsys
import time, os, sys

if len(sys.argv)==1 :
    print 'usage : python gen.py [target dir]'
    sys.exit(0)

def get_images(folder):
    images = []
    for root, dirs, files in os.walk(sys.argv[1]):
        for file_name in files:
            images.append(root + '/' + file_name)
    return images

avg = avg_colors
start = time.time()

# get avg color
dirpath = sys.argv[1]
imgs = get_images(dirpath+'/' or 'test_bundle/')

make_rainbow_rgb([obj.get('rgb') for obj in avg.get_colours(imgs)], 400, 50)
#make_rainbow_hilbert([obj.get('rgb') for obj in avg.get_colours(imgs)], 400, 50)
#print len([obj.get('int') for obj in avg.get_colours(imgs)])


