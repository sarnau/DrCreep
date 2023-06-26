#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
import struct
import binascii

PIXEL_SET = '█'#'■'
PIXEL_CLEAR = ' '

data = bytearray(0x800 - 2) + bytearray(open('./Objects/object.prg','rb').read())
IMAGE_BASE_ADDR = 0x603b
DIGITS_BASE_ADDR = 0x2A1B
item_count = 155

C64_COLORS = [
'BLACK','WHITE','RED','CYAN','PURPLE','GREEN','BLUE','YELLOW',
'ORANGE','BROWN','LIGHT_RED','DARK_GREY','GREY','LIGHT_GREEN','LIGHT_BLUE','LIGHT_GREY'
]

class bcolors:
	BLACK = '\033[38;5;0m'
	WHITE = '\033[38;5;15m'
	RED = '\033[38;5;1m'
	CYAN = '\033[38;5;13m'
	PURPLE = '\033[38;5;5m'
	GREEN = '\033[38;5;2m'
	BLUE = '\033[38;5;4m'
	YELLOW = '\033[38;5;11m'

	ORANGE = '\033[38;5;220m'
	BROWN = '\033[38;5;88m'
	LIGHT_RED = '\033[38;5;9m'
	DARK_GREY = '\033[38;5;238m'
	GREY = '\033[38;5;244m'
	LIGHT_GREEN = '\033[38;5;10m'
	LIGHT_BLUE = '\033[38;5;12m'
	LIGHT_GREY = '\033[38;5;252m'
	
	DEFAULT = '\033[1;39m'

c64_colors = (
			bcolors.BLACK,bcolors.WHITE,bcolors.RED,bcolors.CYAN,bcolors.PURPLE,bcolors.GREEN,bcolors.BLUE,bcolors.YELLOW,
			bcolors.ORANGE,bcolors.BROWN,bcolors.LIGHT_RED,bcolors.DARK_GREY,bcolors.GREY,bcolors.LIGHT_GREEN,bcolors.LIGHT_BLUE,bcolors.LIGHT_GREY,
			)

# list of all sprites (they do not have a color table)
sprites = (0,1,2,3,4,5, # player left/right
		   18,19,20,21, # roommap arrows
		   30,31,32,33,34,35, # player exiting
		   38, # player on pole
		   46,47,48,49, # player on ladder
		   53,61, # forcefield animation
		   65, # forcefield sprite off
		   57,58,59,60, # lighting
		   69,70,71,72,73,74, # mummy slides out
		   75,76,77,78,79,80, # mummy left/right
		   108, # raygun shot
		   132,133,134,135,136,137, # frankenstein left/right
		   138,139,140,141,142, # frankenstein slide/ladder
		   143, # frankenstein sleep
		   151,152,153,154, # player waves goodbye
		   )

# Player sprites have these colors.
spriteColors = [bcolors.BLACK,bcolors.RED,bcolors.YELLOW,bcolors.GREEN]

def setRoomColor(color):
	data[0x63E6 + 1] = color # roommap_floor_square

	dcolor = color | (color << 4)
	data[0x6481] = dcolor # walkway_left
	data[0x648E] = dcolor # walkway_center
	data[0x649B] = dcolor # walkway_right
	data[0x65CC] = dcolor # ladder_b
	data[0x65CC + 2] = dcolor # ladder_b
	for i in range(0,3):
		data[0x6EAE + i] = dcolor # trapdoor_1
		data[0x6EC6 + i] = dcolor # trapdoor_2
		data[0x6EDB + i] = dcolor # trapdoor_3
		data[0x6EED + i] = dcolor # trapdoor_4
		data[0x6EFC + i] = dcolor # trapdoor_5
		data[0x6F08 + i] = dcolor # trapdoor_6
	for i in range(0,8):
		data[0x6FB2 + i] = dcolor # conveyor_anim_1
		data[0x6FF5 + i] = dcolor # conveyor_anim_2
		data[0x7038 + i] = dcolor # conveyor_anim_3
		data[0x707B + i] = dcolor # conveyor_anim_4
	data[0x6584] = color | (1 << 4) # sliding_pole_onePixel
	data[0x659B] = (data[0x649B] & 0xf0) | 0x01 # ladder_a = walkway_right
	data[0x65CC + 1] = data[0x659B] # ladder_b = walkway_right

setRoomColor(6)

def setDoorColor(color):
	for i in range(0,6):
		data[0x6390 + i] = (color << 4) | color # diagonal exit
	for i in range(0,9):
		data[0x6C53 + i] = (color << 4) | color # lock
		data[0x63D2 + i] = (color << 4) | color # button
	data[0x63D2 + 4] = 0x10 | color # button
setDoorColor(6)

# ankh color
color = 6
for i in range(0,6):
	data[0x68F0 + i] = (color << 4) | color

# raygun button color
color = 6
data[0x6DBF + 0] = color << 4
data[0x6DBF + 1] = color << 4

# teleport_booth_colormask
color = 6
data[0x6E70 + 0] = (color << 4) | 10
data[0x6E70 + 1] = (color << 4) | 10
data[0x6E70 + 2] = (color << 4) | 10
data[0x6E70 + 3] = (color << 4) | 15
data[0x6E70 + 4] = (color << 4) | 15
data[0x6E70 + 5] = (color << 4) | 15
# teleport_destination
data[0x6E95 + 0] = (color << 4) | 0
data[0x6E95 + 1] = (color << 4) | 0
data[0x6E95 + 2] = (color << 4) | 0
data[0x6E95 + 3] = (color << 4) | 0

# trapdoor controller
data[0x6F2E + 0] = 0xC0#0x20
data[0x6F2E + 2] = 0x55#0xCC

# conveyor_controller
data[0x70A6 + 0] = 0x50#0x20 0xC0
data[0x70A6 + 2] = 0xC0#0xCC 0x20

# forcefield_progress
for y in range(0,8):
	data[0x6889 + y] = 0x55

# character image
for y in range(0,data[0x73E8]):
	for x in range(0,data[0x73E7]):
		data[0x73ea + y * 2 + x] = 0x55
color = 2
for i in range(0,data[0x73E8]//8 * data[0x73E7]):
	data[0x73ea + data[0x73E8] * data[0x73E7] + i] = (color << 4) | color

def findNextImage(index):
	while True:
		if index == item_count - 1:
			return 0
		nextIndex = struct.unpack('<H', data[IMAGE_BASE_ADDR+index * 2+2:IMAGE_BASE_ADDR+(index + 1) * 2+2])[0]
		if nextIndex != 0:
			break
		index = index + 1
#	print('@@@ %3d %04x' % (index,nextIndex))
	return nextIndex

for index in range(0,item_count):
	imgAddr = struct.unpack('<H', data[IMAGE_BASE_ADDR+index * 2:IMAGE_BASE_ADDR+(index + 1) * 2])[0]
	imgAddrNext = findNextImage(index)
	if imgAddr == 0:
		continue
	w,h,u = struct.unpack('BBB', data[imgAddr:imgAddr + 3])
	if imgAddrNext != 0:
		colorInfoSize = imgAddrNext-imgAddr-3 - w*h
	else:
		colorInfoSize = 0
	if index in sprites: # sprites never have additional colors
		colorInfoSize = 0
	print('%04x #%3d => %04x' % (IMAGE_BASE_ADDR + index * 2, index, imgAddr))
	print("  %dx%d [%#04x]" % (w,h,u))
	if u & 0x10: # no multicolor
		for yp in range(0,h):
			s = ''
			for xp in range(0,w):
				bstr = '{:08b}'.format(data[imgAddr + 3 + yp * w + xp])
				for i in range(len(bstr)):
					if bstr[i] == '0':
						s+= c64_colors[0]+PIXEL_SET
						if u & 0x80: # double width (unused in Dr. Creep)
							s+= PIXEL_SET
					else:
						s+= c64_colors[1]+PIXEL_SET
						if u & 0x80: # double width (unused in Dr. Creep)
							s+= PIXEL_SET
			print(s + bcolors.DEFAULT)
			if u & 0x40: # double height
				print(s + bcolors.DEFAULT)
	else:
		for yp in range(0,h):
			s = ''
			colors = [0] * 4
			for xp in range(0,w):
				if colorInfoSize != 0:
					colors[0] = c64_colors[0]
					colValue = data[imgAddr + 3 + w * h + (yp//8) * w + xp]
					colors[1] = c64_colors[(colValue >> 4) & 0xf]
					colors[2] = c64_colors[colValue & 0xf]
					colValue = data[imgAddr + 3 + w * h + (h + 7)//8 * w + yp//8 * w + xp]
					colors[3] = c64_colors[colValue & 0xf]
				else:
					colors = spriteColors
					colors[2] = c64_colors[u & 0xf]
				bstr = '{:08b}'.format(data[imgAddr + 3 + yp * w + xp])
				for i in range(0,len(bstr),2):
					val = int(bstr[i:i+2],2)
					s+= colors[val]+PIXEL_SET
			print(s + bcolors.DEFAULT)
	if False:
		for yp in range(0,colorInfoSize//w):
			s = ''
			for xp in range(0,w):
				colValue = data[imgAddr + 3 + w * h + yp * w + xp]
				s += '{:02x}'.format(colValue)
			s2 = ''
			se = ','
			for c in s:
				s2 += C64_COLORS[int(c,16)] + se
				if se != ',':
					se = ','
				else:
					se = '  '
			print(s2)
	print('=' * 40)
	
if False:
	for index in range(0,10):
		print('Digit %d (%04x)' % (index, DIGITS_BASE_ADDR + 8 * index))
		for row in range(0,8):
			print(('{:08b}'.format(data[DIGITS_BASE_ADDR + 8 * index + row]).replace('1',PIXEL_SET).replace('0',PIXEL_CLEAR)))
