********************************************************************************
*                           Ethiopia Synthesis Report 
*                                17_Synergies_DNA
* Country: Ethiopia 
* Data: ESS4 
* Author: Paola Mallia | p.mallia@cgiar.org | paola_mallia@ymail.com 
* STATA Version: SE 16.1
********************************************************************************

********* HH -level ******************
use "${data}${slash}ess4_dna_hh_new", clear
merge 1:1 household_id using "${data}${slash}synergies_hh_ess4_new"

keep if _m==3
drop _m

local vars nrm ca crop tree animal breed breed2 psnp rotlegume cresidue mintillage zerotill  

local vars2  maize sorghum barley

lab var maize "Maize - CG germplasm"
lab var sorghum "Sorghum - CG germplasm"
lab var barley "Barley - CG germplasm"

foreach var of local vars {
local lbl : variable label `var'
foreach i of local vars2 {
local lbl2 : variable label `i'
g `var'_`i'=(`var'*`i') 
label variable `var'_`i' `" `lbl' - `lbl2'"'
}
}

foreach i in maize sorghum barley  {
	foreach x in nrm ca crop tree animal breed breed2 psnp rotlegume cresidue mintillage zerotill {
	g `x'`i'=.
	replace `x'`i' =`x' if `i'!=.
}
}

local vars nrm ca crop tree animal breed breed2 psnp rotlegume cresidue mintillage zerotill

foreach var of local vars {
local lbl : variable label `var'

label variable `var'maize `" `lbl'"'
label variable `var'sorghum `" `lbl'"'
label variable `var'barley `" `lbl'"'
}

#delimit;
global int 
nrmmaize         maize nrm_maize
nrmsorghum         sorghum nrm_sorghum 
nrmbarley         barley nrm_barley 
camaize          maize ca_maize 
casorghum          sorghum ca_sorghum 
cabarley          barley ca_barley 
cropmaize        maize crop_maize 
cropsorghum        sorghum crop_sorghum 
cropbarley        barley crop_barley 
treemaize        maize tree_maize 
treesorghum        sorghum tree_sorghum 
treebarley        barley tree_barley 
animalmaize      maize animal_maize 
animalsorghum      sorghum animal_sorghum 
animalbarley      barley animal_barley 
breedmaize       maize breed_maize 
breedsorghum       sorghum breed_sorghum 
breedbarley       barley breed_barley 
breed2maize      maize breed2_maize 
breed2sorghum      sorghum breed2_sorghum 
breed2barley      barley breed2_barley 
psnpmaize        maize psnp_maize 
psnpsorghum        sorghum psnp_sorghum 
psnpbarley        barley psnp_barley 
rotlegumemaize   maize rotlegume_maize 
rotlegumesorghum   sorghum rotlegume_sorghum 
rotlegumebarley   barley rotlegume_barley 
cresiduemaize    maize   cresidue_maize 
cresiduesorghum    sorghum   cresidue_sorghum 
cresiduebarley    barley   cresidue_barley 
mintillagemaize  maize mintillage_maize 
mintillagesorghum  sorghum mintillage_sorghum 
mintillagebarley  barley mintillage_barley 
zerotillmaize     maize zerotill_maize 
zerotillsorghum     sorghum zerotill_sorghum 
zerotillbarley     barley zerotill_barley 
 ;
#delimit cr		


matrix drop _all
foreach x in 1 3 4 7 0 {
foreach var in $int {

 
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
foreach var in $int {
local lbl : variable label `var'
local rname `"  `rname'   "`lbl'" " " "'		
}	



}	
* National
foreach var in $int {

 
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
foreach var in $int {
local lbl : variable label `var'
local rname `"  `rname'   "`lbl'" "'		
}	
mat C= B1, B3, B4, B7, B0, BN


#delimit;
xml_tab C,  save("$table${slash}ESS_innovation overlap_DNANEW.xml") replace sheet("Table 1_hh_ess4", nogridlines)  ///
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') ceq("Tigray" "Tigray" "Tigray" "Tigray" "Tigray" "Amhara"  "Amhara"  "Amhara"  "Amhara" "Amhara" "Oromia" "Oromia" "Oromia" "Oromia" "Oromia" "SNNP"  "SNNP"  "SNNP"  "SNNP" "SNNP" "Other regions" "Other regions" "Other regions" "Other regions" "Other regions" "National" "National" "National" "National" "National" ) showeq ///
title(Table 2: ESS4 - HH LEVEL )  font("Times New Roman" 10) ///
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
	notes(Point estimates are weighted sample means.) 
;
#delimit cr	


************ EA LEVEL 

use "${data}${slash}ess4_dna_ea_new", clear
* Considering only dna sample cultivating households, respectively 
foreach i in qpm dtmz maize_cg barley_cg sorghum_cg {
replace `i'=. if sample_dna_`i'==.
}

merge 1:1 ea_id using "${data}${slash}synergies_ea_ess4_new"
keep if _m==3
drop _m




local vars nrm ca crop tree animal breed breed2 psnp rotlegume cresidue mintillage zerotill  

local vars2  maize sorghum barley

lab var maize "Maize - CG germplasm"
lab var sorghum "Sorghum - CG germplasm"
lab var barley "Barley - CG germplasm"

foreach var of local vars {
local lbl : variable label `var'
foreach i of local vars2 {
local lbl2 : variable label `i'
g `var'_`i'=(`var'*`i') 
label variable `var'_`i' `" `lbl' - `lbl2'"'
}
}


foreach i in maize sorghum barley  {
	foreach x in nrm ca crop tree animal breed breed2 psnp rotlegume cresidue mintillage zerotill {
	g `x'`i'=.
	replace `x'`i' =`x' if `i'!=.
}
}

local vars nrm ca crop tree animal breed breed2 psnp rotlegume cresidue mintillage zerotill

foreach var of local vars {
local lbl : variable label `var'

label variable `var'maize `" `lbl'"'
label variable `var'sorghum `" `lbl'"'
label variable `var'barley `" `lbl'"'
}



#delimit;
global int 
nrmmaize         maize nrm_maize 
nrmsorghum         sorghum nrm_sorghum 
nrmbarley         barley nrm_barley 
camaize          maize ca_maize 
casorghum          sorghum ca_sorghum 
cabarley          barley ca_barley 
cropmaize        maize crop_maize 
cropsorghum        sorghum crop_sorghum 
cropbarley        barley crop_barley 
treemaize        maize tree_maize 
treesorghum        sorghum tree_sorghum 
treebarley        barley tree_barley 
animalmaize      maize animal_maize 
animalsorghum      sorghum animal_sorghum 
animalbarley      barley animal_barley 
breedmaize       maize breed_maize 
breedsorghum       sorghum breed_sorghum 
breedbarley       barley breed_barley 
breed2maize      maize breed2_maize 
breed2sorghum      sorghum breed2_sorghum 
breed2barley      barley breed2_barley 
psnpmaize        maize psnp_maize 
psnpsorghum        sorghum psnp_sorghum 
psnpbarley        barley psnp_barley 
rotlegumemaize   maize rotlegume_maize 
rotlegumesorghum   sorghum rotlegume_sorghum 
rotlegumebarley   barley rotlegume_barley 
cresiduemaize    maize   cresidue_maize 
cresiduesorghum    sorghum   cresidue_sorghum 
cresiduebarley    barley   cresidue_barley 
mintillagemaize  maize   mintillage_maize 
mintillagesorghum  sorghum   mintillage_sorghum 
mintillagebarley  barley   mintillage_barley 
zerotillmaize     maize   zerotill_maize 
zerotillsorghum     sorghum   zerotill_sorghum 
zerotillbarley     barley   zerotill_barley 
 ;
#delimit cr		




matrix drop _all
foreach x in 1 3 4 7 0 {
foreach var in $int {

 
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
foreach var in $int {
local lbl : variable label `var'
local rname `"  `rname'   "`lbl'" " " "'		
}	



}	
* National
foreach var in $int {

 
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
foreach var in $int {
local lbl : variable label `var'
local rname `"  `rname'   "`lbl'" "'		
}	
mat C= B1, B3, B4, B7, B0, BN


#delimit;
xml_tab C,  save("$table${slash}ESS_innovation overlap_DNANEW.xml") append sheet("Table 2_ea_ess4", nogridlines)  ///
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') ceq("Tigray" "Tigray" "Tigray" "Tigray" "Tigray" "Amhara"  "Amhara"  "Amhara"  "Amhara" "Amhara" "Oromia" "Oromia" "Oromia" "Oromia" "Oromia" "SNNP"  "SNNP"  "SNNP"  "SNNP" "SNNP" "Other regions" "Other regions" "Other regions" "Other regions" "Other regions" "National" "National" "National" "National" "National" ) showeq ///
title(Table 2: ESS4 - EA LEVEL )  font("Times New Roman" 10) ///
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
notes(Point estimates are weighted sample means.)
;
#delimit cr		


*********************************************************************
* OTHER REGIONS
********************************************************************	
	*wave4 
matrix drop _all
foreach x in 2 5 6 12 13 15 {
foreach var in $int {

 
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
foreach var in $int {
local lbl : variable label `var'
local rname `"  `rname'   "`lbl'" "'		
}	



}
	
* All Other regions
foreach var in $int {

 
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
foreach var in $int {
local lbl : variable label `var'
local rname `"  `rname'   "`lbl'" "'		
}	


mat C= B2, B5, B6, B12, B13, B15, BN

#delimit;
xml_tab C,  save("$table${slash}ESS_innovation overlap_DNANEW.xml")  append sheet("Table 3_ea_oth regions", nogridlines)  ///
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') ceq("Afar" "Afar" "Afar" "Afar" "Afar" "Somali"  "Somali" "Somali" "Somali" "Somali" "Benshangul Gumuz" "Benshangul Gumuz" "Benshangul Gumuz" "Benshangul Gumuz"  "Benshangul Gumuz"  "Gambela" "Gambela"  "Gambela"    "Gambela"  "Gambela"  "Harar" "Harar" "Harar" "Harar" "Harar" "Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa" "Other regions"   "Other regions" "Other regions" "Other regions" "Other regions") showeq ///
title(Table 3: ESS4 - EA - Other regions )  font("Times New Roman" 10) ///
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
	notes(Point estimates are weighted sample means.) //Add your notes here
; 
# delimit cr
