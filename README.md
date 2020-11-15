# ECL Bundle: LPezet

## Installation

	git clone https://github.com/lpezet/ecl-bundle-lpezet.git LPezet
	ecl-bundle install LPezet


## Usage

### BinUtils

	IMPORT LPezet.Linux.BinUtils;
	
	BinUtils.cat( '/proc/cpuinfo' );
	
	BInUtils.checksum( '/proc/cpuinfo' );
	
	BinUtils.mkdir( '/tmp/test' );
	
	
### Curl

	IMPORT LPezet.Linux.Curl;
	
	Curl.download( 'ftp://ftp.fu-berlin.de/pub/misc/movies/database/actresses.list.gz', '/tmp/actresses.list.gz' );
	
	oFiles := DATASET([ {'ftp://ftp.fu-berlin.de/pub/misc/movies/database/actors.list.gz', '/tmp/actors.list.gz', false}, {'ftp://ftp.fu-berlin.de/pub/misc/movies/database/actresses.list.gz', '/tmp/actresses.list.gz', false}, {'ftp://ftp.fu-berlin.de/pub/misc/movies/database/directors.list.gz', '/tmp/directors.list.gz', false}], Curl.batch_layout );
	Curl.batch_download( oFiles );
	
	
### Archive

	IMPORT LPezet.Linux.Archive;
	
	Archive.unzip( '/tmp/test.zip' );
	
	Archive.gunzip( '/tmp/actresses.list.gz' );
	
	
### HPCC

This package contains modules to help with more ECL processing.

#### DataComp

This is inspired by the `datacompy` python package.

Here's an example on how to use it:

```
IMPORT LPezet.HPCC.DataComp;

layout := RECORD
	STRING id;
	UNSIGNED f;
	DECIMAL10_2 avg;
	DECIMAL10_2 std;
END;

DS1 := DATASET([
	{ 'A', 10, 4.6, 2.1 },
	{ 'B', 8, 5.5, 1.1 }	
	], layout);
DS2 := DATASET([
	{ 'A', 10, 4.5, 2.1 },
	{ 'B', 8, 5.5, 1.0 },
	{ 'C', 2, 1.5, 0.1 }
	], layout);

LOADXML('<xml/>');
DataComp.CompareDatasets(DS1, DS2, 'before', 'after', 'id');
```

