IMPORT LPezet.HPCC.Macros;

EXPORT TestMacros := MODULE
	
	EXPORT TestDefaultValue := [
		ASSERT( Macros.default_value('string') = '\'\'', FAIL ),
		ASSERT( Macros.default_value('qstring') = '\'\'', FAIL ),
		ASSERT( Macros.default_value('varstring') = '\'\'', FAIL ),
		ASSERT( Macros.default_value('unicode') = 'U\'\'', FAIL ),
		ASSERT( Macros.default_value('varunicode') = 'U\'\'', FAIL ),
		ASSERT( Macros.default_value('data') = 'x\'\'', FAIL ),
		ASSERT( Macros.default_value('integer') = '0', FAIL ),
		ASSERT( Macros.default_value('unsigned') = '0', FAIL ),
		ASSERT( Macros.default_value('real') = '0.0', FAIL ),
		ASSERT( Macros.default_value('decimal') = '0.0', FAIL ),
		ASSERT( Macros.default_value('set of string') = '[]', FAIL ),
		ASSERT( Macros.default_value('set of qstring') = '[]', FAIL ),
		ASSERT( Macros.default_value('set of varstring') = '[]', FAIL ),
		ASSERT( Macros.default_value('set of unicode') = '[]', FAIL ),
		ASSERT( Macros.default_value('set of varunicode') = '[]', FAIL ),
		ASSERT( Macros.default_value('set of integer') = '[]', FAIL ),
		ASSERT( Macros.default_value('set of real') = '[]', FAIL ),
		ASSERT( Macros.default_value('set of decimal') = '[]', FAIL )
	];
	
	EXPORT TestDefaultRow := MODULE
		SHARED layout := { STRING toto; INTEGER titi; };
		SHARED ds := DATASET( [ Macros.default_row( layout ) ], layout );
		
		EXPORT Test01 := ASSERT( COUNT(ds) = 1, FAIL );
	
	END;
	
	EXPORT TestDefaultDataset := MODULE
		SHARED layout := { STRING toto; INTEGER titi; };
		SHARED ds := Macros.default_dataset( layout );
		
		EXPORT Test01 := ASSERT( COUNT(ds) = 1, FAIL );
	END;
	
	EXPORT TestDefaultRecord := MODULE
		SHARED layout := { STRING toto; INTEGER titi; };
		
		EXPORT Test01 := ASSERT( Macros.default_record( layout ) = '{\'\',0}', FAIL );
	END;
	
	EXPORT Main := [EVALUATE(TestDefaultValue), EVALUATE(TestDefaultRow), EVALUATE(TestDefaultDataset), EVALUATE(TestDefaultRecord)];
END;