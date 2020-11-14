IMPORT LPezet.Linux.Curl;
IMPORT LPezet.Linux.BinUtils;

// 
// Installation:
// sudo apt-get install python3 python3-pip
// sudo pip3 install pandas
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

	SHARED mBaseScriptsPath := '/tmp/hpcc/lpezet/stata';
	SHARED mDAT2CSVScriptURL := 'https://raw.githubusercontent.com/lpezet/ecl-bundles/master/LPezet/Stata/dta2csv.py';
	SHARED mDAT2CSVScriptLocal := mBaseScriptsPath + '/dta2csv.py';
	
	EXPORT setup_scripts() := SEQUENTIAL(
		OUTPUT( BinUtils.mkdir( mBaseScriptsPath, true ) ), // , NAMED('SetupMkdir' + pNameId ) ),
		OUTPUT( Curl.download( mDAT2CSVScriptURL, mDAT2CSVScriptLocal  ) ) //, NAMED('SetupDownloadDATScript' + pNameId) )
	);
	
	EXPORT dat2csv( STRING pInputFilePath, STRING pOutputFilePath, STRING pSheetName = '', UNSIGNED pSheetIndex = -1, IOptions pOptions = DefaultOptions ) := FUNCTION
		oParams_0 := IF( pOptions.quoting = '', '', ' -q ' + pOptions.quoting );
		oParams_1 := oParams_0 + IF( pOptions.linedelimiter = '', '', ' -l ' + pOptions.linedelimiter );
		oParams_2 := oParams_1 + IF( pOptions.delimiter = '', '', ' -d ' + pOptions.delimiter );
		oParams_3 := oParams_2 + IF( pOptions.output_encoding = '', '', ' -c ' + pOptions.output_encoding );
		oParams := oParams_3;
		RETURN SEQUENTIAL(
			OUTPUT( PIPE( pOptions.python_bin + ' ' + mDAT2CSVScriptLocal + ' ' + oParams + ' "' + pInputFilePath + '" "' + pOutputFilePath + '"', BinUtils.line_layout, CSV(SEPARATOR(''), QUOTE(''))) ) //, NAMED('dat2csv') )
		);
	END;
		

END;