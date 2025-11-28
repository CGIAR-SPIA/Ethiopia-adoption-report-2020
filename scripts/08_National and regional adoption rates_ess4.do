********************************************************************************
*                           Ethiopia Synthesis Report 
*                     8_National and regional adoption rates_ess4
* Country: Ethiopia 
* Data: ESS4
* Author: Paola Mallia | p.mallia@cgiar.org | paola_mallia@ymail.com 
* STATA Version: SE 16.1
********************************************************************************
use "${data}${slash}wave4_hh_new", clear

#delimit ;
global hhlevel     
hhd_livIA hhd_cross_largerum hhd_cross_smallrum hhd_cross_poultry hhd_grass
hhd_ofsp hhd_awassa83
hhd_rdisp hhd_motorpump hhd_swc hhd_consag1 hhd_consag2 hhd_affor hhd_mango hhd_papaya hhd_avocado
hhd_impcr13 hhd_impcr19 hhd_impcr11 hhd_impcr24 hhd_impcr14 hhd_impcr3 hhd_impcr5 hhd_impcr60 hhd_impcr62
;
#delimit cr

********************************************************************************
* TABLE 1 - HH LEVEL
********************************************************************************

*wave4 
matrix drop _all
foreach x in 1 3 4 7 0 {
foreach var in $hhlevel {

 
cap:mean `var' [pw=pw_w4] if region==`x' & wave==4
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

sum    `var'  if region==`x' & wave==4
scalar `var'minr`x'=r(min)
scalar `var'maxr`x'=r(max)
scalar `var'n`x'=r(N)

qui sum region if region==`x' & wave==4
local obsr`x'=r(N)



matrix mat`var'`x'  = ( `var'meanr`x', `var'se`x', `var'minr`x', `var'maxr`x', `var'n`x')


matrix list mat`var'`x'

matrix A1`x' = nullmat(A1`x')\ mat`var'`x'


mat A2`x'=(`obsr`x'', . , ., .,.)
mat B`x'=A1`x'\A2`x'

matrix colnames B`x' = "Mean" "SE" "Min" "Max" "N"

}
local rname ""
foreach var in $hhlevel {
local lbl : variable label `var'
local rname `"  `rname'   "`lbl'" " " "'		
}	



}	
* National
foreach var in $hhlevel {

 
cap:mean `var' [pw=pw_w4] if wave==4
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

sum    `var'  if  wave==4
scalar `var'minrN=r(min)
scalar `var'maxrN=r(max)
scalar `var'nN=r(N)

qui sum region if  wave==4
local obsrN=r(N)



matrix mat`var'N  = ( `var'meanrN,`var'seN, `var'minrN, `var'maxrN, `var'nN)


matrix list mat`var'N

matrix A1N = nullmat(A1N)\ mat`var'N


mat A2N=(`obsrN', . , ., .,.)
mat BN=A1N\A2N

matrix colnames BN = "Mean" "SE" "Min" "Max" "N"

}
local rname ""
foreach var in $hhlevel {
local lbl : variable label `var'
local rname `"  `rname'   "`lbl'" "'		
}	
mat C= B1, B3, B4, B7, B0, BN


#delimit;
xml_tab C,  save("$table${slash}Sec6_ESS4.xml") replace sheet("Table 1_hh", nogridlines)  
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') ceq("Tigray" "Tigray" "Tigray" "Tigray" "Tigray" "Amhara"  "Amhara"  "Amhara"  "Amhara" "Amhara" "Oromia" "Oromia" "Oromia" "Oromia" "Oromia" "SNNP"  "SNNP"  "SNNP"  "SNNP" "SNNP" "Other regions" "Other regions" "Other regions" "Other regions" "Other regions" "National" "National" "National" "National" "National" ) showeq 
rblanks(COL_NAMES "Animal Agriculture"       S2149, 
hhd_grass_r "Crop germplasm improvementes"   S2149,
hhd_awassa83_r "Natural resource management" S2149)	 
title(Table 1: ESS4 - Rural Household level - Section 6)  font("Times New Roman" 10) 
cw(0 110, 1 55, 2 55, 3 30, 4 30, 5 40, 
6 55, 7 55, 8 30, 9 30, 10 40,
11 55, 12 55, 13 30, 14 30, 15 40,
16 55, 17 55, 18 30, 19 30, 20 40,
21 55, 22 55, 23 30, 24 30, 25 40,
26 55, 27 55, 28 30, 29 30, 30 40) 
format((SCLR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0))  
	star(.1 .05 .01)  
	lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 13)   
	notes(Point estimates are weighted sample means. ) 
;
#delimit cr		


********************************************************************************
* TABLE 1a - INNOVATIONS AMONG HOUSEHOLDS WITH SPECIFIC ANIMAL/CROP
********************************************************************************

foreach var in hhd_livIA hhd_cross_largerum hhd_grass{
cap:mean `var' [pw=pw_w4] if wave==4 & largerum_nbhh_k > 0
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

sum    `var'  if wave==4 & largerum_nbhh_k > 0
scalar `var'minrN=r(min)
scalar `var'maxrN=r(max)
scalar `var'nN=r(N)

qui sum region if wave==4 & largerum_nbhh_k > 0
local obsrN=r(N)



matrix mat`var'N  = ( `var'meanrN,`var'seN, `var'minrN, `var'maxrN, `var'nN)
}

foreach var in hhd_cross_smallrum{
cap:mean `var' [pw=pw_w4] if wave==4 & smallrum_nbhh_k > 0
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

sum    `var'  if wave==4 & smallrum_nbhh_k > 0
scalar `var'minrN=r(min)
scalar `var'maxrN=r(max)
scalar `var'nN=r(N)

qui sum region if wave==4 & smallrum_nbhh_k > 0
local obsrN=r(N)



matrix mat`var'N  = ( `var'meanrN,`var'seN, `var'minrN, `var'maxrN, `var'nN)
}

foreach var in hhd_cross_poultry{
cap:mean `var' [pw=pw_w4] if wave==4 & poultry_nbhh_k > 0
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

sum    `var'  if wave==4 & poultry_nbhh_k > 0
scalar `var'minrN=r(min)
scalar `var'maxrN=r(max)
scalar `var'nN=r(N)

qui sum region if wave==4 & poultry_nbhh_k > 0
local obsrN=r(N)

matrix mat`var'N  = ( `var'meanrN,`var'seN, `var'minrN, `var'maxrN, `var'nN)
}

mean hhd_ofsp [pw=pw_w4] if wave==4 & hhd_sweetpotato == 100
mean hhd_awassa83 [pw=pw_w4] if wave==4 & hhd_sweetpotato == 100

foreach var in hhd_ofsp hhd_awassa83{
cap:mean `var' [pw=pw_w4] if wave==4 & hhd_sweetpotato == 100
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

sum    `var'  if wave==4 & hhd_sweetpotato == 100
scalar `var'minrN=r(min)
scalar `var'maxrN=r(max)
scalar `var'nN=r(N)

qui sum region if wave==4 & hhd_sweetpotato == 100
local obsrN=r(N)

matrix mat`var'N  = ( `var'meanrN,`var'seN, `var'minrN, `var'maxrN, `var'nN)
}

matrix Alt = (mathhd_livIAN \ mathhd_cross_largerumN \ mathhd_grassN \ mathhd_cross_smallrumN \ mathhd_cross_poultryN \ mathhd_ofspN \ mathhd_awassa83N)

matrix colnames Alt = "Mean" "SE" "Min" "Max" "N"

matrix list Alt

local rname ""
foreach var in hhd_livIA hhd_cross_largerum hhd_grass hhd_cross_smallrum hhd_cross_poultry hhd_ofsp hhd_awassa83 {
    local lbl : variable label `var'
    local rname `"  `rname'   "`lbl'" "'		
}

#delimit;
xml_tab Alt,  save("$table${slash}Sec6_ESS4.xml") append sheet("Table 1_hh_alt", nogridlines)  
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') ceq("National" "National" "National" "National" "National") showeq 	 
title(Table 1a: ESS4 - Rural Household level - % of households with innovation among household with the specific animal/crop)  font("Times New Roman" 10) 
cw(0 110, 1 55, 2 55, 3 30, 4 30, 5 40) 
format((SCLR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0))  
	star(.1 .05 .01)  
	lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 13)   
	notes(Point estimates are weighted sample means. ) 
;
#delimit cr	

**** Other regions *************************************************************
	*wave4 

matrix drop _all
foreach x in 2 5 6 12 13 15  {
foreach var in $hhlevel {

 
cap: mean `var' [pw=pw_w4] if othregion==`x' & wave==4
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

sum    `var'  if othregion==`x' & wave==4
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
qui sum region if othregion==`x' & wave==4
local obsr`x'=r(N)



matrix mat`var'`x'  = ( `var'meanr`x', `var'se`x', `var'minr`x', `var'maxr`x', `var'n`x')

matrix list mat`var'`x'

matrix A1`x' = nullmat(A1`x')\ mat`var'`x'


mat A2`x'=(`obsr`x'', . , ., .,.)
mat B`x'=A1`x'\A2`x'

matrix colnames B`x' = "Mean" "SE" "Min" "Max" "N"

}
local rname ""
foreach var in $hhlevel {
local lbl : variable label `var'
local rname `"  `rname'   "`lbl'" "'	
}	



}

mat C= B2, B5, B6, B12, B13, B15

# delimit;
xml_tab C,  save("$table${slash}Sec6_ESS4.xml") append sheet("Table 1_hh_oth regions", nogridlines)  ///
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') ceq("Afar" "Afar" "Afar" "Afar" "Afar" "Somali" "Somali" "Somali" "Somali" "Somali" "Benshangul Gumuz" "Benshangul Gumuz" "Benshangul Gumuz"  "Benshangul Gumuz"  "Benshangul Gumuz"  "Gambela"  "Gambela" "Gambela"    "Gambela"  "Gambela"  "Harar" "Harar" "Harar" "Harar" "Harar" "Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa" "Other regions" "Other regions" "Other regions" "Other regions" "Other regions") showeq ///
rblanks(COL_NAMES "Percentage of hh that adopt on at least one plot :" S2149, hhd_impccr  "Share of plots per household" S2149)	
title(Table 1: ESS4 - Rural Household level - Section 6 - Other regions)  font("Times New Roman" 10) ///
cw(0 110, 1 55, 2 55, 3 30, 4 30, 5 40, 
6 55, 7 55, 8 30, 9 30, 10 40,
11 55, 12 55, 13 30, 14 30, 15 40,
16 55, 17 55, 18 30, 19 30, 20 40,
21 55, 22 55, 23 30, 24 30, 25 40,
26 55, 27 55, 28 30, 29 30, 30 40,
) /// 
	format((SCLR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0))  /// 
	star(.1 .05 .01)  /// 
	lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 13)  /// 
	notes( Point estimates are sample means.  ) //Add your notes here
; 
# delimit cr

********************************************************************************
* PSNP
********************************************************************************
use "${data}${slash}ess4_hh_psnp", clear

global psnp hhd_psnp 
	

matrix drop _all
foreach x in 1 3 4 7 0 {
foreach var in $psnp {

 
mean `var' [pw=pw_w4] if region==`x' & wave==4 & saq14==1
matrix  `var'meanr`x'=e(b)'
matrix define `var'V`x'= e(V)'
matrix define `var'VV`x'=(vecdiag(`var'V`x'))'
matrix list `var'VV`x'
scalar `var'se`x'=sqrt(`var'VV`x'[1,1])


sum    `var'  if region==`x' & wave==4 & saq14==1
scalar `var'minr`x'=r(min)
scalar `var'maxr`x'=r(max)
scalar `var'n`x'=r(N)

qui sum region if region==`x' & wave==4 & saq14==1
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

 
mean `var' [pw=pw_w4] if wave==4 & saq14==1
matrix  `var'meanrN=e(b)'
matrix define `var'VN= e(V)'
matrix define `var'VVN=(vecdiag(`var'VN))'
matrix list `var'VVN
scalar `var'seN=sqrt(`var'VVN[1,1])


sum    `var'  if  wave==4 & saq14==1
scalar `var'minrN=r(min)
scalar `var'maxrN=r(max)
scalar `var'nN=r(N)

qui sum region if  wave==4 & saq14==1
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
xml_tab B1 B3 B4 B7 B0 BN,  save("$table${slash}Sec6_ESS4.xml") append sheet("Table 2_hh.", nogridlines)  ///
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') ceq("Tigray" "Tigray" "Tigray" "Tigray"  "Tigray" "Amhara"  "Amhara"  "Amhara"  "Amhara"  "Amhara" "Oromia" "Oromia" "Oromia" "Oromia"  "Oromia" "SNNP"  "SNNP"  "SNNP"  "SNNP"  "SNNP" "Other regions" "Other regions" "Other regions" "Other regions"  "Other regions" "National" "National" "National" "National" "National" ) showeq ///
title(Table 2: ESS4 - PSNP - Section 6)  font("Times New Roman" 10) ///
cw(0 110, 1 55, 2 55, 3 30, 4 30, 5 40, 
6 55, 7 55, 8 30, 9 30, 10 40,
11 55, 12 55, 13 30, 14 30, 15 40,
16 55, 17 55, 18 30, 19 30, 20 40,
21 55, 22 55, 23 30, 24 30, 25 40,
26 55, 27 55, 28 30, 29 30, 30 40,
)
	format((SCLR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0))  
	star(.1 .05 .01)  
	lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 13)  
	notes(Point estimates are weighted sample means. ) ;
#delimit cr



********************************************************************************
* EA LEVEL TABLES
********************************************************************************
use "${data}${slash}wave4_ea_new", clear

*CROP VARIETY
#delimit ;
global ealevel
ead_livIA  ead_cross_largerum ead_cross_smallrum ead_cross_poultry ead_grass
ead_ofsp ead_awassa83
ead_rdisp ead_motorpump ead_swc  ead_consag1 ead_consag2 ead_affor ead_mango ead_papaya ead_avocado
commirr
ead_impcr13 ead_impcr19 ead_impcr11 ead_impcr24 ead_impcr14 ead_impcr3 ead_impcr5 ead_impcr60 ead_impcr62;
#delimit cr
	

matrix drop _all
foreach x in 1 3 4 7 0 {
foreach var in $ealevel {

 
cap: mean `var' [pw=pw_w4] if region==`x' & wave==4
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

sum    `var'  if region==`x' & wave==4

scalar `var'minr`x'=r(min)
scalar `var'maxr`x'=r(max)
scalar `var'n`x'=r(N)


qui sum region if region==`x' & wave==4
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
local rname `"  `rname'   "`lbl'" "'		
}	



}
	
* National
foreach var in $ealevel {

 
cap: mean `var' [pw=pw_w4] if wave==4
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

sum    `var'  if  wave==4
scalar `var'minrN=r(min)
scalar `var'maxrN=r(max)
scalar `var'nN=r(N)

qui sum region if  wave==4
local obsrN=r(N)



matrix mat`var'N  = ( `var'meanrN, `var'seN, `var'minrN, `var'maxrN, `var'nN)


matrix list mat`var'N

matrix A1N = nullmat(A1N)\ mat`var'N


mat A2N=(`obsrN', . , ., ., .)
mat BN=A1N\A2N

matrix colnames BN = "Mean" "SE" "Min" "Max" "N"

}

local rname ""
foreach var in $ealevel {
local lbl : variable label `var'
local rname `"  `rname'   "`lbl'" "'		
}	


mat C= B1, B3, B4, B7, B0, BN


#delimit;
xml_tab C,  save("$table${slash}Sec6_ESS4.xml") append sheet("Table 5_ea", nogridlines)  ///
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') ceq("Tigray" "Tigray" "Tigray" "Tigray" "Tigray" "Amhara"  "Amhara"  "Amhara"  "Amhara" "Amhara" "Oromia" "Oromia" "Oromia" "Oromia" "Oromia" "SNNP"  "SNNP"  "SNNP"  "SNNP" "SNNP" "Other regions" "Other regions" "Other regions" "Other regions" "Other regions"  "National" "National" "National" "National" "National"  ) showeq ///
rblanks(COL_NAMES "Perc. of EA in the sample with at least 1 hh adopting:" S2149,
ead_impccr   "Perc. of hh per EA adopting" S2149, 
sh_ea_impccr"Perc. of plots per EA adopting" S2149)	 
title(Table 5: ESS4 - Crop variety - EA )  font("Times New Roman" 10) ///
cw(0 110, 1 55, 2 55, 3 30, 4 30, 5 40, 
6 55, 7 55, 8 30, 9 30, 10 40,
11 55, 12 55, 13 30, 14 30, 15 40,
16 55, 17 55, 18 30, 19 30, 20 40,
21 55, 22 55, 23 30, 24 30, 25 40,
26 55, 27 55, 28 30, 29 30, 30 40,
) 
	format((SCLR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0)) 
	star(.1 .05 .01)  
	lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 13)  
	notes(Point estimates are weighted sample means.   ) 
; 
# delimit cr

********************************************************************************
* OTHER REGIONS
* TABLE 5	
	
	*wave4 
matrix drop _all
foreach x in 2 5 6 12 13 15 {
foreach var in $ealevel {

 
cap: mean `var' [pw=pw_w4] if othregion==`x' & wave==4
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

sum    `var'  if othregion==`x' & wave==4
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

qui sum region if othregion==`x' & wave==4
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
local rname `"  `rname'   "`lbl'" "'		
}	



}
	
* All Other regions
foreach var in $ealevel {

 
cap:mean `var' [pw=pw_w4] if wave==4 & region==0
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

sum    `var'  if  wave==4 & region==0
scalar `var'minrN=r(min)
scalar `var'maxrN=r(max)
scalar `var'nN=r(N)

qui sum region if  wave==4 & region==0
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


mat C= B2, B5, B6, B12, B13, B15, BN

#delimit;
xml_tab C,  save("$table${slash}Sec6_ESS4.xml") append sheet("Table 5_ea_oth regions", nogridlines)  ///
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') ceq("Afar" "Afar" "Afar" "Afar" "Afar" "Somali"  "Somali" "Somali" "Somali" "Somali" "Benshangul Gumuz" "Benshangul Gumuz" "Benshangul Gumuz" "Benshangul Gumuz"  "Benshangul Gumuz"  "Gambela" "Gambela"  "Gambela"    "Gambela"  "Gambela"  "Harar" "Harar" "Harar" "Harar" "Harar" "Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa" "Other regions"   "Other regions" "Other regions" "Other regions" "Other regions") showeq ///
rblanks(COL_NAMES "Perc. of EA in the sample with at least 1 hh adopting:" S2149,
ead_sweetpotato   "Perc. of hh per EA adopting" S2149, 
sh_ea_sweetpotato "Perc. of plots per EA adopting" S2149)	 
title(Table 5_b: ESS4 - Crop variety - EA - Other regions )  font("Times New Roman" 10) ///
cw(0 110, 1 55, 2 55, 3 30, 4 30, 5 40, 
6 55, 7 55, 8 30, 9 30, 10 40,
11 55, 12 55, 13 30, 14 30, 15 40,
16 55, 17 55, 18 30, 19 30, 20 40,
21 55, 22 55, 23 30, 24 30, 25 40,
26 55, 27 55, 28 30, 29 30, 30 40,
) /// 
	format((SCLR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0))  /// 
	star(.1 .05 .01)  /// 
	lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 13)  /// 
	notes(N=100. Point estimates are weighted sample means.   ) //Add your notes here
; 
# delimit cr


*PSNP - EA level

use "${data}${slash}ess4_ea_psnp", clear

global psnpea ead_psnp 	
	
	
matrix drop _all
foreach x in 1 3 4 7 0 {
foreach var in $psnpea {

 
mean `var' [pw=pw_w4] if region==`x' & wave==4 & saq14==1
matrix  `var'meanr`x'=e(b)'
matrix define `var'V`x'= e(V)'
matrix define `var'VV`x'=(vecdiag(`var'V`x'))'
matrix list `var'VV`x'
scalar `var'se`x'=sqrt(`var'VV`x'[1,1])


sum    `var'  if region==`x' & wave==4 & saq14==1
scalar `var'minr`x'=r(min)
scalar `var'maxr`x'=r(max)
scalar `var'n`x'=r(N)

qui sum region if region==`x' & wave==4 & saq14==1
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

 
mean `var' [pw=pw_w4] if wave==4 & saq14==1
matrix  `var'meanrN=e(b)'
matrix define `var'VN= e(V)'
matrix define `var'VVN=(vecdiag(`var'VN))'
matrix list `var'VVN
scalar `var'seN=sqrt(`var'VVN[1,1])


sum    `var'  if  wave==4 & saq14==1
scalar `var'minrN=r(min)
scalar `var'maxrN=r(max)
scalar `var'nN=r(N)

qui sum region if  wave==4
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
xml_tab B1 B3 B4 B7 B0 BN,  save("$table${slash}Sec6_ESS4.xml") append sheet("Table 4_ea", nogridlines)  
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') ceq("Tigray" "Tigray" "Tigray" "Tigray" "Tigray" "Amhara" "Amhara"  "Amhara"  "Amhara"  "Amhara" "Oromia" "Oromia" "Oromia" "Oromia" "Oromia" "SNNP" "SNNP"  "SNNP"  "SNNP"  "SNNP" "Other regions" "Other regions" "Other regions" "Other regions" "Other regions" "National" "National" "National" "National"  "National") showeq 
title(Table 4: ESS4 - PSNP - EA  )  font("Times New Roman" 10) 
cw(0 110, 1 55, 2 55, 3 30, 4 30, 5 40, 
6 55, 7 55, 8 30, 9 30, 10 40,
11 55, 12 55, 13 30, 14 30, 15 40,
16 55, 17 55, 18 30, 19 30, 20 40,
21 55, 22 55, 23 30, 24 30, 25 40,
26 55, 27 55, 28 30, 29 30, 30 40,
) 
	format((SCLR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0)) 
	star(.1 .05 .01)  
	lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 13)  
	notes(Point estimates are weighted sample means.) 
;
#delimit cr	

*********************************************************
* Crop Germplasm Improved using DNA-fingerprinting data
*********************************************************

use "${data}${slash}misclassification_plot_new", clear


global hhlevel qpm dtmz maize_cg barley_cg sorghum_cg	

matrix drop _all
foreach x in 1 3 4 7 13 15 {
foreach var in $hhlevel {

 
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
foreach var in $hhlevel {
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
foreach var in $hhlevel {
local lbl : variable label `var'
local rname `"  `rname'   "`lbl'" " " "'		
}	
		
mat C= B1, B3, B4, B7, B13, B15, BN
	
	
xml_tab C ,  save("$table${slash}Sec6_ESS4.xml") append sheet("Table 5_hh", nogridlines)  ///
cnames(`cnames')  ceq("Tigray" "Tigray" "Tigray" "Tigray" "Tigray" "Amhara"  "Amhara"  "Amhara"  "Amhara" "Amhara" "Oromia" "Oromia" "Oromia" "Oromia" "Oromia" "SNNP"  "SNNP"  "SNNP"  "SNNP" "SNNP" "Harar" "Harar" "Harar" "Harar" "Harar" "Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa" "National" "National" "National" "National" "National") showeq ///
rblanks(COL_NAMES "Hh level data" S2220)	 /// 
title(Table 5: ESS4 - HH-level - by region)  font("Times New Roman" 10) ///
cw(0 110, 1 55, 2 30, 3 30, 4 40, 5 55, 6 30, 7 30, 8 40, 9 55, 10 30, 11 30, 12 40, 13 55,  14 30,  15 30, 16 40, 17 55, 18 30, 19 30, 20 40, 21 55, 22 30, 23 30, 24 40, 25 55, 26 30, 27 30, 28 40, 29 55, 30 30, 31 30, 32 40, 33 55, 34 30, 35 30, 36 40, 37 55, 38 30, 39 30, 40 40  ) /// 
format((SCLR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0))  /// 
star(.1 .05 .01)  /// 
lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 2)  ///
notes(Point estimates are weighted sample means. Standard errors are reported below. Sub-sample of national sample used. ) 


**************	
* EA LEVEL 
**************
use "${data}${slash}ess4_dna_ea_new", clear

* Considering only dna sample cultivating households, respectively 
foreach i in qpm dtmz maize_cg barley_cg sorghum_cg {
replace `i'=. if sample_dna_`i'==.
}

global ealevel 	qpm dtmz maize_cg barley_cg sorghum_cg

matrix drop _all
foreach x in 1 3 4 7 13 15 {
foreach var in $ealevel {

 
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
	
	
xml_tab C, save("$table${slash}Sec6_ESS4.xml") append sheet("Table 6_ea", nogridlines)  ///
cnames(`cnames')  ceq("Tigray" "Tigray" "Tigray" "Tigray" "Tigray" "Amhara"  "Amhara"  "Amhara"  "Amhara" "Amhara" "Oromia" "Oromia" "Oromia" "Oromia" "Oromia" "SNNP"  "SNNP"  "SNNP"  "SNNP" "SNNP" "Harar" "Harar" "Harar" "Harar" "Harar" "Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa" "National" "National" "National" "National" "National") showeq ///
rblanks(COL_NAMES "EA level data" S2220)	 ///
title(Table 6: ESS4 - EA-level - by region)  font("Times New Roman" 10) ///
cw(0 110, 1 55, 2 30, 3 30, 4 40, 5 55, 6 30, 7 30, 8 40, 9 55, 10 30, 11 30, 12 40, 13 55,  14 30,  15 30, 16 40, 17 55, 18 30, 19 30, 20 40, 21 55, 22 30, 23 30, 24 40, 25 55, 26 30, 27 30, 28 40, 29 55, 30 30, 31 30, 32 40, 33 55, 34 30, 35 30, 36 40, 37 55, 38 30, 39 30, 40 40  ) ///  
format((SCLR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0))  /// 
star(.1 .05 .01)  /// 
lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 2)  /// 
notes(Point estimates are weighted sample means. Standard errors are reported below. Sub-sample of national sample used. ) 

	
