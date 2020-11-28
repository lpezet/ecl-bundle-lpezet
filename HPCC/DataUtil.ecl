EXPORT DataUtil := MODULE

	EXPORT toId(STRING pValue) := REGEXREPLACE('[ /()-]', pValue, '_');

	// NB: At the moment, the TransposeeSelectValue MUST be specified. Can't seem to be able to use a dynamic set of values to create the final layout with dynamic columns.
	EXPORT TransposeWithPivot(pDS, pPivot, pTransposee, pTransposeeValue, pTransposeeSelectValues = []) := FUNCTIONMACRO
		IMPORT LPezet;
		#UNIQUENAME(oDS)
		%oDS% := pDS;
		#UNIQUENAME(transposeeValueType)
		#SET(transposeeValueType, #GETDATATYPE(#EXPAND(%'oDS'% + '.' + pTransposeeValue)))
		#UNIQUENAME(pivotType)
		#SET(pivotType, #GETDATATYPE(#EXPAND(%'oDS'% + '.' + pPivot)))
		
		#UNIQUENAME(addOp)
		#UNIQUENAME(defaultVal)
		#IF(REGEXFIND('UNSIGNED', %'transposeeValueType'%, NOCASE) OR REGEXFIND('INTEGER', %'transposeeValueType'%, NOCASE))
			#SET(defaultVal, '0')
			#SET(addOp, '+')
		#ELSEIF(REGEXFIND('BOOLEAN', %'transposeeValueType'%))
			#SET(defaultVal, 'FALSE')
			#SET(addOp, 'AND')
		#ELSEIF(REGEXFIND('REAL', %'transposeeValueType'%, NOCASE) OR REGEXFIND('DECIMAL', %'transposeeValueType'%, NOCASE))
			#SET(defaultVal, '0.0')
			#SET(addOp, '+')
		#END
		
		#UNIQUENAME(transposeeAllValues)
		%transposeeAllValues% := SORT( TABLE( pDS, { #EXPAND(pTransposee); }, #EXPAND(pTransposee) ), #EXPAND(pTransposee));
		#UNIQUENAME(transposeeValues)
		LOCAL %transposeeValues% := pTransposeeSelectValues; // %transposeeAllValues%; // IF( COUNT(pTransposeeSelectValues) > 0, %transposeeAllValues%( #EXPAND(pTransposee) IN pTransposeeSelectValues ), %transposeeAllValues%);
		
		#UNIQUENAME(countTransposeeValues)
		LOCAL %countTransposeeValues% := COUNT(%transposeeValues%);
		
		#UNIQUENAME(idx)
		#SET(idx, 1)
		#UNIQUENAME(layout)
		%layout% := RECORD
			#EXPAND(%'pivotType'%) #EXPAND(pPivot);
			#LOOP
				#IF( %idx% >  %countTransposeeValues% )
					#BREAK
				#ELSE
					#EXPAND(%'transposeeValueType'% + ' ' + LPezet.HPCC.DataUtil.toId(%transposeeValues%[%idx%]));
					//OUTPUT( SelectCounties[%idx%] );
					#SET(idx, %idx% + 1)
				#END  
			#END
			STRING _tval;
		END;
		/*
		COVID.Analysis.Utils.OutputRecordAsXML(%layout%);
		#SET(idx, 1)
		#LOOP
			#IF( %idx% >  %countTransposeeValues% )
				#BREAK
			#ELSE
				OUTPUT('SELF.' + LPezet.HPCC.DataUtil.toId(%transposeeValues%[%idx%]) + ' := IF(pRec.' + pTransposee + ' = \'' + %transposeeValues%[%idx%] + '\', pRec.' + pTransposeeValue + ', ' + %defaultVal% + ')');
				OUTPUT('SELF.' + LPezet.HPCC.DataUtil.toId(%transposeeValues%[%idx%]) + ' := pLeft.' + LPezet.HPCC.DataUtil.toId(%transposeeValues%[%idx%]) + ' ' + %'addOp'% + ' pRight.' + LPezet.HPCC.DataUtil.toId(%transposeeValues%[%idx%]));
				#SET(idx, %idx% + 1)
			#END 
		#END
		//RETURN %layout%;
		*/
		%layout% DoTranspose(RECORDOF(pDS) pRec) := TRANSFORM
			SELF._tval := #EXPAND('pRec.' + pTransposee);
			#EXPAND('SELF.' + pPivot + ' := pRec.' + pPivot);
			#SET(idx, 1)
			#LOOP
				#IF( %idx% >  %countTransposeeValues% )
					#BREAK
				#ELSE
					#EXPAND('SELF.' + LPezet.HPCC.DataUtil.toId(%transposeeValues%[%idx%]) + ' := IF(pRec.' + pTransposee + ' = \'' + %transposeeValues%[%idx%] + '\', pRec.' + pTransposeeValue + ', ' + %defaultVal% + ')');
					//OUTPUT( SelectCounties[%idx%] );
					#SET(idx, %idx% + 1)
				#END  
			#END
		END;
		
		%layout% RollupSeries(%layout% pLeft, %layout% pRight) := TRANSFORM
			//SELF.date := pLeft.date;
			//SELF._cty := pRight._cty;
			#EXPAND('SELF.' + pPivot + ' := pLeft.' + pPivot);
			SELF._tval := pRight._tval;
			#SET(idx, 1)
			#LOOP
				#IF( %idx% >  %countTransposeeValues% )
					#BREAK
				#ELSE
					#EXPAND('SELF.' + LPezet.HPCC.DataUtil.toId(%transposeeValues%[%idx%]) + ' := pLeft.' + LPezet.HPCC.DataUtil.toId(%transposeeValues%[%idx%]) + ' ' + %'addOp'% + ' pRight.' + LPezet.HPCC.DataUtil.toId(%transposeeValues%[%idx%]));
					//OUTPUT( SelectCounties[%idx%] );
					#SET(idx, %idx% + 1)
				#END  
			#END
		END;

		#UNIQUENAME(transposed)
		%transposed% := PROJECT( pDS, DoTranspose(LEFT));
		#UNIQUENAME(transposedSorted)
		%transposedSorted% := SORT(%transposed%, #EXPAND(pPivot), _tval);
		#UNIQUENAME(transposedSortedRolledUp)
		%transposedSortedRolledUp% := ROLLUP(%transposedSorted%, #EXPAND('LEFT.' + pPivot) = #EXPAND('RIGHT.' + pPivot), RollupSeries(LEFT, RIGHT));
		#UNIQUENAME(cleanedUpLayout)
		%cleanedUpLayout% := %layout% AND NOT _tval;
		#UNIQUENAME(cleanedUp)
		%cleanedUp% := PROJECT(%transposedSortedRolledUp%, %cleanedUpLayout%);
		RETURN %cleanedUp%;

		//#UNIQUENAME(CntiesTranslatedSortedRolledUpFormatted)
		//#%CntiesTranslatedSortedRolledUpFormatted% := PROJECT(%CntiesTranslatedSortedRolledUp%, TRANSFORM(RECORDOF(%CntiesTranslatedSortedRolledUp%),
		//	SELF.date := LEFT.date[5..6] + '/' + LEFT.date[7..8] + '/' + LEFT.date[1..4];
		//	SELF := LEFT;
		//));
		//RETURN %CntiesTranslatedSortedRolledUpFormatted%;
	ENDMACRO;

END;
