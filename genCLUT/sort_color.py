import colorsys

def get_hsv(dic):
	hexrgb = dic.get('hex').lstrip("#")
	r, g, b = (int(hexrgb[i:i+2], 16) / 255.0 for i in xrange(0,5,2))
	return colorsys.rgb_to_hsv(r, g, b)

color_list =  [{'hex':'000050', 'rgb': (255, 222, 222), 'file': 'a'}, {'hex':'005000', 'rgb': (255, 222, 222), 'file': 'a'}, {'hex':'500000', 'rgb': (255, 222, 222), 'file': 'a'}]
# color_list =  [('000050', (255, 222, 222), 'a'), ('005000', (255, 222, 222), 'a'),('500000', (255, 222, 222), 'a')]

#color_list = ["000050", "005000", "500000"] 
color_list.sort(key=get_hsv)
print color_list