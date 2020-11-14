IMPORT Std;

EXPORT SFile := MODULE
	
	EXPORT Create(STRING pFile) := FUNCTION
		RETURN IF(NOT Std.File.SuperFileExists(pFile), 
			SEQUENTIAL(
				Std.File.CreateSuperFile(pFile)
			));
	END;
	
	EXPORT Reset(STRING pFile) := FUNCTION
		RETURN IF(Std.File.SuperFileExists(pFile), SEQUENTIAL(
				Std.File.StartSuperFileTransaction(),
				Std.File.ClearSuperFile(pFile),
				Std.File.FinishSuperFileTransaction()
		), Std.File.CreateSuperFile(pFile));
	END;
	
	EXPORT Drop(STRING pFile) := FUNCTION
		RETURN IF(Std.File.SuperFileExists(pFile), 
			SEQUENTIAL(
				Std.File.DeleteSuperFile(pFile)
			));
	END;
	
	EXPORT RemoveSub(STRING pSuperFile, STRING pSub) := FUNCTION
		RETURN IF(Std.File.SuperFileExists(pSuperFile), SEQUENTIAL(
			Std.File.StartSuperFileTransaction(),
			Std.File.RemoveSuperFile(pSuperFile, pSub),
			Std.File.FinishSuperFileTransaction()
		));
	END;
	
	
	EXPORT AddSub(STRING pSuperFile, STRING pSub) := FUNCTION
		RETURN SEQUENTIAL(
			Std.File.StartSuperFileTransaction(),
			//Std.File.RemoveSuperFile(pSuperFile, pSub),
			Std.File.AddSuperFile(pSuperFile, pSub),
			//Std.File.ReplaceSuperFile(pSuperFile, pSub),
			Std.File.FinishSuperFileTransaction()
		);
	END;

END;