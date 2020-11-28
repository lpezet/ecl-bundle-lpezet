IMPORT LPezet.HPCC.DataUtil;

EXPORT TestDataUtil := MODULE

	EXPORT BasicTest := MODULE
		SHARED layout := RECORD
			STRING date;
			STRING label;
			UNSIGNED some_val;
		END;
		
		SHARED expected_layout := RECORD
			STRING date;
			UNSIGNED hotel;
			UNSIGNED restaurant;
			UNSIGNED misc;
			//STRING _tval;
		END;
		
		SHARED DS := DATASET([
			{ '20200101', 'hotel', 100 },
			{ '20200101', 'restaurant', 50 },
			{ '20200101', 'misc', 23 }	
		], layout);
		SHARED DSExpected := DATASET([
			{ '20200101', 100, 50, 23 }
		], expected_layout);
		
		SHARED x := DataUtil.TransposeWithPivot(DS, 'date', 'label', 'some_val', ['hotel','restaurant','misc']);
		EXPORT Test01 := ASSERT(COUNT(x) = 1);
		EXPORT Test02 := ASSERT(x[1].hotel = 100);
		EXPORT Test03 := ASSERT(x[1].restaurant = 50);
		EXPORT Test04 := ASSERT(x[1].misc = 23);
		
		
	END;
	
	EXPORT Main := [EVALUATE(BasicTest)];
END;