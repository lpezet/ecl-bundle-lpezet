EXPORT DataComp := MODULE

	// Usage:
	// LOADXML('<xml/>');
	// NewDS1 := AppendSuffixToFields(DS1, 'Orig', 'id');
	EXPORT AppendSuffixToFields(pDS, pSuffix, pCommaSeparatedFieldsToExclude) := FUNCTIONMACRO
		//LOADXML('<xml/>');
		
		//#DECLARE(out)
		//#EXPORT(out, RECORDOF(pDS))
		//LOADXML(%'out'%);
		//OUTPUT(%'out'%);
		#EXPORTXML(RecLay, RECORDOF(pDS));
		// OUTPUT(%RecLay%);
		#UNIQUENAME(TrimmedFieldsToExclude)
		LOCAL %TrimmedFieldsToExclude% := '@' + REGEXREPLACE(',', TRIM((STRING) pCommaSeparatedFieldsToExclude, ALL), '@') + '@';
		
		#UNIQUENAME(new_layout)
		%new_layout% := RECORD
			UNSIGNED __dummy := 0; // This is so compiler doesn't throw an exception where this RECORD is of zero length.
			#FOR(RecLay)
				#FOR(Field)
					#IF( NOT REGEXFIND('@' + %'{@name}'% + '@', %TrimmedFieldsToExclude%) )
						//OUTPUT(%'{@ecltype}'% + ' ' + %'{@name}'% + '_original');
						#EXPAND(%'{@ecltype}'% + ' ' + %'{@name}'% + '_' + pSuffix);
					#ELSE
						#EXPAND(%'{@ecltype}'% + ' ' + %'{@name}'%);
						//OUTPUT('ELSE');
					#END
				#END
			#END
		END;
		
		RETURN PROJECT(pDS, TRANSFORM(%new_layout%,
				SELF.__dummy := COUNTER;
				#FOR(RecLay)
					#FOR(Field)
						#IF( NOT REGEXFIND('@' + %'{@name}'% + '@', %TrimmedFieldsToExclude%) )
							#EXPAND('SELF.' + %'{@name}'% + '_' + pSuffix + ' := LEFT.' + %'{@name}'%);
						#ELSE
							#EXPAND('SELF.' + %'{@name}'% + ' := LEFT.' + %'{@name}'%);
						#END
					#END
				#END
		));
	ENDMACRO;

	// Usage:
	// LOADXML('<xml/>');
	// NewDS1 := AppendSuffixToFields(DS1, 'Orig', 'id');
	// NewDS2 := AppendSuffixToFields(DS2, 'New', 'id');	
	// DoCompareDatasets(NewDS1, NewDS2, 'Orig', 'New', 'id');
	EXPORT DoCompareDatasets(pDS0, pDS1, pDS2, pSuffix1, pSuffix2, pJoinColumn) := MACRO
	#EXPORTXML(RecLay, RECORDOF(pDS0));
	#FOR(RecLay)
		#FOR(Field)
			//OUTPUT(%'{@name}'%);
			#IF( %'{@name}'% != pJoinColumn ) // AND %'{@name}'% != '__dummy')
				//OUTPUT('Working on ' + %'{@name}'% + '...');
				#UNIQUENAME(TableORIG)
				%TableORIG% := TABLE(pDS1, { #EXPAND(pJoinColumn); #EXPAND(%'{@name}'% + '_' + pSuffix1); });
				#UNIQUENAME(TableNEW)
				%TableNEW% := TABLE(pDS2, { #EXPAND(pJoinColumn); #EXPAND(%'{@name}'% + '_' + pSuffix2); });
				#UNIQUENAME(Join_1);
				%Join_1% := JOIN(%TableORIG%, %TableNEW%, #EXPAND('LEFT.' + pJoinColumn + ' = RIGHT.' + pJoinColumn));
				#UNIQUENAME(Diff);
				%Diff% := %Join_1%(#EXPAND(%'{@name}'% + '_' + pSuffix1) != #EXPAND(%'{@name}'% + '_' + pSuffix2));
				OUTPUT(%Diff%,,NAMED('DifferencesFor_' + %'{@name}'%));
			#END
			
		#END
	#END
	ENDMACRO;
	
	EXPORT CompareDatasets(pDS1, pDS2, pSuffix1, pSuffix2, pJoinColumn) := MACRO
		IMPORT LPezet;
		#UNIQUENAME(SuffixedDS1)
		%SuffixedDS1% := LPezet.HPCC.DataComp.AppendSuffixToFields(pDS1, pSuffix1, pJoinColumn);
		#UNIQUENAME(SuffixedDS2)
		%SuffixedDS2% := LPezet.HPCC.DataComp.AppendSuffixToFields(pDS2, pSuffix2, pJoinColumn);
		LPezet.HPCC.DataComp.DoCompareDatasets(pDS1, %SuffixedDS1%, %SuffixedDS2%, pSuffix1, pSuffix2, pJoinColumn);
		//%SuffixedDS1%;
	ENDMACRO;
	
END;