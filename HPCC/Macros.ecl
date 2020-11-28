
EXPORT Macros := INTERFACE

	EXPORT default_value( pType ) := FUNCTIONMACRO
		#DECLARE( oRes )
		#SET( oRes, '' )
		#IF( pType = 'string' OR pType = 'qstring' OR pType = 'varstring' )
			#SET( oRes, '\'\'' )
		#ELSEIF( pType = 'unicode' OR pType = 'varunicode' )
			#SET(oRes, 'U\'\'')
		#ELSEIF( pType = 'data' )
			#SET(oRes, 'x\'\'')
		#ELSEIF( pType = 'integer' OR pType = 'unsigned' )
			#SET(oRes, '0')
		#ELSEIF( pType = 'real' OR pType = 'decimal' )
			#SET(oRes, '0.0')
		#ELSEIF( 
				pType = 'set of string' 
				OR pType = 'set of qstring' 
				OR pType = 'set of varstring' 
				OR pType = 'set of unicode'
				OR pType = 'set of varunicode' 
				OR pType = 'set of integer' 
				OR pType = 'set of real' 
				OR pType = 'set of decimal' )
			#SET(oRes, '[]')
		//#ELSE
		//	#APPEND(OutStr, '{}' );
		#END
		RETURN %'oRes'%;	
	ENDMACRO;

	/*
  * Creates a DATASET containing a single record with default values as follows:
	* - STRING : ''
	* - INTEGER/UNSIGNED: 0
	* - REAL/DECIMAL: 0.0
	* - SET OF *: []
	* 
	* NB: I don't believe it can be used as is. #EXPAND of '{ ... }' doesn't seem to work even though that's the syntax used in in-line datasets.
	* But it can be used to troubleshoot defaults by simply OUTPUTing the result.
	*/
	EXPORT default_record( pLayout ) := FUNCTIONMACRO
		IMPORT LPezet;
		#EXPORTXML(oXML, pLayout);
		#UNIQUENAME( DefVal );
		#UNIQUENAME( OutStr );
		
		//#DECLARE(OutStr)
		//#DECLARE(DefVal)
		
		#SET(OutStr, '{' )
		#FOR( oXML )
			//#APPEND( OutStr, Macros.default_value( %'{Field[1]/@type}'% ) );
			#FOR(Field)
				#IF( %{@position}% > 0 )
					#APPEND( OutStr, ',')
				#END
				#SET( DefVal, LPezet.HPCC.Macros.default_value( %'{@type}'% ) );
				#APPEND( OutStr, %'DefVal'% )
			#END	
		#END
		#APPEND(OutStr, '}');
		RETURN %'OutStr'%;
	
	ENDMACRO;
	
	EXPORT default_record_new( pLayout ) := FUNCTIONMACRO
		IMPORT LPezet;
		#EXPORTXML(oXML, pLayout);

		#DECLARE(OutStr)
		#DECLARE(DefVal)
		#SET(OutStr, '{' )
		#FOR( oXML )
			#APPEND( OutStr, LPezet.HPCC.Macros.default_value( %'{Field[1]/@type}'% ) );
			#FOR(Field[@position>0])
				#SET( DefVal, LPezet.HPCC.Macros.default_value( %'@type}'% ) );
				//#IF( %'DefVal'% <> '' )
					#APPEND( OutStr, ',' + %'DefVal'% )
				//#END
				/*
				#IF( %'{@type}'% = 'string' OR %'{@type}'% = 'qstring' OR %'{@type}'% = 'varstring' )
					#APPEND(OutStr, '\'\'')
				#ELSEIF( %'{@type}'% = 'unicode' OR %'{@type}'% = 'varunicode' )
					#APPEND(OutStr, 'U\'\'')
				#ELSEIF( %'{@type}'% = 'data' )
					#APPEND(OutStr, 'x\'\'')
				#ELSEIF( %'{@type}'% = 'integer' OR %'{@type}'% = 'unsigned' )
					#APPEND(OutStr, '0')
				#ELSEIF( %'{@type}'% = 'real' OR %'{@type}'% = 'decimal' )
					#APPEND(OutStr, '0.0')
				#ELSEIF( %'{@type}'% = 'set of string' OR %'{@type}'% = 'set of integer' OR %'{@type}'% = 'set of real' OR %'{@type}'% = 'set of decimal' )
					#APPEND(OutStr, '[]')
				//#ELSE
				//	#APPEND(OutStr, '{}' );
				#END
				*/
				//#IF( %'{@isEnd}'% = '' )
				//	#APPEND(OutStr, ','); // NB: extra "comma" at the end of a record is OK.
				//#END
			#END	
		#END
		#APPEND(OutStr, '}');
		RETURN %'OutStr'%;
	
	ENDMACRO;

	
	/*
	* Usage:
	* r := { STRING toto; INTEGER titi; };
	* oDS := DATASET( [ Macros.default_row( r ) ], r );
	* oDS;
	*/
	EXPORT default_row( pLayout ) := FUNCTIONMACRO
		IMPORT LPezet;
		#UNIQUENAME( oRow );
		//#DECLARE( oRow )
		#SET( oRow, 'ROW(');
		#APPEND( oRow, LPezet.HPCC.Macros.default_record( pLayout ) );
		#APPEND( oRow, ', ');
		#APPEND( oRow, #TEXT( pLayout ));
		#APPEND( oRow, ')');
		RETURN #EXPAND(%'oRow'%);
		
	ENDMACRO;
	
	/*
	* Usage:
	* r := { STRING toto; INTEGER titi; };
	* oDS := DATASET( [ Macros.default_row( r ) ], r );
	* oDS;
	*/
	EXPORT default_dataset( pLayout ) := FUNCTIONMACRO
		IMPORT LPezet;
		#DECLARE( oDS )
		#SET( oDS, 'DATASET( [');
		#APPEND( oDS, LPezet.HPCC.Macros.default_record( pLayout ) );
		#APPEND( oDS, '], ');
		#APPEND( oDS, #TEXT( pLayout ));
		#APPEND( oDS, ')');
		RETURN #EXPAND(%'oDS'%);
		
	ENDMACRO;

END;