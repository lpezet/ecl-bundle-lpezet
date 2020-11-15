IMPORT LPezet.HPCC.DataComp;

EXPORT TestDataComp := MODULE

	EXPORT TestAppendSuffixToFields := MODULE
		SHARED layout := RECORD
			STRING id;
			UNSIGNED f;
			DECIMAL10_2 avg;
			DECIMAL10_2 std;
		END;
		
		SHARED expected_layout := RECORD
			UNSIGNED __dummy := 0;
			STRING id;
			UNSIGNED f_orig;
			DECIMAL10_2 avg_orig;
			DECIMAL10_2 std_orig;
		END;
		
		SHARED DS1 := DATASET([
			{ 'A', 10, 4.6, 2.1 },
			{ 'B', 8, 5.5, 1.1 }	
		], layout);
		SHARED DS2 := DATASET([
			{ 'A', 10, 4.5, 2.1 },
			{	'B', 8, 5.5, 1.0 },
			{ 'C', 2, 1.5, 0.1 }
		], layout);
		
		x := DataComp.AppendSuffixToFields(DS1, 'orig', 'id');
		#DECLARE(out1)
		#DECLARE(out2)
		#EXPORT(out1, RECORDOF(x))
		#EXPORT(out2, expected_layout)
		EXPORT Test01 := ASSERT(%'out1'% = %'out2'%, FAIL);
		
	END;
	
	
	EXPORT TestCompareDatasets := MODULE
		SHARED layout := RECORD
			STRING id;
			UNSIGNED f;
			DECIMAL10_2 avg;
			DECIMAL10_2 std;
		END;
		
		SHARED expected_layout := RECORD
			UNSIGNED __dummy := 0;
			STRING id;
			UNSIGNED f_orig;
			DECIMAL10_2 avg_orig;
			DECIMAL10_2 std_orig;
		END;
		
		SHARED DS1 := DATASET([
			{ 'A', 10, 4.6, 2.1 },
			{ 'B', 8, 5.5, 1.1 }	
		], layout);
		SHARED DS2 := DATASET([
			{ 'A', 10, 4.5, 2.1 },
			{	'B', 8, 5.5, 1.0 },
			{ 'C', 2, 1.5, 0.1 }
		], layout);
		
		EXPORT Test01 := DataComp.CompareDatasets(DS1, DS2, 'orig', 'new', 'id');
	
	END;
	
	EXPORT Main := [EVALUATE(TestAppendSuffixToFields), EVALUATE(TestCompareDatasets)];
END;