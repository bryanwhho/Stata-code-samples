/****************************************
tofips.ado

	Written by: Bryan Ho
	Written on: 12 May 2016
	Last modified: 20 June 2016
	
This simple program converts US full state2 names to FIPS codes.

****************************************/

program tofips
	version 14.1
	args state
	
	cap { 
		drop fips
	}
	
	gen state2 = lower(`state')
	replace state2 = subinstr(state2, " ", "",.)
	
	gen fips = .

	replace fips =  01 if state2 == "alabama" | state2 == "al"
	replace fips =  02 if state2 == "alaska" | state2 == "ak"
	replace fips =  04 if state2 == "arizona" | state2 == "az"
	replace fips =  05 if state2 == "arkansas" | state2 == "ar"
	replace fips =  06 if state2 == "california" | state2 == "californ" | state2 == "ca"
	replace fips =  08 if state2 == "colorado" | state2 == "co"
	replace fips =  09 if state2 == "connecticut" | state2 == "connecti" | state2 == "ct"
	replace fips =  10 if state2 == "delaware" | state2 == "de"
	replace fips =  11 if state2 == "districtofcolumbia" | state2 == "district" | state2 == "dc"
	replace fips =  12 if state2 == "florida" | state2 == "fl"
	replace fips =  13 if state2 == "georgia" | state2 == "ga"
	replace fips =  15 if state2 == "hawaii" | state2 == "hi"
	replace fips =  16 if state2 == "idaho" | state2 == "id"
	replace fips =  17 if state2 == "illinois" | state2 == "il"
	replace fips =  18 if state2 == "indiana" | state2 == "in"
	replace fips =  19 if state2 == "iowa" | state2 == "ia"
	replace fips =  20 if state2 == "kansas" | state2 == "ks"
	replace fips =  21 if state2 == "kentucky" | state2 == "ky" 
	replace fips =  22 if state2 == "louisiana" | state2 == "louisian" | state2 == "la"
	replace fips =  23 if state2 == "maine" | state2 == "me"
	replace fips =  24 if state2 == "maryland" | state2 == "md"
	replace fips =  25 if state2 == "massachusetts" | state2 == "massachu" | state2 == "ma"
	replace fips =  26 if state2 == "michigan" | state2 == "mi"
	replace fips =  27 if state2 == "minnesota" | state2 == "minnesot" | state2 == "mn"
	replace fips =  28 if state2 == "mississippi" | state2 == "mississi" | state2 == "ms"
	replace fips =  29 if state2 == "missouri" | state2 == "mo"
	replace fips =  30 if state2 == "montana" | state2 == "mt"
	replace fips =  31 if state2 == "nebraska" | state2 == "ne"
	replace fips =  32 if state2 == "nevada" | state2 == "nv"
	replace fips =  33 if state2 == "newhampshire" | state2 == "newhamp" | state2 == "nh"
	replace fips =  34 if state2 == "newjersey" | state2 == "newjers" | state2 == "nj"
	replace fips =  35 if state2 == "newmexico" | state2 == "newmexi" | state2 == "nm"
	replace fips =  36 if state2 == "newyork" | state2 == "ny"
	replace fips =  37 if state2 == "northcarolina" | state2 == "northca" | state2 == "nc"
	replace fips =  38 if state2 == "northdakota" | state2 == "northda" | state2 == "nd"
	replace fips =  39 if state2 == "ohio" | state2 == "oh"
	replace fips =  40 if state2 == "oklahoma" | state2 == "ok"
	replace fips =  41 if state2 == "oregon" | state2 == "or"
	replace fips =  42 if state2 == "pennsylvania" | state2 == "pennsylv" | state2 == "pa"
	replace fips =  44 if state2 == "rhodeisland" | state2 == "rhodeis" | state2 == "ri"
	replace fips =  45 if state2 == "southcarolina" | state2 == "southca" | state2 == "sc"
	replace fips =  46 if state2 == "southdakota" | state2 == "southda" | state2 == "sd"
	replace fips =  47 if state2 == "tennessee" | state2 == "tennesse" | state2 == "tn"
	replace fips =  48 if state2 == "texas" | state2 == "tx"
	replace fips =  49 if state2 == "utah" | state2 == "ut"
	replace fips =  50 if state2 == "vermont" | state2 == "vt"
	replace fips =  51 if state2 == "virginia" | state2 == "va"
	replace fips =  53 if state2 == "washington" | state2 == "washingt" | state2 == "wa"
	replace fips =  54 if state2 == "westvirginia" | state2 == "westvir" | state2 == "wv"
	replace fips =  55 if state2 == "wisconsin" | state2 == "wisconsi" | state2 == "wi"
	replace fips =  56 if state2 == "wyoming" | state2 == "wy"

	drop state2
	
end
