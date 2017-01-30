/* ******************************************************************  
arrests.do

	Written by: Bryan Ho
	Written on: 29 April 2016
	Last modified: 29 April 2016
	
	1. Compiles the new Age/Sex/Race (ASR) data for arrests, in state levels. 
	
	2. Age groups are under 25, over 25, and individual ages 15-24.
  

******************************************************************** */      

*******************
// Preliminaries //
*******************
clear all
version 14.1
set more off

*************
// Programs *
*************
cap prog drop destring_males
program define destring_males 
	
forvalues i=18/23 {
	cap {
		destring males_`i', gen(isnumber) force /* generate indicator variable */
		drop if isnumber==.
		drop isnumber
		destring males_`i', replace
	}
}
	
end

**************
// Directory *
**************
global dir "C:\Users\bryanho\Documents\Abortion\PROCESSED\" 
global input "$dir\01_INSHEET\arrests"
global output "$input\cleaned" 
global temp "$input\temp"

***************************************
// Import the crime data, clean it up *
***************************************
/* This is less straightforward than it seems, as different lines of
data store different information in the original .dat files. Using the 
FBI's ASR Record Description we will exploit the differences in the position 
contents to delete rows that contain irrelevant information. */

local yr "99 00 01 02 03 04 05 06 07 08 09 10 11 12 13" 

foreach y of local yr {

	cd $input
	use "asr`y'" , clear 
	
	replace year = year + 2000
	replace year = year - 100 if year==2099
	
	drop fileid oricode group div msa blanks empty
	drop if missing(adultfemale) 
	drop if juvenile > 1
	drop if offensecode==0 

	destring_males

	gen state = "."
	replace state="ALASKA" if statecode==50
	replace state="ALABAMA" if statecode==1
	replace state="ARKANSAS" if statecode==3
	replace state="ARIZONA" if statecode==2
	replace state="CALIFORN" if statecode==4
	replace state="COLORADO" if statecode==5
	replace state="CONNECTI" if statecode==6
	replace state="DISTRICT" if statecode==8
	replace state="DELAWARE" if statecode==7
	replace state="FLORIDA" if statecode==9
	replace state="GEORGIA" if statecode==10
	replace state="HAWAII" if statecode==51
	replace state="IOWA" if statecode==14
	replace state="IDAHO" if statecode==11
	replace state="ILLINOIS" if statecode==12
	replace state="INDIANA" if statecode==13
	replace state="KANSAS" if statecode==15
	replace state="KENTUCKY" if statecode==16
	replace state="LOUISIAN" if statecode==17
	replace state="MASSACHU" if statecode==20
	replace state="MARYLAND" if statecode==19
	replace state="MAINE" if statecode==18
	replace state="MICHIGAN" if statecode==21
	replace state="MINNESOT" if statecode==22
	replace state="MISSOURI" if statecode==24
	replace state="MISSISSI" if statecode==23
	replace state="MONTANA" if statecode==25
	replace state="NEBRASKA" if statecode==26
	replace state="NORTH CA" if statecode==32
	replace state="NORTH DA" if statecode==33
	replace state="NEW HAMP" if statecode==28
	replace state="NEW JERS" if statecode==29
	replace state="NEW MEXI" if statecode==30
	replace state="NEVADA" if statecode==27
	replace state="NEW YORK" if statecode==31
	replace state="OHIO" if statecode==34
	replace state="OKLAHOMA" if statecode==35
	replace state="OREGON" if statecode==36
	replace state="PENNSYLV" if statecode==37
	replace state="RHODE IS" if statecode==38
	replace state="SOUTH CA" if statecode==39
	replace state="SOUTH DA" if statecode==40
	replace state="TENNESSE" if statecode==41
	replace state="TEXAS" if statecode==42
	replace state="UTAH" if statecode==43
	replace state="VIRGINIA" if statecode==45
	replace state="VERMONT" if statecode==44
	replace state="WASHINGT" if statecode==46
	replace state="WISCONSI" if statecode==48
	replace state="WEST VIR" if statecode==47
	replace state="WYOMING" if statecode==49

	cd $output
	save asr`y'_clean, replace

	*******************************************************************
	/* Compile arrest statistics by murder, violent, property crimes */
	*******************************************************************
	local sex males females
	di "`y'"
	di "hoi"
	foreach x in `sex' {
		di "`x'"
		rename `x'_10under `x'_10
		rename `x'_10to12 `x'_12
		rename `x'_13to14 `x'_14

		rename `x'_25to29 `x'_25
		rename `x'_30to34 `x'_30
		rename `x'_35to39 `x'_35
		rename `x'_40to44 `x'_40
		rename `x'_45to49 `x'_45
		rename `x'_50to54 `x'_50

		rename `x'_60to64 `x'_60
		rename `x'_64plus `x'_65
	}
	di "hoi"
	rename males_55to59 males_55
	rename females_55to60 females_55

save, replace

	*** Murder ***
	foreach x of local sex {

	/* get individual ages, sexes arrest counts */
		forvalues i=10(2)14 {		
			cd $output
			use asr`y'_clean , clear
			collapse (sum) murarr`i'_`x'=`x'_`i' if offensecode==11 , by(state year)
			cd $temp
			save asr`y'_murarr`i'_`x' , replace
		}
		
		forvalues i=15/24 { 	
			cd $output
			use asr`y'_clean , clear
			collapse (sum) murarr`i'_`x'=`x'_`i' if offensecode==11 , by(state year)
			cd $temp
			save asr`y'_murarr`i'_`x' , replace
		}
		
		forvalues i=25(5)65 {
			cd $output
			use asr`y'_clean , clear
			collapse (sum) murarr`i'_`x'=`x'_`i' if offensecode==11 , by(state year)
			cd $temp
			save asr`y'_murarr`i'_`x' , replace
		}
		
	/* compile individual ages into 2 sex-specific files */	
		use asr`y'_murarr10_`x' , clear
		forvalues i=12(2)14 {
			cd $temp
			merge 1:1 state year using asr`y'_murarr`i'_`x' , update
			drop _merge
			save asr`y'_murarr_`x'_10to14 , replace
		}
		
		use asr`y'_murarr15_`x' , clear 
		forvalues i=16/24 { 
			cd $temp
			merge 1:1 state year using asr`y'_murarr`i'_`x' , update
			drop _merge
			save asr`y'_murarr_`x'_15to24 , replace
		}
		
		use asr`y'_murarr25_`x' , clear 
		forvalues i=30(5)65 {
			cd $temp
			merge 1:1 state year using asr`y'_murarr`i'_`x' , update
			drop _merge
			save asr`y'_murarr_`x'_25to65 , replace
		}
	}

	/* compile sex-specific files into single file for each end-variable, by year */
	cd $temp		
	use asr`y'_murarr_males_15to24 , clear 
	merge 1:1 state year using asr`y'_murarr_females_15to24 , update
	drop _merge
	save asr`y'_murarr_15to24 , replace

	cd $temp
	use asr`y'_murarr_males_10to14 , clear
	merge 1:1 state year using asr`y'_murarr_females_10to14 , update
	drop _merge
	save asr`y'_murarr_10to14 , replace
	merge 1:1 state year using asr`y'_murarr_15to24 , update
	drop _merge 
	egen mur_u25 = rowtotal(murarr*)
	save asr`y'_murarr_u25 , replace 

	cd $temp
	use asr`y'_murarr_males_25to65 , clear
	merge 1:1 state year using asr`y'_murarr_females_25to65 , update
	drop _merge
	egen mur_o25 = rowtotal(murarr*)
	save asr`y'_murarr_o25 , replace


	*** Violent ***
	foreach x of local sex {

	/* get individual ages, sexes arrest counts */
		forvalues i=10(2)14 {		
			cd $output
			use asr`y'_clean , clear
			collapse (sum) vioarr`i'_`x'=`x'_`i' if offensecode==11 | offensecode==20 | offensecode==30 | offensecode==40, by(state year)
			cd $temp
			save asr`y'_vioarr`i'_`x' , replace
		}
		
		forvalues i=15/24 {		
			cd $output
			use asr`y'_clean , clear
			collapse (sum) vioarr`i'_`x'=`x'_`i' if offensecode==11 | offensecode==20 | offensecode==30 | offensecode==40, by(state year)
			cd $temp
			save asr`y'_vioarr`i'_`x' , replace		
		}
		
		forvalues i=25(5)65 {
			cd $output
			use asr`y'_clean , clear
			collapse (sum) vioarr`i'_`x'=`x'_`i' if offensecode==11 | offensecode==20 | offensecode==30 | offensecode==40, by(state year)
			cd $temp
			save asr`y'_vioarr`i'_`x' , replace
		}

	/* compile individual ages into 2 sex-specific files */
		use asr`y'_vioarr10_`x' , replace 
		forvalues i=12(2)14 { 	
			cd $temp
			merge 1:1 state year using asr`y'_vioarr`i'_`x' , update
			drop _merge
			save asr`y'_vioarr_`x'_10to14 , replace
		}
		
		use asr`y'_vioarr15_`x' , replace 
		forvalues i=16/24 { 	
			cd $temp
			merge 1:1 state year using asr`y'_vioarr`i'_`x' , update
			drop _merge
			save asr`y'_vioarr_`x'_15to24 , replace
		}
		
		use asr`y'_vioarr25_`x' , replace 
		forvalues i=30(5)65 { 	
			cd $temp
			merge 1:1 state year using asr`y'_vioarr`i'_`x' , update
			drop _merge
			save asr`y'_vioarr_`x'_25to65 , replace
		}
	}

	/* compile sex-specific files into single file for each end-variable, by year */
	cd $temp		
	use asr`y'_vioarr_males_15to24 , clear 
	merge 1:1 state year using asr`y'_vioarr_females_15to24 , update
	drop _merge
	save asr`y'_vioarr_15to24 , replace

	cd $temp
	use asr`y'_vioarr_males_10to14 , clear
	merge 1:1 state year using asr`y'_vioarr_females_10to14 , update
	drop _merge
	save asr`y'_vioarr_10to14 , replace
	merge 1:1 state year using asr`y'_vioarr_15to24 , update
	drop _merge
	egen vio_u25 = rowtotal(vioarr*)
	save asr`y'_vioarr_u25 , replace 

	cd $temp
	use asr`y'_vioarr_males_25to65 , clear
	merge 1:1 state year using asr`y'_vioarr_females_25to65 , update
	drop _merge
	egen vio_o25 = rowtotal(vioarr*)
	save asr`y'_vioarr_o25 , replace


	*** Property ***
	foreach x of local sex {	
	/* get individual ages, sexes arrest counts*/
		forvalues i=10(2)14 {		
			cd $output
			use asr`y'_clean , clear
			collapse (sum) proarr`i'_`x'=`x'_`i' if offensecode==50 | offensecode==60 | offensecode==70 | offensecode==90, by(state year)
			cd $temp
			save asr`y'_proarr`i'_`x' , replace
		}
		
		forvalues i=15/24 {
			cd $output
			use asr`y'_clean , clear
			collapse (sum) proarr`i'_`x'=`x'_`i' if offensecode==50 | offensecode==60 | offensecode==70 | offensecode==90, by(state year)
			cd $temp
			save asr`y'_proarr`i'_`x' , replace
		}
		
		forvalues i=25(5)65 {
			cd $output
			use asr`y'_clean , clear
			collapse (sum) proarr`i'_`x'=`x'_`i' if offensecode==50 | offensecode==60 | offensecode==70 | offensecode==90, by(state year)
			cd $temp
			save asr`y'_proarr`i'_`x' , replace
		}

	/* compile individual ages into 2 sex-specific files */
		use asr`y'_proarr10_`x' , replace 
		forvalues i=12(2)14 { 	
			cd $temp
			merge 1:1 state year using asr`y'_proarr`i'_`x' , update
			drop _merge
			save asr`y'_proarr_`x'_10to14 , replace
		}
		
		use asr`y'_proarr15_`x' , replace 
		forvalues i=16/24 { 
			cd $temp
			merge 1:1 state year using asr`y'_proarr`i'_`x' , update
			drop _merge
			save asr`y'_proarr_`x'_15to24 , replace
		}
		
		use asr`y'_proarr25_`x' , replace 
		forvalues i=30(5)65 { 	
			cd $temp
			merge 1:1 state year using asr`y'_proarr`i'_`x' , update
			drop _merge
			save asr`y'_proarr_`x'_25to65 , replace
		}
	}

	/* compile sex-specific files into single file for each end-variable, by year */
	cd $temp		
	use asr`y'_proarr_males_15to24 , clear 
	merge 1:1 state year using asr`y'_proarr_females_15to24 , update
	drop _merge
	save asr`y'_proarr_15to24 , replace

	cd $temp
	use asr`y'_proarr_males_10to14 , clear
	merge 1:1 state year using asr`y'_proarr_females_10to14 , update
	drop _merge
	save asr`y'_proarr_10to14 , replace
	merge 1:1 state year using asr`y'_proarr_15to24 , update
	drop _merge
	egen pro_u25 = rowtotal(proarr*)
	save asr`y'_proarr_u25 , replace 

	cd $temp
	use asr`y'_proarr_males_25to65 , clear
	merge 1:1 state year using asr`y'_proarr_females_25to65 , update
	drop _merge
	egen pro_o25 = rowtotal(proarr*)
	save asr`y'_proarr_o25 , replace

}


************************************************************
// Finally, append all the years in each dataset together //
************************************************************

local yrminusone "00 01 02 03 04 05 06 07 08 09 10 11 12 13"

*** Murder ***
// murarr_15to24 //
cd $temp
use asr99_murarr_15to24 , clear
foreach y of local yrminusone {
	append using asr`y'_murarr_15to24
}
cd $output
save murarr_15to24 , replace

// mur_u25 //
cd $temp
use asr99_murarr_u25 , clear
foreach y of local yrminusone {
	append using asr`y'_murarr_u25
}
cd $output
save murarr_u25 , replace

// mur_o25 //
cd $temp
use asr99_murarr_o25 , clear
foreach y of local yrminusone {
	append using asr`y'_murarr_o25
}
cd $output
save murarr_o25 , replace


*** Violent ***
// vioarr_15to24 //
cd $temp
use asr99_vioarr_15to24 , clear
foreach y of local yrminusone {
	append using asr`y'_vioarr_15to24
}
cd $output
save vioarr_15to24 , replace

// vio_u25 //
cd $temp
use asr99_vioarr_u25 , clear
foreach y of local yrminusone {
	append using asr`y'_vioarr_u25
}
cd $output
save vioarr_u25 , replace

// vio_o25//
cd $temp
use asr99_vioarr_o25 , clear
foreach y of local yrminusone {
	append using asr`y'_vioarr_o25
}
cd $output
save vioarr_o25 , replace


*** Property ***
// proarr_15to24 //
cd $temp
use asr99_proarr_15to24 , clear
foreach y of local yrminusone {
	append using asr`y'_proarr_15to24
}
cd $output
save proarr_15to24 , replace

// pro_u25 //
cd $temp
use asr99_proarr_u25 , clear
foreach y of local yrminusone {
	append using asr`y'_proarr_u25
}
cd $output
save proarr_u25 , replace

// pro_o25 //
cd $temp
use asr99_proarr_o25 , clear
foreach y of local yrminusone {
	append using asr`y'_proarr_o25
}
cd $output
save proarr_o25 , replace


************************
/* Combine everything */
***********************

local crime "mur vio pro"
foreach c of local crime {
	cd $output
	use `c'arr_15to24, clear
	
	merge 1:1 state year using `c'arr_u25
	drop _merge
	
	merge 1:1 state year using `c'arr_o25
	drop _merge
	save  `c', replace
}

use mur , clear
merge 1:1 state year using vio
drop _merge
merge 1:1 state year using pro
drop _merge

// Clean up variables //

foreach c of local crime {
	forvalues i=15/24 {
		gen `c'arr`i' = `c'arr`i'_males + `c'arr`i'_females 
	}
}

keep year state ???_u25 ???_o25 ???arr15 ???arr16 ???arr17 ???arr18 ???arr19 ???arr20 ???arr21 ???arr22 ???arr23 ???arr24 

cd $output
save arrests , replace
