********************************************************************************
*                           Ethiopia Synthesis Report 
*                     7_National and regional adoption rates_ess3
* Country: Ethiopia 
* Data: ESS3  
* Author: Paola Mallia | p.mallia@cgiar.org | paola_mallia@ymail.com 
* STATA Version: SE 16.1
********************************************************************************
*Use data created in do: 4_PP_CG_innovation_ess3
* HH level
use "${data}${slash}wave3_hh", clear

#delimit ;
global hhlevel1     
hhd_livIA_r hhd_cross_largerum_r hhd_cross_smallrum_r hhd_cross_poultry_r hhd_grass_r
hhd_kabuli_r hhd_ofsp_r hhd_awassa83_r
hhd_rdisp_r hhd_motorpump_r hhd_swc_r hhd_bbm_r hhd_consag1_r hhd_consag2_r hhd_affor_r hhd_mango_r hhd_papaya_r hhd_avocado_r
;
#delimit cr



**********************************************************************
* TABLE 1 - HH level - Rural sample
**********************************************************************

*By region
matrix drop _all
foreach x in 1 3 4 7 0 {
foreach var in $hhlevel1 {

 
cap:mean `var' [pw=pw_w3] if region==`x' & wave==3
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

sum    `var'  if region==`x' & wave==3

scalar `var'minr`x'=r(min)
scalar `var'maxr`x'=r(max)
scalar `var'n`x'=r(N)


qui sum region if region==`x' & wave==3
local obsr`x'=r(N)



matrix mat`var'`x'  = ( `var'meanr`x', `var'se`x', `var'minr`x', `var'maxr`x', `var'n`x')


matrix list mat`var'`x'

matrix A1`x' = nullmat(A1`x')\ mat`var'`x'


mat A2`x'=(`obsr`x'', . , ., .,.)
mat B`x'=A1`x'\A2`x'

matrix colnames B`x' = "Mean" "SE" "Min" "Max" "N"

}
local rname ""
foreach var in $hhlevel1 {
local lbl : variable label `var'
local rname `"  `rname'   "`lbl'" " " "'		
}	

}	
* National
foreach var in $hhlevel1 {

 
cap: mean `var' [pw=pw_w3] if wave==3
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

sum    `var'  if  wave==3
scalar `var'minrN=r(min)
scalar `var'maxrN=r(max)
scalar `var'nN=r(N)

qui sum region if  wave==3
local obsrN=r(N)



matrix mat`var'N  = ( `var'meanrN, `var'seN, `var'minrN, `var'maxrN, `var'nN)


matrix list mat`var'N

matrix A1N = nullmat(A1N)\ mat`var'N


mat A2N=(`obsrN', . , ., .,.)
mat BN=A1N\A2N

matrix colnames BN = "Mean" "SE" "Min" "Max" "N"

}
local rname ""
foreach var in $hhlevel1 {
local lbl : variable label `var'
local rname `"  `rname'   "`lbl'" "'		
}	



mat C= B1, B3, B4, B7, B0, BN

#delimit;
xml_tab C,  save("$table${slash}Sec6_ESS3.xml") replace sheet("Table 1_hh.", nogridlines) /// // sihs note: xml_tab needs to be installed in master.do 
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') 
ceq("Tigray" "Tigray" "Tigray" "Tigray" "Tigray" 
"Amhara" "Amhara" "Amhara" "Amhara" "Amhara" 
"Oromia"  "Oromia" "Oromia""Oromia" "Oromia"  
"SNNP"   "SNNP"   "SNNP"  "SNNP"    "SNNP" 
"Other regions" "Other regions" "Other regions" "Other regions" "Other regions" 
"National" "National" "National" "National" "National" ) showeq 
rblanks(COL_NAMES "Animal Agriculture"       S2149, 
hhd_grass_r "Crop germplasm improvementes"   S2149,
hhd_awassa83_r "Natural resource management" S2149)	 
title(Table 1: ESS3 - Rural Household level - Section 6 )  font("Times New Roman" 10) 
cw(0 110, 1 55, 2 55, 3 30, 4 30, 5 40, 
6 55, 7 55, 8 30, 9 30, 10 40,
11 55, 12 55, 13 30, 14 30, 15 40,
16 55, 17 55, 18 30, 19 30, 20 40,
21 55, 22 55, 23 30, 24 30, 25 40,
26 55, 27 55, 28 30, 29 30, 30 40,) 
format((SCLR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0))  
star(.1 .05 .01)  
lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 13)  
notes(Rural sample - Point estimates are weighted sample means.) ;
#delimit cr	

********************************************************************************
* TABLE 1a - INNOVATIONS AMONG HOUSEHOLDS WITH SPECIFIC CROP
********************************************************************************
gen hh_chickpeas = .
replace hh_chickpeas = 100 if hhd_kabuli_r == 100
replace hh_chickpeas = 100 if hhd_desi_r   == 100
replace hh_chickpeas = 100 if hhd_impcr11_r== 100

foreach var in hhd_kabuli_r{

 
cap: mean `var' [pw=pw_w3] if wave==3 & hh_chickpeas == 100
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

sum    `var'  if  wave==3 & hh_chickpeas == 100
scalar `var'minrN=r(min)
scalar `var'maxrN=r(max)
scalar `var'nN=r(N)

qui sum region if  wave==3 & hh_chickpeas == 100
local obsrN=r(N)



matrix mat`var'N  = ( `var'meanrN, `var'seN, `var'minrN, `var'maxrN, `var'nN)


matrix list mat`var'N
}
matrix colnames mathhd_kabuli_rN = "Mean" "SE" "Min" "Max" "N"

#delimit;
xml_tab mathhd_kabuli_rN,  save("$table${slash}Sec6_ESS3.xml") append sheet("Table 1_hh_alt", nogridlines) /// // sihs note: xml_tab needs to be installed in master.do
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') ceq("National" "National" "National" "National" "National") showeq 	 
title(Table 1a: ESS3 - Rural Household level - % of households with innovation among household with the specific animal/crop)  font("Times New Roman" 10) 
cw(0 110, 1 55, 2 55, 3 30, 4 30, 5 40) 
format((SCLR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0))  
	star(.1 .05 .01)  
	lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 13)   
	notes(Point estimates are weighted sample means. ) 
;
#delimit cr	

	
********************************************************************************	
********************************************************************************
* PSNP
********************************************************************************
use "${data}${slash}ess3_hh_psnp", clear

global psnp hhd_psnp 


* RURAL SAMPLE	
*wave4 
matrix drop _all
foreach x in 1 3 4 7 0 {
foreach var in $psnp {

 
mean `var' [pw=pw_w3] if region==`x' & wave==3 & rural==1
matrix  `var'meanr`x'=e(b)'
matrix define `var'V`x'= e(V)'
matrix define `var'VV`x'=(vecdiag(`var'V`x'))'
matrix list `var'VV`x'
scalar `var'se`x'=sqrt(`var'VV`x'[1,1])


sum    `var'  if region==`x' & wave==3 & rural==1
scalar `var'minr`x'=r(min)
scalar `var'maxr`x'=r(max)
scalar `var'n`x'=r(N)

qui sum region if region==`x' & wave==3 & rural==1
local obsr`x'=r(N)



matrix mat`var'`x'  = ( `var'meanr`x', `var'se`x', `var'minr`x', `var'maxr`x', `var'n`x')


matrix list mat`var'`x'

matrix A1`x' = nullmat(A1`x')\ mat`var'`x'


mat A2`x'=(`obsr`x'', . , ., .,.)
mat B`x'=A1`x'\A2`x'

matrix colnames B`x' = "Mean" "SE" "Min" "Max" "N"

}
local rname ""
foreach var in $psnp {
local lbl : variable label `var'
local rname `"  `rname'   "`lbl'" "'		
}	



}	
* National
foreach var in $psnp {

 
mean `var' [pw=pw_w3] if wave==3 & rural==1
matrix  `var'meanrN=e(b)'
matrix define `var'VN= e(V)'
matrix define `var'VVN=(vecdiag(`var'VN))'
matrix list `var'VVN
scalar `var'seN=sqrt(`var'VVN[1,1])


sum    `var'  if  wave==3 & rural==1
scalar `var'minrN=r(min)
scalar `var'maxrN=r(max)
scalar `var'nN=r(N)

qui sum region if  wave==3 & rural==1
local obsrN=r(N)



matrix mat`var'N  = ( `var'meanrN, `var'seN, `var'minrN, `var'maxrN, `var'nN)


matrix list mat`var'N

matrix A1N = nullmat(A1N)\ mat`var'N


mat A2N=(`obsrN', . , ., .,.)
mat BN=A1N\A2N

matrix colnames BN = "Mean" "SE" "Min" "Max" "N"

}

local rname ""
foreach var in $psnp {
local lbl : variable label `var'
local rname `"  `rname'   "`lbl'" "'		
}	


#delimit;
xml_tab B1 B3 B4 B7 B0 BN,  save("$table${slash}Sec6_ESS3.xml") append sheet("Table 2_hh_rural.", nogridlines)  /// // sihs note: xml_tab needs to be installed in master.do
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') ceq("Tigray" "Tigray" "Tigray" "Tigray" "Tigray" "Amhara"  "Amhara"  "Amhara"  "Amhara" "Amhara" "Oromia" "Oromia" "Oromia" "Oromia" "Oromia" "SNNP"  "SNNP"  "SNNP"  "SNNP" "SNNP" "Other regions" "Other regions" "Other regions" "Other regions" "Other regions" "National" "National" "National" "National" "National" ) showeq
title(Table 2: ESS3 - PSNP - RURAL sample - Section 6)  font("Times New Roman" 10) 
cw(0 110, 1 55, 2 55, 3 30, 4 30, 5 40, 
6 55, 7 55, 8 30, 9 30, 10 40,
11 55, 12 55, 13 30, 14 30, 15 40,
16 55, 17 55, 18 30, 19 30, 20 40,
21 55, 22 55, 23 30, 24 30, 25 40,
26 55, 27 55, 28 30, 29 30, 30 40,
)
	format((SCLR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0)) 
	star(.1 .05 .01)  
	lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 2) 
	notes(Rural sample - Point estimates are weighted sample means.) 
;
#delimit cr				
	

********************************************************************************
* EA LEVEL TABLES
********************************************************************************
use "${data}${slash}wave3_ea", clear

*CROP VARIETY
#delimit ;
global ealevel
ead_livIA_r  ead_cross_largerum_r ead_cross_smallrum_r ead_cross_poultry_r ead_grass_r
ead_kabuli_r ead_ofsp_r ead_awassa83_r
ead_rdisp_r ead_motorpump_r ead_swc_r ead_bbm_r ead_consag1_r ead_consag2_r ead_affor_r ead_mango_r ead_papaya_r ead_avocado_r
commirr;
#delimit cr


matrix drop _all
foreach x in 1 3 4 7 0 {
foreach var in $ealevel {

 
cap:mean `var' [pw=pw_w3] if region==`x' & wave==3
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

sum    `var'  if region==`x' & wave==3
if r(N)==0 {
scalar `var'minr`x'=0
scalar `var'maxr`x'=0
scalar `var'n`x'=0
}
else {
scalar `var'minr`x'=r(min)
scalar `var'maxr`x'=r(max)
scalar `var'n`x'=r(N)
}
qui sum region if region==`x' & wave==3
local obsr`x'=r(N)



matrix mat`var'`x'  = ( `var'meanr`x', `var'se`x',`var'minr`x', `var'maxr`x', `var'n`x')

matrix list mat`var'`x'

matrix A1`x' = nullmat(A1`x')\ mat`var'`x'


mat A2`x'=(`obsr`x'', . , ., .,.)
mat B`x'=A1`x'\A2`x'

matrix colnames B`x' = "Mean" "SE" "Min" "Max" "N"

}
local rname ""
foreach var in $ealevel {
local lbl : variable label `var'
local rname `"  `rname'   "`lbl'" "'		
}	



}
	
* National
foreach var in $ealevel {

 
cap: mean `var' [pw=pw_w3] if wave==3
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

sum    `var'  if  wave==3
if r(N)==0 {
scalar `var'minrN=0
scalar `var'maxrN=0
scalar `var'nN=0
}
else {
scalar `var'minrN=r(min)
scalar `var'maxrN=r(max)
scalar `var'nN=r(N)
}
qui sum region if  wave==3
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
local rname `"  `rname'   "`lbl'" "'		
}	


mat C= B1, B3, B4, B7, B0, BN



#delimit ;
xml_tab C,  save("$table${slash}Sec6_ESS3.xml") append sheet("Table 3_ea.", nogridlines) /// // sihs note: xml_tab needs to be installed in master.do 
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') ceq("Tigray" "Tigray" "Tigray" "Tigray" "Tigray" "Amhara"  "Amhara"  "Amhara"  "Amhara" "Amhara" "Oromia" "Oromia" "Oromia" "Oromia" "Oromia" "SNNP"  "SNNP"  "SNNP"  "SNNP" "SNNP" "Other regions" "Other regions" "Other regions" "Other regions" "Other regions"  "National" "National" "National" "National" "National" ) showeq 
rblanks(COL_NAMES "Animal agriculture" S2149, 
ead_grass_r "Crop germplasm improvements" S2149, 
ead_awassa83_r "Natural resource management" S2149, 
ead_avocado_r "Policy influence" S2149 )	
title(Table 3: ESS3 - EA - Rural sample - Section 6 )  font("Times New Roman" 10) 
cw(0 110, 1 55, 2 55, 3 30, 4 30, 5 40, 
6 55, 7 55, 8 30, 9 30, 10 40,
11 55, 12 55, 13 30, 14 30, 15 40,
16 55, 17 55, 18 30, 19 30, 20 40,
21 55, 22 55, 23 30, 24 30, 25 40,
26 55, 27 55, 28 30, 29 30, 30 40) 
format((SCLR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0))   
star(.1 .05 .01) 
lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 13) 
notes(Rural sample - Point estimates are weighted sample means.) 
;
#delimit cr

********************************************************************************
*PSNP - EA level


use "${data}${slash}ess3_ea_psnp", clear

global psnpea ead_psnp 


	
******************	
* TABLE 4 *
******************	

matrix drop _all
foreach x in 1 3 4 7 0 {
foreach var in $psnpea {

 
mean `var' [pw=pw_w3] if region==`x' & wave==3 & rural==1
matrix  `var'meanr`x'=e(b)'
matrix define `var'V`x'= e(V)'
matrix define `var'VV`x'=(vecdiag(`var'V`x'))'
matrix list `var'VV`x'
scalar `var'se`x'=sqrt(`var'VV`x'[1,1])


sum    `var'  if region==`x' & wave==3 & rural==1
scalar `var'minr`x'=r(min)
scalar `var'maxr`x'=r(max)
scalar `var'n`x'=r(N)

qui sum region if region==`x' & wave==3 & rural==1
local obsr`x'=r(N)



matrix mat`var'`x'  = ( `var'meanr`x', `var'se`x', `var'minr`x', `var'maxr`x', `var'n`x')


matrix list mat`var'`x'

matrix A1`x' = nullmat(A1`x')\ mat`var'`x'


mat A2`x'=(`obsr`x'', . , ., .,.)
mat B`x'=A1`x'\A2`x'

matrix colnames B`x' = "Mean" "SE" "Min" "Max" "N"

}
local rname ""
foreach var in $psnpea {
local lbl : variable label `var'
local rname `"  `rname'   "`lbl'" "'		
}	



}
	
* National
foreach var in $psnpea {

 
mean `var' [pw=pw_w3] if wave==3 & rural==1
matrix  `var'meanrN=e(b)'
matrix define `var'VN= e(V)'
matrix define `var'VVN=(vecdiag(`var'VN))'
matrix list `var'VVN
scalar `var'seN=sqrt(`var'VVN[1,1])


sum    `var'  if  wave==3 & rural==1
scalar `var'minrN=r(min)
scalar `var'maxrN=r(max)
scalar `var'nN=r(N)

qui sum region if  wave==3 & rural==1
local obsrN=r(N)



matrix mat`var'N  = ( `var'meanrN, `var'seN, `var'minrN, `var'maxrN, `var'nN)


matrix list mat`var'N

matrix A1N = nullmat(A1N)\ mat`var'N


mat A2N=(`obsrN', . , ., .,.)
mat BN=A1N\A2N

matrix colnames BN = "Mean" "SE" "Min" "Max" "N"

}

local rname ""
foreach var in $psnpea {
local lbl : variable label `var'
local rname `"  `rname'   "`lbl'" "'		
}	

#delimit;
xml_tab B1 B3 B4 B7 B0 BN,  save("$table${slash}Sec6_ESS3.xml") append sheet("Table 4_ea", nogridlines)  /// // sihs note: xml_tab needs to be installed in master.do
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') ceq("Tigray" "Tigray" "Tigray" "Tigray" "Tigray" "Amhara"  "Amhara"  "Amhara"  "Amhara" "Amhara" "Oromia" "Oromia" "Oromia" "Oromia" "Oromia" "SNNP"  "SNNP"  "SNNP"  "SNNP" "SNNP" "Other regions" "Other regions" "Other regions" "Other regions" "Other regions"  "National" "National" "National" "National" "National"  ) showeq ///
title(Table 4: ESS3 - PSNP - EA - RURAL sample  )  font("Times New Roman" 10) ///
cw(0 110, 1 55, 2 55, 3 30, 4 30, 5 40, 
6 55, 7 55, 8 30, 9 30, 10 40,
11 55, 12 55, 13 30, 14 30, 15 40,
16 55, 17 55, 18 30, 19 30, 20 40,
21 55, 22 55, 23 30, 24 30, 25 40,
26 55, 27 55, 28 30, 29 30, 30 40,
) /// *Adjust the column width of the table, column 0 are the variable names* 1, 5 and 9 are the blank columns. 
	format((SCLR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0))    /// * format the columns. Each parentheses represents one column*
	star(.1 .05 .01)  /// Define your star values/signs here (which are stored in B_STARS)
	lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 2)  /// Draws lines in specific format (Numeric Value)
	notes(Point estimates are weighted sample means. Standard errors are reported below.  ) //Add your notes here	
;
#delimit cr	
	
