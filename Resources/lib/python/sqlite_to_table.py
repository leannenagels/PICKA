#! /usr/bin/env python
#-*- coding: utf-8 -*-
# Python 2.7

# sqlShort is in the same directory
from sqlShort import sqlShort
import os, re, sys

# Export to CSV using builtin module
def export_to_csv(dat, dst):
    import csv

    for t in dat.keys():
        fname, ext = os.path.splitext(dst)
        fname = "%s_%s%s" % (fname, t, ext)
        csvW = csv.writer(open(fname, 'wb'))
        csvW.writerow([f.encode('utf-8') for f in dat[t]['fields']])
        d = list()
        UNICODE = type(u"")
        for r in dat[t]['data']:
            row = list()
            for c in r:
                if type(c)==UNICODE:
                    row.append(c.encode('utf-8'))
                else:
                    row.append(c)
            d.append(row)
        csvW.writerows(d)

# Export to XLS. Will need to have xlwt.
def export_to_xls(dat, dst):
    try:
        import xlwt
    except Exception, e:
        print "Module 'xlwt' cannot be located... Install it first (e.g. pip install xlwt)."
        exit(4)

    wb = xlwt.Workbook(encoding='utf-8')
    for t in dat.keys():
        ws = wb.add_sheet(t)
        i = 0
        dat[t]['width'] = list()
        for j,f in enumerate(dat[t]['fields']):
            ws.write(i,j,f)
            dat[t]['width'].append( len(unicode(f)) )
        i += 1
        for r in dat[t]['data']:
            for j,c in enumerate(r):
                ws.write(i,j,c)
                dat[t]['width'][j] = max(dat[t]['width'][j], len(unicode(c)))
            i += 1
        # We adjust the column width so the Excel file is easier to read
        for j,w in enumerate(dat[t]['width']):
            ws.col(j).width = min(int((w+1)*256), 12000)
    wb.save(dst)

# Some regular expression to parse the CREATE TABLE statements and retrieve the field list
reSqlFieldList = re.compile(r"CREATE\s+TABLE\s+.*\(([^)]+)\)", re.S or re.I)
reFieldList    = re.compile(r"\s*[a-zA-Z_][a-zA-Z0-9_]*\s+[^,]+", re.S)

def read_db(db):
    tables, = db.query("SELECT name FROM sqlite_master WHERE type = 'table'")
    tables = [t for t in tables if not t.startswith('sqlite_')]

    dat = dict()

    for t in tables:
        # We get the table's structure to know the types
        sql, = db.query("SELECT sql FROM sqlite_master WHERE type = 'table' AND name = '%s'" % t)
        mSqlFieldList = reSqlFieldList.search( sql[0] )
        if mSqlFieldList is None:
            print "Couldn't parse the SQL from the table...:"
            print sql[0]
            exit(5)
        mSqlFieldList = "".join( mSqlFieldList.groups() )
        fieldDefs = [x.strip() for x in reFieldList.findall(mSqlFieldList)]
        fields = list()
        for f in fieldDefs:
            fields.append( f.split()[0:2] )
        dat[t] = dict()
        dat[t]['fields'] = [f[0] for f in fields]
        dat[t]['types'] = [f[1] for f in fields]

        # We get the data from the table t
        d = db.query("SELECT %s FROM `%s`" % (", ".join(["`"+f[0]+"`" for f in fields]), t))
        dat[t]['data'] = zip(*d)

    return dat

def main():
    if len(sys.argv)<3:
        print "Usage: %s [sqlite database] [destination file]" % os.path.basename(__file__)
        print "The destination file can be .xls or .csv."
        exit(1)
    src = sys.argv[1]
    dst = sys.argv[2]

    if not os.path.exists(src):
        print "File '%s' does not exist. Call export_results.m for your experiment first?" % src
        exit(2)

    db = sqlShort(host=src, type='sqlite')

    dat = read_db(db)

    del db

    _, ext = os.path.splitext(dst)

    if ext=='.xls':
        export_to_xls(dat, dst)
    elif ext=='.csv':
        export_to_csv(dat, dst)
    else:
        print "Format '%s' is not implemented." % ext
        exit(3)

if __name__=='__main__':
    main()