********************************************************************************
*                           Ethiopia Synthesis Report 
*                                6_DNA_ess4
* Country: Ethiopia 
* Data: ESS 4 
* Author: Paola Mallia | p.mallia@cgiar.org | paola_mallia@ymail.com 
* STATA Version: SE 16.1
********************************************************************************
* Barcoded sample
import excel "${rawdata}${slash}ESS4_2018-19${slash}DNA_data_21May20.xlsx", sheet("DNA_data") firstrow clear
save "${raw4}${slash}PP_DNA_data", replace

* Varieties info - reference library
import excel "${rawdata}${slash}ESS4_2018-19${slash}Var_data.xlsx", sheet("Var_data") firstrow clear

save "${raw4}${slash}Var_data.xlsx", replace

use "${raw4}${slash}PP_DNA_data", clear
rename *, lower 

duplicates list id puritypuritypercent subbinreferences, force
// 0 duplicates --> ok

duplicates tag id, g(dup)
// 0 duplicates --> ok
keep if dup==0
drop dup

replace subbinreferences="RLi-BIRHAN-I-A" if subbinreferences=="RLi-BIRHAN-A"
g dnadata=1
tempfile dna_data
save `dna_data'

use "${raw4}${slash}Var_data.xlsx", clear
rename *, lower

replace subbinreferences="RLi-MELEKA-A"   if subbinreferences=="RLi-MELAKA-A"
replace subbinreferences="RLi-mezezo a"   if subbinreferences==" RLi-mezezo a"
replace subbinreferences="not identified" if subbinreferences=="Non identified"

tempfile var_data
save `var_data'

*************************************************************

use "${raw4}${slash}PP${slash}sect9a_pp_w4", clear 
	rename sccq05 id
destring id, force replace

foreach i in sccq01 sccq02a sccq02b sccq03 sccq04 {
replace `i'=`i'[625] if id==707 
} 

drop if id == 707 & s4q01b == 2 

drop if id == 154 & s4q01b == 2

*************************************************************

drop if id==. 

duplicates tag id, g(dup)
duplicates drop id, force

merge 1:1 id using `dna_data'
keep if _m==3
drop _m
* Merge with reference library
merge m:1 subbinreferences using `var_data'
// RLi-ABSHIR-2_A	Barley from var data
keep if _m==3
drop _m


* Merge with post-planting survey cover
merge m:1 household_id using "${data}${slash}w4_coverPP_new"
keep if _m==3
drop _m

merge 1:1 household_id holder_id parcel_id field_id crop_id s4q01b using "${raw4}${slash}PP${slash}sect4_pp_w4" 

keep if _m == 3 
drop _m


* Dummy for crops of interest
g maize=s4q01b==2
g sorghum=s4q01b==6
g barley=s4q01b==1


g       dtmz=. if dtmz_status=="NA"
replace dtmz=0 if dtmz_status=="No"
replace dtmz=1 if dtmz_status=="Yes"


g       qpm=. if maize==0
replace qpm=0 if maize==1 
replace qpm=1 if maize==1 & qpm_status=="Yes"



clonevar region=saq01
replace region=0 if region==2 | region==6 | region==15 | region==12 | region==13 | region==5

g wave=4
* Cleaning intemediate variables
drop dup n

* Labels
lab var maize     "Maize"
lab var sorghum   "Sorghum"
lab var barley    "Barley"
lab var dtmz      "Drought Tolerant Maize"
lab var qpm       "Quality Protein Maize"

save "${data}${slash}ess4_dna_new", replace

* Misclassification variable construction

* CG - germplasm recode
g       cg=0 if cg_source=="No"
replace cg=1 if cg_source=="Yes"


* CG - germplasm only

foreach i in maize barley sorghum { 
	*True positive
g       `i'_tp1=.
replace `i'_tp1=0 if `i'==1 
replace `i'_tp1=1 if `i'==1 & cg_source=="Yes" & (s4q11>1 & s4q11!=.)
lab var `i'_tp1 "True positive `i'"

	*True negative
g       `i'_tn1=.
replace `i'_tn1=0 if `i'==1
replace `i'_tn1=1 if `i'==1 & cg_source=="No" & (s4q11==1)
lab var `i'_tn1 "True negative `i'"

	*False positive (improved when traditional)
g       `i'_fp1=.
replace `i'_fp1=0 if `i'==1
replace `i'_fp1=1 if `i'==1 & cg_source=="No" & (s4q11>1 & s4q11!=.)
lab var `i'_fp1 "False positive `i'"

	*False negative (traditional when improved)
g       `i'_fn1=.
replace `i'_fn1=0 if `i'==1
replace `i'_fn1=1 if `i'==1 & cg_source=="Yes" & (s4q11==1)
lab var `i'_fn1 "False negative `i'"

}


* CG germplasm & purity levels
* Purity cut-off: 70
foreach i in maize barley sorghum { 
	*True positive
g       `i'_tp2a=.
replace `i'_tp2a=0 if `i'==1 
replace `i'_tp2a=1 if `i'==1 & cg_source=="Yes" & puritypuritypercent>=70  & (s4q11>1 & s4q11!=.)
lab var `i'_tp2a "True positive `i' Purity cut-off: 70"

	*True negative
g       `i'_tn2a=.
replace `i'_tn2a=0 if `i'==1
replace `i'_tn2a=1 if `i'==1 & cg_source=="Yes" & puritypuritypercent<70 &  (s4q11==1)
lab var `i'_tn2a "True negative `i' Purity cut-off: 70"

	*False positive (improved when traditional)
g       `i'_fp2a=.
replace `i'_fp2a=0 if `i'==1
replace `i'_fp2a=1 if `i'==1 & cg_source=="Yes" & puritypuritypercent<70 & (s4q11>1 & s4q11!=.)
lab var `i'_fp2a "False positive `i' Purity cut-off: 70"

	*False negative (traditional when improved)
g       `i'_fn2a=.
replace `i'_fn2a=0 if `i'==1
replace `i'_fn2a=1 if `i'==1 & cg_source=="Yes" & puritypuritypercent>=70 & (s4q11==1)
lab var `i'_fn2a "False negative `i' Purity cut-off: 70"

}

* Purity cut-off: 90
foreach i in maize barley sorghum { 
	*True positive
g       `i'_tp2b=.
replace `i'_tp2b=0 if `i'==1 
replace `i'_tp2b=1 if `i'==1 & cg_source=="Yes" & puritypuritypercent>=90  & (s4q11>1 & s4q11!=.)
lab var `i'_tp2b "True positive `i' Purity cut-off: 90"

	*True negative
g       `i'_tn2b=.
replace `i'_tn2b=0 if `i'==1
replace `i'_tn2b=1 if `i'==1 & cg_source=="Yes" & puritypuritypercent<90 &  (s4q11==1)
lab var `i'_tn2b "True negative `i' Purity cut-off: 90"

	*False positive (improved when traditional)
g       `i'_fp2b=.
replace `i'_fp2b=0 if `i'==1
replace `i'_fp2b=1 if `i'==1 & cg_source=="Yes" & puritypuritypercent<90 & (s4q11>1 & s4q11!=.)
lab var `i'_fp2b "False positive `i' Purity cut-off: 90"

	*False negative (traditional when improved)
g       `i'_fn2b=.
replace `i'_fn2b=0 if `i'==1
replace `i'_fn2b=1 if `i'==1 & cg_source=="Yes" & puritypuritypercent>=90 & (s4q11==1)
lab var `i'_fn2b "False negative `i' Purity cut-off: 90"

}
* Purity cut-off: 95
foreach i in maize barley sorghum { 
	*True positive
g       `i'_tp2c=.
replace `i'_tp2c=0 if `i'==1 
replace `i'_tp2c=1 if `i'==1 & cg_source=="Yes" & puritypuritypercent>=95  & (s4q11>1 & s4q11!=.)
lab var `i'_tp2c "True positive `i' Purity cut-off: 95"

	*True negative
g       `i'_tn2c=.
replace `i'_tn2c=0 if `i'==1
replace `i'_tn2c=1 if `i'==1 & cg_source=="Yes" & puritypuritypercent<95 &  (s4q11==1)
lab var `i'_tn2c "True negative `i' Purity cut-off: 95"

	*False positive (improved when traditional)
g       `i'_fp2c=.
replace `i'_fp2c=0 if `i'==1
replace `i'_fp2c=1 if `i'==1 & cg_source=="Yes" & puritypuritypercent<95 & (s4q11>1 & s4q11!=.)
lab var `i'_fp2c "False positive `i' Purity cut-off: 95"

	*False negative (traditional when improved)
g       `i'_fn2c=.
replace `i'_fn2c=0 if `i'==1
replace `i'_fn2c=1 if `i'==1 & cg_source=="Yes" & puritypuritypercent>=95 & (s4q11==1)
lab var `i'_fn2c "False negative `i' Purity cut-off: 95"
}


* Recoding
g year=.
replace year=1970  if year_release=="1970"
replace year=1979  if year_release=="1979"
replace year=1988  if year_release=="1988"
replace year=1993  if year_release=="1993"
replace year=1995  if year_release=="1995"
replace year=1998  if year_release=="1998"
replace year=2000  if year_release=="2000"
replace year=2001  if year_release=="2001"
replace year=2002  if year_release=="2002"
replace year=2004  if year_release=="2004"
replace year=2006  if year_release=="2006"
replace year=2007  if year_release=="2007"
replace year=2008  if year_release=="2008"
replace year=2009  if year_release=="2009"
replace year=2011  if year_release=="2011"
replace year=2012  if year_release=="2012"
replace year=2013  if year_release=="2013"
replace year=2015  if year_release=="2015"
replace year=2016  if year_release=="2016"
replace year=2017  if year_release=="2017"
replace year=.     if year_release=="NA"


************************
	*Cumulative years
************************
* After 1990
foreach i in maize barley sorghum {
	* True positive
	g       `i'_tp3abis=.
	replace `i'_tp3abis=0 if `i'==1 
	replace `i'_tp3abis=1 if `i'==1 & cg_source=="Yes" & year>=1990 & (s4q11>1 & s4q11!=.)
	lab var `i'_tp3abis "True positive `i' (After 1990)"
	
	*True negative
	g       `i'_tn3abis=.
	replace `i'_tn3abis=0 if `i'==1
	replace `i'_tn3abis=1 if `i'==1 & cg_source=="Yes" &  year<1990 &  (s4q11==1)
	lab var `i'_tn3abis "True negative `i' (After 1990)"
	
	*False positive (improved when traditional)
	g       `i'_fp3abis=.
	replace `i'_fp3abis=0 if `i'==1
	replace `i'_fp3abis=1 if `i'==1 & cg_source=="Yes" & year<1990  & (s4q11>1 & s4q11!=.)
	lab var `i'_fp3abis "False positive `i' (After 1990)"
	
	*False negative (traditional when improved)
	g       `i'_fn3abis=.
	replace `i'_fn3abis=0 if `i'==1
	replace `i'_fn3abis=1 if `i'==1 & cg_source=="Yes" & year>=1990 & (s4q11==1)
    lab var `i'_fn3abis "False negative `i' (After 1990)"
	
}
* After 2000
foreach i in maize barley sorghum { 
    * True positive
	g       `i'_tp3bbis=.
	replace `i'_tp3bbis=0 if `i'==1 
	replace `i'_tp3bbis=1 if `i'==1 & cg_source=="Yes" & (year>=2000) & (s4q11>1 & s4q11!=.)
	lab var `i'_tp3bbis "True positive `i' (After 2000)"
	
	* True negative
	g       `i'_tn3bbis=.
	replace `i'_tn3bbis=0 if `i'==1
	replace `i'_tn3bbis=1 if `i'==1 & cg_source=="Yes" &  (year<2000) &  (s4q11==1)
	lab var `i'_tn3bbis "True negative `i' (After 2000)"
	
	* False positive (improved when traditional)
	g       `i'_fp3bbis=.
	replace `i'_fp3bbis=0 if `i'==1
	replace `i'_fp3bbis=1 if `i'==1 & cg_source=="Yes" &  (year<2000) & (s4q11>1 & s4q11!=.)
	lab var `i'_fp3bbis "False positive `i' (After 2000)"
	
	* False negative (traditional when improved)
	g       `i'_fn3bbis=.
	replace `i'_fn3bbis=0 if `i'==1
	replace `i'_fn3bbis=1 if `i'==1 & cg_source=="Yes" &  (year>=2000)  & (s4q11==1)
	lab var `i'_fn3bbis "False negative `i' (After 2000)"
	
}
* After 2010
foreach i in maize barley sorghum { 
	* True positive
	g       `i'_tp3cbis=.
	replace `i'_tp3cbis=0 if `i'==1 
	replace `i'_tp3cbis=1 if `i'==1 & cg_source=="Yes" & (year>=2010) & (s4q11>1 & s4q11!=.)
	lab var `i'_tp3cbis "True positive `i' (After 2010)"
	
	* True negative
	g       `i'_tn3cbis=.
	replace `i'_tn3cbis=0 if `i'==1
	replace `i'_tn3cbis=1 if `i'==1 & cg_source=="Yes" &  (year<2010) &  (s4q11==1)
	lab var `i'_tn3cbis "True negative `i' (After 2010)"
	
	* False positive (improved when traditional)
	g       `i'_fp3cbis=.
	replace `i'_fp3cbis=0 if `i'==1
	replace `i'_fp3cbis=1 if `i'==1 & cg_source=="Yes" & (year<2010) & (s4q11>1 & s4q11!=.)
	lab var `i'_fp3cbis "False positive `i' (After 2010)"
	
	* False negative (traditional when improved)
	g       `i'_fn3cbis=.
	replace `i'_fn3cbis=0 if `i'==1
	replace `i'_fn3cbis=1 if `i'==1 & cg_source=="Yes" & (year>=2010)  & (s4q11==1)
	lab var `i'_fn3cbis "False negative `i' (After 2010)"
	
}


***********************************************
* Adoption estimates using DNA-fingerprinting
***********************************************
 * CG - GERMPLASM
foreach i in maize barley sorghum { 
	g       `i'_cg=.
	replace `i'_cg=0 if `i'==1 
	replace `i'_cg=1 if `i'==1 & cg_source=="Yes"
	lab var `i'_cg "`i' DNA-fingerprinting"
}
 * CG - GERMPLASM AND PURITY LEVEL	
foreach i in maize barley sorghum { 	
	g       `i'_cgp70=.
	replace `i'_cgp70=0 if `i'==1 
	replace `i'_cgp70=1 if `i'==1 & cg_source=="Yes" & puritypuritypercent>=70
	lab var `i'_cgp70 "`i' DNA-fingerprinting Purity cut-off: 70"
	
	g       `i'_cgp90=.
	replace `i'_cgp90=0 if `i'==1 
	replace `i'_cgp90=1 if `i'==1 & cg_source=="Yes" & puritypuritypercent>=90
	lab var `i'_cgp90 "`i' DNA-fingerprinting Purity cut-off: 90"
	
	g       `i'_cgp95=.
	replace `i'_cgp95=0 if `i'==1 
	replace `i'_cgp95=1 if `i'==1 & cg_source=="Yes" & puritypuritypercent>=95
	lab var `i'_cgp95 "`i' DNA-fingerprinting Purity cut-off: 95"
}

 * CG - GERMPLASM AND YEAR OF RELEASE
foreach i in maize barley sorghum { 
	g       `i'_cgy1=.
	replace `i'_cgy1=0 if `i'==1 
	replace `i'_cgy1=1 if `i'==1 & cg_source=="Yes" & year<1990
	lab var `i'_cgy1 "`i' DNA-fingerprinting year 1990"
	
	g       `i'_cgy2=.
	replace `i'_cgy2=0 if `i'==1 
	replace `i'_cgy2=1 if `i'==1 & cg_source=="Yes" & (year>=1990 & year<2000) 
	lab var `i'_cgy2 "`i' DNA-fingerprinting year (1990-2000)"
	
	g       `i'_cgy3=.
	replace `i'_cgy3=0 if `i'==1 
	replace `i'_cgy3=1 if `i'==1 & cg_source=="Yes" & (year>=2000 & year<2010) 
	lab var `i'_cgy3 "`i' DNA-fingerprinting year (2000-2010)"
	
	g       `i'_cgy4=.
	replace `i'_cgy4=0 if `i'==1 
	replace `i'_cgy4=1 if `i'==1 & cg_source=="Yes" & (year>=2010 & year<=2020) 
	lab var `i'_cgy4 "`i' DNA-fingerprinting year (2010-2020)"
}


* UNCONDITIONAL - PURITY LEVEL
foreach i in maize barley sorghum { 	
	g       `i'_p70=.
	replace `i'_p70=0 if `i'==1 
	replace `i'_p70=1 if `i'==1  & puritypuritypercent>=70
	lab var `i'_p70 "`i' Purity cut-off: 70"
	
	g       `i'_p90=.
	replace `i'_p90=0 if `i'==1 
	replace `i'_p90=1 if `i'==1  & puritypuritypercent>=90
	lab var `i'_p90 "`i' Purity cut-off: 90"
	
	g       `i'_p95=.
	replace `i'_p95=0 if `i'==1 
	replace `i'_p95=1 if `i'==1  & puritypuritypercent>=95
	lab var `i'_p95 "`i' Purity cut-off: 95"
}

* UNCONDITIONAL - YEAR OF RELEASE

foreach i in maize barley sorghum { 
	g       `i'_y1=.
	replace `i'_y1=0 if `i'==1 
	replace `i'_y1=1 if `i'==1 & year<1990
	lab var `i'_y1 "`i' year of release < 1990"
	
	g       `i'_y2=.
	replace `i'_y2=0 if `i'==1 
	replace `i'_y2=1 if `i'==1  & (year>=1990 & year<2000)
	lab var `i'_y2 "`i' year of release (1990-2000)"
	
	g       `i'_y3=.
	replace `i'_y3=0 if `i'==1 
	replace `i'_y3=1 if `i'==1  & (year>=2000 & year<2010)
	lab var `i'_y3 "`i' year of release (2000-2010)"
	
	g       `i'_y4=.
	replace `i'_y4=0 if `i'==1 
	replace `i'_y4=1 if `i'==1  & (year>=2010 & year<=2020)
	lab var `i'_y4 "`i' year of release (2010-2020)"
}

* Misclassification: defining as improved by purity level

foreach i in maize barley sorghum { 
	* True positive
	g       `i'_tp8a=.
	replace `i'_tp8a=0 if `i'==1 
	replace `i'_tp8a=1 if `i'==1 & puritypuritypercent>=70  & (s4q11>1 & s4q11!=.)
	lab var `i'_tp8a "True positive `i' (Improved if purity >= 70)"
	
	* True negative
	g       `i'_tn8a=.
	replace `i'_tn8a=0 if `i'==1
	replace `i'_tn8a=1 if `i'==1 & puritypuritypercent<70 &  (s4q11==1)
	lab var `i'_tn8a "True negative `i' (Improved if purity >= 70)"
	
	* False positive (improved when traditional)
	g       `i'_fp8a=.
	replace `i'_fp8a=0 if `i'==1
	replace `i'_fp8a=1 if `i'==1  & puritypuritypercent<70 & (s4q11>1 & s4q11!=.)
	lab var `i'_fp8a "False positive `i' (Improved if purity >= 70)"
	
	* False negative (traditional when improved)
	g       `i'_fn8a=.
	replace `i'_fn8a=0 if `i'==1
	replace `i'_fn8a=1 if `i'==1 & puritypuritypercent>=70 & (s4q11==1)
	lab var `i'_fn8a "False negative `i' (Improved if purity >= 70)"
	
}

foreach i in maize barley sorghum { 
	* True positive
	g       `i'_tp8b=.
	replace `i'_tp8b=0 if `i'==1 
	replace `i'_tp8b=1 if `i'==1 & puritypuritypercent>=90  & (s4q11>1 & s4q11!=.)
	lab var `i'_tp8b "True positive `i' (Improved if purity >= 90)"
	
	* True negative
	g       `i'_tn8b=.
	replace `i'_tn8b=0 if `i'==1
	replace `i'_tn8b=1 if `i'==1  & puritypuritypercent<90 &  (s4q11==1)
	lab var `i'_tn8b "True negative `i' (Improved if purity >= 90)"
	
	* False positive (improved when traditional)
	g       `i'_fp8b=.
	replace `i'_fp8b=0 if `i'==1
	replace `i'_fp8b=1 if `i'==1  & puritypuritypercent<90 & (s4q11>1 & s4q11!=.)
	lab var `i'_fp8b "False positive `i' (Improved if purity >= 90)"
	
	* False negative (traditional when improved)
	g       `i'_fn8b=.
	replace `i'_fn8b=0 if `i'==1
	replace `i'_fn8b=1 if `i'==1  & puritypuritypercent>=90 & (s4q11==1)
	lab var `i'_fn8b "False negative `i' (Improved if purity >= 90)"
}

foreach i in maize barley sorghum { 
	* True positive
	g       `i'_tp8c=.
	replace `i'_tp8c=0 if `i'==1 
	replace `i'_tp8c=1 if `i'==1  & puritypuritypercent>=95  & (s4q11>1 & s4q11!=.)
	lab var `i'_tp8c "True positive `i' (Improved if purity >= 95)"
	
	* True negative
	g       `i'_tn8c=.
	replace `i'_tn8c=0 if `i'==1
	replace `i'_tn8c=1 if `i'==1  & puritypuritypercent<95 &  (s4q11==1)
	lab var `i'_tn8c "True negative `i' (Improved if purity >= 95)"
	
	* False positive (improved when traditional)
	g       `i'_fp8c=.
	replace `i'_fp8c=0 if `i'==1
	replace `i'_fp8c=1 if `i'==1  & puritypuritypercent<95 & (s4q11>1 & s4q11!=.)
	lab var `i'_fp8c "False positive `i' (Improved if purity >= 95)"
	
	* False negative (traditional when improved)
	g       `i'_fn8c=.
	replace `i'_fn8c=0 if `i'==1
	replace `i'_fn8c=1 if `i'==1  & puritypuritypercent>=95 & (s4q11==1)
	lab var `i'_fn8c "False negative `i' (Improved if purity >= 95)"
	
}


************************************************************
* Misclassification: defining as improved by year of release
*************************************************************
* Before 1990
foreach i in maize barley sorghum {
	* True positive
	g       `i'_tp9a=.
	replace `i'_tp9a=0 if `i'==1 
	replace `i'_tp9a=1 if `i'==1  & year<1990 & (s4q11>1 & s4q11!=.)
	lab var `i'_tp9a "True positive `i' (Improved if year < 1990)"
	
	* True negative
	g       `i'_tn9a=.
	replace `i'_tn9a=0 if `i'==1
	replace `i'_tn9a=1 if `i'==1 &  year>=1990 &  (s4q11==1)
	lab var `i'_tn9a "True negative `i' (Improved if year < 1990)"
	
	* False positive (improved when traditional)
	g       `i'_fp9a=.
	replace `i'_fp9a=0 if `i'==1
	replace `i'_fp9a=1 if `i'==1 & year>=1990 & (s4q11>1 & s4q11!=.)
	lab var `i'_fp9a "False positive `i' (Improved if year < 1990)"
	
	* False negative (traditional when improved)
	g       `i'_fn9a=.
	replace `i'_fn9a=0 if `i'==1
	replace `i'_fn9a=1 if `i'==1  & year<1990 & (s4q11==1)
	lab var `i'_fn9a "False negative `i' (Improved if year < 1990)"
}
* 1990- 2000
foreach i in maize barley sorghum { 
	* True positive
	g       `i'_tp9b=.
	replace `i'_tp9b=0 if `i'==1 
	replace `i'_tp9b=1 if `i'==1  & (year>=1990 & year<2000) & (s4q11>1 & s4q11!=.)
	lab var `i'_tp9b "True positive `i' (Improved if year < 2000)"
	
	*True negative
	g       `i'_tn9b=.
	replace `i'_tn9b=0 if `i'==1
	replace `i'_tn9b=1 if `i'==1 &  (year<1990 | year>=2000) &  (s4q11==1)
	lab var `i'_tn9b "True negative `i' (Improved if year < 2000)"
	
	*False positive (improved when traditional)
	g       `i'_fp9b=.
	replace `i'_fp9b=0 if `i'==1
	replace `i'_fp9b=1 if `i'==1  & (year<1990 | year>=2000) & (s4q11>1 & s4q11!=.)
	lab var `i'_fp9b "False positive `i' (Improved if year < 2000)"
	
	*False negative (traditional when improved)
	g       `i'_fn9b=.
	replace `i'_fn9b=0 if `i'==1
	replace `i'_fn9b=1 if `i'==1  & (year>=1990 & year<2000)  & (s4q11==1)
	lab var `i'_fn9b "False negative `i' (Improved if year < 2000)"
}
* 2000-2010
foreach i in maize barley sorghum { 
	* True positive
	g       `i'_tp9c=.
	replace `i'_tp9c=0 if `i'==1 
	replace `i'_tp9c=1 if `i'==1 & (year>=2000 & year<2010) & (s4q11>1 & s4q11!=.)
	lab var `i'_tp9c "True positive `i' (Improved if year 2000-2010)"
	
	*True negative
	g       `i'_tn9c=.
	replace `i'_tn9c=0 if `i'==1
	replace `i'_tn9c=1 if `i'==1 &  (year<2000 | year>=2010) &  (s4q11==1)
	lab var `i'_tn9c "True negative `i' (Improved if year 2000-2010)"
	
	* False positive (improved when traditional)
	g       `i'_fp9c=.
	replace `i'_fp9c=0 if `i'==1
	replace `i'_fp9c=1 if `i'==1 & (year<2000 | year>=2010) & (s4q11>1 & s4q11!=.)
	lab var `i'_fp9c "False positive `i' (Improved if year 2000-2010)"
	
	* False negative (traditional when improved)
	g       `i'_fn9c=.
	replace `i'_fn9c=0 if `i'==1
	replace `i'_fn9c=1 if `i'==1 & (year>=2000 & year<2010)  & (s4q11==1)
	lab var `i'_fn9c "False negative `i' (Improved if year 2000-2010)"
}
* 2010-2020
foreach i in maize barley sorghum { 
	* True positive
	g       `i'_tp9d=.
	replace `i'_tp9d=0 if `i'==1 
	replace `i'_tp9d=1 if `i'==1  & (year>=2010 & year<2020) & (s4q11>1 & s4q11!=.)
	lab var `i'_tp9d "True positive `i' (Improved if year 2010-2020)"
	* True negative
	g       `i'_tn9d=.
	replace `i'_tn9d=0 if `i'==1
	replace `i'_tn9d=1 if `i'==1  &  (year<2010 | year>=2020) &  (s4q11==1)
	lab var `i'_tn9d "True negative `i' (Improved if year 2010-2020)"
	
	* False positive (improved when traditional)
	g       `i'_fp9d=.
	replace `i'_fp9d=0 if `i'==1
	replace `i'_fp9d=1 if `i'==1  & (year<2010 | year>=2020) & (s4q11>1 & s4q11!=.)
	lab var `i'_fp9d "False positive `i' (Improved if year 2010-2020)"
	
	* False negative (traditional when improved)
	g       `i'_fn9d=.
	replace `i'_fn9d=0 if `i'==1
	replace `i'_fn9d=1 if `i'==1  & (year>=2010 & year<2020)  & (s4q11==1)
	lab var `i'_fn9d "False negative `i' (Improved if year 2010-2020)"
}

* Labels
lab var maize     "Maize"
lab var sorghum   "Sorghum"
lab var barley    "Barley"
lab var dtmz      "Drought Tolerant Maize"
lab var qpm       "Quality Protein Maize"

* Save plot level data *
save "${data}${slash}misclassification_plot_new", replace

	
********************************************************************************
* Collapse at HH-level 
********************************************************************************


collapse (max) qpm dtmz maize_cg barley_cg sorghum_cg	 (firstnm) pw_w4  region saq01 ea_id, by(household_id)

save "${data}${slash}ess4_dna_hh_new", replace


**************	
* EA LEVEL 
**************
collapse (max) 	qpm dtmz maize_cg barley_cg sorghum_cg (firstnm) pw_w4  region saq01, by(ea_id)

* In some EAs the barcodes were not collected (not at least for all plots). 
foreach i in qpm dtmz maize_cg barley_cg sorghum_cg {
gen sample_dna_`i'=1 if `i'!=.
lab var sample_dna_`i' "`i' sample"
}

foreach i in qpm dtmz maize_cg barley_cg sorghum_cg {
replace `i'=0 if `i'==.
}

save "${data}${slash}ess4_dna_ea_new", replace

