#!/usr/bin/env python
#-*- coding: utf-8 -*-

# Python 2.7

# This script calls the markdown binary to convert markdown files to html, and then
# corrects the links to md files into links to html files.

# Etienne Gaudrain <etienne.gaudrain@cnrs.fr> = 2018-02-19
# CRNL, CNRS, Lyon, FR | UMCG KNO, RUG, Groningen, NL

import subprocess
import fnmatch
import os
import re

path = os.path.dirname(__file__)
path = os.path.join(path, '../../../')
path = os.path.abspath(path)

lst = list()
for root, dirnames, filenames in os.walk(path):
    for filename in fnmatch.filter(filenames, '*.md'):
        lst.append(os.path.join(root, filename))

print "%d Markdown file(s) found...\n" % len(lst)

re_html_link = re.compile(r"(<a.*?href=[\"'].*?)\.md([\"'].*?>)")

for f in lst:
    html, ext = os.path.splitext(f)
    html = html+'.html'
    cmd = ['markdown', f, html]
    #print " ".join(cmd)
    subprocess.call(cmd)

    txt = open(html, 'rb').read()
    txt = re_html_link.sub(r"\1.html\2", txt)

    open(html, 'wb').write(txt)


