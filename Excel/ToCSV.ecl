IMPORT LPezet.Linux.Curl;
IMPORT LPezet.Linux.BinUtils;

// TODO: Change .py script(s) to use Pandas instead.
//
// Installation:
// sudo apt-get install python3 python3-pip
// sudo pip3 install xlrd
// 
EXPORT ToCSV := MODULE
	
	EXPORT IOptions := INTERFACE
		EXPORT STRING python_bin;				// Python 3 bin
		EXPORT STRING quoting; 					// possible values: none, minimal, nonnumeric, all
		EXPORT STRING linedelimiter;		// usually: \r, \n, \r\n
		EXPORT STRING delimiter;
		EXPORT STRING output_encoding;	// utf-8
	END;
	
	EXPORT DefaultOptions := MODULE(IOptions)
		EXPORT STRING python_bin := '/usr/bin/python3';
		EXPORT STRING quoting := 'nonnumeric';
		EXPORT STRING linedelimiter := '\\n';
		EXPORT STRING delimiter := ',';
		EXPORT STRING output_encoding := 'utf-8';
	END;

	SHARED mBaseScriptsPath := '/tmp/hpcc/lpezet/excel';
	SHARED mXLS2CSVScriptURL := 'https://raw.githubusercontent.com/lpezet/ecl-bundle-lpezet/master/Excel/xls2csv.py';
	SHARED mXLS2CSVScriptLocal := mBaseScriptsPath + '/xls2csv.py';
	
	EXPORT setup_scripts() := SEQUENTIAL(
		OUTPUT( BinUtils.mkdir( mBaseScriptsPath, true ), NAMED('SetupMkdir') ),
		OUTPUT( Curl.download( mXLS2CSVScriptURL, mXLS2CSVScriptLocal ), NAMED('SetupDownloadXLSScript') )
	);
	
	EXPORT xls2csv( STRING pXLSFilePath, STRING pCSVFilePath, STRING pSheetName = '', UNSIGNED pSheetIndex = -1, IOptions pOptions = DefaultOptions ) := FUNCTION
		oParams_0 := IF( pSheetName != '', '-n "' + pSheetName + '"', '-s ' + pSheetIndex );
		oParams_1 := oParams_0 + IF( pOptions.quoting = '', '', ' -q ' + pOptions.quoting );
		oParams_2 := oParams_1 + IF( pOptions.linedelimiter = '', '', ' -l ' + pOptions.linedelimiter );
		oParams_3 := oParams_2 + IF( pOptions.delimiter = '', '', ' -d ' + pOptions.delimiter );
		oParams_4 := oParams_3 + IF( pOptions.output_encoding = '', '', ' -c ' + pOptions.output_encoding );

		oParams := oParams_4;
		RETURN SEQUENTIAL(
			setup_scripts(),
			OUTPUT( PIPE( pOptions.python_bin + ' ' + mXLS2CSVScriptLocal + ' ' + oParams + ' "' + pXLSFilePath + '" "' + pCSVFilePath + '"', BinUtils.line_layout, CSV(SEPARATOR(''), QUOTE(''))), NAMED('xls2csv') )
		);
	END;
		

END;