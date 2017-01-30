/******************************************************************************
* dlabo_2016.do
*
* Written by: Bryan Ho
* Written on: 09/09/2016
* 
* This is an new version of the original Do-file written to generate the 
* analyses for Donohue & Levitt (2001), for a potential new paper describing
* the effects of abortion on crime from 1985 to the present. 
* 
* This version runs the same analysis on the new extended time period, which now
* goes all the way to 2014 (2013 for the regression analyses).
* 
* NB: Regressions should be based on time period up to 2013, as 2014 data is not 
* available for xxpolice and xxprison. 
*
* CHANGES
* - I have updated the syntax so that it will run on Stata 14. 
* - This Do-file analyses the updated "dlab 3.1" dataset, where abresrt has been
* modified due to errors found in the original dataset. 
* - The EARs have been replaced by those based on abortions by residence, 
* instead of by occurrence.
* - Coding errors in the original Do-file HAVE been corrected in this file,
except for Table 7 which is corrected in the reply to Foote & Goetz file 
(fg_final.do).
*
******************************************************************************/ 
version 14.1

*****************
* Preliminaries *
*****************

global dir "C:\Users\bryanho\Documents\Abortion\"
global input "$dir\PROCESSED\02_MERGE"
global output "$dir\ANALYSIS\2016_abortion_v_crime"

set more off

cd $output
capture log close _all
log using dlabo_2016.log, replace

/*The Impact of Legalized Abortion on Crime*/
/*John J. Donohue III and Steven D. Levitt*/
/*Tables 1-7*/
/* ************************************************************************** */

cd $output
capture log close Table_1.log
log using Table_1.log, replace name(Table_1)

/* ************************************************************************** */
								/* Table 1 */
/* ************************************************************************** */

/*Top Panel - % Changes in Crime */
/*
/*---------------*/
/*Period 1976-82*/
/*-------------*/

clear 
cd $input
use "dlab 3.1.dta"
replace year = year - 1900
keep state statenum year popul lpc_*
sort statenum year

/*Keeping the Pertinent Years*/
drop if year!=76&year!=82&year!=85

/*Creating a Variable to Weight by 1985 Population*/
gen pop85=popul if year==85
replace pop85=popul[_n+2] if year==76
replace pop85=popul[_n+1] if year==82
drop if year==85

/*Creating a dummy variable for Early Legalizers*/
gen byte earlydum=1 if statenum==2|statenum==5|statenum==12|statenum==33|statenum==48
replace earlydum=0 if earlydum==.

/*Initialize Excel Table*/
cd $output
putexcel set Table_1 , replace
putexcel A1:F1 , merge hcenter
putexcel A1="TABLE I"
putexcel A2:F2 , merge hcenter
putexcel A2="Crime Trends for States Legalizing Abortion Early versus the Rest of the United States" , txtwrap
putexcel A2:G2 , border(bottom , double)

putexcel B3:E3="Percent change in crime rate over the period" , merge hcenter border(bottom)

putexcel A4="Crime category" , hcenter
putexcel B4="1976-1982" , hcenter
putexcel C4="1982-1988" , hcenter
putexcel D4="1988-1994" , hcenter
putexcel E4="1994-1997" , hcenter
putexcel F4="Cumulative, 1982-1997" , hcenter txtwrap
putexcel G4="New period, 1997-2014" , hcenter txtwrap

putexcel A4:G4 , border(bottom)

putexcel A5="Violent crime"
putexcel A6="Early legalizers" , txtindent(1)
putexcel A7="Rest of U.S." , txtindent(1)
putexcel A8="Difference" , txtindent(1)

putexcel A10="Property crime"
putexcel A11="Early legalizers" , txtindent(1)
putexcel A12="Rest of U.S." , txtindent(1)
putexcel A13="Difference" , txtindent(1)

putexcel A15="Murder"
putexcel A16="Early legalizers" , txtindent(1)
putexcel A17="Rest of U.S." , txtindent(1)
putexcel A18="Difference" , txtindent(1)

putexcel A19:G19 , border(bottom)

putexcel A20=("Effective abortion rate at end of period"), txtwrap
putexcel A21=("Early legalizers") , txtindent(1)
putexcel A22=("Rest of U.S.") , txtindent(1)
putexcel A23=("Difference") , txtindent(1)

putexcel A23:G23 , border(bottom , double)

/*Results for Column 1*/

/*Violent Crime*/
gen violdiff=lpc_viol[_n]-lpc_viol[_n-1] if statenum==statenum[_n-1]
/*Early Legalizers*/
sum violdiff if earlydum==1 [aw=pop85]
putexcel B6=`r(mean)'*100 , nformat(#.0)
/*Rest of U.S.*/
sum violdiff if earlydum==0 [aw=pop85]
putexcel B7=`r(mean)'*100 , nformat(#.0)
/*Difference & SE*/
regress violdiff earlydum [aw=pop85] if statenum==statenum[_n-1]
putexcel B8=_b[earlydum]*100 , nformat(#.0)
putexcel B9=_se[earlydum]*100 , nformat((#.0))

/*Property Crime*/
gen propdiff=lpc_prop[_n]-lpc_prop[_n-1] if statenum==statenum[_n-1]
/*Early Legalizers*/
sum propdiff if earlydum==1 [aw=pop85]
putexcel B11=`r(mean)'*100 , nformat(#.0)
/*Rest of U.S.*/
sum propdiff if earlydum==0 [aw=pop85]
putexcel B12=`r(mean)'*100 , nformat(#.0)
/*Difference & SE*/
regress propdiff earlydum [aw=pop85] if statenum==statenum[_n-1]
putexcel B13=_b[earlydum]*100 , nformat(#.0)
putexcel B14=_se[earlydum]*100 , nformat((#.0))

/*Murder*/
gen murddiff=lpc_murd[_n]-lpc_murd[_n-1] if statenum==statenum[_n-1]
/*Early Legalizers*/
sum murddiff if earlydum==1 [aw=pop85]
putexcel B16=`r(mean)'*100 , nformat(#.0)
/*Rest of U.S.*/
sum murddiff if earlydum==0 [aw=pop85] 
putexcel B17=`r(mean)'*100 , nformat(#.0)
/*Difference & SE*/
regress murddiff earlydum [aw=pop85] if statenum==statenum[_n-1]
putexcel B18=_b[earlydum]*100 , nformat(#.0)
putexcel B19=_se[earlydum]*100 , nformat((#.0))

/*---------------*/
/*Period 1982-88*/
/*-------------*/

clear 
cd $input
use "dlab 3.1.dta"
replace year = year - 1900
keep state statenum year popul lpc_*
sort statenum year

/*Keeping the Pertinent Years*/
drop if year!=82&year!=85&year!=88

/*Creating a Variable to Weight by 1985 Population*/
gen pop85=popul if year==85
replace pop85=popul[_n+1] if year==82
replace pop85=popul[_n-1] if year==88
drop if year==85

/*Creating a dummy variable for Early Legalizers*/
gen byte earlydum=1 if statenum==2|statenum==5|statenum==12|statenum==33|statenum==48
replace earlydum=0 if earlydum==.

/*Reinitialize Excel Table*/
cd $output
putexcel set Table_1 , modify

/*Results for Column 2*/
/*Violent Crime*/
gen violdiff=lpc_viol[_n]-lpc_viol[_n-1] if statenum==statenum[_n-1]
/*Early Legalizers*/
sum violdiff if earlydum==1 [aw=pop85]
putexcel C6=`r(mean)'*100 , nformat(#.0)
/*Rest of U.S.*/
sum violdiff if earlydum==0 [aw=pop85]
putexcel C7=`r(mean)'*100 , nformat(#.0)
/*Difference & SE*/
regress violdiff earlydum [aw=pop85] if statenum==statenum[_n-1]
putexcel C8=(_b[earlydum]*100) , nformat(#.0)
putexcel C9=(_se[earlydum]*100) , nformat((#.0))

/*Property Crime*/
gen propdiff=lpc_prop[_n]-lpc_prop[_n-1] if statenum==statenum[_n-1]
/*Early Legalizers*/
sum propdiff if earlydum==1 [aw=pop85]
putexcel C11=`r(mean)'*100 , nformat(#.0)
/*Rest of U.S.*/
sum propdiff if earlydum==0 [aw=pop85]
putexcel C12=`r(mean)'*100 , nformat(#.0)
/*Difference & SE*/
regress propdiff earlydum [aw=pop85] if statenum==statenum[_n-1]
putexcel C13=(_b[earlydum]*100), nformat(#.0)
putexcel C14=(_se[earlydum]*100), nformat((#.0))

/*Murder*/
gen murddiff=lpc_murd[_n]-lpc_murd[_n-1] if statenum==statenum[_n-1]
/*Early Legalizers*/
sum murddiff if earlydum==1 [aw=pop85]
putexcel C16=`r(mean)'*100 , nformat(0.0)
/*Rest of U.S.*/
sum murddiff if earlydum==0 [aw=pop85]
putexcel C17=`r(mean)'*100 , nformat(#.0)
/*Difference & SE*/
regress murddiff earlydum [aw=pop85] if statenum==statenum[_n-1]
putexcel C18=(_b[earlydum]*100), nformat(#.0)
putexcel C19=(_se[earlydum]*100), nformat((#.0))

/*---------------*/
/*Period 1988-94*/
/*-------------*/

clear 
cd $input
use "dlab 3.1.dta"
replace year = year - 1900
keep state statenum year popul lpc_*
sort statenum year

/*Keeping the Pertinent Years*/
drop if year!=85&year!=88&year!=94

/*Creating a Variable to Weight by 1985 Population*/
gen pop85=popul if year==85
replace pop85=popul[_n-1] if year==88
replace pop85=popul[_n-2] if year==94
drop if year==85

/*Creating a dummy variable for Early Legalizers*/
gen byte earlydum=1 if statenum==2|statenum==5|statenum==12|statenum==33|statenum==48
replace earlydum=0 if earlydum==.

/*Reinitialize Excel Table*/
cd $output
putexcel set Table_1 , modify

/*Results for Column 3*/
/*Violent Crime*/
gen violdiff=lpc_viol[_n]-lpc_viol[_n-1] if statenum==statenum[_n-1]
/*Early Legalizers*/
sum violdiff if earlydum==1 [aw=pop85]
putexcel D6=`r(mean)'*100 , nformat(#.0)
/*Rest of U.S.*/
sum violdiff if earlydum==0 [aw=pop85]
putexcel D7=`r(mean)'*100 , nformat(#.0)
/*Difference & SE*/
regress violdiff earlydum [aw=pop85] if statenum==statenum[_n-1]
putexcel D8=(_b[earlydum]*100), nformat(#.0)
putexcel D9=(_se[earlydum]*100), nformat((#.0))

/*Property Crime*/
gen propdiff=lpc_prop[_n]-lpc_prop[_n-1] if statenum==statenum[_n-1]
/*Early Legalizers*/
sum propdiff if earlydum==1 [aw=pop85]
putexcel D11=`r(mean)'*100 , nformat(#.0)
/*Rest of U.S.*/
sum propdiff if earlydum==0 [aw=pop85]
putexcel D12=`r(mean)'*100 , nformat(#.0)
/*Difference & SE*/
regress propdiff earlydum [aw=pop85] if statenum==statenum[_n-1]
putexcel D13=(_b[earlydum]*100), nformat(#.0)
putexcel D14=(_se[earlydum]*100), nformat((#.0))

/*Murder*/
gen murddiff=lpc_murd[_n]-lpc_murd[_n-1] if statenum==statenum[_n-1]
/*Early Legalizers*/
sum murddiff if earlydum==1 [aw=pop85]
putexcel D16=`r(mean)'*100 , nformat(#.0)
/*Rest of U.S.*/
sum murddiff if earlydum==0 [aw=pop85]
putexcel D17=`r(mean)'*100 , nformat(#.0)
/*Difference & SE*/
regress murddiff earlydum [aw=pop85] if statenum==statenum[_n-1]
putexcel D18=(_b[earlydum]*100), nformat(#.0)
putexcel D19=(_se[earlydum]*100), nformat((#.0))

/*---------------*/
/*Period 1994-97*/
/*-------------*/

clear 
cd $input
use "dlab 3.1.dta"
replace year = year - 1900
keep state statenum year popul lpc_*
sort statenum year

/*Keeping the Pertinent Years*/
drop if year!=85&year!=94&year!=97

/*Creating a Variable to Weight by 1985 Population*/
gen pop85=popul if year==85
replace pop85=popul[_n-1] if year==94
replace pop85=popul[_n-2] if year==97
drop if year==85

/*Creating a dummy variable for Early Legalizers*/
gen byte earlydum=1 if statenum==2|statenum==5|statenum==12|statenum==33|statenum==48
replace earlydum=0 if earlydum==.

/*Reinitialize Excel Table*/
cd $output
putexcel set Table_1 , modify

/*Results for Column 4*/
/*Violent Crime*/
gen violdiff=lpc_viol[_n]-lpc_viol[_n-1] if statenum==statenum[_n-1]
/*Early Legalizers*/
sum violdiff if earlydum==1 [aw=pop85]
putexcel E6=`r(mean)'*100 , nformat(#.0)
/*Rest of U.S.*/
sum violdiff if earlydum==0 [aw=pop85]
putexcel E7=`r(mean)'*100 , nformat(#.0)
/*Difference & SE*/
regress violdiff earlydum [aw=pop85] if statenum==statenum[_n-1]
putexcel E8=(_b[earlydum]*100), nformat(#.0)
putexcel E9=(_se[earlydum]*100), nformat((#.0))

/*Property Crime*/
gen propdiff=lpc_prop[_n]-lpc_prop[_n-1] if statenum==statenum[_n-1]
/*Early Legalizers*/
sum propdiff if earlydum==1 [aw=pop85]
putexcel E11=`r(mean)'*100 , nformat(#.0)
/*Rest of U.S.*/
sum propdiff if earlydum==0 [aw=pop85]
putexcel E12=`r(mean)'*100 , nformat(#.0)
/*Difference & SE*/
regress propdiff earlydum [aw=pop85] if statenum==statenum[_n-1]
putexcel E13=(_b[earlydum]*100), nformat(#.0)
putexcel E14=(_se[earlydum]*100), nformat((#.0))

/*Murder*/
gen murddiff=lpc_murd[_n]-lpc_murd[_n-1] if statenum==statenum[_n-1]
/*Early Legalizers*/
sum murddiff if earlydum==1 [aw=pop85]
putexcel E16=`r(mean)'*100 , nformat(#.0)
/*Rest of U.S.*/
sum murddiff if earlydum==0 [aw=pop85]
putexcel E17=`r(mean)'*100 , nformat(#.0)
/*Difference & SE*/
regress murddiff earlydum [aw=pop85] if statenum==statenum[_n-1]
putexcel E18=(_b[earlydum]*100), nformat(#.0)
putexcel E19=(_se[earlydum]*100), nformat((#.0))

/*--------------------*/
/*Cumulative, 1982-97*/
/*------------------*/

clear 
cd $input
use "dlab 3.1.dta"
replace year = year - 1900
keep state statenum year popul lpc_*
sort statenum year

/*Keeping the Pertinent Years*/
drop if year!=82&year!=85&year!=97

/*Creating a Variable to Weight by 1985 Population*/
gen pop85=popul if year==85
replace pop85=popul[_n+1] if year==82
replace pop85=popul[_n-1] if year==97
drop if year==85

/*Creating a dummy variable for Early Legalizers*/
gen byte earlydum=1 if statenum==2|statenum==5|statenum==12|statenum==33|statenum==48
replace earlydum=0 if earlydum==.

/*Reinitialize Excel Table*/
cd $output
putexcel set Table_1 , modify

/*Results for Column 5*/
/*Violent Crime*/
gen violdiff=lpc_viol[_n]-lpc_viol[_n-1] if statenum==statenum[_n-1]
/*Early Legalizers*/
sum violdiff if earlydum==1 [aw=pop85]
putexcel F6=`r(mean)'*100 , nformat(#.0)
/*Rest of U.S.*/
sum violdiff if earlydum==0 [aw=pop85]
putexcel F7=`r(mean)'*100 , nformat(#.0)
/*Difference & SE*/
regress violdiff earlydum [aw=pop85] if statenum==statenum[_n-1]
putexcel F8=(_b[earlydum]*100), nformat(#.0)
putexcel F9=(_se[earlydum]*100), nformat((#.0))

/*Property Crime*/
gen propdiff=lpc_prop[_n]-lpc_prop[_n-1] if statenum==statenum[_n-1]
/*Early Legalizers*/
sum propdiff if earlydum==1 [aw=pop85]
putexcel F11=`r(mean)'*100 , nformat(#.0)
/*Rest of U.S.*/
sum propdiff if earlydum==0 [aw=pop85]
putexcel F12=`r(mean)'*100 , nformat(#.0)
/*Difference & SE*/
regress propdiff earlydum [aw=pop85] if statenum==statenum[_n-1]
putexcel F13=(_b[earlydum]*100), nformat(#.0)
putexcel F14=(_se[earlydum]*100), nformat((#.0))

/*Murder*/
gen murddiff=lpc_murd[_n]-lpc_murd[_n-1] if statenum==statenum[_n-1]
/*Early Legalizers*/
sum murddiff if earlydum==1 [aw=pop85]
putexcel F16=`r(mean)'*100 , nformat(#.0)
/*Rest of U.S.*/
sum murddiff if earlydum==0 [aw=pop85]
putexcel F17=`r(mean)'*100 , nformat(#.0)
/*Difference & SE*/
regress murddiff earlydum [aw=pop85] if statenum==statenum[_n-1]
putexcel F18=(_b[earlydum]*100), nformat(#.0)
putexcel F19=(_se[earlydum]*100), nformat((#.0))


/*---------------------*/
/*New Period 1997-2014*/
/*-------------------*/

clear 
cd $input
use "dlab 3.1.dta"
replace year = year - 1900
keep state statenum year popul lpc_*
sort statenum year

/*Keeping the Pertinent Years*/
drop if year!=97&year!=85&year!=114

/*Creating a Variable to Weight by 1985 Population*/
gen pop85=popul if year==85
replace pop85=popul[_n-1] if year==97
replace pop85=popul[_n-2] if year==114
drop if year==85

/*Creating a dummy variable for Early Legalizers*/
gen byte earlydum=1 if statenum==2|statenum==5|statenum==12|statenum==33|statenum==48
replace earlydum=0 if earlydum==.

/*Reinitialize Excel Table*/
cd $output
putexcel set Table_1 , modify

/*Results for Column 6*/
/*Violent Crime*/
gen violdiff=lpc_viol[_n]-lpc_viol[_n-1] if statenum==statenum[_n-1]
/*Early Legalizers*/
sum violdiff if earlydum==1 [aw=pop85]
putexcel G6=`r(mean)'*100 , nformat(#.0)
/*Rest of U.S.*/
sum violdiff if earlydum==0 [aw=pop85]
putexcel G7=`r(mean)'*100 , nformat(#.0)
/*Difference & SE*/
regress violdiff earlydum [aw=pop85] if statenum==statenum[_n-1]
putexcel G8=(_b[earlydum]*100), nformat(#.0)
putexcel G9=(_se[earlydum]*100), nformat((#.0))

/*Property Crime*/
gen propdiff=lpc_prop[_n]-lpc_prop[_n-1] if statenum==statenum[_n-1]
/*Early Legalizers*/
sum propdiff if earlydum==1 [aw=pop85]
putexcel G11=`r(mean)'*100 , nformat(#.0)
/*Rest of U.S.*/
sum propdiff if earlydum==0 [aw=pop85]
putexcel G12=`r(mean)'*100 , nformat(#.0)
/*Difference & SE*/
regress propdiff earlydum [aw=pop85] if statenum==statenum[_n-1]
putexcel G13=(_b[earlydum]*100), nformat(#.0)
putexcel G14=(_se[earlydum]*100), nformat((#.0))

/*Murder*/
gen murddiff=lpc_murd[_n]-lpc_murd[_n-1] if statenum==statenum[_n-1]
/*Early Legalizers*/
sum murddiff if earlydum==1 [aw=pop85]
putexcel G16=`r(mean)'*100 , nformat(#.0)
/*Rest of U.S.*/
sum murddiff if earlydum==0 [aw=pop85]
putexcel G17=`r(mean)'*100 , nformat(#.0)
/*Difference & SE*/
regress murddiff earlydum [aw=pop85] if statenum==statenum[_n-1]
putexcel G18=(_b[earlydum]*100), nformat(#.0)
putexcel G19=(_se[earlydum]*100), nformat((#.0))


/*Bottom Panel - EAR for Violent Crime at the End of the Period*/

clear 
cd $input
use "dlab 3.1.dta"
replace year = year - 1900
sort statenum year

/*Keeping only the pertinent variables*/
keep state statenum year popul arefav

/*Keeping only the pertinent years*/
drop if year!=85&year!=88&year!=94&year!=97&year!=114

/*Creating a Variable to Weight by 1985 Population*/
gen pop85=popul if year==85
replace pop85=popul[_n-1] if year==88
replace pop85=popul[_n-2] if year==94
replace pop85=popul[_n-3] if year==97
replace pop85=popul[_n-3] if year==114
drop if year==85

/*Creating a dummy variable for Early Legalizers*/
gen byte earlydum=1 if statenum==2|statenum==5|statenum==12|statenum==33|statenum==48
replace earlydum=0 if earlydum==.

/*Reinitialize Excel Table*/
cd $output
putexcel set Table_1 , modify

/*Results for Column 1*/
/*1982*/
/*I. Early Legalizers */
putexcel B21=(0.0), nformat(0.0)
/*II. Rest of U.S. */
putexcel B22=(0.0), nformat(0.0)
/*Difference*/
putexcel B23=(0.0), nformat(0.0)

/*Results for Column 2*/
/*1988*/
/*I. Early Legalizers */
sum arefav [weight=pop85] if year==88&earlydum==1
putexcel C21=`r(mean)'*100 , nformat(#.0)
/*II. Rest of U.S. */
sum arefav [weight=pop85] if year==88&earlydum==0
putexcel C22=`r(mean)'*100 , nformat(#.0)
/*Difference*/
regress arefav earlydum [aw=pop85] if year==88
putexcel C23=(_b[earlydum]*100), nformat(#.0)

/*Results for Column 3*/
/*1994*/
/*I. Early Legalizers */
sum arefav [weight=pop85] if year==94&earlydum==1
putexcel D21=`r(mean)'*100 , nformat(#.0)
/*II. Rest of U.S. */
sum arefav [weight=pop85] if year==94&earlydum==0
putexcel D22=`r(mean)'*100 , nformat(#.0)
/*Difference*/
regress arefav earlydum [aw=pop85] if year==94
putexcel D23=(_b[earlydum]*100), nformat(#.0)

/*Results for Columns 4 & 5*/
/*1997*/
/*I. Early Legalizers */
sum arefav [weight=pop85] if year==97&earlydum==1
putexcel E21=`r(mean)'*100 , nformat(#.0)
putexcel F21=`r(mean)'*100 , nformat(#.0)
/*II. Rest of U.S. */
sum arefav [weight=pop85] if year==97&earlydum==0
putexcel E22=`r(mean)'*100 , nformat(#.0)
putexcel F22=`r(mean)'*100 , nformat(#.0)
/*Difference*/
regress arefav earlydum [aw=pop85] if year==97
putexcel E23=(_b[earlydum]*100), nformat(#.0)
putexcel F23=(_b[earlydum]*100), nformat(#.0)

/*Results for Columns 6*/
/*2014*/
/*I. Early Legalizers */
sum arefav [weight=pop85] if year==114&earlydum==1
putexcel G21=`r(mean)'*100 , nformat(#.0)
/*II. Rest of U.S. */
sum arefav [weight=pop85] if year==114&earlydum==0
putexcel G22=`r(mean)'*100 , nformat(#.0)
/*Difference*/
regress arefav earlydum [aw=pop85] if year==114
putexcel G23=(_b[earlydum]*100), nformat(#.0)

log close Table_1

/* ************************************************************************** */
cd $output
capture log close Table_2
log using Table_2.log, replace name(Table_2)

/* ************************************************************************** */
								/* Table 2 */
/* ************************************************************************** */

/*Initialize Excel Table*/
cd $output
putexcel set Table_2 , replace
putexcel A1:K1=("TABLE II") , merge hcenter
putexcel A2:K2=("Crime Changes 1985-2014 as a Function of Abortion Rates 1973-???") , merge hcenter border(bottom , double)

putexcel A3:A4=("Abortion frequency (Ranked by effective abortion rate in 1997)") , merge hcenter txtwrap
putexcel B3:B4=("Effective abortions per 1000 live births, 1997") , merge hcenter txtwrap
putexcel C3:E3=("% Change in crime rate, 1973-1985") , merge hcenter txtwrap border(bottom)
putexcel F3:H3=("% Change in crime rate, 1985-1997") , merge hcenter txtwrap border(bottom)
putexcel I3:K3=("% Change in crime rate, 1997-2014") , merge hcenter txtwrap border(bottom)
putexcel C4=("Violent crime") , hcenter txtwrap
putexcel D4=("Property crime") , hcenter txtwrap
putexcel E4=("Murder") , hcenter txtwrap
putexcel F4=("Violent crime") , hcenter txtwrap
putexcel G4=("Property crime") , hcenter txtwrap
putexcel H4=("Murder") , hcenter txtwrap
putexcel I4=("Violent crime") , hcenter txtwrap
putexcel J4=("Property crime") , hcenter txtwrap
putexcel K4=("Murder") , hcenter txtwrap
putexcel A4:K4 , border(bottom)

putexcel A5=("Lowest") , hcenter
putexcel A6=("Medium") , hcenter
putexcel A7=("Highest") , hcenter
putexcel A7:K7 , border(bottom, double)

/*Column 1*/

clear
cd $input
use "dlab 3.1.dta"
replace year = year - 1900
cd $output
putexcel set Table_2 , modify

/*Keeping only the important years*/
drop if year!=85&year!=97
sort statenum year

/*Creating a Variable to Weight by 1985 Population*/
gen pop85=popul if year==85
replace pop85=popul[_n-1] if year==97
drop if year==85

/*Creating a Variable for Ranking States by Abortion Frequency*/
/*(Ranked by EAR for Violent Crime in 1997)*/

** These have been updated to reflect the new cutoff points for the updated EAR variables 
gen rank=1 if arefav<1.05
replace rank=2 if arefav>1.05&arefav<1.65
replace rank=3 if arefav>1.65

/*Results for Column 1*/
/*Generating Fixed 1985 Pop-Wt. Avg. EAR for Violent Crime in 1997*/
/*Lowest States*/
sum arefav [weight=pop85] if rank==1
putexcel B5=`r(mean)'*100, nformat(0.0)
/*Medium States*/
sum arefav [weight=pop85] if rank==2
putexcel B6=`r(mean)'*100, nformat(0.0)
/*Highest States*/
sum arefav [weight=pop85] if rank==3
putexcel B7=`r(mean)'*100, nformat(0.0)

/*Columns 2-4*/

/*1973-1985*/

clear
cd $input
use "dlab 3.1.dta"
replace year = year - 1900
cd $output
putexcel set Table_2 , modify

/*Keeping only the important years*/
drop if year!=73&year!=85&year!=97

/*Keeping only the important variables*/
keep state statenum year arefav popul lpc*
sort statenum year

/*Creating a Variable to Weight by 1985 Population*/
gen pop85=popul if year==85
replace pop85=popul[_n+1] if year==73

/*Creating a Variable for Ranking States by Abortion Frequency*/
/*(Ranked by EAR for Violent Crime in 1997)*/
gen efav97=arefav if year==97
replace efav97=arefav[_n+1] if year==85
replace efav97=arefav[_n+2] if year==73
drop if year==97
gen rank=1 if efav97<1.05
replace rank=2 if efav97>1.05&efav97<1.65
replace rank=3 if efav97>1.65

/*Results for Column 2*/
/*Violent Crime*/
gen violdiff=lpc_viol[_n]-lpc_viol[_n-1] if statenum==statenum[_n-1]
/*Lowest*/
sum violdiff if rank==1 [aw=pop85]
putexcel C5=`r(mean)'*100, nformat(+ 0.0)
/*Medium*/
sum violdiff if rank==2 [aw=pop85]
putexcel C6=`r(mean)'*100, nformat(+ 0.0)
/*Highest*/
sum violdiff if rank==3 [aw=pop85]
putexcel C7=`r(mean)'*100, nformat(+ 0.0)

/*Results for Column 3*/
/*Property Crime*/
gen propdiff=lpc_prop[_n]-lpc_prop[_n-1] if statenum==statenum[_n-1]
/*Lowest*/
sum propdiff if rank==1 [aw=pop85]
putexcel D5=`r(mean)'*100, nformat(+ 0.0)
/*Medium*/
sum propdiff if rank==2 [aw=pop85]
putexcel D6=`r(mean)'*100, nformat(+ 0.0)
/*Highest*/
sum propdiff if rank==3 [aw=pop85]
putexcel D7=`r(mean)'*100, nformat(+ 0.0)

/*Results for Column 4*/
/*Murder*/
gen murddiff=lpc_murd[_n]-lpc_murd[_n-1] if statenum==statenum[_n-1]
/*Lowest*/
sum murddiff if rank==1 [aw=pop85]
putexcel E5=`r(mean)'*100, nformat(0.0)
/*Medium*/
sum murddiff if rank==2 [aw=pop85]
putexcel E6=`r(mean)'*100, nformat(0.0)
/*Highest*/
sum murddiff if rank==3 [aw=pop85]
putexcel E7=`r(mean)'*100, nformat(0.0)

/*Columns 5-7*/

/*1985-1997*/

clear
cd $input
use "dlab 3.1.dta"
replace year = year - 1900
cd $output
putexcel set Table_2 , modify

/*Keeping only the important years*/
drop if year!=85&year!=97

/*Keeping only the important variables*/
keep state statenum year arefav popul lpc*
sort statenum year

/*Creating a Variable to Weight by 1985 Population*/
gen pop85=popul if year==85
replace pop85=popul[_n-1] if year==97

/*Creating a Variable for Ranking States by Abortion Frequency*/
/*(Ranked by EAR for Violent Crime in 1997)*/
gen efav97=arefav if year==97
replace efav97=arefav[_n+1] if year==85
gen rank=1 if efav97<1.05
replace rank=2 if efav97>1.05&efav97<1.65
replace rank=3 if efav97>1.65

/*Results for Column 5*/
/*Violent Crime*/
gen violdiff=lpc_viol[_n]-lpc_viol[_n-1] if statenum==statenum[_n-1]
/*Lowest*/
sum violdiff if rank==1 [aw=pop85]
putexcel F5=`r(mean)'*100, nformat(+ 0.0)
/*Medium*/
sum violdiff if rank==2 [aw=pop85]
putexcel F6=`r(mean)'*100, nformat(+ 0.0)
/*Highest*/
sum violdiff if rank==3 [aw=pop85]
putexcel F7=`r(mean)'*100, nformat(0.0)

/*Results for Column 6*/
/*Property Crime*/
gen propdiff=lpc_prop[_n]-lpc_prop[_n-1] if statenum==statenum[_n-1]
/*Lowest*/
sum propdiff if rank==1 [aw=pop85]
putexcel G5=`r(mean)'*100, nformat(+ 0.0)
/*Medium*/
sum propdiff if rank==2 [aw=pop85]
putexcel G6=`r(mean)'*100, nformat(+ 0.0)
/*Highest*/
sum propdiff if rank==3 [aw=pop85]
putexcel G7=`r(mean)'*100, nformat(0.0)

/*Results for Column 7*/
/*Murder*/
gen murddiff=lpc_murd[_n]-lpc_murd[_n-1] if statenum==statenum[_n-1]
/*Lowest*/
sum murddiff if rank==1 [aw=pop85]
putexcel H5=`r(mean)'*100, nformat(+ 0.0)
/*Medium*/
sum murddiff if rank==2 [aw=pop85]
putexcel H6=`r(mean)'*100, nformat(0.0)
/*Highest*/
sum murddiff if rank==3 [aw=pop85]
putexcel H7=`r(mean)'*100, nformat(0.0)


/*New Columns 8-10*/

/*1997-2014*/

clear
cd $input
use "dlab 3.1.dta"
replace year = year - 1900
cd $output
putexcel set Table_2 , modify

/*Keeping only the important years*/
drop if year!=85&year!=97&year!=114

/*Keeping only the important variables*/
keep state statenum year arefav popul lpc*
sort statenum year

/*Creating a Variable to Weight by 1985 Population*/
gen pop85=popul if year==85
replace pop85=popul[_n-1] if year==97
replace pop85=popul[_n-2] if year==114
drop if year==85

/*Creating a Variable for Ranking States by Abortion Frequency*/
/*(Ranked by EAR for Violent Crime in 1997)*/
gen efav97=arefav if year==97
replace efav97=arefav[_n-1] if year==114
gen rank=1 if efav97<1.05
replace rank=2 if efav97>1.05&efav97<1.65
replace rank=3 if efav97>1.65

/*Results for Column 8*/
/*Violent Crime*/
gen violdiff=lpc_viol[_n]-lpc_viol[_n-1] if statenum==statenum[_n-1]
/*Lowest*/
sum violdiff if rank==1 [aw=pop85]
putexcel I5=`r(mean)'*100, nformat(0.0)
/*Medium*/
sum violdiff if rank==2 [aw=pop85]
putexcel I6=`r(mean)'*100, nformat(0.0)
/*Highest*/
sum violdiff if rank==3 [aw=pop85]
putexcel I7=`r(mean)'*100, nformat(0.0)

/*Results for Column 9*/
/*Property Crime*/
gen propdiff=lpc_prop[_n]-lpc_prop[_n-1] if statenum==statenum[_n-1]
/*Lowest*/
sum propdiff if rank==1 [aw=pop85]
putexcel J5=`r(mean)'*100, nformat(0.0)
/*Medium*/
sum propdiff if rank==2 [aw=pop85]
putexcel J6=`r(mean)'*100, nformat(0.0)
/*Highest*/
sum propdiff if rank==3 [aw=pop85]
putexcel J7=`r(mean)'*100, nformat(0.0)

/*Results for Column 10*/
/*Murder*/
gen murddiff=lpc_murd[_n]-lpc_murd[_n-1] if statenum==statenum[_n-1]
/*Lowest*/
sum murddiff if rank==1 [aw=pop85]
putexcel K5=`r(mean)'*100, nformat(0.0)
/*Medium*/
sum murddiff if rank==2 [aw=pop85]
putexcel K6=`r(mean)'*100, nformat(0.0)
/*Highest*/
sum murddiff if rank==3 [aw=pop85]
putexcel K7=`r(mean)'*100, nformat(0.0)

log close Table_2

/* ************************************************************************** */
cd $output
capture log close Table_3
log using Table_3.log, replace name(Table_3)
/* ************************************************************************** */

/* Table 3 */

clear
cd $input
use "dlab 3.1.dta"
replace year = year - 1900

/*Initialize Excel Table*/
cd $output
putexcel set Table_3 , replace

putexcel A1:D1="TABLE III" , merge hcenter 
putexcel A2:D2="Summary Statistics" , merge hcenter border(bottom, double)
putexcel A3="Variable" B3="Mean" C3="Standard deviation (overall)" ///
	D3="Standard deviation (within state)" , hcenter txtwrap border(bottom)

putexcel 	A4="Violent crime per 1000 residents" ///
			A5="Property crime per 1000 residents" ///
			A6="Murder per 1000 residents" 
putexcel	A7="Effective abortion rate per 1000 live births by crime: " , txtwrap
putexcel 	A8="Violent crime" ///
			A9="Property crime" ///
			A10="Murder" , txtindent(1)
putexcel	A11="Prisoners per 1000 residents" ///
			A12="Police per 1000 residents" 
putexcel	A13="State personal income per capita (current $ unadj)" ///
			A14="AFDC generosity per recipient family (t-15)" ///
			A15="State unemployment rate (percent unemployed)" ///
			A16="Beer shipments per capita" ///
			A17="Poverty rate (percent below poverty level)" ///
			A18="Violent crime arrests per 1000, under age 25" ///
			A19="Property crime arrests per 1000, under age 25" ///
			A20="Murder arrests per 1000, under age 25" ///
			A21="Violent crime arrests per 1000, age 25 and over" ///
			A22="Property crime arrests per 1000, age 25 and over" ///
			A23="Murder arrests per 1000, age 25 and over" , txtwrap
putexcel A23:D23 , border(bottom, double)

/*Make summary statistics*/
gen popul15=popul[_n-15] if statenum==statenum[_n-15]
gen viol=exp(lpc_viol)
gen prop=exp(lpc_prop)
gen murd=exp(lpc_murd)
replace arefav=arefav*100
replace arefap=arefap*100
replace arefam=arefam*100
gen pris=exp(xxprison)
gen police=exp(xxpolice)
gen income=exp(xxincome) 
gen afdc15=xxafdc15
gen unemp=xxunemp*100
gen beer=xxbeer
gen pover=xxpover
gen muro25=(mur_o25)
gen vioo25=(vio_o25)
gen proo25=(pro_o25)
gen aavu25=vio_u25*(1000/a024)
gen aapu25=pro_u25*(1000/a024)
gen aamu25=mur_u25*(1000/a024)
gen aavo25=vioo25*(1000/a25p)
gen aapo25=proo25*(1000/a25p)
gen aamo25=muro25*(1000/a25p)

keep if year>84 & year<114

/* Results for Columns 1 & 2 */
estpost sum viol-murd [aw=popul]
matrix mean=e(mean)' 
matrix sd=e(sd)'
putexcel B4=matrix(mean), nformat(number_d2)
putexcel C4=matrix(sd), nformat(number_d2)

estpost sum arefav arefap arefam pris-income [aw=popul]
matrix mean=e(mean)' 
matrix sd=e(sd)'
putexcel B8=matrix(mean), nformat(number_d2)
putexcel C8=matrix(sd), nformat(number_d2)

/* for afdc15, weight by popul15 to take into account 15 year lag */
estpost sum afdc15 [aw=popul15]
matrix mean=e(mean)' 
matrix sd=e(sd)'
putexcel B14=matrix(mean), nformat(number_d2)
putexcel C14=matrix(sd), nformat(number_d2)

estpost sum unemp-pover aa* [aw=popul]
matrix mean=e(mean)' 
matrix sd=e(sd)'
putexcel B15=matrix(mean), nformat(number_d2)
putexcel C15=matrix(sd), nformat(number_d2)

/* calculating standard deviations within state */ 
gen rrviol=viol 
gen rrprop=prop
gen rrmurd=murd
gen rrefav=arefav
gen rrefap=arefap
gen rrefam=arefam
gen rrpris=pris
gen rrpolice=police
gen rrincome=income
gen rrafdc15=afdc15
gen rrunemp=unemp
gen rrbeer=beer
gen rrpover=pover
gen rrvu25=aavu25
gen rrpu25=aapu25
gen rrmu25=aamu25
gen rrvo25=aavo25
gen rrpo25=aapo25
gen rrmo25=aamo25

for var rr* \ new nn1-nn19: egen Y=mean(X), by(statenum)
for var nn* \ var rr*: replace Y=Y-X

/* Results for Column 3 */
estpost sum rrviol-rrmurd [aw=popul]
matrix sd=e(sd)'
putexcel D4=matrix(sd), nformat(number_d2)

estpost sum rrefav rrefap rrefam rrpris-rrincome [aw=popul]
matrix sd=e(sd)'
putexcel D8=matrix(sd), nformat(number_d2)

/* for afdc15, weight by popul15 to take into account 15 year lag */
estpost sum rrafdc15 [aw=popul15]
matrix sd=e(sd)'
putexcel D14=matrix(sd), nformat(number_d2)

estpost sum rrunemp-rrpover rr??25 [aw=popul]
matrix sd=e(sd)'
putexcel D15=matrix(sd), nformat(number_d2)

log close Table_3
*/
/* ************************************************************************** */
cd $output
capture log close Table_4
log using Table_4.log, replace name(Table_4)
/* ************************************************************************** */

/* Table 4 */
* Remember: xxprison & xxpolice only run until 2013!!!
clear
cd $input
use "dlab 3.1.dta"
replace year = year - 1900
keep if year>65 
drop xxtanf15

tab year, gen(yy) nof
tab statenum, gen(ss) nof

gen txprison=xxprison
gen txpolice=xxpolice
gen txunemp=xxunemp
gen txincome=xxincome
gen txpover=xxpover
replace xxafdc15=xxafdc15*1000
gen txafdc=xxafdc15
gen txgunlaw=xxgunlaw
gen txbeer=xxbeer

cd $output
/*
/* Column 1*/
regress lpc_viol arefav yy* ss* [aw=popul], robust 
predict resid, resid
sort statenum year
generate resid1=resid[_n-1] if statenum==statenum[_n-1]&year>84&year<114
generate resid1sq=(resid-resid1)^2
generate residsq=resid^2 if year>84&year<114
egen residnum=sum(resid1sq) if year>84&year<114
egen residden=sum(residsq) if year>84&year<114
generate rho=1-(residnum/residden)/2
sort statenum year
for var lpc_viol arefav yy* ss*  \ new tpc_viol tefa tyy1-tyy49 tss1-tss51 : generate Y=X-rho*X[_n-1]
for var lpc_viol arefav yy* ss* xx* \ var tpc_viol tefa tyy1-tyy49 tss1-tss51 tx*: replace Y=X*(1-rho^2)^.5 if year==85
regress tpc_viol tefa tyy* tss* [aw=popul], robust
outreg , keep(tefa) se summstat(r2) nocons nostars ///
	title("TABLE IV"\"Panel-data Estimates of the Relationship between Abortion Rates and Crime") ///
	ctitles("","ln(Violent crime per capita)"\"Variable","(1)")  ///
	rtitles("Effective abortion rate "\ ///
			" (x 100)"\ ///
			"ln(prisoners per capita) "\ ///
			" (t - 1)"\ ///
			"ln(police per capita)  "\ ///
			" (t - 1)"\ ///
			"State unemployment rate "\ ///
			" (percent unemployed)"\ ///
			"ln(state income per"\ ///
			" capita)"\ ///
			"Poverty rate (percent "\ ///
			" below poverty line)"\ ///
			"AFDC generosity "\ ///
			" (t - 15) (x1000)"\ ///
			"Shall-issue concealed"\ ///
			" weapons law"\ ///
			"Beer shipments per"\ ///
			" capita") 
			 
drop tpc* tefa* tyy* tss* resid* rho

/* Column 2 */
regress lpc_viol arefav xx*  yy* ss* [aw=popul], robust 
predict resid, resid
sort statenum year
generate resid1=resid[_n-1] if statenum==statenum[_n-1]&year>84&year<114
generate resid1sq=(resid-resid1)^2
generate residsq=resid^2 if year>84&year<114
egen residnum=sum(resid1sq) if year>84&year<114
egen residden=sum(residsq) if year>84&year<114
generate rho=1-(residnum/residden)/2
sort statenum year
for var lpc_viol arefav yy* ss*  \ new tpc_viol tefa tyy1-tyy49 tss1-tss51 : generate Y=X-rho*X[_n-1]
for var xx* \ var tx*: replace Y=X-rho*X[_n-1]
for var lpc_viol arefav yy* ss* xx* \ var tpc_viol tefa tyy1-tyy49 tss1-tss51 tx*: replace Y=X*(1-rho^2)^.5 if year==85
regress tpc_viol tefa tx* tyy* tss* [aw=popul], robust
outreg, keep(tefa txprison txpolice txunemp txincome txpover txafdc txgunlaw txbeer) se summstat(r2) nocons nostars ///
	ctitles("",""\"","(2)") multicol(1,2,2) ///
	rtitles("Effective abortion rate "\ ///
			" (x 100)"\ ///
			"ln(prisoners per capita) "\ ///
			" (t - 1)"\ ///
			"ln(police per capita)  "\ ///
			" (t - 1)"\ ///
			"State unemployment rate "\ ///
			" (percent unemployed)"\ ///
			"ln(state income per"\ ///
			" capita)"\ ///
			"Poverty rate (percent "\ ///
			" below poverty line)"\ ///
			"AFDC generosity "\ ///
			" (t - 15) (x1000)"\ ///
			"Shall-issue concealed"\ ///
			" weapons law"\ ///
			"Beer shipments per"\ ///
			" capita") ///
			merge 			
drop tpc* tefa* tyy* tss* resid* rho

/* Column 3 */
regress lpc_prop arefap yy* ss* [aw=popul], robust 
predict resid, resid
sort statenum year
generate resid1=resid[_n-1] if statenum==statenum[_n-1]&year>84&year<114
generate resid1sq=(resid-resid1)^2
generate residsq=resid^2 if year>84&year<114
egen residnum=sum(resid1sq) if year>84&year<114
egen residden=sum(residsq) if year>84&year<114
generate rho=1-(residnum/residden)/2
sort statenum year
for var lpc_prop arefap yy* ss*  \ new tpc_prop tefa tyy1-tyy49 tss1-tss51 : generate Y=X-rho*X[_n-1]
for var lpc_prop arefap yy* ss* xx* \ var tpc_prop tefa tyy1-tyy49 tss1-tss51 tx*: replace Y=X*(1-rho^2)^.5 if year==85
regress tpc_prop tefa tyy* tss* [aw=popul], robust
outreg , keep(tefa) se summstat(r2) nocons nostars ///
	ctitles("","ln(Property crime per capita)"\"","(3)")  ///
	rtitles("Effective abortion rate "\ ///
			" (x 100)"\ ///
			"ln(prisoners per capita) "\ ///
			" (t - 1)"\ ///
			"ln(police per capita)  "\ ///
			" (t - 1)"\ ///
			"State unemployment rate "\ ///
			" (percent unemployed)"\ ///
			"ln(state income per"\ ///
			" capita)"\ ///
			"Poverty rate (percent "\ ///
			" below poverty line)"\ ///
			"AFDC generosity "\ ///
			" (t - 15) (x1000)"\ ///
			"Shall-issue concealed"\ ///
			" weapons law"\ ///
			"Beer shipments per"\ ///
			" capita") ///
			merge 
drop tpc* tefa* tyy* tss* resid* rho

/* Column 4 */
regress lpc_prop arefap xx*  yy* ss* [aw=popul], robust 
predict resid, resid
sort statenum year
generate resid1=resid[_n-1] if statenum==statenum[_n-1]&year>84&year<114
generate resid1sq=(resid-resid1)^2
generate residsq=resid^2 if year>84&year<114
egen residnum=sum(resid1sq) if year>84&year<114
egen residden=sum(residsq) if year>84&year<114
generate rho=1-(residnum/residden)/2
sort statenum year
for var lpc_prop arefap yy* ss*  \ new tpc_prop tefa tyy1-tyy49 tss1-tss51 : generate Y=X-rho*X[_n-1]
for var xx* \ var tx*: replace Y=X-rho*X[_n-1]
for var lpc_prop arefap yy* ss* xx* \ var tpc_prop tefa tyy1-tyy49 tss1-tss51 tx*: replace Y=X*(1-rho^2)^.5 if year==85
regress tpc_prop tefa tx* tyy* tss* [aw=popul], robust
outreg , keep(tefa txprison txpolice txunemp txincome txpover txafdc txgunlaw txbeer) se summstat(r2) nocons nostars ///
	ctitles("",""\"","(4)") multicol(1,2,2;1,4,2) ///
	rtitles("Effective abortion rate "\ ///
			" (x 100)"\ ///
			"ln(prisoners per capita) "\ ///
			" (t - 1)"\ ///
			"ln(police per capita)  "\ ///
			" (t - 1)"\ ///
			"State unemployment rate "\ ///
			" (percent unemployed)"\ ///
			"ln(state income per"\ ///
			" capita)"\ ///
			"Poverty rate (percent "\ ///
			" below poverty line)"\ ///
			"AFDC generosity "\ ///
			" (t - 15) (x1000)"\ ///
			"Shall-issue concealed"\ ///
			" weapons law"\ ///
			"Beer shipments per"\ ///
			" capita") ///
			merge  
drop tpc* tefa* tyy* tss* resid* rho

/* Column 5 */
regress lpc_murd arefam yy* ss* [aw=popul], robust 
predict resid, resid
sort statenum year
generate resid1=resid[_n-1] if statenum==statenum[_n-1]&year>84&year<114
generate resid1sq=(resid-resid1)^2
generate residsq=resid^2 if year>84&year<114
egen residnum=sum(resid1sq) if year>84&year<114
egen residden=sum(residsq) if year>84&year<114
generate rho=1-(residnum/residden)/2
sort statenum year
for var lpc_murd arefam yy* ss*  \ new tpc_murd tefa tyy1-tyy49 tss1-tss51 : generate Y=X-rho*X[_n-1]
for var lpc_murd arefam yy* ss* xx* \ var tpc_murd tefa tyy1-tyy49 tss1-tss51 tx*: replace Y=X*(1-rho^2)^.5 if year==85
regress tpc_murd tefa tyy* tss*  [aw=popul], robust
outreg , keep(tefa) se summstat(r2) nocons nostars ///
	ctitles("","ln(Murder per capita)"\"","(5)")  ///
	rtitles("Effective abortion rate "\ ///
			" (x 100)"\ ///
			"ln(prisoners per capita) "\ ///
			" (t - 1)"\ ///
			"ln(police per capita)  "\ ///
			" (t - 1)"\ ///
			"State unemployment rate "\ ///
			" (percent unemployed)"\ ///
			"ln(state income per"\ ///
			" capita)"\ ///
			"Poverty rate (percent "\ ///
			" below poverty line)"\ ///
			"AFDC generosity "\ ///
			" (t - 15) (x1000)"\ ///
			"Shall-issue concealed"\ ///
			" weapons law"\ ///
			"Beer shipments per"\ ///
			" capita") ///
			merge 
drop tpc* tefa* tyy* tss* resid* rho

/* Column 6 */
regress lpc_murd arefam xx*  yy* ss* [aw=popul], robust 
predict resid, resid
sort statenum year
generate resid1=resid[_n-1] if statenum==statenum[_n-1]&year>84&year<114
generate resid1sq=(resid-resid1)^2
generate residsq=resid^2 if year>84&year<114
egen residnum=sum(resid1sq) if year>84&year<114
egen residden=sum(residsq) if year>84&year<114
generate rho=1-(residnum/residden)/2
sort statenum year
for var lpc_murd arefam yy* ss*  \ new tpc_murd tefa tyy1-tyy49 tss1-tss51 : generate Y=X-rho*X[_n-1]
for var xx* \ var tx*: replace Y=X-rho*X[_n-1]
for var lpc_murd arefam yy* ss* xx* \ var tpc_murd tefa tyy1-tyy49 tss1-tss51 tx*: replace Y=X*(1-rho^2)^.5 if year==85
regress tpc_murd tefa tx* tyy* tss*  [aw=popul], robust
outreg using Table_4, keep(tefa txprison txpolice txunemp txincome txpover txafdc txgunlaw txbeer) se summstat(r2) nocons nostars ///
	ctitles("",""\"","(6)") multicol(1,2,2;1,4,2;1,6,2) coljust(lcccccc) ///
	rtitles("Effective abortion rate "\ ///
			" (x 100)"\ ///
			"ln(prisoners per capita) "\ ///
			" (t - 1)"\ ///
			"ln(police per capita)  "\ ///
			" (t - 1)"\ ///
			"State unemployment rate "\ ///
			" (percent unemployed)"\ ///
			"ln(state income per"\ ///
			" capita)"\ ///
			"Poverty rate (percent "\ ///
			" below poverty line)"\ ///
			"AFDC generosity "\ ///
			" (t - 15) (x1000)"\ ///
			"Shall-issue concealed"\ ///
			" weapons law"\ ///
			"Beer shipments per"\ ///
			" capita") ///
			hlines(1{0};1{0};{0};1{0}1) hlstyle(d{};s{}s;{};s{}d) ///
			merge replace
drop tpc* tefa* tyy* tss* resid* rho

log close Table_4

/* ************************************************************************** */
cd $output
capture log close Table_5
log using Table_5.log, replace name(Table_5)
/* ************************************************************************** */

/* Table 5 */

/* Rows 1-5, 10-12 */

/* Column 1 */

regress lpc_viol arefav xx*  yy* ss* [aw=popul], robust 
predict resid, resid
sort statenum year
generate resid1=resid[_n-1] if statenum==statenum[_n-1]&year>84&year<114
generate resid1sq=(resid-resid1)^2
generate residsq=resid^2 if year>84&year<114
egen residnum=sum(resid1sq) if year>84&year<114
egen residden=sum(residsq) if year>84&year<114
generate rho=1-(residnum/residden)/2
sort statenum year
for var lpc_viol arefav yy* ss*  \ new tpc_viol tefa tyy1-tyy49 tss1-tss51 : generate Y=X-rho*X[_n-1]
for var xx* \ var tx*: replace Y=X-rho*X[_n-1]
for var lpc_viol arefav yy* ss* xx* \ var tpc_viol tefa tyy1-tyy49 tss1-tss51 tx*: replace Y=X*(1-rho^2)^.5 if year==85
/* Results for Column 1 */
**1. baseline
regress tpc_viol tefa tx* tyy* tss* [aw=popul], robust
**2. drop NY
regress tpc_viol tefa tx* tyy* tss* [aw=popul] if statenum!=33, robust
**3. drop CA
regress tpc_viol tefa tx* tyy* tss* [aw=popul] if statenum!=5, robust
**4. drop DC
regress tpc_viol tefa tx* tyy* tss* [aw=popul] if statenum!=9, robust
**5. drop NY, CA, DC
regress tpc_viol tefa tx* tyy* tss* [aw=popul] if statenum!=33&statenum!=5&statenum!=9, robust
**10. unweighted
regress tpc_viol tefa tx* tyy* tss* , robust
**11. unweighted, drop DC
regress tpc_viol tefa tx* tyy* tss* if statenum!=9, robust
**12. unweighted, drop DC, CA, NY
regress tpc_viol tefa tx* tyy* tss* if statenum!=33&statenum!=5&statenum!=9, robust

drop tpc* tefa* tyy* tss* resid* rho

/* Column 2 */

regress lpc_prop arefap xx*  yy* ss* [aw=popul], robust 
predict resid, resid
sort statenum year
generate resid1=resid[_n-1] if statenum==statenum[_n-1]&year>84&year<114
generate resid1sq=(resid-resid1)^2
generate residsq=resid^2 if year>84&year<114
egen residnum=sum(resid1sq) if year>84&year<114
egen residden=sum(residsq) if year>84&year<114
generate rho=1-(residnum/residden)/2
sort statenum year
for var lpc_prop arefap yy* ss*  \ new tpc_prop tefa tyy1-tyy49 tss1-tss51 : generate Y=X-rho*X[_n-1]
for var xx* \ var tx*: replace Y=X-rho*X[_n-1]
for var lpc_prop arefap yy* ss* xx* \ var tpc_prop tefa tyy1-tyy49 tss1-tss51 tx*: replace Y=X*(1-rho^2)^.5 if year==85
/* Results for Column 2 */
**1. baseline
regress tpc_prop tefa tx* tyy* tss* [aw=popul], robust
**2. drop NY
regress tpc_prop tefa tx* tyy* tss* [aw=popul] if statenum!=33, robust
**3. drop CA
regress tpc_prop tefa tx* tyy* tss* [aw=popul] if statenum!=5, robust
**4. drop DC
regress tpc_prop tefa tx* tyy* tss* [aw=popul] if statenum!=9, robust
**5. drop NY, CA, DC
regress tpc_prop tefa tx* tyy* tss* [aw=popul] if statenum!=33 & statenum!=5 & statenum!=9, robust
**10. unweighted
regress tpc_prop tefa tx* tyy* tss* , robust
**11. unweighted, drop DC
regress tpc_prop tefa tx* tyy* tss* if statenum!=9, robust
**12. unweighted, drop DC CA, NY
regress tpc_prop tefa tx* tyy* tss* if statenum!=33&statenum!=5&statenum!=9, robust

drop tpc* tefa* tyy* tss* resid* rho

/* Column 3 */

regress lpc_murd arefam xx*  yy* ss* [aw=popul], robust 
predict resid, resid
sort statenum year
generate resid1=resid[_n-1] if statenum==statenum[_n-1]&year>84&year<114
generate resid1sq=(resid-resid1)^2
generate residsq=resid^2 if year>84&year<114
egen residnum=sum(resid1sq) if year>84&year<114
egen residden=sum(residsq) if year>84&year<114
generate rho=1-(residnum/residden)/2
sort statenum year
for var lpc_murd arefam yy* ss*  \ new tpc_murd tefa tyy1-tyy49 tss1-tss51 : generate Y=X-rho*X[_n-1]
for var xx* \ var tx*: replace Y=X-rho*X[_n-1]
for var lpc_murd arefam yy* ss* xx* \ var tpc_murd tefa tyy1-tyy49 tss1-tss51 tx*: replace Y=X*(1-rho^2)^.5 if year==85
/* Results for Column 3 */
**1. baseline
regress tpc_murd tefa tx* tyy* tss* [aw=popul], robust
**2. drop NY
regress tpc_murd tefa tx* tyy* tss* [aw=popul] if statenum!=33, robust
**3. drop CA
regress tpc_murd tefa tx* tyy* tss* [aw=popul] if statenum!=5, robust
**4. drop DC
regress tpc_murd tefa tx* tyy* tss* [aw=popul] if statenum!=9, robust
**5. drop NY, CA, DC
regress tpc_murd tefa tx* tyy* tss* [aw=popul] if statenum!=33&statenum!=5&statenum!=9, robust
**10. unweighted
regress tpc_murd tefa tx* tyy* tss* , robust
**11. unweighted, drop DC
regress tpc_murd tefa tx* tyy* tss* if statenum!=9, robust
**12. unweighted, drop DC, CA, NY
regress tpc_murd tefa tx* tyy* tss* if statenum!=33&statenum!=5&statenum!=9, robust

drop tpc* tefa* tyy* tss* resid* rho


/* Row 6: Adjust "effective" abortion rate for X-state mobility */

/* Column 1 */
regress lpc_viol aremigv xx*  yy* ss* [aw=popul], robust 
predict resid, resid
sort statenum year
generate resid1=resid[_n-1] if statenum==statenum[_n-1]&year>84&year<114
generate resid1sq=(resid-resid1)^2
generate residsq=resid^2 if year>84&year<114
egen residnum=sum(resid1sq) if year>84&year<114
egen residden=sum(residsq) if year>84&year<114
generate rho=1-(residnum/residden)/2
sort statenum year
for var lpc_viol aremigv yy* ss*  \ new tpc_viol tefa tyy1-tyy49 tss1-tss51 : generate Y=X-rho*X[_n-1]
for var xx* \ var tx*: replace Y=X-rho*X[_n-1]
for var lpc_viol aremigv yy* ss* xx* \ var tpc_viol tefa tyy1-tyy49 tss1-tss51 tx*: replace Y=X*(1-rho^2)^.5 if year==85
regress tpc_viol tefa tx* tyy* tss* [aw=popul], robust
drop tpc* tefa* tyy* tss* resid* rho

/* Column 2 */
regress lpc_prop aremigp xx*  yy* ss* [aw=popul], robust 
predict resid, resid
sort statenum year
generate resid1=resid[_n-1] if statenum==statenum[_n-1]&year>84&year<114
generate resid1sq=(resid-resid1)^2
generate residsq=resid^2 if year>84&year<114
egen residnum=sum(resid1sq) if year>84&year<114
egen residden=sum(residsq) if year>84&year<114
generate rho=1-(residnum/residden)/2
sort statenum year
for var lpc_prop aremigp yy* ss*  \ new tpc_prop tefa tyy1-tyy49 tss1-tss51 : generate Y=X-rho*X[_n-1]
for var xx* \ var tx*: replace Y=X-rho*X[_n-1]
for var lpc_prop aremigp yy* ss* xx* \ var tpc_prop tefa tyy1-tyy49 tss1-tss51 tx*: replace Y=X*(1-rho^2)^.5 if year==85
regress tpc_prop tefa tx* tyy* tss* [aw=popul], robust
drop tpc* tefa* tyy* tss* resid* rho

/* Column 3 */
regress lpc_murd aremigm xx*  yy* ss* [aw=popul], robust 
predict resid, resid
sort statenum year
generate resid1=resid[_n-1] if statenum==statenum[_n-1]&year>84&year<114
generate resid1sq=(resid-resid1)^2
generate residsq=resid^2 if year>84&year<114
egen residnum=sum(resid1sq) if year>84&year<114
egen residden=sum(residsq) if year>84&year<114
generate rho=1-(residnum/residden)/2
sort statenum year
for var lpc_murd aremigm yy* ss*  \ new tpc_murd tefa tyy1-tyy49 tss1-tss51 : generate Y=X-rho*X[_n-1]
for var xx* \ var tx*: replace Y=X-rho*X[_n-1]
for var lpc_murd aremigm yy* ss* xx* \ var tpc_murd tefa tyy1-tyy49 tss1-tss51 tx*: replace Y=X*(1-rho^2)^.5 if year==85
regress tpc_murd tefa tx* tyy* tss*  [aw=popul], robust
drop tpc* tefa* tyy* tss* resid* rho


/* Row 7: Include control for flow of immigrants */

generate xxfb=fb/(popul*1000)
generate txfb=xxfb

/* Column 1 */
regress lpc_viol arefav xx*  yy* ss* [aw=popul], robust 
predict resid, resid
sort statenum year
generate resid1=resid[_n-1] if statenum==statenum[_n-1]&year>84&year<114
generate resid1sq=(resid-resid1)^2
generate residsq=resid^2 if year>84&year<114
egen residnum=sum(resid1sq) if year>84&year<114
egen residden=sum(residsq) if year>84&year<114
generate rho=1-(residnum/residden)/2
sort statenum year
for var lpc_viol arefav yy* ss*  \ new tpc_viol tefa tyy1-tyy49 tss1-tss51 : generate Y=X-rho*X[_n-1]
for var xx* \ var tx*: replace Y=X-rho*X[_n-1]
for var lpc_viol arefav yy* ss* xx* \ var tpc_viol tefa tyy1-tyy49 tss1-tss51 tx*: replace Y=X*(1-rho^2)^.5 if year==85
regress tpc_viol tefa tx* tyy* tss* [aw=popul], robust
drop tpc* tefa* tyy* tss* resid* rho

/* Column 2 */
regress lpc_prop arefap xx*  yy* ss* [aw=popul], robust 
predict resid, resid
sort statenum year
generate resid1=resid[_n-1] if statenum==statenum[_n-1]&year>84&year<114
generate resid1sq=(resid-resid1)^2
generate residsq=resid^2 if year>84&year<114
egen residnum=sum(resid1sq) if year>84&year<114
egen residden=sum(residsq) if year>84&year<114
generate rho=1-(residnum/residden)/2
sort statenum year
for var lpc_prop arefap yy* ss*  \ new tpc_prop tefa tyy1-tyy49 tss1-tss51 : generate Y=X-rho*X[_n-1]
for var xx* \ var tx*: replace Y=X-rho*X[_n-1]
for var lpc_prop arefap yy* ss* xx* \ var tpc_prop tefa tyy1-tyy49 tss1-tss51 tx*: replace Y=X*(1-rho^2)^.5 if year==85
regress tpc_prop tefa tx* tyy* tss* [aw=popul], robust
drop tpc* tefa* tyy* tss* resid* rho

/* Column 3 */
regress lpc_murd arefam xx*  yy* ss* [aw=popul], robust 
predict resid, resid
sort statenum year
generate resid1=resid[_n-1] if statenum==statenum[_n-1]&year>84&year<114
generate resid1sq=(resid-resid1)^2
generate residsq=resid^2 if year>84&year<114
egen residnum=sum(resid1sq) if year>84&year<114
egen residden=sum(residsq) if year>84&year<114
generate rho=1-(residnum/residden)/2
sort statenum year
for var lpc_murd arefam yy* ss*  \ new tpc_murd tefa tyy1-tyy49 tss1-tss51 : generate Y=X-rho*X[_n-1]
for var xx* \ var tx*: replace Y=X-rho*X[_n-1]
for var lpc_murd arefam yy* ss* xx* \ var tpc_murd tefa tyy1-tyy49 tss1-tss51 tx*: replace Y=X*(1-rho^2)^.5 if year==85
regress tpc_murd tefa tx* tyy* tss*  [aw=popul], robust
drop tpc* tefa* tyy* tss* resid* rho

drop xxfb txfb


/* Row 8: Include state specific trends  */

generate trend=year-85
for new tt1-tt51 \ var ss1-ss51: generate X=Y*trend
summ tt*

/* Column 1 */
regress lpc_viol arefav xx*  yy* ss* tt*  [aw=popul], robust 
predict resid, resid
sort statenum year
generate resid1=resid[_n-1] if statenum==statenum[_n-1]&year>84&year<114
generate resid1sq=(resid-resid1)^2
generate residsq=resid^2 if year>84&year<114
egen residnum=sum(resid1sq) if year>84&year<114
egen residden=sum(residsq) if year>84&year<114
generate rho=1-(residnum/residden)/2
sort statenum year
for var lpc_viol arefav yy* ss* tt* \ new tpc_viol tefa tyy1-tyy49 tss1-tss51 ttt1-ttt51: generate Y=X-rho*X[_n-1]
for var xx* \ var tx*: replace Y=X-rho*X[_n-1]
for var lpc_viol arefav yy* ss* xx* tt1-tt51 \ var tpc_viol tefa tyy1-tyy49 tss1-tss51 tx* ttt1-ttt51: replace Y=X*(1-rho^2)^.5 if year==85
regress tpc_viol tefa tx* tyy* tss* ttt* [aw=popul], robust
drop tpc* tefa* tyy* tss* ttt* resid* rho

/* Column 2 */
regress lpc_prop arefap xx*  yy* ss* tt*  [aw=popul], robust 
predict resid, resid
sort statenum year
generate resid1=resid[_n-1] if statenum==statenum[_n-1]&year>84&year<114
generate resid1sq=(resid-resid1)^2
generate residsq=resid^2 if year>84&year<114
egen residnum=sum(resid1sq) if year>84&year<114
egen residden=sum(residsq) if year>84&year<114
generate rho=1-(residnum/residden)/2
sort statenum year
for var lpc_prop arefap yy* ss* tt* \ new tpc_prop tefa tyy1-tyy49 tss1-tss51 ttt1-ttt51: generate Y=X-rho*X[_n-1]
for var xx* \ var tx*: replace Y=X-rho*X[_n-1]
for var lpc_prop arefap yy* ss* xx* tt1-tt51 \ var tpc_prop tefa tyy1-tyy49 tss1-tss51 tx* ttt1-ttt51: replace Y=X*(1-rho^2)^.5 if year==85
regress tpc_prop tefa tx* tyy* tss* ttt* [aw=popul], robust
drop tpc* tefa* tyy* tss* ttt* resid* rho

/* Column 3 */
regress lpc_murd arefam xx*  yy* ss* tt*  [aw=popul], robust 
predict resid, resid
sort statenum year
generate resid1=resid[_n-1] if statenum==statenum[_n-1]&year>84&year<114
generate resid1sq=(resid-resid1)^2
generate residsq=resid^2 if year>84&year<114
egen residnum=sum(resid1sq) if year>84&year<114
egen residden=sum(residsq) if year>84&year<114
generate rho=1-(residnum/residden)/2
sort statenum year
for var lpc_murd arefam yy* ss* tt* \ new tpc_murd tefa tyy1-tyy49 tss1-tss51 ttt1-ttt51: generate Y=X-rho*X[_n-1]
for var xx* \ var tx*: replace Y=X-rho*X[_n-1]
for var lpc_murd arefam yy* ss* xx* tt1-tt51 \ var tpc_murd tefa tyy1-tyy49 tss1-tss51 tx* ttt1-ttt51: replace Y=X*(1-rho^2)^.5 if year==85
regress tpc_murd tefa tx* tyy* tss* ttt* [aw=popul], robust
drop tpc* tefa* tyy* tss* ttt* resid* rho


/* Row 9: add region-year interactions */

generate regiyear=region*1000+year if year>84&year<114
tab regiyear, gen(ryy) nof

/* Column 1 */
regress lpc_viol arefav xx*  ryy* ss* [aw=popul], robust 
predict resid, resid
sort statenum year
generate resid1=resid[_n-1] if statenum==statenum[_n-1]&year>84&year<114
generate resid1sq=(resid-resid1)^2
generate residsq=resid^2 if year>84&year<114
egen residnum=sum(resid1sq) if year>84&year<114
egen residden=sum(residsq) if year>84&year<114
generate rho=1-(residnum/residden)/2
sort statenum year
for var lpc_viol arefav ryy* ss*  \ new tpc_viol tefa tyy1-tyy261 tss1-tss51 : generate Y=X-rho*X[_n-1]
for var xx* \ var tx*: replace Y=X-rho*X[_n-1]
for var lpc_viol arefav ryy* ss* xx* \ var tpc_viol tefa tyy1-tyy261 tss1-tss51 tx*: replace Y=X*(1-rho^2)^.5 if year==85
regress tpc_viol tefa tx* tyy* tss* [aw=popul], robust
drop tpc* tefa* tyy* tss* resid* rho

/* Column 2 */
regress lpc_prop arefap xx*  ryy* ss* [aw=popul], robust 
predict resid, resid
sort statenum year
generate resid1=resid[_n-1] if statenum==statenum[_n-1]&year>84&year<114
generate resid1sq=(resid-resid1)^2
generate residsq=resid^2 if year>84&year<114
egen residnum=sum(resid1sq) if year>84&year<114
egen residden=sum(residsq) if year>84&year<114
generate rho=1-(residnum/residden)/2
sort statenum year
for var lpc_prop arefap ryy* ss*  \ new tpc_prop tefa tyy1-tyy261 tss1-tss51 : generate Y=X-rho*X[_n-1]
for var xx* \ var tx*: replace Y=X-rho*X[_n-1]
for var lpc_prop arefap ryy* ss* xx* \ var tpc_prop tefa tyy1-tyy261 tss1-tss51 tx*: replace Y=X*(1-rho^2)^.5 if year==85
regress tpc_prop tefa tx* tyy* tss* [aw=popul], robust
drop tpc* tefa* tyy* tss* resid* rho

/* Column 3 */
regress lpc_murd arefam xx*  ryy* ss* [aw=popul], robust 
predict resid, resid
sort statenum year
generate resid1=resid[_n-1] if statenum==statenum[_n-1]&year>84&year<114
generate resid1sq=(resid-resid1)^2
generate residsq=resid^2 if year>84&year<114
egen residnum=sum(resid1sq) if year>84&year<114
egen residden=sum(residsq) if year>84&year<114
generate rho=1-(residnum/residden)/2
sort statenum year
for var lpc_murd arefam ryy* ss*  \ new tpc_murd tefa tyy1-tyy261 tss1-tss51 : generate Y=X-rho*X[_n-1]
for var xx* \ var tx*: replace Y=X-rho*X[_n-1]
for var lpc_murd arefam ryy* ss* xx* \ var tpc_murd tefa tyy1-tyy261 tss1-tss51 tx*: replace Y=X*(1-rho^2)^.5 if year==85
regress tpc_murd tefa tx* tyy* tss*  [aw=popul], robust
drop tpc* tefa* tyy* tss* resid* rho

drop ryy* 


/* Row 13: Control for fertility 20 years earlier */

sort statenum year
generate xxfert=fertil[_n-19] if statenum==statenum[_n-19]
generate txfert=xxfert

/* Column 1 */
regress lpc_viol arefav xx*  yy* ss* [aw=popul], robust 
predict resid, resid
sort statenum year
generate resid1=resid[_n-1] if statenum==statenum[_n-1]&year>84&year<114
generate resid1sq=(resid-resid1)^2
generate residsq=resid^2 if year>84&year<114
egen residnum=sum(resid1sq) if year>84&year<114
egen residden=sum(residsq) if year>84&year<114
generate rho=1-(residnum/residden)/2
sort statenum year
for var lpc_viol arefav yy* ss*  \ new tpc_viol tefa tyy1-tyy49 tss1-tss51 : generate Y=X-rho*X[_n-1]
for var xx* \ var tx*: replace Y=X-rho*X[_n-1]
for var lpc_viol arefav yy* ss* xx* \ var tpc_viol tefa tyy1-tyy49 tss1-tss51 tx*: replace Y=X*(1-rho^2)^.5 if year==85
regress tpc_viol tefa tx* tyy* tss* [aw=popul], robust
drop tpc* tefa* tyy* tss* resid* rho

/* Column 2 */
regress lpc_prop arefap xx*  yy* ss* [aw=popul], robust 
predict resid, resid
sort statenum year
generate resid1=resid[_n-1] if statenum==statenum[_n-1]&year>84&year<114
generate resid1sq=(resid-resid1)^2
generate residsq=resid^2 if year>84&year<114
egen residnum=sum(resid1sq) if year>84&year<114
egen residden=sum(residsq) if year>84&year<114
generate rho=1-(residnum/residden)/2
sort statenum year
for var lpc_prop arefap yy* ss*  \ new tpc_prop tefa tyy1-tyy49 tss1-tss51 : generate Y=X-rho*X[_n-1]
for var xx* \ var tx*: replace Y=X-rho*X[_n-1]
for var lpc_prop arefap yy* ss* xx* \ var tpc_prop tefa tyy1-tyy49 tss1-tss51 tx*: replace Y=X*(1-rho^2)^.5 if year==85
regress tpc_prop tefa tx* tyy* tss* [aw=popul], robust
drop tpc* tefa* tyy* tss* resid* rho

/* Column 3 */
regress lpc_murd arefam xx*  yy* ss* [aw=popul], robust 
predict resid, resid
sort statenum year
generate resid1=resid[_n-1] if statenum==statenum[_n-1]&year>84&year<114
generate resid1sq=(resid-resid1)^2
generate residsq=resid^2 if year>84&year<114
egen residnum=sum(resid1sq) if year>84&year<114
egen residden=sum(residsq) if year>84&year<114
generate rho=1-(residnum/residden)/2
sort statenum year
for var lpc_murd arefam yy* ss*  \ new tpc_murd tefa tyy1-tyy49 tss1-tss51 : generate Y=X-rho*X[_n-1]
for var xx* \ var tx*: replace Y=X-rho*X[_n-1]
for var lpc_murd arefam yy* ss* xx* \ var tpc_murd tefa tyy1-tyy49 tss1-tss51 tx*: replace Y=X*(1-rho^2)^.5 if year==85
regress tpc_murd tefa tx* tyy* tss*  [aw=popul], robust
drop tpc* tefa* tyy* tss* resid* rho

drop xxfert  txfert


/* Row 14: Long difference estimates using only 85 and 13 data */

/* Column 1 */
regress lpc_viol arefav xx*  yy* ss* if year==85|year==113 [aw=popul], robust 

/* Column 2 */
regress lpc_prop arefap xx*  yy* ss* if year==85|year==113   [aw=popul], robust 

/* Column 3 */
regress lpc_murd arefam xx*  yy* ss* if year==85|year==113  [aw=popul], robust 

log close Table_5

/* ************************************************************************** */
cd $output
capture log close Table_6
log using Table_6.log, replace name(Table_6)
/* ************************************************************************** */

/* Table 6 */

**arrest rates per capita, by age
generate l_ymurd=ln(mur_u25/a024)
generate l_yviol=ln(vio_u25/a024)
generate l_yprop=ln(pro_u25/a024)

generate l_omurd=ln(mur_o25/a25p)
generate l_oviol=ln(vio_o25/a25p)
generate l_oprop=ln(pro_o25/a25p)

generate dif_murd=l_ymurd-l_omurd
generate dif_viol=l_yviol-l_oviol
generate dif_prop=l_yprop-l_oprop

/* Under Age 25, Without Full Covariates */
**1. Violent Crime
regress l_yviol arefav  yy* ss*  [aw=popul], robust 
predict resid, resid
sort statenum year
generate resid1=resid[_n-1] if statenum==statenum[_n-1]&year>84&year<114
generate resid1sq=(resid-resid1)^2
generate residsq=resid^2 if year>84&year<114
egen residnum=sum(resid1sq) if year>84&year<114
egen residden=sum(residsq) if year>84&year<114
generate rho=1-(residnum/residden)/2
sort statenum year
for var l_yviol arefav yy* ss*  \ new t_yviol tefa tyy1-tyy49 tss1-tss51 : generate Y=X-rho*X[_n-1]
for var l_yviol arefav yy* ss* \ var t_yviol tefa tyy1-tyy49 tss1-tss51: replace Y=X*(1-rho^2)^.5 if year==85
regress t_yviol tefa tyy* tss*  [aw=popul], robust
est title: Under Age 25, Without Full Covariates: Violent Crime
est sto m1
drop t_y* tefa* tyy* tss*  resid* rho
**2. Property Crime
regress l_yprop arefap  yy* ss*   [aw=popul], robust 
predict resid, resid
sort statenum year
generate resid1=resid[_n-1] if statenum==statenum[_n-1]&year>84&year<114
generate resid1sq=(resid-resid1)^2
generate residsq=resid^2 if year>84&year<114
egen residnum=sum(resid1sq) if year>84&year<114
egen residden=sum(residsq) if year>84&year<114
generate rho=1-(residnum/residden)/2
sort statenum year
for var l_yprop arefap yy* ss*  \ new t_yprop tefa tyy1-tyy49 tss1-tss51 : generate Y=X-rho*X[_n-1]
for var l_yprop arefap yy* ss* \ var t_yprop tefa tyy1-tyy49 tss1-tss51: replace Y=X*(1-rho^2)^.5 if year==85
regress t_yprop tefa tyy* tss*  [aw=popul], robust
est title: Under Age 25, Without Full Covariates: Property Crime
est sto m2
drop t_y* tefa* tyy* tss*  resid* rho
**3. Murder
regress l_ymurd arefam  yy* ss*  [aw=popul], robust 
predict resid, resid
sort statenum year
generate resid1=resid[_n-1] if statenum==statenum[_n-1]&year>84&year<114
generate resid1sq=(resid-resid1)^2
generate residsq=resid^2 if year>84&year<114
egen residnum=sum(resid1sq) if year>84&year<114
egen residden=sum(residsq) if year>84&year<114
generate rho=1-(residnum/residden)/2
sort statenum year
for var l_ymurd arefam yy* ss*  \ new t_ymurd tefa tyy1-tyy49 tss1-tss51 : generate Y=X-rho*X[_n-1]
for var l_ymurd arefam yy* ss* \ var t_ymurd tefa tyy1-tyy49 tss1-tss51: replace Y=X*(1-rho^2)^.5 if year==85
regress t_ymurd tefa  tyy* tss*  [aw=popul], robust
est title: Under Age 25, Without Full Covariates: Murder
est sto m3
drop t_y* tefa* tyy* tss*  resid* rho

/* Under Age 25, With Full Covariates*/
**1. Violent Crime
regress l_yviol arefav xx*  yy* ss*  [aw=popul], robust 
predict resid, resid
sort statenum year
generate resid1=resid[_n-1] if statenum==statenum[_n-1]&year>84&year<114
generate resid1sq=(resid-resid1)^2
generate residsq=resid^2 if year>84&year<114
egen residnum=sum(resid1sq) if year>84&year<114
egen residden=sum(residsq) if year>84&year<114
generate rho=1-(residnum/residden)/2
sort statenum year
for var l_yviol arefav yy* ss*  \ new t_yviol tefa tyy1-tyy49 tss1-tss51 : generate Y=X-rho*X[_n-1]
for var xx* \ var tx*: replace Y=X-rho*X[_n-1]
for var l_yviol arefav yy* ss* xx* \ var t_yviol tefa tyy1-tyy49 tss1-tss51 tx*: replace Y=X*(1-rho^2)^.5 if year==85
regress t_yviol tefa tx* tyy* tss*  [aw=popul], robust
est title: Under Age 25, With Full Covariates: Violent Crime
est sto m4
drop t_y* tefa* tyy* tss*  resid* rho
**2. Property Crime
regress l_yprop arefap xx*  yy* ss*   [aw=popul], robust 
predict resid, resid
sort statenum year
generate resid1=resid[_n-1] if statenum==statenum[_n-1]&year>84&year<114
generate resid1sq=(resid-resid1)^2
generate residsq=resid^2 if year>84&year<114
egen residnum=sum(resid1sq) if year>84&year<114
egen residden=sum(residsq) if year>84&year<114
generate rho=1-(residnum/residden)/2
sort statenum year
for var l_yprop arefap yy* ss*  \ new t_yprop tefa tyy1-tyy49 tss1-tss51 : generate Y=X-rho*X[_n-1]
for var xx* \ var tx*: replace Y=X-rho*X[_n-1]
for var l_yprop arefap yy* ss* xx* \ var t_yprop tefa tyy1-tyy49 tss1-tss51 tx*: replace Y=X*(1-rho^2)^.5 if year==85
regress t_yprop tefa tx* tyy* tss*  [aw=popul], robust
est title: Under Age 25, With Full Covariates: Property Crime
est sto m5
drop t_y* tefa* tyy* tss*  resid* rho
**3. Murder
regress l_ymurd arefam xx*  yy* ss*  [aw=popul], robust 
predict resid, resid
sort statenum year
generate resid1=resid[_n-1] if statenum==statenum[_n-1]&year>84&year<114
generate resid1sq=(resid-resid1)^2
generate residsq=resid^2 if year>84&year<114
egen residnum=sum(resid1sq) if year>84&year<114
egen residden=sum(residsq) if year>84&year<114
generate rho=1-(residnum/residden)/2
sort statenum year
for var l_ymurd arefam yy* ss*  \ new t_ymurd tefa tyy1-tyy49 tss1-tss51 : generate Y=X-rho*X[_n-1]
for var xx* \ var tx*: replace Y=X-rho*X[_n-1]
for var l_ymurd arefam yy* ss* xx* \ var t_ymurd tefa tyy1-tyy49 tss1-tss51 tx*: replace Y=X*(1-rho^2)^.5 if year==85
regress t_ymurd tefa tx* tyy* tss*  [aw=popul], robust
est title: Under Age 25, With Full Covariates: Murder
est sto m6
drop t_y* tefa* tyy* tss*  resid* rho

/* Age 25+, Without Full Covariates */
**1. Violent Crime
regress l_oviol arefav  yy* ss*  [aw=popul], robust 
predict resid, resid
sort statenum year
generate resid1=resid[_n-1] if statenum==statenum[_n-1]&year>84&year<114
generate resid1sq=(resid-resid1)^2
generate residsq=resid^2 if year>84&year<114
egen residnum=sum(resid1sq) if year>84&year<114
egen residden=sum(residsq) if year>84&year<114
generate rho=1-(residnum/residden)/2
sort statenum year
for var l_oviol arefav yy* ss*  \ new t_oviol tefa tyy1-tyy49 tss1-tss51 : generate Y=X-rho*X[_n-1]
for var l_oviol arefav yy* ss* \ var t_oviol tefa tyy1-tyy49 tss1-tss51: replace Y=X*(1-rho^2)^.5 if year==85
regress t_oviol tefa  tyy* tss*  [aw=popul], robust
est title: Age 25+, Without Full Covariates: Violent Crime
est sto m7
drop t_o* tefa* tyy* tss*  resid* rho
**2. Property Crime
regress l_oprop arefap  yy* ss*   [aw=popul], robust 
predict resid, resid
sort statenum year
generate resid1=resid[_n-1] if statenum==statenum[_n-1]&year>84&year<114
generate resid1sq=(resid-resid1)^2
generate residsq=resid^2 if year>84&year<114
egen residnum=sum(resid1sq) if year>84&year<114
egen residden=sum(residsq) if year>84&year<114
generate rho=1-(residnum/residden)/2
sort statenum year
for var l_oprop arefap yy* ss*  \ new t_oprop tefa tyy1-tyy49 tss1-tss51 : generate Y=X-rho*X[_n-1]
for var l_oprop arefap yy* ss* \ var t_oprop tefa tyy1-tyy49 tss1-tss51: replace Y=X*(1-rho^2)^.5 if year==85
regress t_oprop tefa  tyy* tss*  [aw=popul], robust
est title: Age 25+, Without Full Covariates: Property Crime
est sto m8
drop t_o* tefa* tyy* tss*  resid* rho
**3. Murder
regress l_omurd arefam  yy* ss*  [aw=popul], robust 
predict resid, resid
sort statenum year
generate resid1=resid[_n-1] if statenum==statenum[_n-1]&year>84&year<114
generate resid1sq=(resid-resid1)^2
generate residsq=resid^2 if year>84&year<114
egen residnum=sum(resid1sq) if year>84&year<114
egen residden=sum(residsq) if year>84&year<114
generate rho=1-(residnum/residden)/2
sort statenum year
for var l_omurd arefam yy* ss*  \ new t_omurd tefa tyy1-tyy49 tss1-tss51 : generate Y=X-rho*X[_n-1]
for var l_omurd arefam yy* ss* \ var t_omurd tefa tyy1-tyy49 tss1-tss51: replace Y=X*(1-rho^2)^.5 if year==85
regress t_omurd tefa  tyy* tss*  [aw=popul], robust
est title: Age 25+, Without Full Covariates: Murder
est sto m9
drop t_o* tefa* tyy* tss*  resid* rho

/* Age 25+, With Full Covariates*/
**1. Violent Crime
regress l_oviol arefav xx*  yy* ss*  [aw=popul], robust 
predict resid, resid
sort statenum year
generate resid1=resid[_n-1] if statenum==statenum[_n-1]&year>84&year<114
generate resid1sq=(resid-resid1)^2
generate residsq=resid^2 if year>84&year<114
egen residnum=sum(resid1sq) if year>84&year<114
egen residden=sum(residsq) if year>84&year<114
generate rho=1-(residnum/residden)/2
sort statenum year
for var l_oviol arefav yy* ss*  \ new t_oviol tefa tyy1-tyy49 tss1-tss51 : generate Y=X-rho*X[_n-1]
for var xx* \ var tx*: replace Y=X-rho*X[_n-1]
for var l_oviol arefav yy* ss* xx* \ var t_oviol tefa tyy1-tyy49 tss1-tss51 tx*: replace Y=X*(1-rho^2)^.5 if year==85
regress t_oviol tefa tx* tyy* tss*  [aw=popul], robust
est title: Age 25+, With Full Covariates: Violent Crime
est sto m10
drop t_o* tefa* tyy* tss*  resid* rho
**2. Property Crime
regress l_oprop arefap xx*  yy* ss*   [aw=popul], robust 
predict resid, resid
sort statenum year
generate resid1=resid[_n-1] if statenum==statenum[_n-1]&year>84&year<114
generate resid1sq=(resid-resid1)^2
generate residsq=resid^2 if year>84&year<114
egen residnum=sum(resid1sq) if year>84&year<114
egen residden=sum(residsq) if year>84&year<114
generate rho=1-(residnum/residden)/2
sort statenum year
for var l_oprop arefap yy* ss*  \ new t_oprop tefa tyy1-tyy49 tss1-tss51 : generate Y=X-rho*X[_n-1]
for var xx* \ var tx*: replace Y=X-rho*X[_n-1]
for var l_oprop arefap yy* ss* xx* \ var t_oprop tefa tyy1-tyy49 tss1-tss51 tx*: replace Y=X*(1-rho^2)^.5 if year==85
regress t_oprop tefa tx* tyy* tss*  [aw=popul], robust
est title: Age 25+, With Full Covariates: Property Crime
est sto m11
drop t_o* tefa* tyy* tss*  resid* rho
**3. Murder
regress l_omurd arefam xx*  yy* ss*  [aw=popul], robust 
predict resid, resid
sort statenum year
generate resid1=resid[_n-1] if statenum==statenum[_n-1]&year>84&year<114
generate resid1sq=(resid-resid1)^2
generate residsq=resid^2 if year>84&year<114
egen residnum=sum(resid1sq) if year>84&year<114
egen residden=sum(residsq) if year>84&year<114
generate rho=1-(residnum/residden)/2
sort statenum year
for var l_omurd arefam yy* ss*  \ new t_omurd tefa tyy1-tyy49 tss1-tss51 : generate Y=X-rho*X[_n-1]
for var xx* \ var tx*: replace Y=X-rho*X[_n-1]
for var l_omurd arefam yy* ss* xx* \ var t_omurd tefa tyy1-tyy49 tss1-tss51 tx*: replace Y=X*(1-rho^2)^.5 if year==85
regress t_omurd tefa tx* tyy* tss*  [aw=popul], robust
est title: Age 25+, With Full Covariates: Murder
est sto m12
drop t_o* tefa* tyy* tss*  resid* rho

/* Under Age 25 minus Age 25+, Without Covariates */
**1. Violent Crime
regress dif_viol arefav  yy* ss*  [aw=popul], robust cluster(statenum)
predict resid, resid
sort statenum year
generate resid1=resid[_n-1] if statenum==statenum[_n-1]&year>84&year<114
generate resid1sq=(resid-resid1)^2
generate residsq=resid^2 if year>84&year<114
egen residnum=sum(resid1sq) if year>84&year<114
egen residden=sum(residsq) if year>84&year<114
generate rho=1-(residnum/residden)/2
sort statenum year
for var dif_viol arefav yy* ss*  \ new tif_viol tefa tyy1-tyy49 tss1-tss51 : generate Y=X-rho*X[_n-1]
for var dif_viol arefav yy* ss* \ var tif_viol tefa tyy1-tyy49 tss1-tss51: replace Y=X*(1-rho^2)^.5 if year==85
regress tif_viol tefa  tyy* tss*  [aw=popul], robust
est title: Under 25 minus 25+, Without Covariates: Violent Crime
est sto m13
drop tif* tefa* tyy* tss*  resid* rho
**2. Property Crime
regress dif_prop arefap  yy* ss*   [aw=popul], robust cluster(statenum)
predict resid, resid
sort statenum year
generate resid1=resid[_n-1] if statenum==statenum[_n-1]&year>84&year<114
generate resid1sq=(resid-resid1)^2
generate residsq=resid^2 if year>84&year<114
egen residnum=sum(resid1sq) if year>84&year<114
egen residden=sum(residsq) if year>84&year<114
generate rho=1-(residnum/residden)/2
sort statenum year
for var dif_prop arefap yy* ss*  \ new tif_prop tefa tyy1-tyy49 tss1-tss51 : generate Y=X-rho*X[_n-1]
for var dif_prop arefap yy* ss* \ var tif_prop tefa tyy1-tyy49 tss1-tss51: replace Y=X*(1-rho^2)^.5 if year==85
regress tif_prop tefa  tyy* tss*  [aw=popul], robust
est title: Under 25 minus 25+, Without Covariates: Property Crime
est sto m14
drop tif* tefa* tyy* tss*  resid* rho
**3. Murder
regress dif_murd arefam  yy* ss*  [aw=popul], robust cluster(statenum)
predict resid, resid
sort statenum year
generate resid1=resid[_n-1] if statenum==statenum[_n-1]&year>84&year<114
generate resid1sq=(resid-resid1)^2
generate residsq=resid^2 if year>84&year<114
egen residnum=sum(resid1sq) if year>84&year<114
egen residden=sum(residsq) if year>84&year<114
generate rho=1-(residnum/residden)/2
sort statenum year
for var dif_murd arefam yy* ss*  \ new tif_murd tefa tyy1-tyy49 tss1-tss51 : generate Y=X-rho*X[_n-1]
for var dif_murd arefam yy* ss* \ var tif_murd tefa tyy1-tyy49 tss1-tss51: replace Y=X*(1-rho^2)^.5 if year==85
regress tif_murd tefa  tyy* tss*  [aw=popul], robust
est title: Under 25 minus 25+, Without Covariates: Murder
est sto m15
drop tif* tefa* tyy* tss*  resid* rho

/* Under Age 25 minus Age 25+, With Covariates */
**1. Violent Crime
regress dif_viol arefav xx*  yy* ss*  [aw=popul], robust cluster(statenum)
predict resid, resid
sort statenum year
generate resid1=resid[_n-1] if statenum==statenum[_n-1]&year>84&year<114
generate resid1sq=(resid-resid1)^2
generate residsq=resid^2 if year>84&year<114
egen residnum=sum(resid1sq) if year>84&year<114
egen residden=sum(residsq) if year>84&year<114
generate rho=1-(residnum/residden)/2
sort statenum year
for var dif_viol arefav yy* ss*  \ new tif_viol tefa tyy1-tyy49 tss1-tss51 : generate Y=X-rho*X[_n-1]
for var xx* \ var tx*: replace Y=X-rho*X[_n-1]
for var dif_viol arefav yy* ss* xx* \ var tif_viol tefa tyy1-tyy49 tss1-tss51 tx*: replace Y=X*(1-rho^2)^.5 if year==85
regress tif_viol tefa tx* tyy* tss*  [aw=popul], robust
est title: Under 25 minus 25+, With Covariates: Violent Crime
est sto m16
drop tif* tefa* tyy* tss*  resid* rho
**2. Property Crime
regress dif_prop arefap xx*  yy* ss*   [aw=popul], robust cluster(statenum)
predict resid, resid
sort statenum year
generate resid1=resid[_n-1] if statenum==statenum[_n-1]&year>84&year<114
generate resid1sq=(resid-resid1)^2
generate residsq=resid^2 if year>84&year<114
egen residnum=sum(resid1sq) if year>84&year<114
egen residden=sum(residsq) if year>84&year<114
generate rho=1-(residnum/residden)/2
sort statenum year
for var dif_prop arefap yy* ss*  \ new tif_prop tefa tyy1-tyy49 tss1-tss51 : generate Y=X-rho*X[_n-1]
for var xx* \ var tx*: replace Y=X-rho*X[_n-1]
for var dif_prop arefap yy* ss* xx* \ var tif_prop tefa tyy1-tyy49 tss1-tss51 tx*: replace Y=X*(1-rho^2)^.5 if year==85
regress tif_prop tefa tx* tyy* tss*  [aw=popul], robust
est title: Under 25 minus 25+, With Covariates: Property Crime
est sto m17
drop tif* tefa* tyy* tss*  resid* rho
**3. Murder
regress dif_murd arefam xx*  yy* ss*  [aw=popul], robust cluster(statenum)
predict resid, resid
sort statenum year
generate resid1=resid[_n-1] if statenum==statenum[_n-1]&year>84&year<114
generate resid1sq=(resid-resid1)^2
generate residsq=resid^2 if year>84&year<114
egen residnum=sum(resid1sq) if year>84&year<114
egen residden=sum(residsq) if year>84&year<114
generate rho=1-(residnum/residden)/2
sort statenum year
for var dif_murd arefam yy* ss*  \ new tif_murd tefa tyy1-tyy49 tss1-tss51 : generate Y=X-rho*X[_n-1]
for var xx* \ var tx*: replace Y=X-rho*X[_n-1]
for var dif_murd arefam yy* ss* xx* \ var tif_murd tefa tyy1-tyy49 tss1-tss51 tx*: replace Y=X*(1-rho^2)^.5 if year==85
regress tif_murd tefa tx* tyy* tss*  [aw=popul], robust
est title: Under 25 minus 25+, With Covariates: Murder
est sto m18
drop tif* tefa* tyy* tss*  resid* rho


log close Table_6
*/
/* ************************************************************************** */
cd $output
capture log close Table_7
log using Table_7.log, replace name(Table_7)
/* ************************************************************************** */

* The following code is taken from "fg_final.do"7 as it produces the corrected 
* version of Table 7. For the original version please see the original do-file,
* dolabo.do.

/* ************************************************ */
/* Table 7 */

* This set of regressions uses cosmetically improved version of the corrected 
* code used in the Reply to Foote & Goetz. We only replicate the new columns 
* in the Reply to Foote & Goetz, i.e. Columns 5 & 6, and Columns 11 & 12.
*
* Arrest data from 1999 - 2013 is new; 1998 and before is from the original 
* dataset. 
* Abortion data from 1978-2008 is new; abortion data prior to 1978 is from the 
* original dataset.

keep statenum year mur* vio* pro* abresrt* xx* popul 
expand 10
sort statenum year
generate age=15
replace age=age[_n-1]+1 if statenum==statenum[_n-1]&year==year[_n-1]

summ
sort age statenum year
generate abort2=0

replace abort2=abresrt[_n-16] if age==15&statenum==statenum[_n-16]&age[_n-16]==age
replace abort2=abresrt[_n-17] if age==16&statenum==statenum[_n-17]&age[_n-17]==age
replace abort2=abresrt[_n-18] if age==17&statenum==statenum[_n-18]&age[_n-18]==age
replace abort2=abresrt[_n-19] if age==18&statenum==statenum[_n-19]&age[_n-19]==age
replace abort2=abresrt[_n-20] if age==19&statenum==statenum[_n-20]&age[_n-20]==age
replace abort2=abresrt[_n-21] if age==20&statenum==statenum[_n-21]&age[_n-21]==age
replace abort2=abresrt[_n-22] if age==21&statenum==statenum[_n-22]&age[_n-22]==age
replace abort2=abresrt[_n-23] if age==22&statenum==statenum[_n-23]&age[_n-23]==age
replace abort2=abresrt[_n-24] if age==23&statenum==statenum[_n-24]&age[_n-24]==age
replace abort2=abresrt[_n-25] if age==24&statenum==statenum[_n-25]&age[_n-25]==age

replace abort2=0 if abort2==.
************************************************
* NB: 
* (1) In the original do-file, abort2 was (erroneously) calculated as the mean 
* of abort[_n-a] and abort[_n-(a+1)], where a is age. According to the paper
* itself, it should only have been calculated as abortions "in year y - a - 1".
* This has been corrected here. 
*
* (2) In the do-file for the Reply to Foote & Goetz, the RA re-derives a new 
* abortion variable he calls "hist_abt_orig_no", and uses this instead. It is 
* essentially identical to "abort2"/100, with any differences due to the number
* of decimal places in the storage format. 
************************************************
summ abort2
summ abort2 if year==90&age==15
summ abort2 if year==90&age==22

generate violarr=.
replace violarr=vioarr15 if age==15
replace violarr=vioarr16 if age==16
replace violarr=vioarr17 if age==17
replace violarr=vioarr18 if age==18
replace violarr=vioarr19 if age==19
replace violarr=vioarr20 if age==20
replace violarr=vioarr21 if age==21
replace violarr=vioarr22 if age==22
replace violarr=vioarr23 if age==23
replace violarr=vioarr24 if age==24

generate proparr=.
replace proparr=proarr15 if age==15
replace proparr=proarr16 if age==16
replace proparr=proarr17 if age==17
replace proparr=proarr18 if age==18
replace proparr=proarr19 if age==19
replace proparr=proarr20 if age==20
replace proparr=proarr21 if age==21
replace proparr=proarr22 if age==22
replace proparr=proarr23 if age==23
replace proparr=proarr24 if age==24

generate murdarr=.
replace murdarr=murarr15 if age==15
replace murdarr=murarr16 if age==16
replace murdarr=murarr17 if age==17
replace murdarr=murarr18 if age==18
replace murdarr=murarr19 if age==19
replace murdarr=murarr20 if age==20
replace murdarr=murarr21 if age==21
replace murdarr=murarr22 if age==22
replace murdarr=murarr23 if age==23
replace murdarr=murarr24 if age==24

generate l_viol=ln(violarr)
generate l_prop=ln(proparr)
generate l_murd=ln(murdarr)

keep if year>84 & year<114

******************************************
* Generate dummies and interaction terms *
******************************************
tab year, 		gen(yy) nof
tab statenum, 	gen(ss) nof
tab age, 		gen(aa) nof

**generate YOBxSTATE interactions
generate yob=year-age
generate yobstate=statenum*1000+yob
tab yobstate,	gen(yobxs)

**generate STATExAGE interactions
generate stateage=statenum*1000+age
tab stateage, 	gen(sxa)

**generate YEARxAGE interactions
generate yearage=year*1000+age
tab yearage, 	gen(axy) nof

**generate STATExYEAR interaction
gen stateyear = statenum*1000 + year
tab stateyear, 	gen(sxy)

**dividing by 100 to make consistent with other regressions
replace abort2=abort2/100

generate abor15=abort2*(age==15)
generate abor16=abort2*(age==16)
generate abor17=abort2*(age==17)
generate abor18=abort2*(age==18)
generate abor19=abort2*(age==19)
generate abor20=abort2*(age==20)
generate abor21=abort2*(age==21)
generate abor22=abort2*(age==22)
generate abor23=abort2*(age==23)
generate abor24=abort2*(age==24)

estimates clear

set matsize 1000

/* Violent arrests */
/* F&G Column 5, abortion rate constant */
areg l_viol abort2 ss* axy* sxa* [aweight=popul] if year<114, abs(stateyear) cluster(yobstate)
estimates store t5, title(t5)

/* F&G Column 6, abortion rate interacted with age */
areg l_viol abor15-abor24 ss* axy* sxa* [aweight=popul] if year<114, abs(stateyear) cluster(yobstate)
estimates store t6, title(t6)

/* Property arrests */
/* F&G Column 11, abortion rate constant */
areg l_prop abort2 ss* axy* sxa* [aweight=popul] if year<114, abs(stateyear) cluster(yobstate)
estimates store t11, title(t11)

/* F&G Column 12, abortion rate interacted with age */
areg l_prop abor15-abor24 ss* axy* sxa* [aweight=popul] if year<114, abs(stateyear) cluster(yobstate)
estimates store t12, title(t12)

esttab * using output_table7.txt, keep(abort2 abor*) cells(b(fmt(%9.3f)) se(star par("[" "]") fmt(%9.3f))) style(tab) stat(N r2) starlevels(* 0.05 ** 0.01) replace


log close
