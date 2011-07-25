#!/usr/bin/python

from struct import *
import os

def bin (num): 
	return pack('>i', num)

def build ():
	input = open('levels/all.list')

	levels = input.read().split("\n")
	
	levels = [l for l in levels if len(l) > 0 and not l.startswith('#')]

	input.close()

	output = open('assets/all.lvls', 'wb')

	output.write(bin(len(levels)))

	for level in levels:
		filename = "levels/" + level + ".lvl"
		
		print filename
		
		filesize = os.path.getsize(filename)
	
		output.write(bin(filesize));
	
		file = open(filename, 'rb')
	
		output.write(file.read())
	
		file.close()

	output.close()


build()

