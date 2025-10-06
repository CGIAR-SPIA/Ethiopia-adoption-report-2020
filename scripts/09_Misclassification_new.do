********************************************************************************
*                           Ethiopia Synthesis Report 
*                            9_Misclassification_new
* Country: Ethiopia 
* Data: ESS 3 and ESS 4 
* Author: Paola Mallia | p.mallia@cgiar.org | paola_mallia@ymail.com 
* STATA Version: SE 16.1
********************************************************************************

* DNA fingerprinting data - Misclassification estimates *

* SR

use "${data}${slash}ess4_dna_new", clear

* CG - germplasm recode
g       cg=0 if cg_source=="No"
replace cg=1 if cg_source=="Yes"


* CG - germplasm only

foreach i in maize barley sorghum { 
	*True positive
g       `i'_tp1=.
replace `i'_tp1=0 if `i'==1 
replace `i'_tp1=1 if `i'==1 & cg_source=="Yes" & (s4q11>1 & s4q11!=.)

	*True negative
g       `i'_tn1=.
replace `i'_tn1=0 if `i'==1
replace `i'_tn1=1 if `i'==1 & cg_source=="No" & (s4q11==1)

	*False positive (improved when traditional)
g       `i'_fp1=.
replace `i'_fp1=0 if `i'==1
replace `i'_fp1=1 if `i'==1 & cg_source=="No" & (s4q11>1 & s4q11!=.)

	*False negative (traditional when improved)
g       `i'_fn1=.
replace `i'_fn1=0 if `i'==1
replace `i'_fn1=1 if `i'==1 & cg_source=="Yes" & (s4q11==1)

}


global var1    maize_tp1 maize_tn1 maize_fp1 maize_fn1 barley_tp1 barley_tn1 barley_fp1 barley_fn1 sorghum_tp1 sorghum_tn1 sorghum_fp1 sorghum_fn1

matrix drop _all
foreach var in $var1 {

 
mean `var' [pw=pw_w4] if wave==4
matrix  `var'meanrN=e(b)'
matrix define `var'VN= e(V)'
matrix define `var'VVN=(vecdiag(`var'VN))'
matrix list `var'VVN
scalar `var'seN=sqrt(`var'VVN[1,1])


sum    `var'  if  wave==4
scalar `var'minrN=r(min)
scalar `var'maxrN=r(max)
scalar `var'nN=r(N)

qui sum region if  wave==4
local obsrN=r(N)



matrix mat`var'N  = ( `var'meanrN, `var'minrN, `var'maxrN, `var'nN)
matrix mat1`var'N= (`var'seN, ., ., .)

matrix list mat`var'N

matrix A1N = nullmat(A1N)\ mat`var'N\mat1`var'N


mat A2N=(`obsrN', . , ., .)
mat BN=A1N\A2N

matrix colnames BN = "Mean" "Min" "Max" "N"

}
local rname ""
foreach var in $var1 {
local lbl : variable label `var'
local rname `"  `rname'   "`lbl'" " " "'		
}	

mat C= BN

xml_tab BN,  save("$table${slash}ESS4_MisclassificationNEW.xml") replace sheet("Table 1", nogridlines)  ///
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') ///
rblanks(COL_NAMES "Plot level data" S2220)	 /// Adds blank columns which are used to separate Treatment and Control graphically.
title(Table 1: ESS4 - CG germplasm )  font("Times New Roman" 10) ///
cw(0 110, 1 55, 2 30, 3 30, 4 40, 5 55, 6 30, 7 30, 8 40, 9 55, 10 30, 11 30, 12 40, 13 55,  14 30,  15 30, 16 40, 17 55, 18 30, 19 30, 20 40, 21 55, 22 30, 23 30, 24 40, 25 55, 26 30, 27 30, 28 40, 29 55, 30 30, 31 30, 32 40, 33 55, 34 30, 35 30, 36 40, 37 55, 38 30, 39 30, 40 40  ) /// *Adjust the column width of the table, column 0 are the variable names* 1, 5 and 9 are the blank columns. 
	format((SCLR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0))  /// * format the columns. Each parentheses represents one column*
	star(.1 .05 .01)  /// Define your star values/signs here (which are stored in B_STARS)
	lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 2)  /// Draws lines in specific format (Numeric Value)
	notes(Point estimates are weighted sample means. Standard errors are reported below. Sub-sample of national sample used. ) //Add your notes here


* CG germplasm & purity levels
* Purity cut-off: 70
foreach i in maize barley sorghum { 
	*True positive
g       `i'_tp2a=.
replace `i'_tp2a=0 if `i'==1 
replace `i'_tp2a=1 if `i'==1 & cg_source=="Yes" & puritypuritypercent>=70  & (s4q11>1 & s4q11!=.)

	*True negative
g       `i'_tn2a=.
replace `i'_tn2a=0 if `i'==1
replace `i'_tn2a=1 if `i'==1 & cg_source=="Yes" & puritypuritypercent<70 &  (s4q11==1)

	*False positive (improved when traditional)
g       `i'_fp2a=.
replace `i'_fp2a=0 if `i'==1
replace `i'_fp2a=1 if `i'==1 & cg_source=="Yes" & puritypuritypercent<70 & (s4q11>1 & s4q11!=.)

	*False negative (traditional when improved)
g       `i'_fn2a=.
replace `i'_fn2a=0 if `i'==1
replace `i'_fn2a=1 if `i'==1 & cg_source=="Yes" & puritypuritypercent>=70 & (s4q11==1)

}
* Purity cut-off: 90
foreach i in maize barley sorghum { 
	*True positive
g       `i'_tp2b=.
replace `i'_tp2b=0 if `i'==1 
replace `i'_tp2b=1 if `i'==1 & cg_source=="Yes" & puritypuritypercent>=90  & (s4q11>1 & s4q11!=.)

	*True negative
g       `i'_tn2b=.
replace `i'_tn2b=0 if `i'==1
replace `i'_tn2b=1 if `i'==1 & cg_source=="Yes" & puritypuritypercent<90 &  (s4q11==1)

	*False positive (improved when traditional)
g       `i'_fp2b=.
replace `i'_fp2b=0 if `i'==1
replace `i'_fp2b=1 if `i'==1 & cg_source=="Yes" & puritypuritypercent<90 & (s4q11>1 & s4q11!=.)

	*False negative (traditional when improved)
g       `i'_fn2b=.
replace `i'_fn2b=0 if `i'==1
replace `i'_fn2b=1 if `i'==1 & cg_source=="Yes" & puritypuritypercent>=90 & (s4q11==1)

}
* Purity cut-off: 95
foreach i in maize barley sorghum { 
	*True positive
g       `i'_tp2c=.
replace `i'_tp2c=0 if `i'==1 
replace `i'_tp2c=1 if `i'==1 & cg_source=="Yes" & puritypuritypercent>=95  & (s4q11>1 & s4q11!=.)

	*True negative
g       `i'_tn2c=.
replace `i'_tn2c=0 if `i'==1
replace `i'_tn2c=1 if `i'==1 & cg_source=="Yes" & puritypuritypercent<95 &  (s4q11==1)

	*False positive (improved when traditional)
g       `i'_fp2c=.
replace `i'_fp2c=0 if `i'==1
replace `i'_fp2c=1 if `i'==1 & cg_source=="Yes" & puritypuritypercent<95 & (s4q11>1 & s4q11!=.)

	*False negative (traditional when improved)
g       `i'_fn2c=.
replace `i'_fn2c=0 if `i'==1
replace `i'_fn2c=1 if `i'==1 & cg_source=="Yes" & puritypuritypercent>=95 & (s4q11==1)

}

* Table - CG Germplasm by purity level
global var2    maize_tp2a maize_tn2a maize_fp2a maize_fn2a maize_tp2b maize_tn2b maize_fp2b maize_fn2b maize_tp2c maize_tn2c maize_fp2c maize_fn2c barley_tp2a barley_tn2a barley_fp2a barley_fn2a barley_tp2b barley_tn2b barley_fp2b barley_fn2b barley_tp2c barley_tn2c barley_fp2c barley_fn2c sorghum_tp2a sorghum_tn2a sorghum_fp2a sorghum_fn2a sorghum_tp2b sorghum_tn2b sorghum_fp2b sorghum_fn2b sorghum_tp2c sorghum_tn2c sorghum_fp2c sorghum_fn2c

matrix drop _all
foreach var in $var2 {

	mean `var' [pw=pw_w4] if wave==4
	matrix  `var'meanrN=e(b)'
	matrix define `var'VN= e(V)'
	matrix define `var'VVN=(vecdiag(`var'VN))'
	matrix list `var'VVN
	scalar `var'seN=sqrt(`var'VVN[1,1])

	sum    `var'  if  wave==4
	scalar `var'minrN=r(min)
	scalar `var'maxrN=r(max)
	scalar `var'nN=r(N)

	qui sum region if  wave==4
	local obsrN=r(N)



matrix mat`var'N  = ( `var'meanrN, `var'minrN, `var'maxrN, `var'nN)
matrix mat1`var'N= (`var'seN, ., ., .)

matrix list mat`var'N

matrix A1N = nullmat(A1N)\ mat`var'N\mat1`var'N


mat A2N=(`obsrN', . , ., .)
mat BN=A1N\A2N

matrix colnames BN = "Mean" "Min" "Max" "N"

}

local rname ""
foreach var in $var2 {
	local lbl : variable label `var'
	local rname `"  `rname'   "`lbl'" " " "'		
}	

mat C= BN

xml_tab BN ,  save("$table${slash}ESS4_MisclassificationNEW.xml") append sheet("Table 2", nogridlines)  ///
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') ///
rblanks(COL_NAMES "Plot level data" S2220)	                   /// 
title(Table 2: ESS4 - CG germplasm & purity level)  font("Times New Roman" 10) ///
cw(0 110, 1 55, 2 30, 3 30, 4 40, 5 55, 6 30, 7 30, 8 40, 9 55, 10 30, 11 30, 12 40, 13 55,  14 30,  15 30, 16 40, 17 55, 18 30, 19 30, 20 40, 21 55, 22 30, 23 30, 24 40, 25 55, 26 30, 27 30, 28 40, 29 55, 30 30, 31 30, 32 40, 33 55, 34 30, 35 30, 36 40, 37 55, 38 30, 39 30, 40 40  ) /// 
format((SCLR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0))  /// 
star(.1 .05 .01) lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 2)  /// 
notes(Point estimates are weighted sample means. Standard errors are reported below. Sub-sample of national sample used. ) //Add your notes here

***********************************	
* CG Germplasm and year of release
***********************************

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

* Year cut-off: 1990
foreach i in maize barley sorghum {
	* True positive
	g       `i'_tp3a=.
	replace `i'_tp3a=0 if `i'==1 
	replace `i'_tp3a=1 if `i'==1 & cg_source=="Yes" & year<1990 & (s4q11>1 & s4q11!=.)

	* True negative
	g       `i'_tn3a=.
	replace `i'_tn3a=0 if `i'==1
	replace `i'_tn3a=1 if `i'==1 & cg_source=="Yes" &  year>=1990 &  (s4q11==1)

	* False positive (improved when traditional)
	g       `i'_fp3a=.
	replace `i'_fp3a=0 if `i'==1
	replace `i'_fp3a=1 if `i'==1 & cg_source=="Yes" & year>=1990  & (s4q11>1 & s4q11!=.)

	* False negative (traditional when improved)
	g       `i'_fn3a=.
	replace `i'_fn3a=0 if `i'==1
	replace `i'_fn3a=1 if `i'==1 & cg_source=="Yes" & year<1990 & (s4q11==1)

}
* Year: 1990- 2000
foreach i in maize barley sorghum { 
	* True positive
	g       `i'_tp3b=.
	replace `i'_tp3b=0 if `i'==1 
	replace `i'_tp3b=1 if `i'==1 & cg_source=="Yes" & (year>=1990 & year<2000) & (s4q11>1 & s4q11!=.)
	
	* True negative
	g       `i'_tn3b=.
	replace `i'_tn3b=0 if `i'==1
	replace `i'_tn3b=1 if `i'==1 & cg_source=="Yes" &  (year<1990 | year>=2000) &  (s4q11==1)
	
	* False positive (improved when traditional)
	g       `i'_fp3b=.
	replace `i'_fp3b=0 if `i'==1
	replace `i'_fp3b=1 if `i'==1 & cg_source=="Yes" & (year<1990 | year>=2000) & (s4q11>1 & s4q11!=.)
	
	* False negative (traditional when improved)
	g       `i'_fn3b=.
	replace `i'_fn3b=0 if `i'==1
	replace `i'_fn3b=1 if `i'==1 & cg_source=="Yes" & (year>=1990 & year<2000)  & (s4q11==1)

}
* Year: 2000-2010
foreach i in maize barley sorghum { 
	* True positive
	g       `i'_tp3c=.
	replace `i'_tp3c=0 if `i'==1 
	replace `i'_tp3c=1 if `i'==1 & cg_source=="Yes" & (year>=2000 & year<2010) & (s4q11>1 & s4q11!=.)
	
	* True negative
	g       `i'_tn3c=.
	replace `i'_tn3c=0 if `i'==1
	replace `i'_tn3c=1 if `i'==1 & cg_source=="Yes" &  (year<2000 | year>=2010) &  (s4q11==1)
	
	* False positive (improved when traditional)
	g       `i'_fp3c=.
	replace `i'_fp3c=0 if `i'==1
	replace `i'_fp3c=1 if `i'==1 & cg_source=="Yes" & (year<2000 | year>=2010) & (s4q11>1 & s4q11!=.)
	
	* False negative (traditional when improved)
	g       `i'_fn3c=.
	replace `i'_fn3c=0 if `i'==1
	replace `i'_fn3c=1 if `i'==1 & cg_source=="Yes" & (year>=2000 & year<2010)  & (s4q11==1)

}
* Year: 2010-2020
foreach i in maize barley sorghum { 
	* True positive
	g       `i'_tp3d=.
	replace `i'_tp3d=0 if `i'==1 
	replace `i'_tp3d=1 if `i'==1 & cg_source=="Yes" & (year>=2010 & year<2020) & (s4q11>1 & s4q11!=.)
	
	* True negative
	g       `i'_tn3d=.
	replace `i'_tn3d=0 if `i'==1
	replace `i'_tn3d=1 if `i'==1 & cg_source=="Yes" &  (year<2010 | year>=2020) &  (s4q11==1)
	
	* False positive (improved when traditional)
	g       `i'_fp3d=.
	replace `i'_fp3d=0 if `i'==1
	replace `i'_fp3d=1 if `i'==1 & cg_source=="Yes" & (year<2010 | year>=2020) & (s4q11>1 & s4q11!=.)
	
	* False negative (traditional when improved)
	g       `i'_fn3d=.
	replace `i'_fn3d=0 if `i'==1
	replace `i'_fn3d=1 if `i'==1 & cg_source=="Yes" & (year>=2010 & year<2020)  & (s4q11==1)

}

* Table
global var3   maize_tp3a maize_tn3a maize_fp3a maize_fn3a maize_tp3b maize_tn3b maize_fp3b maize_fn3b maize_tp3c maize_tn3c maize_fp3c maize_fn3c maize_tp3d maize_tn3d maize_fp3d maize_fn3d barley_tp3a barley_tn3a barley_fp3a barley_fn3a barley_tp3b barley_tn3b barley_fp3b barley_fn3b barley_tp3c barley_tn3c barley_fp3c barley_fn3c barley_tp3d barley_tn3d barley_fp3d barley_fn3d sorghum_tp3a sorghum_tn3a sorghum_fp3a sorghum_fn3a sorghum_tp3b sorghum_tn3b sorghum_fp3b sorghum_fn3b sorghum_tp3c sorghum_tn3c sorghum_fp3c sorghum_fn3c sorghum_tp3d sorghum_tn3d sorghum_fp3d sorghum_fn3d

matrix drop _all
foreach var in $var3 {

	mean `var' [pw=pw_w4] if wave==4
	matrix  `var'meanrN=e(b)'
	matrix define `var'VN= e(V)'
	matrix define `var'VVN=(vecdiag(`var'VN))'
	matrix list `var'VVN
	scalar `var'seN=sqrt(`var'VVN[1,1])
	
	sum    `var'  if  wave==4
	scalar `var'minrN=r(min)
	scalar `var'maxrN=r(max)
	scalar `var'nN=r(N)
	
	qui sum region if  wave==4
	local obsrN=r(N)

matrix mat`var'N  = ( `var'meanrN, `var'minrN, `var'maxrN, `var'nN)
matrix mat1`var'N= (`var'seN, ., ., .)

matrix list mat`var'N

matrix A1N = nullmat(A1N)\ mat`var'N\mat1`var'N


mat A2N=(`obsrN', . , ., .)
mat BN=A1N\A2N

matrix colnames BN = "Mean" "Min" "Max" "N"

}
local rname ""
foreach var in $var3 {
local lbl : variable label `var'
local rname `"  `rname'   "`lbl'" " " "'		
}	

mat C= BN


xml_tab BN ,  save("$table${slash}ESS4_MisclassificationNEW.xml") append sheet("Table 3", nogridlines)  ///
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') ///
rblanks(COL_NAMES "Plot level data" S2220)	 ///
title(Table 3: ESS4 - CG germplasm & Year of release)  font("Times New Roman" 10) ///
cw(0 110, 1 55, 2 30, 3 30, 4 40, 5 55, 6 30, 7 30, 8 40, 9 55, 10 30, 11 30, 12 40, 13 55,  14 30,  15 30, 16 40, 17 55, 18 30, 19 30, 20 40, 21 55, 22 30, 23 30, 24 40, 25 55, 26 30, 27 30, 28 40, 29 55, 30 30, 31 30, 32 40, 33 55, 34 30, 35 30, 36 40, 37 55, 38 30, 39 30, 40 40  ) /// 
format((SCLR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0))  /// 
star(.1 .05 .01) lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 2)  ///
notes(Point estimates are weighted sample means. Standard errors are reported below. Sub-sample of national sample used.)

************************
	*Cumulative years
************************
* After 1990
foreach i in maize barley sorghum {
	* True positive
	g       `i'_tp3abis=.
	replace `i'_tp3abis=0 if `i'==1 
	replace `i'_tp3abis=1 if `i'==1 & cg_source=="Yes" & year>=1990 & (s4q11>1 & s4q11!=.)
	
	*True negative
	g       `i'_tn3abis=.
	replace `i'_tn3abis=0 if `i'==1
	replace `i'_tn3abis=1 if `i'==1 & cg_source=="Yes" &  year<1990 &  (s4q11==1)
	
	*False positive (improved when traditional)
	g       `i'_fp3abis=.
	replace `i'_fp3abis=0 if `i'==1
	replace `i'_fp3abis=1 if `i'==1 & cg_source=="Yes" & year<1990  & (s4q11>1 & s4q11!=.)
	
	*False negative (traditional when improved)
	g       `i'_fn3abis=.
	replace `i'_fn3abis=0 if `i'==1
	replace `i'_fn3abis=1 if `i'==1 & cg_source=="Yes" & year>=1990 & (s4q11==1)

}
* After 2000
foreach i in maize barley sorghum { 
    * True positive
	g       `i'_tp3bbis=.
	replace `i'_tp3bbis=0 if `i'==1 
	replace `i'_tp3bbis=1 if `i'==1 & cg_source=="Yes" & (year>=2000) & (s4q11>1 & s4q11!=.)
	
	* True negative
	g       `i'_tn3bbis=.
	replace `i'_tn3bbis=0 if `i'==1
	replace `i'_tn3bbis=1 if `i'==1 & cg_source=="Yes" &  (year<2000) &  (s4q11==1)
	
	* False positive (improved when traditional)
	g       `i'_fp3bbis=.
	replace `i'_fp3bbis=0 if `i'==1
	replace `i'_fp3bbis=1 if `i'==1 & cg_source=="Yes" &  (year<2000) & (s4q11>1 & s4q11!=.)
	
	* False negative (traditional when improved)
	g       `i'_fn3bbis=.
	replace `i'_fn3bbis=0 if `i'==1
	replace `i'_fn3bbis=1 if `i'==1 & cg_source=="Yes" &  (year>=2000)  & (s4q11==1)

}
* After 2010
foreach i in maize barley sorghum { 
	* True positive
	g       `i'_tp3cbis=.
	replace `i'_tp3cbis=0 if `i'==1 
	replace `i'_tp3cbis=1 if `i'==1 & cg_source=="Yes" & (year>=2010) & (s4q11>1 & s4q11!=.)
	
	* True negative
	g       `i'_tn3cbis=.
	replace `i'_tn3cbis=0 if `i'==1
	replace `i'_tn3cbis=1 if `i'==1 & cg_source=="Yes" &  (year<2010) &  (s4q11==1)
	
	* False positive (improved when traditional)
	g       `i'_fp3cbis=.
	replace `i'_fp3cbis=0 if `i'==1
	replace `i'_fp3cbis=1 if `i'==1 & cg_source=="Yes" & (year<2010) & (s4q11>1 & s4q11!=.)
	
	* False negative (traditional when improved)
	g       `i'_fn3cbis=.
	replace `i'_fn3cbis=0 if `i'==1
	replace `i'_fn3cbis=1 if `i'==1 & cg_source=="Yes" & (year>=2010)  & (s4q11==1)

}
* Table
global var3b   maize_tp3abis maize_tn3abis maize_fp3abis maize_fn3abis maize_tp3bbis maize_tn3bbis maize_fp3bbis maize_fn3bbis maize_tp3cbis maize_tn3cbis maize_fp3cbis maize_fn3cbis barley_tp3abis barley_tn3abis barley_fp3abis barley_fn3abis barley_tp3bbis barley_tn3bbis barley_fp3bbis barley_fn3bbis barley_tp3cbis barley_tn3cbis barley_fp3cbis barley_fn3cbis sorghum_tp3abis sorghum_tn3abis sorghum_fp3abis sorghum_fn3abis sorghum_tp3bbis sorghum_tn3bbis sorghum_fp3bbis sorghum_fn3bbis sorghum_tp3cbis sorghum_tn3cbis sorghum_fp3cbis sorghum_fn3cbis 

matrix drop _all
foreach var in $var3b {

	mean `var' [pw=pw_w4] if wave==4
	matrix  `var'meanrN=e(b)'
	matrix define `var'VN= e(V)'
	matrix define `var'VVN=(vecdiag(`var'VN))'
	matrix list `var'VVN
	scalar `var'seN=sqrt(`var'VVN[1,1])
	
	sum    `var'  if  wave==4
	scalar `var'minrN=r(min)
	scalar `var'maxrN=r(max)
	scalar `var'nN=r(N)
	
	qui sum region if  wave==4
	local obsrN=r(N)

matrix mat`var'N  = ( `var'meanrN, `var'minrN, `var'maxrN, `var'nN)
matrix mat1`var'N= (`var'seN, ., ., .)
matrix list mat`var'N
matrix A1N = nullmat(A1N)\ mat`var'N\mat1`var'N
mat A2N=(`obsrN', . , ., .)
mat BN=A1N\A2N
matrix colnames BN = "Mean" "Min" "Max" "N"

}

local rname ""
foreach var in $var3b {
	local lbl : variable label `var'
	local rname `"  `rname'   "`lbl'" " " "'		
}	

mat C= BN

xml_tab BN ,  save("$table${slash}ESS4_MisclassificationNEW.xml") append sheet("Table 3b", nogridlines)  ///
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') ///
rblanks(COL_NAMES "Plot level data" S2220)	 /// 
title(Table 3b: ESS4 - CG germplasm & Year of release - cumulative)  font("Times New Roman" 10) ///
cw(0 110, 1 55, 2 30, 3 30, 4 40, 5 55, 6 30, 7 30, 8 40, 9 55, 10 30, 11 30, 12 40, 13 55,  14 30,  15 30, 16 40, 17 55, 18 30, 19 30, 20 40, 21 55, 22 30, 23 30, 24 40, 25 55, 26 30, 27 30, 28 40, 29 55, 30 30, 31 30, 32 40, 33 55, 34 30, 35 30, 36 40, 37 55, 38 30, 39 30, 40 40  ) /// 
format((SCLR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0))  ///
star(.1 .05 .01) lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 2)  /// 
notes(Point estimates are weighted sample means. Standard errors are reported below. Sub-sample of national sample used. ) 

* NB of obs // additional
global var3brel  maize_tp3abis maize_fn3abis maize_tp3bbis maize_fn3bbis maize_tp3cbis maize_fn3cbis barley_tp3abis barley_fn3abis barley_tp3bbis barley_fn3bbis barley_tp3cbis barley_fn3cbis sorghum_tp3abis sorghum_fn3abis sorghum_tp3bbis sorghum_fn3bbis sorghum_tp3cbis sorghum_fn3cbis 

foreach var in $var3brel {
	tab `var'
}


****************************************************************************
	* EXOTIC GERMPLASM (NOT IN THE REPORT)
********************************************************************************
* Exotic  only

foreach i in maize barley sorghum { 
	* True positive
	g       `i'_tp4=.
	replace `i'_tp4=0 if `i'==1 
	replace `i'_tp4=1 if `i'==1 & exotic_source=="Yes" & (s4q11>1 & s4q11!=.)
	
	* True negative
	g       `i'_tn4=.
	replace `i'_tn4=0 if `i'==1
	replace `i'_tn4=1 if `i'==1 & exotic_source=="No" & (s4q11==1)
	
	* False positive (improved when traditional)
	g       `i'_fp4=.
	replace `i'_fp4=0 if `i'==1
	replace `i'_fp4=1 if `i'==1 & exotic_source=="No" & (s4q11>1 & s4q11!=.)
	
	* False negative (traditional when improved)
	g       `i'_fn4=.
	replace `i'_fn4=0 if `i'==1
	replace `i'_fn4=1 if `i'==1 & exotic_source=="Yes" & (s4q11==1)

}


global var4    maize_tp4 maize_tn4 maize_fp4 maize_fn4 barley_tp4 barley_tn4 barley_fp4 barley_fn4 sorghum_tp4 sorghum_tn4 sorghum_fp4 sorghum_fn4

matrix drop _all
foreach var in $var4 {

	mean `var' [pw=pw_w4] if wave==4
	matrix  `var'meanrN=e(b)'
	matrix define `var'VN= e(V)'
	matrix define `var'VVN=(vecdiag(`var'VN))'
	matrix list `var'VVN
	scalar `var'seN=sqrt(`var'VVN[1,1])

	sum    `var'  if  wave==4
	scalar `var'minrN=r(min)
	scalar `var'maxrN=r(max)
	scalar `var'nN=r(N)

	qui sum region if  wave==4
	local obsrN=r(N)



matrix mat`var'N  = ( `var'meanrN, `var'minrN, `var'maxrN, `var'nN)
matrix mat1`var'N= (`var'seN, ., ., .)
matrix list mat`var'N
matrix A1N = nullmat(A1N)\ mat`var'N\mat1`var'N
mat A2N=(`obsrN', . , ., .)
mat BN=A1N\A2N
matrix colnames BN = "Mean" "Min" "Max" "N"

}

local rname ""
foreach var in $var4 {
	local lbl : variable label `var'
	local rname `"  `rname'   "`lbl'" " " "'		
}	

mat C= BN

xml_tab BN ,  save("$table${slash}ESS4_MisclassificationNEW.xml") append sheet("Table 4", nogridlines)  ///
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') ///
rblanks(COL_NAMES "Plot level data" S2220) title(Table 4: ESS4 - Exotic germplasm )  font("Times New Roman" 10) ///
cw(0 110, 1 55, 2 30, 3 30, 4 40, 5 55, 6 30, 7 30, 8 40, 9 55, 10 30, 11 30, 12 40, 13 55,  14 30,  15 30, 16 40, 17 55, 18 30, 19 30, 20 40, 21 55, 22 30, 23 30, 24 40, 25 55, 26 30, 27 30, 28 40, 29 55, 30 30, 31 30, 32 40, 33 55, 34 30, 35 30, 36 40, 37 55, 38 30, 39 30, 40 40  ) /// 
format((SCLR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0))  /// 
star(.1 .05 .01) lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 2)  ///
notes(Point estimates are weighted sample means. Standard errors are reported below. Sub-sample of national sample used. ) 


* CG germplasm & purity levels

foreach i in maize barley sorghum { 
	* True positive
	g       `i'_tp5a=.
	replace `i'_tp5a=0 if `i'==1 
	replace `i'_tp5a=1 if `i'==1 & exotic_source=="Yes" & puritypuritypercent>=70  & (s4q11>1 & s4q11!=.)
	
	* True negative
	g       `i'_tn5a=.
	replace `i'_tn5a=0 if `i'==1
	replace `i'_tn5a=1 if `i'==1 & exotic_source=="Yes" & puritypuritypercent<70 &  (s4q11==1)
	
	* False positive (improved when traditional)
	g       `i'_fp5a=.
	replace `i'_fp5a=0 if `i'==1
	replace `i'_fp5a=1 if `i'==1 & exotic_source=="Yes" & puritypuritypercent<70 & (s4q11>1 & s4q11!=.)
	
	* False negative (traditional when improved)
	g       `i'_fn5a=.
	replace `i'_fn5a=0 if `i'==1
	replace `i'_fn5a=1 if `i'==1 & exotic_source=="Yes" & puritypuritypercent>=70 & (s4q11==1)
}

foreach i in maize barley sorghum { 
	* True positive
	g       `i'_tp5b=.
	replace `i'_tp5b=0 if `i'==1 
	replace `i'_tp5b=1 if `i'==1 & exotic_source=="Yes" & puritypuritypercent>=90  & (s4q11>1 & s4q11!=.)
	
	* True negative
	g       `i'_tn5b=.
	replace `i'_tn5b=0 if `i'==1
	replace `i'_tn5b=1 if `i'==1 & exotic_source=="Yes" & puritypuritypercent<90 &  (s4q11==1)
	
	* False positive (improved when traditional)
	g       `i'_fp5b=.
	replace `i'_fp5b=0 if `i'==1
	replace `i'_fp5b=1 if `i'==1 & exotic_source=="Yes" & puritypuritypercent<90 & (s4q11>1 & s4q11!=.)
	
	* False negative (traditional when improved)
	g       `i'_fn5b=.
	replace `i'_fn5b=0 if `i'==1
	replace `i'_fn5b=1 if `i'==1 & exotic_source=="Yes" & puritypuritypercent>=90 & (s4q11==1)

}

foreach i in maize barley sorghum { 
	* True positive
	g       `i'_tp5c=.
	replace `i'_tp5c=0 if `i'==1 
	replace `i'_tp5c=1 if `i'==1 & exotic_source=="Yes" & puritypuritypercent>=95  & (s4q11>1 & s4q11!=.)
	
	* True negative
	g       `i'_tn5c=.
	replace `i'_tn5c=0 if `i'==1
	replace `i'_tn5c=1 if `i'==1 & exotic_source=="Yes" & puritypuritypercent<95 &  (s4q11==1)
	
	* False positive (improved when traditional)
	g       `i'_fp5c=.
	replace `i'_fp5c=0 if `i'==1
	replace `i'_fp5c=1 if `i'==1 & exotic_source=="Yes" & puritypuritypercent<95 & (s4q11>1 & s4q11!=.)
	
	* False negative (traditional when improved)
	g       `i'_fn5c=.
	replace `i'_fn5c=0 if `i'==1
	replace `i'_fn5c=1 if `i'==1 & exotic_source=="Yes" & puritypuritypercent>=95 & (s4q11==1)

}


global var5    maize_tp5a maize_tn5a maize_fp5a maize_fn5a maize_tp5b maize_tn5b maize_fp5b maize_fn5b maize_tp5c maize_tn5c maize_fp5c maize_fn5c barley_tp5a barley_tn5a barley_fp5a barley_fn5a barley_tp5b barley_tn5b barley_fp5b barley_fn5b barley_tp5c barley_tn5c barley_fp5c barley_fn5c sorghum_tp5a sorghum_tn5a sorghum_fp5a sorghum_fn5a sorghum_tp5b sorghum_tn5b sorghum_fp5b sorghum_fn5b sorghum_tp5c sorghum_tn5c sorghum_fp5c sorghum_fn5c

matrix drop _all
foreach var in $var5 {

	mean `var' [pw=pw_w4] if wave==4
	matrix  `var'meanrN=e(b)'
	matrix define `var'VN= e(V)'
	matrix define `var'VVN=(vecdiag(`var'VN))'
	matrix list `var'VVN
	scalar `var'seN=sqrt(`var'VVN[1,1])
	
	sum    `var'  if  wave==4
	scalar `var'minrN=r(min)
	scalar `var'maxrN=r(max)
	scalar `var'nN=r(N)
	
	qui sum region if  wave==4
	local obsrN=r(N)
	
	matrix mat`var'N  = ( `var'meanrN, `var'minrN, `var'maxrN, `var'nN)
	matrix mat1`var'N= (`var'seN, ., ., .)
	
	matrix list mat`var'N
	
	matrix A1N = nullmat(A1N)\ mat`var'N\mat1`var'N
	
	
	mat A2N=(`obsrN', . , ., .)
	mat BN=A1N\A2N
	
	matrix colnames BN = "Mean" "Min" "Max" "N"

}
local rname ""
foreach var in $var5 {
	local lbl : variable label `var'
	local rname `"  `rname'   "`lbl'" " " "'		
}	

mat C= BN


xml_tab BN ,  save("$table${slash}ESS4_MisclassificationNEW.xml") append sheet("Table 5", nogridlines)  ///
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') ///
rblanks(COL_NAMES "Plot level data" S2220)	 /// 
title(Table 5: ESS4 - Exotic germplasm & purity level)  font("Times New Roman" 10) ///
cw(0 110, 1 55, 2 30, 3 30, 4 40, 5 55, 6 30, 7 30, 8 40, 9 55, 10 30, 11 30, 12 40, 13 55,  14 30,  15 30, 16 40, 17 55, 18 30, 19 30, 20 40, 21 55, 22 30, 23 30, 24 40, 25 55, 26 30, 27 30, 28 40, 29 55, 30 30, 31 30, 32 40, 33 55, 34 30, 35 30, 36 40, 37 55, 38 30, 39 30, 40 40  ) /// 
format((SCLR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0))  /// 
star(.1 .05 .01)  /// 
lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 2)  /// 
notes(Point estimates are weighted sample means. Standard errors are reported below. Sub-sample of national sample used. ) 

***************************************
* Exotic Germplasm and year of release
***************************************
* Before 1990
foreach i in maize barley sorghum {
	* True positive
	g       `i'_tp6a=.
	replace `i'_tp6a=0 if `i'==1 
	replace `i'_tp6a=1 if `i'==1 & exotic_source=="Yes" & year<1990 & (s4q11>1 & s4q11!=.)
	
	* True negative
	g       `i'_tn6a=.
	replace `i'_tn6a=0 if `i'==1
	replace `i'_tn6a=1 if `i'==1 & exotic_source=="Yes" &  year>=1990 &  (s4q11==1)
	
	* False positive (improved when traditional)
	g       `i'_fp6a=.
	replace `i'_fp6a=0 if `i'==1
	replace `i'_fp6a=1 if `i'==1 & exotic_source=="Yes" & year>=1990 & (s4q11>1 & s4q11!=.)
	
	* False negative (traditional when improved)
	g       `i'_fn6a=.
	replace `i'_fn6a=0 if `i'==1
	replace `i'_fn6a=1 if `i'==1 & exotic_source=="Yes" & year<1990 & (s4q11==1)

}
* 1990- 2000
foreach i in maize barley sorghum { 
	g       `i'_tp6b=.
	replace `i'_tp6b=0 if `i'==1 
	replace `i'_tp6b=1 if `i'==1 & exotic_source=="Yes" & (year>=1990 & year<2000) & (s4q11>1 & s4q11!=.)
	
	*True negative
	g       `i'_tn6b=.
	replace `i'_tn6b=0 if `i'==1
	replace `i'_tn6b=1 if `i'==1 & exotic_source=="Yes" &  (year<1990 | year>=2000) &  (s4q11==1)
	
	*False positive (improved when traditional)
	g       `i'_fp6b=.
	replace `i'_fp6b=0 if `i'==1
	replace `i'_fp6b=1 if `i'==1 & exotic_source=="Yes" & (year<1990 | year>=2000) & (s4q11>1 & s4q11!=.)
	
	*False negative (traditional when improved)
	g       `i'_fn6b=.
	replace `i'_fn6b=0 if `i'==1
	replace `i'_fn6b=1 if `i'==1 & exotic_source=="Yes" & (year>=1990 & year<2000)  & (s4q11==1)

}
* 2000-2010
foreach i in maize barley sorghum { 
	* True positive
	g       `i'_tp6c=.
	replace `i'_tp6c=0 if `i'==1 
	replace `i'_tp6c=1 if `i'==1 & exotic_source=="Yes" & (year>=2000 & year<2010) & (s4q11>1 & s4q11!=.)
	
	*True negative
	g       `i'_tn6c=.
	replace `i'_tn6c=0 if `i'==1
	replace `i'_tn6c=1 if `i'==1 & exotic_source=="Yes" &  (year<2000 | year>=2010) &  (s4q11==1)
	
	*False positive (improved when traditional)
	g       `i'_fp6c=.
	replace `i'_fp6c=0 if `i'==1
	replace `i'_fp6c=1 if `i'==1 & exotic_source=="Yes" & (year<2000 | year>=2010) & (s4q11>1 & s4q11!=.)
	
	*False negative (traditional when improved)
	g       `i'_fn6c=.
	replace `i'_fn6c=0 if `i'==1
	replace `i'_fn6c=1 if `i'==1 & exotic_source=="Yes" & (year>=2000 & year<2010)  & (s4q11==1)
	
}
* 2010-2020
foreach i in maize barley sorghum { 
	* True positive
	g       `i'_tp6d=.
	replace `i'_tp6d=0 if `i'==1 
	replace `i'_tp6d=1 if `i'==1 & exotic_source=="Yes" & (year>=2010 & year<2020) & (s4q11>1 & s4q11!=.)
	
	* True negative
	g       `i'_tn6d=.
	replace `i'_tn6d=0 if `i'==1
	replace `i'_tn6d=1 if `i'==1 & exotic_source=="Yes" &  (year<2010 | year>=2020) &  (s4q11==1)
	
	* False positive (improved when traditional)
	g       `i'_fp6d=.
	replace `i'_fp6d=0 if `i'==1
	replace `i'_fp6d=1 if `i'==1 & exotic_source=="Yes" & (year<2010 | year>=2020) & (s4q11>1 & s4q11!=.)
	
	* False negative (traditional when improved)
	g       `i'_fn6d=.
	replace `i'_fn6d=0 if `i'==1
	replace `i'_fn6d=1 if `i'==1 & exotic_source=="Yes" & (year>=2010 & year<2020)  & (s4q11==1)

}

global var6    maize_tp6a maize_tn6a maize_fp6a maize_fn6a maize_tp6b maize_tn6b maize_fp6b maize_fn6b maize_tp6c maize_tn6c maize_fp6c maize_fn6c maize_tp6d maize_tn6d maize_fp6d maize_fn6d barley_tp6a barley_tn6a barley_fp6a barley_fn6a barley_tp6b barley_tn6b barley_fp6b barley_fn6b barley_tp6c barley_tn6c barley_fp6c barley_fn6c barley_tp6d barley_tn6d barley_fp6d barley_fn6d sorghum_tp6a sorghum_tn6a sorghum_fp6a sorghum_fn6a sorghum_tp6b sorghum_tn6b sorghum_fp6b sorghum_fn6b sorghum_tp6c sorghum_tn6c sorghum_fp6c sorghum_fn6c sorghum_tp6d sorghum_tn6d sorghum_fp6d sorghum_fn6d

matrix drop _all
foreach var in $var6 {

	mean `var' [pw=pw_w4] if wave==4
	matrix  `var'meanrN=e(b)'
	matrix define `var'VN= e(V)'
	matrix define `var'VVN=(vecdiag(`var'VN))'
	matrix list `var'VVN
	scalar `var'seN=sqrt(`var'VVN[1,1])
	sum    `var'  if  wave==4
	scalar `var'minrN=r(min)
	scalar `var'maxrN=r(max)
	scalar `var'nN=r(N)	
	qui sum region if  wave==4
	local obsrN=r(N)

matrix mat`var'N  = ( `var'meanrN, `var'minrN, `var'maxrN, `var'nN)
matrix mat1`var'N= (`var'seN, ., ., .)
matrix list mat`var'N
matrix A1N = nullmat(A1N)\ mat`var'N\mat1`var'N
mat A2N=(`obsrN', . , ., .)
mat BN=A1N\A2N
matrix colnames BN = "Mean" "Min" "Max" "N"

}
local rname ""
foreach var in $var6 {
	local lbl : variable label `var'
	local rname `"  `rname'   "`lbl'" " " "'		
}	

mat C= BN


xml_tab BN ,  save("$table${slash}ESS4_MisclassificationNEW.xml") append sheet("Table 6", nogridlines)  ///
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') ///
rblanks(COL_NAMES "Plot level data" S2220)	 /// 
title(Table 6: ESS4 - Exotic germplasm & Year of release)  font("Times New Roman" 10) ///
cw(0 110, 1 55, 2 30, 3 30, 4 40, 5 55, 6 30, 7 30, 8 40, 9 55, 10 30, 11 30, 12 40, 13 55,  14 30,  15 30, 16 40, 17 55, 18 30, 19 30, 20 40, 21 55, 22 30, 23 30, 24 40, 25 55, 26 30, 27 30, 28 40, 29 55, 30 30, 31 30, 32 40, 33 55, 34 30, 35 30, 36 40, 37 55, 38 30, 39 30, 40 40  ) /// 
format((SCLR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0))  /// 
star(.1 .05 .01)  ///
lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 2)  /// 
notes(Point estimates are weighted sample means. Standard errors are reported below. Sub-sample of national sample used. ) 

***********************************************
* Adoption estimates using DNA-fingerprinting
***********************************************
 * CG - GERMPLASM
foreach i in maize barley sorghum { 
	g       `i'_cg=.
	replace `i'_cg=0 if `i'==1 
	replace `i'_cg=1 if `i'==1 & cg_source=="Yes"
}
 * CG - GERMPLASM AND PURITY LEVEL	
foreach i in maize barley sorghum { 	
	g       `i'_cgp70=.
	replace `i'_cgp70=0 if `i'==1 
	replace `i'_cgp70=1 if `i'==1 & cg_source=="Yes" & puritypuritypercent>=70
	
	g       `i'_cgp90=.
	replace `i'_cgp90=0 if `i'==1 
	replace `i'_cgp90=1 if `i'==1 & cg_source=="Yes" & puritypuritypercent>=90
	
	g       `i'_cgp95=.
	replace `i'_cgp95=0 if `i'==1 
	replace `i'_cgp95=1 if `i'==1 & cg_source=="Yes" & puritypuritypercent>=95
}

 * CG - GERMPLASM AND YEAR OF RELEASE
foreach i in maize barley sorghum { 
	g       `i'_cgy1=.
	replace `i'_cgy1=0 if `i'==1 
	replace `i'_cgy1=1 if `i'==1 & cg_source=="Yes" & year<1990
	
	g       `i'_cgy2=.
	replace `i'_cgy2=0 if `i'==1 
	replace `i'_cgy2=1 if `i'==1 & cg_source=="Yes" & (year>=1990 & year<2000) 
	
	
	g       `i'_cgy3=.
	replace `i'_cgy3=0 if `i'==1 
	replace `i'_cgy3=1 if `i'==1 & cg_source=="Yes" & (year>=2000 & year<2010) 
	
	g       `i'_cgy4=.
	replace `i'_cgy4=0 if `i'==1 
	replace `i'_cgy4=1 if `i'==1 & cg_source=="Yes" & (year>=2010 & year<=2020) 
}

 * EXOTIC GERMPLASM 
foreach i in maize barley sorghum { 
	g       `i'_ex=.
	replace `i'_ex=0 if `i'==1 
	replace `i'_ex=1 if `i'==1 & exotic_source=="Yes"
}
* EXOTIC GERMPLASM & PURITY LEVEL	
foreach i in maize barley sorghum { 	
	g       `i'_exp70=.
	replace `i'_exp70=0 if `i'==1 
	replace `i'_exp70=1 if `i'==1 & exotic_source=="Yes" & puritypuritypercent>=70
	
	g       `i'_exp90=.
	replace `i'_exp90=0 if `i'==1 
	replace `i'_exp90=1 if `i'==1 & exotic_source=="Yes" & puritypuritypercent>=90
	
	g       `i'_exp95=.
	replace `i'_exp95=0 if `i'==1 
	replace `i'_exp95=1 if `i'==1 & exotic_source=="Yes" & puritypuritypercent>=95
}

* EXOTIC GERMPLASM & YEAR OF RELEASE
foreach i in maize barley sorghum { 
	g       `i'_exy1=.
	replace `i'_exy1=0 if `i'==1 
	replace `i'_exy1=1 if `i'==1 & exotic_source=="Yes" & year<1990
	
	g       `i'_exy2=.                                  
	replace `i'_exy2=0 if `i'==1                        
	replace `i'_exy2=1 if `i'==1 & exotic_source=="Yes" & (year>=1990 & year<2000) 
														
	g       `i'_exy3=.                                  
	replace `i'_exy3=0 if `i'==1                        
	replace `i'_exy3=1 if `i'==1 & exotic_source=="Yes" & (year>=2000 & year<2010)  
														
	g       `i'_exy4=.                                  
	replace `i'_exy4=0 if `i'==1                        
	replace `i'_exy4=1 if `i'==1 & exotic_source=="Yes" & (year>=2010 & year<=2020) 
}                                                   
                                                    


* UNCONDITIONAL - PURITY LEVEL
foreach i in maize barley sorghum { 	
	g       `i'_p70=.
	replace `i'_p70=0 if `i'==1 
	replace `i'_p70=1 if `i'==1  & puritypuritypercent>=70
	
	g       `i'_p90=.
	replace `i'_p90=0 if `i'==1 
	replace `i'_p90=1 if `i'==1  & puritypuritypercent>=90
	
	g       `i'_p95=.
	replace `i'_p95=0 if `i'==1 
	replace `i'_p95=1 if `i'==1  & puritypuritypercent>=95
}

* UNCONDITIONAL - YEAR OF RELEASE

foreach i in maize barley sorghum { 
	g       `i'_y1=.
	replace `i'_y1=0 if `i'==1 
	replace `i'_y1=1 if `i'==1 & year<1990
	
	g       `i'_y2=.
	replace `i'_y2=0 if `i'==1 
	replace `i'_y2=1 if `i'==1  & (year>=1990 & year<2000)
	
	g       `i'_y3=.
	replace `i'_y3=0 if `i'==1 
	replace `i'_y3=1 if `i'==1  & (year>=2000 & year<2010) 
	
	g       `i'_y4=.
	replace `i'_y4=0 if `i'==1 
	replace `i'_y4=1 if `i'==1  & (year>=2010 & year<=2020) 
}

 * Table 
global var7 maize_cg barley_cg sorghum_cg maize_cgp70 maize_cgp90 maize_cgp95 barley_cgp70 barley_cgp90 barley_cgp95 sorghum_cgp70 sorghum_cgp90 sorghum_cgp95 maize_cgy1 maize_cgy2 maize_cgy3 maize_cgy4 barley_cgy1 barley_cgy2 barley_cgy3 barley_cgy4 sorghum_cgy1 sorghum_cgy2 sorghum_cgy3 sorghum_cgy4 maize_ex barley_ex sorghum_ex maize_exp70 maize_exp90 maize_exp95 barley_exp70 barley_exp90 barley_exp95 sorghum_exp70 sorghum_exp90 sorghum_exp95 maize_exy1 maize_exy2 maize_exy3 maize_exy4 barley_exy1 barley_exy2 barley_exy3 barley_exy4 sorghum_exy1 sorghum_exy2 sorghum_exy3 sorghum_exy4 maize_p70 maize_p90 maize_p95 barley_p70 barley_p90 barley_p95 sorghum_p70 sorghum_p90 sorghum_p95 maize_y1 maize_y2 maize_y3 maize_y4 barley_y1 barley_y2 barley_y3 barley_y4 sorghum_y1 sorghum_y2 sorghum_y3 sorghum_y4

matrix drop _all
foreach var in $var7 {

	mean `var' [pw=pw_w4] if wave==4
	matrix  `var'meanrN=e(b)'
	matrix define `var'VN= e(V)'
	matrix define `var'VVN=(vecdiag(`var'VN))'
	matrix list `var'VVN
	scalar `var'seN=sqrt(`var'VVN[1,1])
	sum    `var'  if  wave==4
	scalar `var'minrN=r(min)
	scalar `var'maxrN=r(max)
	scalar `var'nN=r(N)
	qui sum region if  wave==4
	local obsrN=r(N)

matrix mat`var'N  = ( `var'meanrN, `var'minrN, `var'maxrN, `var'nN)
matrix mat1`var'N= (`var'seN, ., ., .)
matrix list mat`var'N
matrix A1N = nullmat(A1N)\ mat`var'N\mat1`var'N
mat A2N=(`obsrN', . , ., .)
mat BN=A1N\A2N
matrix colnames BN = "Mean" "Min" "Max" "N"

}
local rname ""
foreach var in $var7 {
	local lbl : variable label `var'
	local rname `"  `rname'   "`lbl'" " " "'		
}	

mat C= BN

xml_tab BN ,  save("$table${slash}ESS4_MisclassificationNEW.xml") append sheet("Table 7", nogridlines)  ///
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') ///
rblanks(COL_NAMES "Plot level data" S2220)	 /// 
title(Table 7: ESS4 - Related stats)  font("Times New Roman" 10) ///
cw(0 110, 1 55, 2 30, 3 30, 4 40, 5 55, 6 30, 7 30, 8 40, 9 55, 10 30, 11 30, 12 40, 13 55,  14 30,  15 30, 16 40, 17 55, 18 30, 19 30, 20 40, 21 55, 22 30, 23 30, 24 40, 25 55, 26 30, 27 30, 28 40, 29 55, 30 30, 31 30, 32 40, 33 55, 34 30, 35 30, 36 40, 37 55, 38 30, 39 30, 40 40  ) /// 
format((SCLR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0))  /// 
star(.1 .05 .01)  /// 
lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 2)  ///
notes(Point estimates are weighted sample means. Standard errors are reported below. Sub-sample of national sample used. ) 
	
* Misclassification: defining as improved by purity level

foreach i in maize barley sorghum { 
	* True positive
	g       `i'_tp8a=.
	replace `i'_tp8a=0 if `i'==1 
	replace `i'_tp8a=1 if `i'==1 & puritypuritypercent>=70  & (s4q11>1 & s4q11!=.)
	
	* True negative
	g       `i'_tn8a=.
	replace `i'_tn8a=0 if `i'==1
	replace `i'_tn8a=1 if `i'==1 & puritypuritypercent<70 &  (s4q11==1)
	
	* False positive (improved when traditional)
	g       `i'_fp8a=.
	replace `i'_fp8a=0 if `i'==1
	replace `i'_fp8a=1 if `i'==1  & puritypuritypercent<70 & (s4q11>1 & s4q11!=.)
	
	* False negative (traditional when improved)
	g       `i'_fn8a=.
	replace `i'_fn8a=0 if `i'==1
	replace `i'_fn8a=1 if `i'==1 & puritypuritypercent>=70 & (s4q11==1)

}

foreach i in maize barley sorghum { 
	* True positive
	g       `i'_tp8b=.
	replace `i'_tp8b=0 if `i'==1 
	replace `i'_tp8b=1 if `i'==1 & puritypuritypercent>=90  & (s4q11>1 & s4q11!=.)
	
	* True negative
	g       `i'_tn8b=.
	replace `i'_tn8b=0 if `i'==1
	replace `i'_tn8b=1 if `i'==1  & puritypuritypercent<90 &  (s4q11==1)
	
	* False positive (improved when traditional)
	g       `i'_fp8b=.
	replace `i'_fp8b=0 if `i'==1
	replace `i'_fp8b=1 if `i'==1  & puritypuritypercent<90 & (s4q11>1 & s4q11!=.)
	
	* False negative (traditional when improved)
	g       `i'_fn8b=.
	replace `i'_fn8b=0 if `i'==1
	replace `i'_fn8b=1 if `i'==1  & puritypuritypercent>=90 & (s4q11==1)

}

foreach i in maize barley sorghum { 
	* True positive
	g       `i'_tp8c=.
	replace `i'_tp8c=0 if `i'==1 
	replace `i'_tp8c=1 if `i'==1  & puritypuritypercent>=95  & (s4q11>1 & s4q11!=.)
	
	* True negative
	g       `i'_tn8c=.
	replace `i'_tn8c=0 if `i'==1
	replace `i'_tn8c=1 if `i'==1  & puritypuritypercent<95 &  (s4q11==1)
	
	* False positive (improved when traditional)
	g       `i'_fp8c=.
	replace `i'_fp8c=0 if `i'==1
	replace `i'_fp8c=1 if `i'==1  & puritypuritypercent<95 & (s4q11>1 & s4q11!=.)
	
	* False negative (traditional when improved)
	g       `i'_fn8c=.
	replace `i'_fn8c=0 if `i'==1
	replace `i'_fn8c=1 if `i'==1  & puritypuritypercent>=95 & (s4q11==1)

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
	
	* True negative
	g       `i'_tn9a=.
	replace `i'_tn9a=0 if `i'==1
	replace `i'_tn9a=1 if `i'==1 &  year>=1990 &  (s4q11==1)
	
	* False positive (improved when traditional)
	g       `i'_fp9a=.
	replace `i'_fp9a=0 if `i'==1
	replace `i'_fp9a=1 if `i'==1 & year>=1990 & (s4q11>1 & s4q11!=.)
	
	* False negative (traditional when improved)
	g       `i'_fn9a=.
	replace `i'_fn9a=0 if `i'==1
	replace `i'_fn9a=1 if `i'==1  & year<1990 & (s4q11==1)

}
* 1990- 2000
foreach i in maize barley sorghum { 
	* True positive
	g       `i'_tp9b=.
	replace `i'_tp9b=0 if `i'==1 
	replace `i'_tp9b=1 if `i'==1  & (year>=1990 & year<2000) & (s4q11>1 & s4q11!=.)
	
	*True negative
	g       `i'_tn9b=.
	replace `i'_tn9b=0 if `i'==1
	replace `i'_tn9b=1 if `i'==1 &  (year<1990 | year>=2000) &  (s4q11==1)
	
	*False positive (improved when traditional)
	g       `i'_fp9b=.
	replace `i'_fp9b=0 if `i'==1
	replace `i'_fp9b=1 if `i'==1  & (year<1990 | year>=2000) & (s4q11>1 & s4q11!=.)
	
	*False negative (traditional when improved)
	g       `i'_fn9b=.
	replace `i'_fn9b=0 if `i'==1
	replace `i'_fn9b=1 if `i'==1  & (year>=1990 & year<2000)  & (s4q11==1)

}
* 2000-2010
foreach i in maize barley sorghum { 
	* True positive
	g       `i'_tp9c=.
	replace `i'_tp9c=0 if `i'==1 
	replace `i'_tp9c=1 if `i'==1 & (year>=2000 & year<2010) & (s4q11>1 & s4q11!=.)
	
	*True negative
	g       `i'_tn9c=.
	replace `i'_tn9c=0 if `i'==1
	replace `i'_tn9c=1 if `i'==1 &  (year<2000 | year>=2010) &  (s4q11==1)
	
	* False positive (improved when traditional)
	g       `i'_fp9c=.
	replace `i'_fp9c=0 if `i'==1
	replace `i'_fp9c=1 if `i'==1 & (year<2000 | year>=2010) & (s4q11>1 & s4q11!=.)
	
	* False negative (traditional when improved)
	g       `i'_fn9c=.
	replace `i'_fn9c=0 if `i'==1
	replace `i'_fn9c=1 if `i'==1 & (year>=2000 & year<2010)  & (s4q11==1)

}
* 2010-2020
foreach i in maize barley sorghum { 
	* True positive
	g       `i'_tp9d=.
	replace `i'_tp9d=0 if `i'==1 
	replace `i'_tp9d=1 if `i'==1  & (year>=2010 & year<2020) & (s4q11>1 & s4q11!=.)
	
	* True negative
	g       `i'_tn9d=.
	replace `i'_tn9d=0 if `i'==1
	replace `i'_tn9d=1 if `i'==1  &  (year<2010 | year>=2020) &  (s4q11==1)
	
	* False positive (improved when traditional)
	g       `i'_fp9d=.
	replace `i'_fp9d=0 if `i'==1
	replace `i'_fp9d=1 if `i'==1  & (year<2010 | year>=2020) & (s4q11>1 & s4q11!=.)
	
	* False negative (traditional when improved)
	g       `i'_fn9d=.
	replace `i'_fn9d=0 if `i'==1
	replace `i'_fn9d=1 if `i'==1  & (year>=2010 & year<2020)  & (s4q11==1)

}

global var8  qpm dtmz maize_tp8a maize_tn8a maize_fp8a maize_fn8a maize_tp8b maize_tn8b maize_fp8b maize_fn8b maize_tp8c maize_tn8c maize_fp8c maize_fn8c barley_tp8a barley_tn8a barley_fp8a barley_fn8a barley_tp8b barley_tn8b barley_fp8b barley_fn8b barley_tp8c barley_tn8c barley_fp8c barley_fn8c sorghum_tp8a sorghum_tn8a sorghum_fp8a sorghum_fn8a sorghum_tp8b sorghum_tn8b sorghum_fp8b sorghum_fn8b sorghum_tp8c sorghum_tn8c sorghum_fp8c sorghum_fn8c   maize_tp9a maize_tn9a maize_fp9a maize_fn9a maize_tp9b maize_tn9b maize_fp9b maize_fn9b maize_tp9c maize_tn9c maize_fp9c maize_fn9c maize_tp9d maize_tn9d maize_fp9d maize_fn9d barley_tp9a barley_tn9a barley_fp9a barley_fn9a barley_tp9b barley_tn9b barley_fp9b barley_fn9b barley_tp9c barley_tn9c barley_fp9c barley_fn9c barley_tp9d barley_tn9d barley_fp9d barley_fn9d sorghum_tp9a sorghum_tn9a sorghum_fp9a sorghum_fn9a sorghum_tp9b sorghum_tn9b sorghum_fp9b sorghum_fn9b sorghum_tp9c sorghum_tn9c sorghum_fp9c sorghum_fn9c sorghum_tp9d sorghum_tn9d sorghum_fp9d sorghum_fn9d

matrix drop _all
foreach var in $var8 {

	mean `var' [pw=pw_w4] if wave==4
	matrix  `var'meanrN=e(b)'
	matrix define `var'VN= e(V)'
	matrix define `var'VVN=(vecdiag(`var'VN))'
	matrix list `var'VVN
	scalar `var'seN=sqrt(`var'VVN[1,1])
	sum    `var'  if  wave==4
	scalar `var'minrN=r(min)
	scalar `var'maxrN=r(max)
	scalar `var'nN=r(N)
	qui sum region if  wave==4
	local obsrN=r(N)

matrix mat`var'N  = ( `var'meanrN, `var'minrN, `var'maxrN, `var'nN)
matrix mat1`var'N= (`var'seN, ., ., .)
matrix list mat`var'N
matrix A1N = nullmat(A1N)\ mat`var'N\mat1`var'N
mat A2N=(`obsrN', . , ., .)
mat BN=A1N\A2N
matrix colnames BN = "Mean" "Min" "Max" "N"
}

local rname ""
foreach var in $var8 {
	local lbl : variable label `var'
	local rname `"  `rname'   "`lbl'" " " "'		
}	
mat C= BN

xml_tab BN ,  save("$table${slash}ESS4_MisclassificationNEW.xml") append sheet("Table 8", nogridlines)  ///
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') ///
rblanks(COL_NAMES "Plot level data" S2220)	 ///
title(Table 8: ESS4 - Unconditional)  font("Times New Roman" 10) ///
cw(0 110, 1 55, 2 30, 3 30, 4 40, 5 55, 6 30, 7 30, 8 40, 9 55, 10 30, 11 30, 12 40, 13 55,  14 30,  15 30, 16 40, 17 55, 18 30, 19 30, 20 40, 21 55, 22 30, 23 30, 24 40, 25 55, 26 30, 27 30, 28 40, 29 55, 30 30, 31 30, 32 40, 33 55, 34 30, 35 30, 36 40, 37 55, 38 30, 39 30, 40 40  ) ///
format((SCLR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0))  ///
star(.1 .05 .01)  /// 
lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 2)  /// 
notes(Point estimates are weighted sample means. Standard errors are reported below. Sub-sample of national sample used. )
	
* Save plot level data *
save "${data}${slash}misclassification_plot_new", replace 

	
********************************************************************************
* Collapse at HH-level 
********************************************************************************


collapse (max) qpm dtmz maize_cg barley_cg sorghum_cg maize_cgp70 maize_cgp90 maize_cgp95 barley_cgp70 barley_cgp90 barley_cgp95 sorghum_cgp70 sorghum_cgp90 sorghum_cgp95 maize_cgy1 maize_cgy2 maize_cgy3 maize_cgy4 barley_cgy1 barley_cgy2 barley_cgy3 barley_cgy4 sorghum_cgy1 sorghum_cgy2 sorghum_cgy3 sorghum_cgy4 maize_ex barley_ex sorghum_ex maize_exp70 maize_exp90 maize_exp95 barley_exp70 barley_exp90 barley_exp95 sorghum_exp70 sorghum_exp90 sorghum_exp95 maize_exy1 maize_exy2 maize_exy3 maize_exy4 barley_exy1 barley_exy2 barley_exy3 barley_exy4 sorghum_exy1 sorghum_exy2 sorghum_exy3 sorghum_exy4 maize_p70 maize_p90 maize_p95 barley_p70 barley_p90 barley_p95 sorghum_p70 sorghum_p90 sorghum_p95 maize_y1 maize_y2 maize_y3 maize_y4 barley_y1 barley_y2 barley_y3 barley_y4 sorghum_y1 sorghum_y2 sorghum_y3 sorghum_y4 (firstnm) pw_w4 wave region saq01 ea_id, by(household_id)


global hhlevel qpm dtmz maize_cg barley_cg sorghum_cg maize_cgp70 maize_cgp90 maize_cgp95 barley_cgp70 barley_cgp90 barley_cgp95 sorghum_cgp70 sorghum_cgp90 sorghum_cgp95 maize_cgy1 maize_cgy2 maize_cgy3 maize_cgy4 barley_cgy1 barley_cgy2 barley_cgy3 barley_cgy4 sorghum_cgy1 sorghum_cgy2 sorghum_cgy3 sorghum_cgy4 maize_ex barley_ex sorghum_ex maize_exp70 maize_exp90 maize_exp95 barley_exp70 barley_exp90 barley_exp95 sorghum_exp70 sorghum_exp90 sorghum_exp95 maize_exy1 maize_exy2 maize_exy3 maize_exy4 barley_exy1 barley_exy2 barley_exy3 barley_exy4 sorghum_exy1 sorghum_exy2 sorghum_exy3 sorghum_exy4 maize_p70 maize_p90 maize_p95 barley_p70 barley_p90 barley_p95 sorghum_p70 sorghum_p90 sorghum_p95 maize_y1 maize_y2 maize_y3 maize_y4 barley_y1 barley_y2 barley_y3 barley_y4 sorghum_y1 sorghum_y2 sorghum_y3 sorghum_y4


save "${data}${slash}dna_data_hhlevel_new", replace 

matrix drop _all
foreach var in $hhlevel {

	mean `var' [pw=pw_w4] if wave==4
	matrix  `var'meanrN=e(b)'
	matrix define `var'VN= e(V)'
	matrix define `var'VVN=(vecdiag(`var'VN))'
	matrix list `var'VVN
	scalar `var'seN=sqrt(`var'VVN[1,1])
	
	sum    `var'  if  wave==4
	scalar `var'minrN=r(min)
	scalar `var'maxrN=r(max)
	scalar `var'nN=r(N)
	
	qui sum region if  wave==4
	local obsrN=r(N)

matrix mat`var'N  = ( `var'meanrN, `var'minrN, `var'maxrN, `var'nN)
matrix mat1`var'N= (`var'seN, ., ., .)
matrix list mat`var'N
matrix A1N = nullmat(A1N)\ mat`var'N\mat1`var'N
mat A2N=(`obsrN', . , ., .)
mat BN=A1N\A2N
matrix colnames BN = "Mean" "Min" "Max" "N"
}
local rname ""
foreach var in $hhlevel {
	local lbl : variable label `var'
	local rname `"  `rname'   "`lbl'" " " "'		
}	

mat C= BN

xml_tab BN ,  save("$table${slash}ESS4_MisclassificationNEW.xml") append sheet("Table 9", nogridlines)  ///
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') ///
rblanks(COL_NAMES "Plot level data" S2220)	 /// 
title(Table 9: ESS4 - HH-level)  font("Times New Roman" 10) ///
cw(0 110, 1 55, 2 30, 3 30, 4 40, 5 55, 6 30, 7 30, 8 40, 9 55, 10 30, 11 30, 12 40, 13 55,  14 30,  15 30, 16 40, 17 55, 18 30, 19 30, 20 40, 21 55, 22 30, 23 30, 24 40, 25 55, 26 30, 27 30, 28 40, 29 55, 30 30, 31 30, 32 40, 33 55, 34 30, 35 30, 36 40, 37 55, 38 30, 39 30, 40 40  ) /// 
format((SCLR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0))  /// 
star(.1 .05 .01)  /// 
lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 2)  /// 
notes(Point estimates are weighted sample means. Standard errors are reported below. Sub-sample of national sample used. ) 

********************************************************************************	
use  "${data}${slash}dna_data_hhlevel_new", clear

global hhlevel2 qpm dtmz maize_cg barley_cg sorghum_cg	

matrix drop _all
foreach x in 1 3 4 7 13 15 {
foreach var in $hhlevel {

 
cap:mean `var' [pw=pw_w4] if saq01==`x' & wave==4
if _rc==2000 {
matrix  `var'meanr`x'=0
matrix define `var'V`x'= 0

scalar `var'se`x'=0


}
else if _rc!=0 {
error _rc
}
else {
matrix  `var'meanr`x'=e(b)'
matrix define `var'V`x'= e(V)'
matrix define `var'VV`x'=(vecdiag(`var'V`x'))'
matrix list `var'VV`x'
scalar `var'se`x'=sqrt(`var'VV`x'[1,1])
}

sum    `var'  if saq01==`x' & wave==4
scalar `var'minr`x'=r(min)
scalar `var'maxr`x'=r(max)
scalar `var'n`x'=r(N)

qui sum region if saq01==`x' & wave==4
local obsr`x'=r(N)
matrix mat`var'`x'  = ( `var'meanr`x', `var'se`x', `var'minr`x', `var'maxr`x', `var'n`x')
matrix list mat`var'`x'
matrix A1`x' = nullmat(A1`x')\ mat`var'`x'
mat A2`x'=(`obsr`x'', . , ., .,.)
mat B`x'=A1`x'\A2`x'
matrix colnames B`x' = "Mean" "SE" "Min" "Max" "N"

}
local rname ""
foreach var in $hhlevel2 {
local lbl : variable label `var'
local rname `"  `rname'   "`lbl'" " " "'		
}	



}	

* National
foreach var in $hhlevel {

 
cap:mean `var' [pw=pw_w4]
if _rc==2000 {
	matrix  `var'meanrN=0
	matrix define `var'VN= 0
	scalar `var'seN=0
}
else if _rc!=0 {
	error _rc
}

else {
	matrix  `var'meanrN=e(b)'
	matrix define `var'VN= e(V)'
	matrix define `var'VVN=(vecdiag(`var'VN))'
	matrix list `var'VVN
	scalar `var'seN=sqrt(`var'VVN[1,1])
}

	sum    `var'  
	scalar `var'minrN=r(min)
	scalar `var'maxrN=r(max)
	scalar `var'nN=r(N)

qui sum region 
local obsrN=r(N)
matrix mat`var'N  = ( `var'meanrN, `var'seN, `var'minrN, `var'maxrN, `var'nN)
matrix list mat`var'N
matrix A1N = nullmat(A1N)\ mat`var'N
mat A2N=(`obsrN', . , ., .,.)
mat BN=A1N\A2N
matrix colnames BN = "Mean" "SE" "Min" "Max" "N"

}
local rname ""
foreach var in $hhlevel2 {
local lbl : variable label `var'
local rname `"  `rname'   "`lbl'" " " "'		
}	
		
mat C= B1, B3, B4, B7, B13, B15, BN
	
	
xml_tab C ,  save("$table${slash}ESS4_MisclassificationNEW.xml") append sheet("Table 10", nogridlines)  ///
cnames(`cnames')  ceq("Tigray" "Tigray" "Tigray" "Tigray" "Tigray" "Amhara"  "Amhara"  "Amhara"  "Amhara" "Amhara" "Oromia" "Oromia" "Oromia" "Oromia" "Oromia" "SNNP"  "SNNP"  "SNNP"  "SNNP" "SNNP" "Harar" "Harar" "Harar" "Harar" "Harar" "Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa" "National" "National" "National" "National" "National") showeq ///
rblanks(COL_NAMES "Hh level data" S2220)	 /// 
title(Table 10: ESS4 - HH-level - by region)  font("Times New Roman" 10) ///
cw(0 110, 1 55, 2 30, 3 30, 4 40, 5 55, 6 30, 7 30, 8 40, 9 55, 10 30, 11 30, 12 40, 13 55,  14 30,  15 30, 16 40, 17 55, 18 30, 19 30, 20 40, 21 55, 22 30, 23 30, 24 40, 25 55, 26 30, 27 30, 28 40, 29 55, 30 30, 31 30, 32 40, 33 55, 34 30, 35 30, 36 40, 37 55, 38 30, 39 30, 40 40  ) /// 
format((SCLR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0))  /// 
star(.1 .05 .01)  /// 
lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 2)  ///
notes(Point estimates are weighted sample means. Standard errors are reported below. Sub-sample of national sample used. ) 

**************	
* EA LEVEL 
**************
collapse (max) 	qpm dtmz maize_cg barley_cg sorghum_cg (firstnm) pw_w4 wave region saq01, by(ea_id)

global ealevel 	qpm dtmz maize_cg barley_cg sorghum_cg

matrix drop _all
foreach x in 1 3 4 7 13 15 {
foreach var in $ealevel {

 
cap:mean `var' [pw=pw_w4] if saq01==`x' & wave==4
if _rc==2000 {
matrix  `var'meanr`x'=0
matrix define `var'V`x'= 0

scalar `var'se`x'=0


}
else if _rc!=0 {
error _rc
}
else {
matrix  `var'meanr`x'=e(b)'
matrix define `var'V`x'= e(V)'
matrix define `var'VV`x'=(vecdiag(`var'V`x'))'
matrix list `var'VV`x'
scalar `var'se`x'=sqrt(`var'VV`x'[1,1])
}

sum    `var'  if saq01==`x' & wave==4
scalar `var'minr`x'=r(min)
scalar `var'maxr`x'=r(max)
scalar `var'n`x'=r(N)

qui sum region if saq01==`x' & wave==4
local obsr`x'=r(N)



matrix mat`var'`x'  = ( `var'meanr`x', `var'se`x', `var'minr`x', `var'maxr`x', `var'n`x')


matrix list mat`var'`x'

matrix A1`x' = nullmat(A1`x')\ mat`var'`x'


mat A2`x'=(`obsr`x'', . , ., .,.)
mat B`x'=A1`x'\A2`x'

matrix colnames B`x' = "Mean" "SE" "Min" "Max" "N"

}
local rname ""
foreach var in $ealevel {
local lbl : variable label `var'
local rname `"  `rname'   "`lbl'" " " "'		
}	



}	

* National
foreach var in $ealevel {

 
cap:mean `var' [pw=pw_w4]
if _rc==2000 {
	matrix  `var'meanrN=0
	matrix define `var'VN= 0
	scalar `var'seN=0
}
else if _rc!=0 {
	error _rc
}

else {
	matrix  `var'meanrN=e(b)'
	matrix define `var'VN= e(V)'
	matrix define `var'VVN=(vecdiag(`var'VN))'
	matrix list `var'VVN
	scalar `var'seN=sqrt(`var'VVN[1,1])
}

	sum    `var'  
	scalar `var'minrN=r(min)
	scalar `var'maxrN=r(max)
	scalar `var'nN=r(N)

qui sum region 
local obsrN=r(N)
matrix mat`var'N  = ( `var'meanrN, `var'seN, `var'minrN, `var'maxrN, `var'nN)
matrix list mat`var'N
matrix A1N = nullmat(A1N)\ mat`var'N
mat A2N=(`obsrN', . , ., .,.)
mat BN=A1N\A2N
matrix colnames BN = "Mean" "SE" "Min" "Max" "N"

}
local rname ""
foreach var in $ealevel {
local lbl : variable label `var'
local rname `"  `rname'   "`lbl'" " " "'		
}		
	
	mat C= B1, B3, B4, B7, B13, B15, BN
	
	
xml_tab C, save("$table${slash}ESS4_MisclassificationNEW.xml") append sheet("Table 11", nogridlines)  ///
cnames(`cnames')  ceq("Tigray" "Tigray" "Tigray" "Tigray" "Tigray" "Amhara"  "Amhara"  "Amhara"  "Amhara" "Amhara" "Oromia" "Oromia" "Oromia" "Oromia" "Oromia" "SNNP"  "SNNP"  "SNNP"  "SNNP" "SNNP" "Harar" "Harar" "Harar" "Harar" "Harar" "Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa" "National" "National" "National" "National" "National") showeq ///
rblanks(COL_NAMES "EA level data" S2220)	 ///
title(Table 10: ESS4 - HH-level - by region)  font("Times New Roman" 10) ///
cw(0 110, 1 55, 2 30, 3 30, 4 40, 5 55, 6 30, 7 30, 8 40, 9 55, 10 30, 11 30, 12 40, 13 55,  14 30,  15 30, 16 40, 17 55, 18 30, 19 30, 20 40, 21 55, 22 30, 23 30, 24 40, 25 55, 26 30, 27 30, 28 40, 29 55, 30 30, 31 30, 32 40, 33 55, 34 30, 35 30, 36 40, 37 55, 38 30, 39 30, 40 40  ) ///  
format((SCLR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0))  /// 
star(.1 .05 .01)  /// 
lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 2)  /// 
notes(Point estimates are weighted sample means. Standard errors are reported below. Sub-sample of national sample used. ) 
