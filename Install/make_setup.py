#!/usr/bin/env python
#-*- coding: utf-8 -*-

import sys
import os
import base64

if len(sys.argv)<3:
	print "You need to call the function with two extra arguments: a py filename and a m filename."
	exit(1)

f1 = sys.argv[1]
f2 = sys.argv[2]

if f1.endswith('.m') and f2.endswith('.py'):
	py_filename = f2
	m_filename  = f1
elif f2.endswith('.m') and f1.endswith('.py'):
	py_filename = f1
	m_filename  = f2
else:
	print "You need to provide a py file and m file..."
	exit(1)

py_code = open(py_filename, 'rb').read()
m_file  = open(m_filename, 'rb')

new_m_code = ''
for l in m_file:
	new_m_code += l
	if l.startswith('function x = payload()'):
		new_m_code += "\n"
		new_m_code += "x = '" + base64.b64encode(py_code) + "';\n"
		break
m_file.close()

open(m_filename, 'wb').write(new_m_code)

