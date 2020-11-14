# Copyright 2017 Luke Pezet.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

__author__ = "Luke Pezet <lpezet@gmail.com>"
__license__ = "MIT"
__version__ = "0.0.1"

import xlrd
import csv, argparse, datetime, zipfile, string, sys, os, re, signal

# https://github.com/dilshod/xlsx2csv/blob/master/xlsx2csv.py
# Options from xlsx2csv we may want to implement:
# xlsx2csv.py [-h] [-v] [-a] [-c OUTPUTENCODING] [-s SHEETID]
#                   [-n SHEETNAME] [-d DELIMITER] [-l LINETERMINATOR]
#                   [-f DATEFORMAT] [-i] [-e] [-p SHEETDELIMITER]
#                   [--hyperlinks]
#                   [-I INCLUDE_SHEET_PATTERN [INCLUDE_SHEET_PATTERN ...]]
#                   [-E EXCLUDE_SHEET_PATTERN [EXCLUDE_SHEET_PATTERN ...]] [-m]
#                   xlsxfile [outfile]
# positional arguments:
#  xlsxfile              xlsx file path
#  outfile               output csv file path

# optional arguments:
#  -h, --help            show this help message and exit
#  -v, --version         show program's version number and exit
#  -a, --all             export all sheets
#  -c OUTPUTENCODING, --outputencoding OUTPUTENCODING
#                        encoding of output csv ** Python 3 only ** (default: utf-8)
#  -f DATEFORMAT, --dateformat DATEFORMAT
#                        override date/time format (ex. %Y/%m/%d)
#  -i, --ignoreempty     skip empty lines
#  -e, --escape          Escape \r\n\t characters
#  -p SHEETDELIMITER, --sheetdelimiter SHEETDELIMITER
#                        sheet delimiter used to separate sheets, pass '' if
#                        you do not need delimiter, or 'x07' or '\\f' for form
#                        feed (default: '--------')
#  --hyperlinks, --hyperlinks
#                        include hyperlinks
#  -I INCLUDE_SHEET_PATTERN [INCLUDE_SHEET_PATTERN ...], --include_sheet_pattern INCLUDE_SHEET_PATTERN [INCLUDE_SHEET_PATTERN ...]
#                        only include sheets named matching given pattern, only
#                        effects when -a option is enabled.
#  -E EXCLUDE_SHEET_PATTERN [EXCLUDE_SHEET_PATTERN ...], --exclude_sheet_pattern EXCLUDE_SHEET_PATTERN [EXCLUDE_SHEET_PATTERN ...]
#                        exclude sheets named matching given pattern, only
#                        effects when -a option is enabled.
#  -m, --merge-cells     merge cells

def xls2csv( pOptions ):
	wb = xlrd.open_workbook( pOptions.infile )
	#print(wb.sheet_names())
	print(pOptions.sheetindex)
	
	sh = None
	#sh = wb.sheet_by_index(0)
	if pOptions.sheetname:
		sh = wb.sheet_by_name( pOptions.sheetname )
	else:
		sh = wb.sheet_by_index( pOptions.sheetindex )
	csv_file = pOptions.outfile
	closefile = False
	if isinstance(pOptions.outfile, str):
		if sys.version_info[0] == 2:
			csv_file = open(pOptions.outfile, 'wb+')
		elif sys.version_info[0] == 3:
			csv_file = open(pOptions.outfile, 'w+', encoding=pOptions.outputencoding, newline="")
		else:
			sys.stderr.write("error: version of your python is not supported: " + str(sys.version_info) + "\n")
			sys.exit(1)
		closefile = True
	#csv_file = open(pOptions.outfile,'w')
	try:
		wr = csv.writer(csv_file, quoting=pOptions.quoting, delimiter=pOptions.delimiter, lineterminator=pOptions.lineterminator)      
		#wr = csv.writer(csv_file, quoting=csv.QUOTE_ALL)
		for rownum in range(sh.nrows):
			wr.writerow(sh.row_values(rownum))
	finally:
		if closefile:
			csv_file.close()

# def convert_recursive(path, sheetid, outfile, kwargs):
#     for name in os.listdir(path):
#         fullpath = os.path.join(path, name)
#         if os.path.isdir(fullpath):
#             convert_recursive(fullpath, sheetid, outfile, kwargs)
#         else:
#             outfilepath = outfile
#             if len(outfilepath) == 0 and fullpath.lower().endswith(".xlsx"):
#                 outfilepath = fullpath[:-4] + 'csv'
# 
#             print("Converting %s to %s" %(fullpath, outfilepath))
#             Xls2csv(fullpath, **kwargs).convert(outfilepath, sheetid)
#             
if __name__ == "__main__":
	try:
	    signal.signal(signal.SIGPIPE, signal.SIG_DFL)
	    signal.signal(signal.SIGINT, signal.SIG_DFL)
	except AttributeError:
	    pass
    
	parser = argparse.ArgumentParser(description='Convert XLS (not XLSX) to CSV file(s)')
	parser.add_argument('-v', '--version', action='version', version=__version__)
	parser.add_argument('infile', metavar='xlsxfile', help="excel .xls file path")
	parser.add_argument('outfile', metavar='outfile', nargs='?', help="output csv file path")
	parser.add_argument("-q", "--quoting", dest="quoting", default="minimal", help="quoting in csv - possible values: 'none' 'minimal' 'nonnumeric' or 'all' (default: minimal)")
	parser.add_argument("-s", "--sheet", dest="sheetindex", default=0, type=int, help="sheet index to convert")
	parser.add_argument("-n", "--sheetname", dest="sheetname", default=None, help="sheet name to convert")
	parser.add_argument("-c", "--outputencoding", dest="outputencoding", default="utf-8", action="store", help="encoding of output csv ** Python 3 only ** (default: utf-8)")
	parser.add_argument("-d", "--delimiter", dest="delimiter", default=",", help="columns delimiter in csv - example: 'tab' or 'x09' for a tab (default: comma ',')")
	parser.add_argument("-l", "--lineterminator", dest="lineterminator", default="\n", help="line terminator in csv - possible values: '\\n' '\\r\\n' or '\\r' (default: \\n)")

	options = parser.parse_args()
	if len(options.delimiter) == 1:
		pass
	elif options.delimiter == 'tab' or options.delimiter == '\\t':
		options.delimiter = '\t'
	elif options.delimiter == 'comma':
		options.delimiter = ','
	elif options.delimiter[0] == 'x':
		options.delimiter = chr(int(options.delimiter[1:]))
	else:
		sys.stderr.write("error: invalid delimiter\n")
		sys.exit(1)

	if options.quoting == 'none':
		options.quoting = csv.QUOTE_NONE
	elif options.quoting == 'minimal':
		options.quoting = csv.QUOTE_MINIMAL
	elif options.quoting == 'nonnumeric':
		options.quoting = csv.QUOTE_NONNUMERIC
	elif options.quoting == 'all':
		options.quoting = csv.QUOTE_ALL
	else:
		sys.stderr.write("error: invalid quoting\n")
		sys.exit(1)

	if options.lineterminator == '\n':
		pass
	elif options.lineterminator == '\\n':
		options.lineterminator = '\n'
	elif options.lineterminator == '\\r':
		options.lineterminator = '\r'
	elif options.lineterminator == '\\r\\n':
		options.lineterminator = '\r\n'
	else:
		sys.stderr.write("error: invalid line terminator\n")
		sys.exit(1)
	
	#options.func( args )
	options.outfile = options.outfile or sys.stdout
	#if os.path.isdir(options.infile):
	#	convert_recursive(options.infile, sheetid, outfile, kwargs)
	#else:
	#xlsx2csv = Xlsx2csv(options.infile, **kwargs)
	#if options.sheetname:
	#	sheetid = xlsx2csv.getSheetIdByName(options.sheetname)
	#	if not sheetid:
	#		raise Exception("Sheet '%s' not found" % options.sheetname)
	xls2csv( options )