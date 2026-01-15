* ESS4 - LIVESTOCK - URBAN AREA

use "${raw4}${slash}HH${slash}sect10d2_hh_w4", clear
merge m:1 household_id livestock_cd using "${raw4}${slash}HH${slash}sect10d1_hh_w4"

keep if _m==3
drop _m

g       hhd_liv=0
replace hhd_liv=1 if ((livestock_cd>=501 & livestock_cd<=506) | (livestock_cd>=507 & livestock_cd<=508) | (livestock_cd==513)) & s10dq01==1
egen liv=max(hhd_liv), by(household_id)


g       hhd_crlr=0 if liv==1
replace hhd_crlr=1 if ((s10d_indq05>0 & s10d_indq05!=.) | (s10d_indq09>0 & s10d_indq09!=.))         & (livestock_cd>=501 & livestock_cd<=506) & s10dq01==1

g       hhd_crsr=0 if liv==1
replace hhd_crsr=1 if ((s10d_indq05>0 & s10d_indq05!=.) | (s10d_indq09>0 & s10d_indq09!=.))         & (livestock_cd>=507 & livestock_cd<=508) & s10dq01==1

g       hhd_crpo=0 if liv==1
replace hhd_crpo=1 if ((s10d_indq05>0 & s10d_indq05!=.) | (s10d_indq09>0 & s10d_indq09!=.))         & (livestock_cd==513) & s10dq01==1


g       hhd_cross=0  if liv==1
replace hhd_cross=1  if hhd_crlr==1 | hhd_crsr==1 | hhd_crpo==1

foreach i in hhd_crlr hhd_crsr hhd_crpo {
	replace `i'=0 if `i'==. & hhd_cross!=.
}


collapse (max) hhd_* (firstnm) saq14 ea_id pw_w4 saq01, by(household_id)

lab var hhd_cross "Any crossbred livestock"
lab var hhd_crlr  "Crossbred large ruminants"
lab var hhd_crsr  "Crossbred small ruminants"
lab var hhd_crpo  "Crossbred poultry"


global crossliv hhd_cross hhd_crlr hhd_crsr hhd_crpo

*Keep if Urban
preserve
keep if  saq14==2


matrix drop _all
foreach x in 1 2 3 4 5 6  7 12 13 14 15 {
foreach var in $crossliv {

 
cap:mean `var' [pw=pw_w4] if saq01==`x' 
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

sum    `var'  if saq01==`x'
scalar `var'minr`x'=r(min)
scalar `var'maxr`x'=r(max)
scalar `var'n`x'=r(N)

qui sum saq01 if saq01==`x' 
local obsr`x'=r(N)



matrix mat`var'`x'  = ( `var'meanr`x', `var'se`x', `var'minr`x', `var'maxr`x', `var'n`x')


matrix list mat`var'`x'

matrix A1`x' = nullmat(A1`x')\ mat`var'`x'


mat A2`x'=(`obsr`x'', . , ., .,.)
mat B`x'=A1`x'\A2`x'

matrix colnames B`x' = "Mean" "SE" "Min" "Max" "N"

}




}	

local rname ""
foreach var in $crossliv {
local lbl : variable label `var'
local rname `"  `rname'   "`lbl'" " " "'		
}	


* National
foreach var in $crossliv {

 
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

qui sum saq01 
local obsrN=r(N)



matrix mat`var'N  = ( `var'meanrN,`var'seN, `var'minrN, `var'maxrN, `var'nN)


matrix list mat`var'N

matrix A1N = nullmat(A1N)\ mat`var'N


mat A2N=(`obsrN', . , ., .,.)
mat BN=A1N\A2N

matrix colnames BN = "Mean" "SE" "Min" "Max" "N"

}
local rname ""
foreach var in $crossliv {
local lbl : variable label `var'
local rname `"  `rname'   "`lbl'" "'		
}	

mat C= B1, B2, B3, B4, B5, B6, B7, B12, B13, B14, B15, BN


#delimit;
xml_tab C,  save("$table${slash}ESS4_Individual_livestock.xml") replace sheet("Table 1_hh_urban", nogridlines)  ///
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') ceq("Tigray" "Tigray" "Tigray" "Tigray" "Tigray"
"Afar" "Afar" "Afar" "Afar" "Afar"
"Amhara"  "Amhara"  "Amhara"  "Amhara" "Amhara"
"Oromia" "Oromia" "Oromia" "Oromia" "Oromia" 
"Somali" "Somali" "Somali" "Somali" "Somali"
"Benishangul Gumuz" "Benishangul Gumuz" "Benishangul Gumuz" "Benishangul Gumuz" "Benishangul Gumuz"
"SNNP"  "SNNP"  "SNNP"  "SNNP" "SNNP" 
"Gambela" "Gambela" "Gambela" "Gambela" "Gambela"
"Harar" "Harar" "Harar" "Harar" "Harar"
"Addis Ababa" "Addis Ababa" "Addis Ababa" "Addis Ababa" "Addis Ababa"
"Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa"
"National" "National" "National" "National" "National" ) showeq ///
rblanks(COL_NAMES "Percentage of hh that adopt on at least one plot :" S2149, hhd_impccr  "Share of plots per household" S2149)	 /// Adds blank columns which are used to separate Treatment and Control graphically.
title(Table 1: ESS4 - Livestock - Urban - From Individual level data )  font("Times New Roman" 10) ///
cw(0 110, 1 55, 2 55, 3 30, 4 30, 5 40, 
6 55, 7 55, 8 30, 9 30, 10 40,
11 55, 12 55, 13 30, 14 30, 15 40,
16 55, 17 55, 18 30, 19 30, 20 40,
21 55, 22 55, 23 30, 24 30, 25 40,
26 55, 27 55, 28 30, 29 30, 30 40,
) /// *Adjust the column width of the table, column 0 are the variable names* 1, 5 and 9 are the blank columns. 
	format((SCLR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0))  /// * format the columns. Each parentheses represents one column*
	star(.1 .05 .01)  /// Define your star values/signs here (which are stored in B_STARS)
	lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 13)  /// Draws lines in specific format (Numeric Value)
	notes(Point estimates are weighted sample means. ) //Add your notes here
;
#delimit cr		


restore


* Rural 

preserve
keep if  saq14==1


matrix drop _all
foreach x in 1 2 3 4 5 6  7 12 13 14 15 {
	foreach var in $crossliv {

 
	cap:mean `var' [pw=pw_w4] if saq01==`x' 
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

sum    `var'  if saq01==`x'
scalar `var'minr`x'=r(min)
scalar `var'maxr`x'=r(max)
scalar `var'n`x'=r(N)

qui sum saq01 if saq01==`x' 
local obsr`x'=r(N)



matrix mat`var'`x'  = ( `var'meanr`x', `var'se`x', `var'minr`x', `var'maxr`x', `var'n`x')


matrix list mat`var'`x'

matrix A1`x' = nullmat(A1`x')\ mat`var'`x'


mat A2`x'=(`obsr`x'', . , ., .,.)
mat B`x'=A1`x'\A2`x'

matrix colnames B`x' = "Mean" "SE" "Min" "Max" "N"

}




}	

local rname ""
foreach var in $crossliv {
local lbl : variable label `var'
local rname `"  `rname'   "`lbl'" " " "'		
}	


* National
foreach var in $crossliv {

 
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

qui sum saq01 
local obsrN=r(N)



matrix mat`var'N  = ( `var'meanrN,`var'seN, `var'minrN, `var'maxrN, `var'nN)


matrix list mat`var'N

matrix A1N = nullmat(A1N)\ mat`var'N


mat A2N=(`obsrN', . , ., .,.)
mat BN=A1N\A2N

matrix colnames BN = "Mean" "SE" "Min" "Max" "N"

}
local rname ""
foreach var in $crossliv {
local lbl : variable label `var'
local rname `"  `rname'   "`lbl'" "'		
}	

mat C= B1, B2, B3, B4, B5, B6, B7, B12, B13, B14, B15, BN


#delimit;
xml_tab C,  save("$table${slash}ESS4_Individual_livestock.xml") append sheet("Table 2_hh_rural", nogridlines)  ///
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') ceq("Tigray" "Tigray" "Tigray" "Tigray" "Tigray"
"Afar" "Afar" "Afar" "Afar" "Afar"
"Amhara"  "Amhara"  "Amhara"  "Amhara" "Amhara"
"Oromia" "Oromia" "Oromia" "Oromia" "Oromia" 
"Somali" "Somali" "Somali" "Somali" "Somali"
"Benishangul Gumuz" "Benishangul Gumuz" "Benishangul Gumuz" "Benishangul Gumuz" "Benishangul Gumuz"
"SNNP"  "SNNP"  "SNNP"  "SNNP" "SNNP" 
"Gambela" "Gambela" "Gambela" "Gambela" "Gambela"
"Harar" "Harar" "Harar" "Harar" "Harar"
"Addis Ababa" "Addis Ababa" "Addis Ababa" "Addis Ababa" "Addis Ababa"
"Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa"
"National" "National" "National" "National" "National" ) showeq ///
rblanks(COL_NAMES "Percentage of hh that adopt on at least one plot :" S2149, hhd_impccr  "Share of plots per household" S2149)	 /// Adds blank columns which are used to separate Treatment and Control graphically.
title(Table 2: ESS4 - Livestock - Rural - From Individual level data )  font("Times New Roman" 10) ///
cw(0 110, 1 55, 2 55, 3 30, 4 30, 5 40, 
6 55, 7 55, 8 30, 9 30, 10 40,
11 55, 12 55, 13 30, 14 30, 15 40,
16 55, 17 55, 18 30, 19 30, 20 40,
21 55, 22 55, 23 30, 24 30, 25 40,
26 55, 27 55, 28 30, 29 30, 30 40,
) /// *Adjust the column width of the table, column 0 are the variable names* 1, 5 and 9 are the blank columns. 
	format((SCLR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0))  /// * format the columns. Each parentheses represents one column*
	star(.1 .05 .01)  /// Define your star values/signs here (which are stored in B_STARS)
	lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 13)  /// Draws lines in specific format (Numeric Value)
	notes(Point estimates are weighted sample means. ) //Add your notes here
;
#delimit cr		


restore



********************************************************************************
* Collapse at EA level 
********************************************************************************

collapse (max) hhd_* (firstnm) saq14 pw_w4 saq01, by(ea_id)
lab var hhd_cross "Any crossbred livestock"
lab var hhd_crlr  "Crossbred large ruminants"
lab var hhd_crsr  "Crossbred small ruminants"
lab var hhd_crpo  "Crossbred poultry"


global hhd_cross hhd_crlr hhd_crsr hhd_crpo

* Urban*
preserve
keep if  saq14==2


matrix drop _all
foreach x in 1 2 3 4 5 6  7 12 13 14 15 {
	foreach var in $crossliv {

 
	cap:mean `var' [pw=pw_w4] if saq01==`x' 
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

sum    `var'  if saq01==`x'
scalar `var'minr`x'=r(min)
scalar `var'maxr`x'=r(max)
scalar `var'n`x'=r(N)

qui sum saq01 if saq01==`x' 
local obsr`x'=r(N)



matrix mat`var'`x'  = ( `var'meanr`x', `var'se`x', `var'minr`x', `var'maxr`x', `var'n`x')


matrix list mat`var'`x'

matrix A1`x' = nullmat(A1`x')\ mat`var'`x'


mat A2`x'=(`obsr`x'', . , ., .,.)
mat B`x'=A1`x'\A2`x'

matrix colnames B`x' = "Mean" "SE" "Min" "Max" "N"

}




}	

local rname ""
foreach var in $crossliv {
local lbl : variable label `var'
local rname `"  `rname'   "`lbl'" " " "'		
}	


* National
foreach var in $crossliv {

 
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

qui sum saq01 
local obsrN=r(N)



matrix mat`var'N  = ( `var'meanrN,`var'seN, `var'minrN, `var'maxrN, `var'nN)


matrix list mat`var'N

matrix A1N = nullmat(A1N)\ mat`var'N


mat A2N=(`obsrN', . , ., .,.)
mat BN=A1N\A2N

matrix colnames BN = "Mean" "SE" "Min" "Max" "N"

}
local rname ""
foreach var in $crossliv {
local lbl : variable label `var'
local rname `"  `rname'   "`lbl'" "'		
}	

mat C= B1, B2, B3, B4, B5, B6, B7, B12, B13, B14, B15, BN


#delimit;
xml_tab C,  save("$table${slash}ESS4_Individual_livestock.xml") append sheet("Table 3_ea_urban", nogridlines)  ///
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') ceq("Tigray" "Tigray" "Tigray" "Tigray" "Tigray"
"Afar" "Afar" "Afar" "Afar" "Afar"
"Amhara"  "Amhara"  "Amhara"  "Amhara" "Amhara"
"Oromia" "Oromia" "Oromia" "Oromia" "Oromia" 
"Somali" "Somali" "Somali" "Somali" "Somali"
"Benishangul Gumuz" "Benishangul Gumuz" "Benishangul Gumuz" "Benishangul Gumuz" "Benishangul Gumuz"
"SNNP"  "SNNP"  "SNNP"  "SNNP" "SNNP" 
"Gambela" "Gambela" "Gambela" "Gambela" "Gambela"
"Harar" "Harar" "Harar" "Harar" "Harar"
"Addis Ababa" "Addis Ababa" "Addis Ababa" "Addis Ababa" "Addis Ababa"
"Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa"
"National" "National" "National" "National" "National" ) showeq ///
rblanks(COL_NAMES "Percentage of hh that adopt on at least one plot :" S2149, hhd_impccr  "Share of plots per household" S2149)	 /// Adds blank columns which are used to separate Treatment and Control graphically.
title(Table 3: ESS4 - Livestock - Urban - From Individual level data )  font("Times New Roman" 10) ///
cw(0 110, 1 55, 2 55, 3 30, 4 30, 5 40, 
6 55, 7 55, 8 30, 9 30, 10 40,
11 55, 12 55, 13 30, 14 30, 15 40,
16 55, 17 55, 18 30, 19 30, 20 40,
21 55, 22 55, 23 30, 24 30, 25 40,
26 55, 27 55, 28 30, 29 30, 30 40,
) /// *Adjust the column width of the table, column 0 are the variable names* 1, 5 and 9 are the blank columns. 
	format((SCLR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0))  /// * format the columns. Each parentheses represents one column*
	star(.1 .05 .01)  /// Define your star values/signs here (which are stored in B_STARS)
	lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 13)  /// Draws lines in specific format (Numeric Value)
	notes(Point estimates are weighted sample means. ) //Add your notes here
;
#delimit cr		


restore



* Urban*
preserve
keep if  saq14==2


matrix drop _all
foreach x in 1 2 3 4 5 6  7 12 13 14 15 {
	foreach var in $crossliv {

 
	cap:mean `var' [pw=pw_w4] if saq01==`x' 
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

sum    `var'  if saq01==`x'
scalar `var'minr`x'=r(min)
scalar `var'maxr`x'=r(max)
scalar `var'n`x'=r(N)

qui sum saq01 if saq01==`x' 
local obsr`x'=r(N)



matrix mat`var'`x'  = ( `var'meanr`x', `var'se`x', `var'minr`x', `var'maxr`x', `var'n`x')


matrix list mat`var'`x'

matrix A1`x' = nullmat(A1`x')\ mat`var'`x'


mat A2`x'=(`obsr`x'', . , ., .,.)
mat B`x'=A1`x'\A2`x'

matrix colnames B`x' = "Mean" "SE" "Min" "Max" "N"

}




}	

local rname ""
foreach var in $crossliv {
local lbl : variable label `var'
local rname `"  `rname'   "`lbl'" " " "'		
}	


* National
foreach var in $crossliv {

 
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

qui sum saq01 
local obsrN=r(N)



matrix mat`var'N  = ( `var'meanrN,`var'seN, `var'minrN, `var'maxrN, `var'nN)


matrix list mat`var'N

matrix A1N = nullmat(A1N)\ mat`var'N


mat A2N=(`obsrN', . , ., .,.)
mat BN=A1N\A2N

matrix colnames BN = "Mean" "SE" "Min" "Max" "N"

}
local rname ""
foreach var in $crossliv {
local lbl : variable label `var'
local rname `"  `rname'   "`lbl'" "'		
}	

mat C= B1, B2, B3, B4, B5, B6, B7, B12, B13, B14, B15, BN


#delimit;
xml_tab C,  save("$table${slash}ESS4_Individual_livestock.xml") append sheet("Table 4_ea_rural", nogridlines)  ///
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') ceq("Tigray" "Tigray" "Tigray" "Tigray" "Tigray"
"Afar" "Afar" "Afar" "Afar" "Afar"
"Amhara"  "Amhara"  "Amhara"  "Amhara" "Amhara"
"Oromia" "Oromia" "Oromia" "Oromia" "Oromia" 
"Somali" "Somali" "Somali" "Somali" "Somali"
"Benishangul Gumuz" "Benishangul Gumuz" "Benishangul Gumuz" "Benishangul Gumuz" "Benishangul Gumuz"
"SNNP"  "SNNP"  "SNNP"  "SNNP" "SNNP" 
"Gambela" "Gambela" "Gambela" "Gambela" "Gambela"
"Harar" "Harar" "Harar" "Harar" "Harar"
"Addis Ababa" "Addis Ababa" "Addis Ababa" "Addis Ababa" "Addis Ababa"
"Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa"
"National" "National" "National" "National" "National" ) showeq ///
rblanks(COL_NAMES "Percentage of hh that adopt on at least one plot :" S2149, hhd_impccr  "Share of plots per household" S2149)	 /// Adds blank columns which are used to separate Treatment and Control graphically.
title(Table 4: ESS4 - Livestock - Rural - From Individual level data )  font("Times New Roman" 10) ///
cw(0 110, 1 55, 2 55, 3 30, 4 30, 5 40, 
6 55, 7 55, 8 30, 9 30, 10 40,
11 55, 12 55, 13 30, 14 30, 15 40,
16 55, 17 55, 18 30, 19 30, 20 40,
21 55, 22 55, 23 30, 24 30, 25 40,
26 55, 27 55, 28 30, 29 30, 30 40,
) /// *Adjust the column width of the table, column 0 are the variable names* 1, 5 and 9 are the blank columns. 
	format((SCLR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0))  /// * format the columns. Each parentheses represents one column*
	star(.1 .05 .01)  /// Define your star values/signs here (which are stored in B_STARS)
	lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 13)  /// Draws lines in specific format (Numeric Value)
	notes(Point estimates are weighted sample means. ) //Add your notes here
;
#delimit cr		


restore
