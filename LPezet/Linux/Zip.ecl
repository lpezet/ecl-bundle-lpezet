IMPORT LPezet.Linux.BinUtils;

EXPORT Zip := MODULE

	EXPORT unzip(STRING localUri, STRING targetUri = '', BOOLEAN forceOverwrite = FALSE) := FUNCTION
		A := 'unzip ';
		B := A + IF(forceOverwrite, ' -o ', '');
		C := B + localUri;
		D := C + IF(LENGTH(targetUri) > 0, ' -d ' + targetUri, '');
		oCmd := D;
		RETURN PIPE(oCmd, BinUtils.line_layout, CSV(SEPARATOR(''), QUOTE('')) );
	END;
	
END;