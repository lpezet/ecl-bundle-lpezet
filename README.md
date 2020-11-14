# ECL Bundle: LPezet

## Installation

	ecl-bundle install https://github.com/lpezet/ecl-bundle-lpezet.git


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
	

