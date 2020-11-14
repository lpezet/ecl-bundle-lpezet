EXPORT Geocoding := MODULE

	EXPORT ipstack_ip_geocode(STRING pKey, STRING pIP) := FUNCTION
		ipstack_layout := RECORD
			STRING ip {XPATH('ip')};
			STRING type {XPATH('type')};
			STRING continent_code {XPATH('continent_code')};
			STRING continent_name {XPATH('continent_name')};
			STRING region_code {XPATH('region_code')};
			STRING region_name {XPATH('region_name')};
			STRING city {XPATH('city')};
			STRING zip {XPATH('zip')};
			REAL8 latitude {XPATH('latitude')};
			REAL8 longitude {XPATH('longitude')};
			// not interested in rest for now
		END;	

		RETURN HTTPCALL('http://api.ipstack.com/' + pIP + '?access_key=' + pKey + '&format=1&output=xml', 'GET', 'text/xml', ipstack_layout);
	END;

	EXPORT google_geocode(STRING pKey, STRING pAddress) := FUNCTION
		google_geocode_type_layout := RECORD
			STRING type;
		END;
		google_geocode_address_compoent_layout := RECORD
			STRING long_name;
			STRING short_name;
			
		END;
		google_geocode_response_layout := RECORD
			STRING status {XPATH('status')};
			STRING type {XPATH('result/type')};
			STRING formatted_address {XPATH('result/formatted_address')};
			//DATASET(google_geocode_address_compoent_layout) address_components;
			REAL8 geometry_location_latitude {XPATH('result/geometry/location/lat')};
			REAL8 geometry_location_longitude {XPATH('result/geometry/location/lng')};
			STRING geometry_location_type {XPATH('result/geometry/location_type')};
			// not interested in the rest
		END;

		RETURN HTTPCALL('https://maps.googleapis.com/maps/api/geocode/xml?address='+pAddress+'&key=' + pKey, 'GET', 'text/xml', google_geocode_response_layout);
		//OUTPUT(raw);
	END;

	// Inspiration:
	// https://www.movable-type.co.uk/scripts/latlong.html
	// https://www.geodatasource.com/developers/c
	EXPORT REAL8 calculate_distance(const real8 pLat1, const real8 pLng1, const real8 pLat2, const real8 pLng2, string pUnit) := BEGINC++
		#include <math.h>
	 #define pi 3.14159265358979323846
	 double deg2rad(double deg) {
			return (deg * pi / 180);
		}
		double rad2deg(double rad) {
			return (rad * 180 / pi);
		}
		double distance(double lat1, double lon1, double lat2, double lon2, char unit) {
				double theta, dist;
				theta = lon1 - lon2;
				dist = sin(deg2rad(lat1)) * sin(deg2rad(lat2)) + cos(deg2rad(lat1)) * cos(deg2rad(lat2)) * cos(deg2rad(theta));
				dist = acos(dist);
				dist = rad2deg(dist);
				dist = dist * 60 * 1.1515;
				switch(unit) {
					case 'M':
						break;
					case 'K':
						dist = dist * 1.609344;
						break;
					case 'N':
						dist = dist * 0.8684;
						break;
				}
				return (dist);
			}
		#body
		return distance(plat1, plng1, plat2, plng2, punit[0]);
	ENDC++;


END;