*****************
/* dlab 3.1.do */
*****************

/*-----------------------------------------------------------------------------
 *  Author:        Bryan Ho
 *  Written:       04/13/2016
 *  Last updated:  07/05/2016
 *
 *
 *  1. This file extends "dlab 2.1.dta" (1966-2000), the original 
 *	abortion v. crime dataset, up to 2013, and saves it as "dlab 3.1.dta" 
 *	(1929-2013). 
 *
 *	2. All variables are calculated based on the original formulae except for:
 *	
 *	- xxbeer: the Beer Institute sent us data for annual beer shipments by state
 *	instead of Consumption of Malt Beverages, so we contructed beer shipments 
 *	per capita. 
 *
 *	- xxafdc15, xxtanf15: AFDC was converted into TANF in 1997, so xxafdc15 
 *	reflects TANF expenditure per family from then on, while xxtanf15 is a dummy
 *	equal to 1 when this is so. 
 *
 *	- xxgunlaw: this was recoded by Donohue's RAs and differs from the original.
 *
 *	3. Other variables which have been substantially changed are:
 *
 *	- abresrt: for reasons unknown, Donohue's RAs' abortion / live birth data 
 *	is quite different from the old abortion data. Their data is based on 
 *	http://www.johnstonsarchive.net/policy/abortion/usa/ab-usa-AL.html, which
 *	in turn is based on CDC, AGI, and state health department data. As this 
 *	data seems fairly reliable, we replaced the old abortion data up to and 
 *	including 1977. 
 *
 *	- mur*, vio*, pro*: the data from the FBI's UCR is very noisy, and was not 
 *	cleaned in the original dataset. Besides extending these variables, the data
 *	in this dataset are cleaned based on observations flagged out by UCR's CIUS 
 *	as incomplete in some way. (NB: remaining data is still very noisy, as 
 *	agencies submit arrest data voluntarily, resulting in submission 
 *	discrepancies over time.)
 *
 *	4. New variables include:
 *
 *	- abresmig: the old effective abortion rate, controlling for migration, was
 *	based on abortions by state of occurrence, which we are no longer using. 
 *	This variable is used to calculate the new EAR, controlling for migration. 
 *
 * 
 *	NB: AIDS, teenfertil, and wedlockfertil are not included in this dataset. 
 *----------------------------------------------------------------------------*/
 
*****************
* Preliminaries *
*****************

clear all
version 14.1
set more off

global dir = "C:/Users\bryanho/Documents/Abortion"
global input = "$dir/PROCESSED/01_INSHEET"
global output = "$dir/PROCESSED/02_MERGE"
 

*****************************
* Start merging in new data *
*****************************

cd $dir
use "dlab 2.1.dta", clear
replace year = year+1900 //old dta had year saved as two-digits

/* Merge in population data, first */
merge 1:1 state year using "$input\population\popul_new" , update
drop _merge

/* Merge in income data, next */
merge 1:1 state year using "$input\income\income", update replace /* using current $ unadjusted instead of 97 dollars*/
drop _merge

replace xxincome = ln(income)
label var xxincome "ln(state income per capita, current $ unadj), BEA.gov"

drop income

sort state year

************* Merge in the rest in alphabetical order *******************

tofips state

/* Merge in abortion data */
merge 1:1 fips year using "$input\abort\abortion_numbers", update
drop _merge

/* Merge in blank abortion data from 1950-1965 */
merge 1:1 state year using "$input/abort/abort_1940_1965", update
drop _merge 

/* Merge in migration-adjusted abortion data */
merge 1:1 state year using "$input\abort\abresmig", update
drop _merge

/* Merge in arrests data */
merge 1:1 state year using "$input\arrests\cleaned\arrests", update
drop _merge

do $input\arrests\cleaned\cleanarrests.do

** fix old data issues **
local crime "mur pro vio"
foreach c of local crime {
	egen `c'_u25_fix = rowtotal(`c'arr*) if (state=="DISTRICT" | state=="VERMONT") & year==1995
	replace `c'_u25 = `c'_u25_fix if (state=="DISTRICT" | state=="VERMONT") & year==1995
	drop `c'_u25_fix 
	
	egen `c'_u25_fix = rowtotal(`c'arr*) if (state=="NEBRASKA") & year==1996
	replace `c'_u25 = `c'_u25_fix if (state=="NEBRASKA") & year==1996
	drop `c'_u25_fix 	
}
// Note `c'_o25 cannot be generated from available data 


/* Merge in beer data */
merge 1:1 state year using "$input\beer\beer", update
drop _merge

replace xxbeer = beer_new / (popul * 1000)
drop beer_new
label var xxbeer "beer shipments per capita"

/* Merge in crime data */
merge 1:1 state year using "$input\crime\crime_new", update
drop _merge

drop metro_pop
drop violent property murder

/* Merge in natality (i.e. births) data  - WONDER CDC data */
merge 1:1 fips year using "$input/natality/natality"
drop _merge

/* Merge in fertility data (also births) - NBER CDC data*/
merge 1:1 state year using "$input\fertility\births1970_2004", update
drop _merge 

/* Generate abresrt variable */
bysort fips: ipolate aborts_res_agi year , gen(aborts_new) 

gen abresrt_new = aborts_new / births * 1000

replace abresrt = abresrt_new if year >=1977 

// Old abortion data was wonky, but new data only available from 1977 onwards. //

drop abresrt_new aborts_new aborts_res_agi births

/* Update fips for new data */

sort state year

replace fips =  01 if state == "ALABAMA"
replace fips =  02 if state == "ALASKA" 
replace fips =  04 if state == "ARIZONA" 
replace fips =  05 if state == "ARKANSAS"  
replace fips =  06 if state == "CALIFORN"  
replace fips =  08 if state == "COLORADO"  
replace fips =  09 if state == "CONNECTI"  
replace fips =  10 if state == "DELAWARE"  
replace fips =  11 if state == "DISTRICT"  
replace fips =  12 if state == "FLORIDA"  
replace fips =  13 if state == "GEORGIA"  
replace fips =  15 if state == "HAWAII"  
replace fips =  16 if state == "IDAHO"  
replace fips =  17 if state == "ILLINOIS"  
replace fips =  18 if state == "INDIANA"  
replace fips =  19 if state == "IOWA"  
replace fips =  20 if state == "KANSAS"  
replace fips =  21 if state == "KENTUCKY" 
replace fips =  22 if state == "LOUISIAN"  
replace fips =  23 if state == "MAINE"  
replace fips =  24 if state == "MARYLAND"  
replace fips =  25 if state == "MASSACHU"  
replace fips =  26 if state == "MICHIGAN"  
replace fips =  27 if state == "MINNESOT"  
replace fips =  28 if state == "MISSISSI"  
replace fips =  29 if state == "MISSOURI"  
replace fips =  30 if state == "MONTANA"  
replace fips =  31 if state == "NEBRASKA"  
replace fips =  32 if state == "NEVADA"  
replace fips =  33 if state == "NEW HAMP"  
replace fips =  34 if state == "NEW JERS"  
replace fips =  35 if state == "NEW MEXI"  
replace fips =  36 if state == "NEW YORK" 
replace fips =  37 if state == "NORTH CA"  
replace fips =  38 if state == "NORTH DA"  
replace fips =  39 if state == "OHIO"  
replace fips =  40 if state == "OKLAHOMA"  
replace fips =  41 if state == "OREGON"  
replace fips =  42 if state == "PENNSYLV"  
replace fips =  44 if state == "RHODE IS"  
replace fips =  45 if state == "SOUTH CA"  
replace fips =  46 if state == "SOUTH DA"  
replace fips =  47 if state == "TENNESSE"  
replace fips =  48 if state == "TEXAS" 
replace fips =  49 if state == "UTAH"  
replace fips =  50 if state == "VERMONT"  
replace fips =  51 if state == "VIRGINIA"  
replace fips =  53 if state == "WASHINGT"  
replace fips =  54 if state == "WEST VIR"  
replace fips =  55 if state == "WISCONSI"  
replace fips =  56 if state == "WYOMING" 

/* Update statenum for new data */

replace statenum =  01 if state == "ALABAMA"
replace statenum =  02 if state == "ALASKA" 
replace statenum =  03 if state == "ARIZONA" 
replace statenum =  04 if state == "ARKANSAS"  
replace statenum =  05 if state == "CALIFORN"  
replace statenum =  06 if state == "COLORADO"  
replace statenum =  07 if state == "CONNECTI"  
replace statenum =  08 if state == "DELAWARE"  
replace statenum =  09 if state == "DISTRICT"  
replace statenum =  10 if state == "FLORIDA"  
replace statenum =  11 if state == "GEORGIA"  
replace statenum =  12 if state == "HAWAII"  
replace statenum =  13 if state == "IDAHO"  
replace statenum =  14 if state == "ILLINOIS"  
replace statenum =  15 if state == "INDIANA"  
replace statenum =  16 if state == "IOWA"  
replace statenum =  17 if state == "KANSAS"  
replace statenum =  18 if state == "KENTUCKY" 
replace statenum =  19 if state == "LOUISIAN"  
replace statenum =  20 if state == "MAINE"  
replace statenum =  21 if state == "MARYLAND"  
replace statenum =  22 if state == "MASSACHU"  
replace statenum =  23 if state == "MICHIGAN"  
replace statenum =  24 if state == "MINNESOT"  
replace statenum =  25 if state == "MISSISSI"  
replace statenum =  26 if state == "MISSOURI"  
replace statenum =  27 if state == "MONTANA"  
replace statenum =  28 if state == "NEBRASKA"  
replace statenum =  29 if state == "NEVADA"  
replace statenum =  30 if state == "NEW HAMP"  
replace statenum =  31 if state == "NEW JERS"  
replace statenum =  32 if state == "NEW MEXI"  
replace statenum =  33 if state == "NEW YORK" 
replace statenum =  34 if state == "NORTH CA"  
replace statenum =  35 if state == "NORTH DA"  
replace statenum =  36 if state == "OHIO"  
replace statenum =  37 if state == "OKLAHOMA"  
replace statenum =  38 if state == "OREGON"  
replace statenum =  39 if state == "PENNSYLV"  
replace statenum =  40 if state == "RHODE IS"  
replace statenum =  41 if state == "SOUTH CA"  
replace statenum =  42 if state == "SOUTH DA"  
replace statenum =  43 if state == "TENNESSE"  
replace statenum =  44 if state == "TEXAS" 
replace statenum =  45 if state == "UTAH"  
replace statenum =  46 if state == "VERMONT"  
replace statenum =  47 if state == "VIRGINIA"  
replace statenum =  48 if state == "WASHINGT"  
replace statenum =  49 if state == "WEST VIR"  
replace statenum =  50 if state == "WISCONSI"  
replace statenum =  51 if state == "WYOMING" 

/* Update region for new data */

replace region =  6 if state == "ALABAMA"
replace region =  9 if state == "ALASKA" 
replace region =  8 if state == "ARIZONA" 
replace region =  7 if state == "ARKANSAS"  
replace region =  9 if state == "CALIFORN"  
replace region =  8 if state == "COLORADO"  
replace region =  1 if state == "CONNECTI"  
replace region =  5 if state == "DELAWARE"  
replace region =  5 if state == "DISTRICT"  
replace region =  5 if state == "FLORIDA"  
replace region =  5 if state == "GEORGIA"  
replace region =  9 if state == "HAWAII"  
replace region =  8 if state == "IDAHO"  
replace region =  3 if state == "ILLINOIS"  
replace region =  3 if state == "INDIANA"  
replace region =  4 if state == "IOWA"  
replace region =  4 if state == "KANSAS"  
replace region =  6 if state == "KENTUCKY" 
replace region =  7 if state == "LOUISIAN"  
replace region =  1 if state == "MAINE"  
replace region =  5 if state == "MARYLAND"  
replace region =  1 if state == "MASSACHU"  
replace region =  3 if state == "MICHIGAN"  
replace region =  4 if state == "MINNESOT"  
replace region =  6 if state == "MISSISSI"  
replace region =  4 if state == "MISSOURI"  
replace region =  8 if state == "MONTANA"  
replace region =  4 if state == "NEBRASKA"  
replace region =  8 if state == "NEVADA"  
replace region =  1 if state == "NEW HAMP"  
replace region =  2 if state == "NEW JERS"  
replace region =  8 if state == "NEW MEXI"  
replace region =  2 if state == "NEW YORK" 
replace region =  5 if state == "NORTH CA"  
replace region =  4 if state == "NORTH DA"  
replace region =  3 if state == "OHIO"  
replace region =  7 if state == "OKLAHOMA"  
replace region =  9 if state == "OREGON"  
replace region =  2 if state == "PENNSYLV"  
replace region =  1 if state == "RHODE IS"  
replace region =  5 if state == "SOUTH CA"  
replace region =  4 if state == "SOUTH DA"  
replace region =  6 if state == "TENNESSE"  
replace region =  7 if state == "TEXAS" 
replace region =  8 if state == "UTAH"  
replace region =  1 if state == "VERMONT"  
replace region =  5 if state == "VIRGINIA"  
replace region =  9 if state == "WASHINGT"  
replace region =  5 if state == "WEST VIR"  
replace region =  3 if state == "WISCONSI"  
replace region =  8 if state == "WYOMING" 

/* Merge in AFDC/TANF data*/
merge 1:1 fips year using "$input\afdc\afdc_tanf", update
drop _merge

/* Merge in foreignborn data */
merge 1:1 fips year using "$input\foreignborn\foreignborn", update
drop _merge

bysort state: ipolate fb year , generate(fb_new)
replace fb = fb_new
drop fb_new

sort state year

/* Merge in gunlaw data */
merge 1:1 fips year using "$input\gunlaw\gunlaw", update replace /* old gunlaw data found to be inaccurate */
drop _merge

** NB: xxgunlaw has dummies as fractions for years in which gun law was in passage 

/* Merge in police data */
// NB: I suspect "police" was meant as civilians AND uniformed employees, not just officers as per the FBI's definition of police. 
// As such I have used the total # of law enforcement employees instead of the total number of officers, 
// the latter of which did not match the dlab 2.1 police data. 

forvalues i=2001/2014 {
	merge 1:1 state year using "$input\police\police_`i'" , update
	drop _merge
}

compress

// Illinois, Louisiana, New Mexico, Utah police data in 2013 is very low, but there is no documentation on UCR's website to explain it //
// It appears that this is due to these states having much fewer agency submissions in 2013 //
// For this reason I use interpolated results for these state-year combinations //
replace police = . if year==2013 & (state=="ILLINOIS" | state=="LOUISIAN" | state=="NEW MEXI" | state=="UTAH")
bysort state: ipolate police year , gen(police_fix)

sort state year
replace police = police_fix
drop police_fix
replace xxpolice = ln(police[_n+1]/popul[_n+1]) if missing(xxpolice)

drop police

/* Merge in poverty data */
merge 1:1 state year using "$input\poverty\poverty_new", update
drop _merge

/* Merge in prisoner data */
merge 1:1 state year using "$input\prisoners\prisoners", update
drop _merge 

sort state year
replace xxprison = ln(prisoners[_n+1]/popul[_n+1]) if missing(xxprison) 
drop prisoners 

/* Update repeal */
bysort state: replace repeal = repeal[_n-1] if missing(repeal)

/* Merge in statepop_asr data*/
tofips state
merge 1:1 fips year using "$input\statepop_asr\statepop_asr_all", update
drop _merge

** interpolate 1999 values **
bysort state: ipolate a024 year , generate(a024_1999)
replace a024 = a024_1999 if year==1999
drop a024_1999

bysort state: ipolate a25p year , generate(a25p_1999)
replace a25p = a25p_1999 if year==1999
drop a25p_1999

/* Merge in unemp data */
merge 1:1 fips year using "$input\unemp\unemp_all", update replace
drop _merge

keep if year <2015 & year > 1944

******************************************************************
* Generate effective abortion rate variables, based on residence *
******************************************************************
* Abortion data only starts from 1970, so we'll add lags up till then. 
* I.e. t : 1999 - 2013, a: 8 - 43. 

replace abresrt = 0 if abresrt == . & year < 2009

* We will use the 1985 age-specific crime weights, for consistency with dlab2.1

cd $output
save "dlab 3.1.dta", replace

* Merge in the EFA weights 

infile prowt0-prowt49 using $input/efaweights/efawt_prop_new.dat, clear
save temp, replace

infile viowt0-viowt49 using $input/efaweights/efawt_viol_new.dat, clear 
merge 1:1 _n using temp
tab _merge
drop _merge
save temp, replace

infile murwt0-murwt49 using $input/efaweights/efawt_murd_new.dat, clear 
merge 1:1 _n using temp
tab _merge
drop _merge
save temp, replace

summ prowt0-prowt7 viowt0-viowt7 murwt0-murwt7
drop prowt0-prowt7 viowt0-viowt7 murwt0-murwt7

summ

expand 51

input str20 state
"ALABAMA"
"ALASKA" 
"ARIZONA" 
"ARKANSAS"  
"CALIFORN"  
"COLORADO"  
"CONNECTI"  
"DELAWARE"
"DISTRICT"  
"FLORIDA"
"GEORGIA" 
"HAWAII"
"IDAHO"
"ILLINOIS"  
"INDIANA"  
"IOWA"
"KANSAS"
"KENTUCKY"
"LOUISIAN"  
"MAINE"
"MARYLAND" 
"MASSACHU" 
"MICHIGAN" 
"MINNESOT" 
"MISSISSI" 
"MISSOURI"  
"MONTANA"
"NEBRASKA"  
"NEVADA"
"NEW HAMP" 
"NEW JERS" 
"NEW MEXI" 
"NEW YORK"
"NORTH CA" 
"NORTH DA"  
"OHIO"
"OKLAHOMA" 
"OREGON"
"PENNSYLV" 
"RHODE IS" 
"SOUTH CA" 
"SOUTH DA" 
"TENNESSE"  
"TEXAS" 
"UTAH"
"VERMONT"
"VIRGINIA" 
"WASHINGT" 
"WEST VIR" 
"WISCONSI"
"WYOMING"

label var state "string state indicator"

merge 1:m state using "dlab 3.1.dta"
drop _merge

* Drop old abortion by occurrence variables so we don't get confused

drop abort efa* 

* First regenerate the arefa variables from dlab 2.1 since we are using revised
* abresrt variables covering that time period (1970-1999). 

replace abresrt = 0 if abresrt == . & year < 1974

sort fips year
tsset fips year

local crime pro vio mur

foreach x of local crime {
	gen arefa`x' = 	L30.abresrt*`x'wt29 +		///
					L29.abresrt*`x'wt28 +    	///
                    L28.abresrt*`x'wt27 +    	///
                    L27.abresrt*`x'wt26 +    	///
                    L26.abresrt*`x'wt25 +    	///
                    L25.abresrt*`x'wt24 +    	///
                    L24.abresrt*`x'wt23 +    	///
                    L23.abresrt*`x'wt22 +    	///
                    L22.abresrt*`x'wt21 +    	///
                    L21.abresrt*`x'wt20 +    	///
                    L20.abresrt*`x'wt19 +    	///
                    L19.abresrt*`x'wt18 +    	///
                    L18.abresrt*`x'wt17 +    	///
                    L17.abresrt*`x'wt16 +    	///
                    L16.abresrt*`x'wt15 +    	///
                    L15.abresrt*`x'wt14 +    	///
                    L14.abresrt*`x'wt13 +    	///
                    L13.abresrt*`x'wt12 +    	///
                    L12.abresrt*`x'wt11 +    	///
                    L11.abresrt*`x'wt10 +    	///
                    L10.abresrt*`x'wt9  +    	///
                    L9.abresrt*`x'wt8       	///
      if year <= 1999            
}

* Generate abortion by residence EAR variables

foreach c of local crime {
	replace arefa`c' =	L50.abresrt*`c'wt49 +        	///
					L49.abresrt*`c'wt48 +        	///
					L48.abresrt*`c'wt47 +        	///
					L47.abresrt*`c'wt46 +        	///
					L46.abresrt*`c'wt45 +        	///
					L45.abresrt*`c'wt44 +        	///
					L44.abresrt*`c'wt43 +        	///
					L43.abresrt*`c'wt42 +        	///
					L42.abresrt*`c'wt41 +        	///
					L41.abresrt*`c'wt40 +        	///
					L40.abresrt*`c'wt39 +        	///
					L39.abresrt*`c'wt38 +        	///
					L38.abresrt*`c'wt37 +        	///
					L37.abresrt*`c'wt36 +        	///
					L36.abresrt*`c'wt35 +        	///
					L35.abresrt*`c'wt34 +        	///
					L34.abresrt*`c'wt33 +     		///
					L33.abresrt*`c'wt32 +     		///
					L32.abresrt*`c'wt31 +     		///
					L31.abresrt*`c'wt30 +     		///
					L30.abresrt*`c'wt29 +     		///
					L29.abresrt*`c'wt28 +    		///
					L28.abresrt*`c'wt27 +    		///
					L27.abresrt*`c'wt26 +    		///
					L26.abresrt*`c'wt25 +    		///
					L25.abresrt*`c'wt24 +    		///
					L24.abresrt*`c'wt23 +    		///
					L23.abresrt*`c'wt22 +    		///
					L22.abresrt*`c'wt21 +    		///
					L21.abresrt*`c'wt20 +    		///
					L20.abresrt*`c'wt19 +    		///
					L19.abresrt*`c'wt18 +    		///
					L18.abresrt*`c'wt17 +    		///
					L17.abresrt*`c'wt16 +    		///
					L16.abresrt*`c'wt15 +    		///
					L15.abresrt*`c'wt14 +    		///
					L14.abresrt*`c'wt13 +    		///
					L13.abresrt*`c'wt12 +    		///
					L12.abresrt*`c'wt11 +    		///
					L11.abresrt*`c'wt10 +    		///
					L10.abresrt*`c'wt9  +    		///
					L9.abresrt*`c'wt8       		///
				if year > 1999
}

replace arefamur = arefamur/100
replace arefavio = arefavio/100
replace arefapro = arefapro/100

replace arefam = arefamur 
replace arefav = arefavio 
replace arefap = arefapro 

label var arefam "EAR by res, murder (*.01), updated 6/6/2016"
label var arefav "EAR by res, vio crime (*.01), updated 6/6/2016"
label var arefap "EAR by res, prop crime (*.01), updated 6/6/2016"

* Generate migration-adjusted EAR variables from 1980 to 1999

replace abresmig = 0 if missing(abresmig) & year < 1975
replace abresmig = . if abresmig == 0 & year > 2000

foreach x of local crime {
	gen aremig`x' = L30.abresmig*`x'wt29 +		///
					L29.abresmig*`x'wt28 +    	///
                    L28.abresmig*`x'wt27 +    	///
                    L27.abresmig*`x'wt26 +    	///
                    L26.abresmig*`x'wt25 +    	///
                    L25.abresmig*`x'wt24 +    	///
                    L24.abresmig*`x'wt23 +    	///
                    L23.abresmig*`x'wt22 +    	///
                    L22.abresmig*`x'wt21 +    	///
                    L21.abresmig*`x'wt20 +    	///
                    L20.abresmig*`x'wt19 +    	///
                    L19.abresmig*`x'wt18 +    	///
                    L18.abresmig*`x'wt17 +    	///
                    L17.abresmig*`x'wt16 +    	///
                    L16.abresmig*`x'wt15 +    	///
                    L15.abresmig*`x'wt14 +    	///
                    L14.abresmig*`x'wt13 +    	///
                    L13.abresmig*`x'wt12 +    	///
                    L12.abresmig*`x'wt11 +    	///
                    L11.abresmig*`x'wt10 +    	///
                    L10.abresmig*`x'wt9  +    	///
                    L9.abresmig*`x'wt8       	///
      if year <= 1999            
}

* Generate migration-adjusted EAR variables from 2000 onwards
/* Note that this is based on abortion by residence (abresrt), 
NOT by occurence (abort) as per the original dataset */

foreach c of local crime {
	replace aremig`c' =	L50.abresmig*`c'wt49 +        	///
						L49.abresmig*`c'wt48 +        	///
						L48.abresmig*`c'wt47 +        	///
						L47.abresmig*`c'wt46 +        	///
						L46.abresmig*`c'wt45 +        	///
						L45.abresmig*`c'wt44 +        	///
						L44.abresmig*`c'wt43 +        	///
						L43.abresmig*`c'wt42 +        	///
						L42.abresmig*`c'wt41 +        	///
						L41.abresmig*`c'wt40 +        	///
						L40.abresmig*`c'wt39 +        	///
						L39.abresmig*`c'wt38 +        	///
						L38.abresmig*`c'wt37 +        	///
						L37.abresmig*`c'wt36 +        	///
						L36.abresmig*`c'wt35 +        	///
						L35.abresmig*`c'wt34 +        	///
						L34.abresmig*`c'wt33 +     		///
						L33.abresmig*`c'wt32 +     		///
						L32.abresmig*`c'wt31 +     		///
						L31.abresmig*`c'wt30 +     		///
						L30.abresmig*`c'wt29 +     		///
						L29.abresmig*`c'wt28 +    		///
						L28.abresmig*`c'wt27 +    		///
						L27.abresmig*`c'wt26 +    		///
						L26.abresmig*`c'wt25 +    		///
						L25.abresmig*`c'wt24 +    		///
						L24.abresmig*`c'wt23 +    		///
						L23.abresmig*`c'wt22 +    		///
						L22.abresmig*`c'wt21 +    		///
						L21.abresmig*`c'wt20 +    		///
						L20.abresmig*`c'wt19 +    		///
						L19.abresmig*`c'wt18 +    		///
						L18.abresmig*`c'wt17 +    		///
						L17.abresmig*`c'wt16 +    		///
						L16.abresmig*`c'wt15 +    		///
						L15.abresmig*`c'wt14 +    		///
						L14.abresmig*`c'wt13 +    		///
						L13.abresmig*`c'wt12 +    		///
						L12.abresmig*`c'wt11 +    		///
						L11.abresmig*`c'wt10 +    		///
						L10.abresmig*`c'wt9  +    		///
						L9.abresmig*`c'wt8   			///    	
				if year > 1999
}

replace aremigmur = aremigmur/100
replace aremigvio = aremigvio/100
replace aremigpro = aremigpro/100

rename aremigmur aremigm
rename aremigvio aremigv
rename aremigpro aremigp

label var aremigm "EAR by res for murder, controlling for migration"
label var aremigv "EAR by res for vio crime, controlling for migration"
label var aremigp "EAR by res for prop crime, controlling for migration"

drop *wt* arefamur arefavio arefapro

order fips, first
order aremig*, after(arefam)
order abresmig, after(abresrt)
order xxtanf15, after(xxafdc15)

label var year "numerical year indicator, 1966-2014"

drop if year < 1966 

cd $output
compress
save "dlab 3.1.dta" , replace
