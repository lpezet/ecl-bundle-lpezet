IMPORT LPezet.Linux.BinUtils;

EXPORT Curl := MODULE

	EXPORT IOptions := INTERFACE
		EXPORT BOOLEAN follow_redirects;
	END;
	
	EXPORT DefaultOptions := MODULE(IOptions)
		EXPORT BOOLEAN follow_redirects := false;
	END;

	EXPORT info_layout := RECORD
		STRING content_type; 					// The Content-Type of the requested document, if there was any.
		//STRING filename_effective; 	// The ultimate filename that curl writes out to. This is only meaningful if curl is told to write to a file with the --remote-name or --output option. It's most useful in combination with the --remote-header-name option. (Added in 7.25.1)
		STRING ftp_entry_path;				// The initial path curl ended up in when logging on to the remote FTP server. (Added in 7.15.4)
		STRING http_code;							// The numerical response code that was found in the last retrieved HTTP(S) or FTP(s) transfer. In 7.18.2 the alias response_code was added to show the same info.
		STRING http_connect;					// The numerical code that was found in the last response (from a proxy) to a curl CONNECT request. (Added in 7.12.4)
		//STRING local_ip;							// The IP address of the local end of the most recently done connection - can be either IPv4 or IPv6 (Added in 7.29.0)
		//STRING local_port;						// The local port number of the most recently done connection (Added in 7.29.0)
		INTEGER num_connects; 				// Number of new connects made in the recent transfer. (Added in 7.12.3)
		INTEGER num_redirects;				// Number of redirects that were followed in the request. (Added in 7.12.3)
		STRING redirect_url;					// When an HTTP request was made without -L to follow redirects, this variable will show the actual URL a redirect would take you to. (Added in 7.18.2)
		//STRING remote_ip;							// The remote IP address of the most recently done connection - can be either IPv4 or IPv6 (Added in 7.29.0)
		//INTEGER remote_port;					// The remote port number of the most recently done connection (Added in 7.29.0)
		REAL size_download;						// The total amount of bytes that were downloaded.
		REAL size_header;							// The total amount of bytes of the downloaded headers.
		REAL size_request;						// The total amount of bytes that were sent in the HTTP request.
		REAL size_upload;							// The total amount of bytes that were uploaded.
		REAL speed_download;					// The average download speed that curl measured for the complete download. Bytes per second.
		REAL speed_upload;						// The average upload speed that curl measured for the complete upload. Bytes per second.
		INTEGER ssl_verify_result;		// The result of the SSL peer certificate verification that was requested. 0 means the verification was successful. (Added in 7.19.0)
		REAL time_appconnect;					// The time, in seconds, it took from the start until the SSL/SSH/etc connect/handshake to the remote host was completed. (Added in 7.19.0)
		REAL time_connect;						// The time, in seconds, it took from the start until the TCP connect to the remote host (or proxy) was completed.
		REAL time_namelookup;					// The time, in seconds, it took from the start until the name resolving was completed.
		REAL time_pretransfer;				// The time, in seconds, it took from the start until the file transfer was just about to begin. This includes all pre-transfer commands and negotiations that are specific to the particular protocol(s) involved.
		REAL time_redirect;						// The time, in seconds, it took for all redirection steps include name lookup, connect, pretransfer and transfer before the final transaction was started. time_redirect shows the complete execution time for multiple redirections. (Added in 7.12.3)
		REAL time_starttransfer;			// The time, in seconds, it took from the start until the first byte was just about to be transferred. This includes time_pretransfer and also the time the server needed to calculate the result.
		REAL time_total;							// The total time, in seconds, that the full operation lasted. The time will be displayed with millisecond resolution.
		STRING url_effective;					// The URL that was fetched last. This is most meaningful if you've told curl to follow location: headers.
	END;
	
	EXPORT batch_info_layout := RECORD
		STRING remoteUri;
		STRING localUri;
		info_layout;
	END;
	
	EXPORT batch_layout := RECORD
		STRING remoteUri;
		STRING localUri;
	END;
	
	
	SHARED mFormat := '%{content_type}\t%{ftp_entry_path}\t%{http_code}\t%{http_connect}\t%{num_connects}\t%{num_redirects}\t"%{redirect_url}"\t%{size_download}\t%{size_header}\t%{size_request}\t%{size_upload}\t%{speed_download}\t%{speed_upload}\t%{ssl_verify_result}\t%{time_appconnect}\t%{time_connect}\t%{time_namelookup}\t%{time_pretransfer}\t%{time_redirect}\t%{time_starttransfer}\t%{time_total}\t"%{url_effective}"';
	//SHARED mFormat := '%{content_type},%{ftp_entry_path},%{http_code},%{http_connect},%{num_connects},%{num_redirects},"%{redirect_url}",%{size_download},%{size_header},%{size_request},%{size_upload},%{speed_download},%{speed_upload},%{ssl_verify_result},%{time_appconnect},%{time_connect},%{time_namelookup},%{time_pretransfer},%{time_redirect},%{time_starttransfer},%{time_total},"%{url_effective}"';
	//PIPE('curl -w \'' + format + '\' -s -o /dev/null http://www.centos.org', curl_layout, CSV);
	
	SHARED create_options(IOptions pOptions) := FUNCTION
		oParams_0 := IF( pOptions.follow_redirects, ' -L', '' );
		oParams := oParams_0;
		RETURN oParams;
	END;
	
	EXPORT download(
		STRING remoteUri,
		STRING localUri,
		IOptions pOptions = DefaultOptions) := PIPE('curl -w \'' + mFormat + '\' ' + create_options( pOptions ) + ' -s -o ' + localUri + ' "' + remoteUri + '"', info_layout, CSV(SEPARATOR('\t')) );
		//OUTPUT('curl -w \'' + mFormat + '\' -s -o ' + localUri + ' "' + remoteUri + '"');//, info_layout, CSV(SEPARATOR('\t')) );
		
	EXPORT download_to_dataset(
		STRING remoteUri,
		IOptions pOptions = DefaultOptions) := PIPE('curl -s -o - "' + remoteUri + '"', Binutils.line_layout, CSV(SEPARATOR(''), QUOTE('')) );
		
	SHARED batch_info_layout BatchDownload (batch_layout pInput, IOptions pOptions) := TRANSFORM
		SELF.remoteUri := pInput.remoteUri;
		SELF.localUri := pInput.localUri;
		SELF := download(pInput.remoteUri, pInput.localUri, pOptions)[1];
	END;

	EXPORT batch_download(
		DATASET(batch_layout) batch, IOptions pOptions = DefaultOptions) := NORMALIZE( batch, 1, BatchDownload(LEFT, pOptions) );
		
END;

