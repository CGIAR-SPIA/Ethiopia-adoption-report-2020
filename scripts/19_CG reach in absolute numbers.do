
********************************************************************************
* CG reach in absolute numbers (nb of households)
********************************************************************************
* ESS4 
use "${data}${slash}wave4_hh_new", clear
merge m:1 ea_id using "${data}${slash}wave4_ea_new"
drop _m
drop saq13

merge 1:1 household_id using "${data}${slash}ess4_dna_hh_new"

g       dnadata=0
replace dnadata=1 if _m==3
*keep if _m==3

g       anycr=0
replace anycr=1 if cr1==1 | cr2==1 | cr6==1



* Upper bound *
foreach i in  hhd_treadle hhd_motorpump hhd_rdisp hhd_consag1 hhd_swc hhd_cross hhd_livIA hhd_elepgrass hhd_gaya hhd_sasbaniya hhd_alfa hhd_indprod hhd_grass hhd_avocado hhd_mango hhd_papaya hhd_sweetpotato hhd_fieldp commirr plotirr maize sorghum barley hhd_ofsp  hhd_awassa83 {
	replace `i'=1 if `i'==100
}

g ubound1=0 if dnadata==1
replace ubound1=1 if dnadata==1 & (maize==1 | hhd_treadle==1 | hhd_motorpump==1 | hhd_rdisp==1 | hhd_consag1==1 | hhd_swc==1 | hhd_cross==1 | hhd_livIA==1 | hhd_elepgrass==1 | hhd_gaya==1 | hhd_sasbaniya==1 | hhd_alfa==1 | hhd_indprod==1 | hhd_grass==1  | hhd_avocado==1 | hhd_mango==1 | hhd_papaya==1 | hhd_sweetpotato==1 | hhd_fieldp==1 | (commirr==1 & plotirr==1) |   hhd_ofsp==1 | hhd_awassa83==1)


g       ubound2=0 
replace ubound2=1 if  (hhd_treadle==1 | hhd_motorpump==1 | hhd_rdisp==1 | hhd_consag1==1 | hhd_swc==1 | hhd_cross==1 | hhd_livIA==1 | hhd_elepgrass==1 | hhd_gaya==1 | hhd_sasbaniya==1 | hhd_alfa==1 | hhd_indprod==1 | hhd_grass==1  | hhd_avocado==1 | hhd_mango==1 | hhd_papaya==1 | hhd_sweetpotato==1 | hhd_fieldp==1 | (commirr==1 & plotirr==1) |   hhd_ofsp==1 | hhd_awassa83==1)


g       ubound3=0 
replace ubound3=1 if   (hhd_treadle==1 | hhd_motorpump==1 | hhd_rdisp==1 | hhd_consag1==1 | hhd_swc==1 | hhd_cross==1 | hhd_livIA==1 | hhd_elepgrass==1 | hhd_gaya==1 | hhd_sasbaniya==1 | hhd_alfa==1 | hhd_indprod==1 | hhd_grass==1  | hhd_avocado==1 | hhd_mango==1 | hhd_papaya==1 | hhd_sweetpotato==1 | hhd_fieldp==1 | (commirr==1 & plotirr==1) |   hhd_ofsp==1 | hhd_awassa83==1)

g       percrural=0
replace percrural=1 if maize==1 | barley==1 | sorghum==1 | hhd_ofsp==100 | hhd_awassa83==100 | hhd_treadle==1 | hhd_motorpump==1 | hhd_rdisp==1 | hhd_consag1==1 | hhd_swc==1 | hhd_cross==1 | hhd_livIA==1 | hhd_elepgrass==1 | hhd_gaya==1 | hhd_sasbaniya==1 | hhd_alfa==1 | hhd_indprod==1 | hhd_grass==1  | hhd_avocado==1 | hhd_mango==1 | hhd_papaya==1 | hhd_sweetpotato==1 | hhd_fieldp==1 | (commirr==1 & plotirr==1) 


global dnastats maize barley sorghum cr2 ubound1 ubound2 ubound3

* TABLES * hh - level
matrix drop _all
foreach x in 1 2 3 4 5 6 7 12 13 15 {
foreach var in $dnastats {

 
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

qui sum region if saq01==`x' 
local obsr`x'=r(N)



matrix mat`var'`x'  = ( `var'meanr`x', `var'se`x', `var'minr`x', `var'maxr`x', `var'n`x')


matrix list mat`var'`x'

matrix A1`x' = nullmat(A1`x')\ mat`var'`x'


mat A2`x'=(`obsr`x'', . , ., .,.)
mat B`x'=A1`x'\A2`x'

matrix colnames B`x' = "Mean" "SE" "Min" "Max" "N"

}
local rname ""
foreach var in $dnastats {
local lbl : variable label `var'
local rname `"  `rname'   "`lbl'" " " "'		
}	

}	

mat C= B1, B2, B3, B4, B5, B6, B7, B12, B13, B15


#delimit;
xml_tab C,  save("$table${slash}ESS4_ABSNUMBERBEN.xml") replace sheet("Table 1_LOWERB", nogridlines)  ///
cnames(`cnames') ceq("Tigray" "Tigray" "Tigray" "Tigray" "Tigray" 
"Afar" "Afar" "Afar"  "Afar"  "Afar"  
"Amhara"  "Amhara"  "Amhara"  "Amhara" "Amhara" 
"Oromia" "Oromia" "Oromia" "Oromia" "Oromia" 
"Somali" "Somali" "Somali" "Somali" "Somali"
"Benishangul Gumuz" "Benishangul Gumuz" "Benishangul Gumuz" "Benishangul Gumuz" "Benishangul Gumuz" 
"SNNP"  "SNNP"  "SNNP"  "SNNP" "SNNP" 
"Gambela" "Gambela" "Gambela" "Gambela" "Gambela"
"Harar" "Harar" "Harar" "Harar" "Harar"
"Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa") showeq ///
title(Table 1: ESS4 - Lower )  font("Times New Roman" 10) ///
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
	notes(Point estimates are weighted sample means. Rural sample ) //Add your notes here
;
#delimit cr		
*ex
* Upper bound *
foreach i in  hhd_treadle hhd_motorpump hhd_rdisp hhd_consag1 hhd_swc hhd_cross hhd_livIA hhd_elepgrass hhd_gaya hhd_sasbaniya hhd_alfa hhd_indprod hhd_grass hhd_avocado hhd_mango hhd_papaya hhd_sweetpotato hhd_fieldp commirr plotirr maize sorghum barley hhd_ofsp  hhd_awassa83 {
	replace `i'=1 if `i'==100
}

g       ubound=0  if  dnadata==0
replace ubound=1 if dnadata==0 & (hhd_treadle==1 | hhd_motorpump==1 | hhd_rdisp==1 | hhd_consag1==1 | hhd_swc==1 | hhd_cross==1 | hhd_livIA==1 | hhd_elepgrass==1 | hhd_gaya==1 | hhd_sasbaniya==1 | hhd_alfa==1 | hhd_indprod==1 | hhd_grass==1  | hhd_avocado==1 | hhd_mango==1 | hhd_papaya==1 | hhd_sweetpotato==1 | hhd_fieldp==1 | (commirr==1 & plotirr==1) | hhd_ofsp==1 | hhd_awassa83==1)







global ubound ubound

* TABLES * hh - level
matrix drop _all
foreach x in 1 2 3 4 5 6 7 12 13 15 {
foreach var in $ubound {

 
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

qui sum region if saq01==`x' 
local obsr`x'=r(N)



matrix mat`var'`x'  = ( `var'meanr`x', `var'se`x', `var'minr`x', `var'maxr`x', `var'n`x')


matrix list mat`var'`x'

matrix A1`x' = nullmat(A1`x')\ mat`var'`x'


mat A2`x'=(`obsr`x'', . , ., .,.)
mat B`x'=A1`x'\A2`x'

matrix colnames B`x' = "Mean" "SE" "Min" "Max" "N"

}
local rname ""
foreach var in $ubound {
local lbl : variable label `var'
local rname `"  `rname'   "`lbl'" " " "'		
}	

}	

mat C= B1, B2, B3, B4, B5, B6, B7, B12, B13, B15


#delimit;
xml_tab C,  save("$table${slash}ESS4_ABSNUMBERBEN.xml") append sheet("Table 2_UPPERB", nogridlines)  ///
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') ceq("Tigray" "Tigray" "Tigray" "Tigray" "Tigray" 
"Afar" "Afar" "Afar"  "Afar"  "Afar"  
"Amhara"  "Amhara"  "Amhara"  "Amhara" "Amhara" 
"Oromia" "Oromia" "Oromia" "Oromia" "Oromia" 
"Somali" "Somali" "Somali" "Somali" "Somali"
"Benishangul Gumuz" "Benishangul Gumuz" "Benishangul Gumuz" "Benishangul Gumuz" "Benishangul Gumuz" 
"SNNP"  "SNNP"  "SNNP"  "SNNP" "SNNP" 
"Gambela" "Gambela" "Gambela" "Gambela" "Gambela"
"Harar" "Harar" "Harar" "Harar" "Harar"
"Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa") showeq ///
title(Table 1: ESS4 - Lower )  font("Times New Roman" 10) ///
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
	notes(Point estimates are weighted sample means. Rural sample ) //Add your notes here
;
#delimit cr		
****
* TABLES * hh - level
matrix drop _all
foreach x in 1 2 3 4 5 6 7 12 13 15 {
foreach var in $ubound {

 
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

sum    `var'  if saq01==`x' & _m==3
scalar `var'minr`x'=r(min)
scalar `var'maxr`x'=r(max)
scalar `var'n`x'=r(N)

qui sum region if saq01==`x' 
local obsr`x'=r(N)



matrix mat`var'`x'  = ( `var'meanr`x', `var'se`x', `var'minr`x', `var'maxr`x', `var'n`x')


matrix list mat`var'`x'

matrix A1`x' = nullmat(A1`x')\ mat`var'`x'


mat A2`x'=(`obsr`x'', . , ., .,.)
mat B`x'=A1`x'\A2`x'

matrix colnames B`x' = "Mean" "SE" "Min" "Max" "N"

}
local rname ""
foreach var in $ubound {
local lbl : variable label `var'
local rname `"  `rname'   "`lbl'" " " "'		
}	

}	

mat C= B1, B2, B3, B4, B5, B6, B7, B12, B13, B15


#delimit;
xml_tab C,  save("$table${slash}ESS4_ABSNUMBERBEN.xml") append sheet("Table 3_UPPERB", nogridlines)  ///
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') ceq("Tigray" "Tigray" "Tigray" "Tigray" "Tigray" 
"Afar" "Afar" "Afar"  "Afar"  "Afar"  
"Amhara"  "Amhara"  "Amhara"  "Amhara" "Amhara" 
"Oromia" "Oromia" "Oromia" "Oromia" "Oromia" 
"Somali" "Somali" "Somali" "Somali" "Somali"
"Benishangul Gumuz" "Benishangul Gumuz" "Benishangul Gumuz" "Benishangul Gumuz" "Benishangul Gumuz" 
"SNNP"  "SNNP"  "SNNP"  "SNNP" "SNNP" 
"Gambela" "Gambela" "Gambela" "Gambela" "Gambela"
"Harar" "Harar" "Harar" "Harar" "Harar"
"Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa") showeq ///
title(Table 1: ESS4 - Lower )  font("Times New Roman" 10) ///
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
	notes(Point estimates are weighted sample means. Rural sample ) //Add your notes here
;
#delimit cr		

**********************************************************************
* ESS3 
**********************************************************************


use "${data}${slash}wave3_hh", clear
merge m:1 ea_id using "${data}${slash}wave3_ea"
drop _m
keep if rural==1
g       lbound=0
replace lbound=1 if  hhd_ofsp==100 | hhd_awassa83==100 | hhd_desi==1 | hhd_kabuli==100

global lbound   hhd_ofsp hhd_awassa83 lbound

* TABLES * hh - level
matrix drop _all
foreach x in 1  3 4 7 0 {
foreach var in $lbound {

 
cap:mean `var' [pw=pw_w3] if region==`x' 
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

sum    `var'  if region==`x' 
scalar `var'minr`x'=r(min)
scalar `var'maxr`x'=r(max)
scalar `var'n`x'=r(N)

qui sum region if region==`x' 
local obsr`x'=r(N)



matrix mat`var'`x'  = ( `var'meanr`x', `var'se`x', `var'minr`x', `var'maxr`x', `var'n`x')


matrix list mat`var'`x'

matrix A1`x' = nullmat(A1`x')\ mat`var'`x'


mat A2`x'=(`obsr`x'', . , ., .,.)
mat B`x'=A1`x'\A2`x'

matrix colnames B`x' = "Mean" "SE" "Min" "Max" "N"

}
local rname ""
foreach var in $lbound {
local lbl : variable label `var'
local rname `"  `rname'   "`lbl'" " " "'		
}	

}	

mat C= B1,  B3, B4, B7, B0


#delimit;
xml_tab C,  save("$table${slash}ESS3_ABSNUMBERBEN.xml") replace sheet("Table 1_LOWERB", nogridlines)  ///
cnames(`cnames') ceq("Tigray" "Tigray" "Tigray" "Tigray" "Tigray" 
"Amhara"  "Amhara"  "Amhara"  "Amhara" "Amhara" 
"Oromia" "Oromia" "Oromia" "Oromia" "Oromia" 
"SNNP"  "SNNP"  "SNNP"  "SNNP" "SNNP" 
"Other regions" "Other regions" "Other regions" "Other regions" "Other regions") showeq ///
title(Table 1: ESS4 - Lower )  font("Times New Roman" 10) ///
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
	notes(Point estimates are weighted sample means. Rural sample ) //Add your notes here
;
#delimit cr		


* Upper bound *
foreach i in  hhd_treadle hhd_motorpump hhd_rdisp hhd_consag1 hhd_swc hhd_cross hhd_livIA hhd_elepgrass hhd_gaya hhd_sasbaniya hhd_alfa hhd_indprod hhd_grass hhd_avocado hhd_mango hhd_papaya hhd_sweetpotato hhd_fieldp commirr plotirr  hhd_ofsp  hhd_awassa83 hhd_desi hhd_kabuli hhd_bbm {
	replace `i'=1 if `i'==100
}

g       ubound=0
replace ubound=1 if hhd_treadle==1 | hhd_motorpump==1 | hhd_rdisp==1 | hhd_consag1==1 | hhd_swc==1 | hhd_cross==1 | hhd_livIA==1 | hhd_elepgrass==1 | hhd_gaya==1 | hhd_sasbaniya==1 | hhd_alfa==1 | hhd_indprod==1 | hhd_grass==1  | hhd_avocado==1 | hhd_mango==1 | hhd_papaya==1 | hhd_sweetpotato==1 | hhd_fieldp==1 | (commirr==1 & plotirr==1) |  hhd_ofsp==1 | hhd_awassa83==1 | hhd_desi==1 | hhd_kabuli==1 | hhd_bbm==1

global ubound ubound

****
* TABLES * hh - level
matrix drop _all
foreach x in 1 3 4 7 0 {
foreach var in $ubound {

 
cap:mean `var' [pw=pw_w3] if region==`x' 
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

sum    `var'  if region==`x' 
scalar `var'minr`x'=r(min)
scalar `var'maxr`x'=r(max)
scalar `var'n`x'=r(N)

qui sum region if region==`x' 
local obsr`x'=r(N)



matrix mat`var'`x'  = ( `var'meanr`x', `var'se`x', `var'minr`x', `var'maxr`x', `var'n`x')


matrix list mat`var'`x'

matrix A1`x' = nullmat(A1`x')\ mat`var'`x'


mat A2`x'=(`obsr`x'', . , ., .,.)
mat B`x'=A1`x'\A2`x'

matrix colnames B`x' = "Mean" "SE" "Min" "Max" "N"

}
local rname ""
foreach var in $ubound {
local lbl : variable label `var'
local rname `"  `rname'   "`lbl'" " " "'		
}	

}	

mat C= B1,  B3, B4, B7, B0


#delimit;
xml_tab C,  save("$table${slash}ESS3_ABSNUMBERBEN.xml") append sheet("Table 3_UPPERB", nogridlines)  ///
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') ceq("Tigray" "Tigray" "Tigray" "Tigray" "Tigray" 
"Amhara"  "Amhara"  "Amhara"  "Amhara" "Amhara" 
"Oromia" "Oromia" "Oromia" "Oromia" "Oromia" 
"SNNP"  "SNNP"  "SNNP"  "SNNP" "SNNP" 
"Other regions" "Other regions" "Other regions" "Other regions" "Other regions") showeq ///
title(Table 1: ESS4 - Lower )  font("Times New Roman" 10) ///
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
	notes(Point estimates are weighted sample means. Rural sample ) //Add your notes here
;
#delimit cr		
