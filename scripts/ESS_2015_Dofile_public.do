clear all
clear matrix
capture log close
set more off

********************************************************************************
*                            Covariates - ESSW3-2015/16               
********************************************************************************
* Country: ETHIOPIA                                                            
* Created by: Solomon Alemu - S.Alemu@cgiar.org        
* Date:  April,2020                                                               
********************************************************************************

*===============================================================================
** Covariates from ESS3-HH modules 
*===============================================================================

** Demographics and Education-sect1& 2_hh_w3

{/*Demographics-sect1_hh_w3.dta*/

use "${raw3}${slash}sect1_hh_w3", clear

gen age_head= hh_s1q04a if hh_s1q02==1

label variable age_head "age_head"

egen uni_id = concat( household_id individual_id )
duplicates drop uni_id, force
order uni_id

save "$temp${slash}sect1_hh_w3_demo", replace

collapse (max)  age_head , by ( household_id2 )

clonevar age_head_wiz= age_head
winsor2 age_head_wiz , replace cuts(1 99)
order age_head_wiz,after ( age_head)

label variable age_head "age_head"
label variable age_head_wiz "age_head"
save "$temp${slash}sect1_hh_w3_demo_hh", replace

}


**Non-farm enterprise and Other income- section 12

{/*Non-farm enterprise-sect12_hh_w3*/


**Other income-sect12_hh_w3

use "${raw3}${slash}sect12_hh_w3", clear 

clonevar hh_s12q02_wiz=hh_s12q02

winsor2 hh_s12q02_wiz , replace cuts(1 99)

order hh_s12q02_wiz, after (hh_s12q02)

collapse (sum) hh_s12q02 hh_s12q02_wiz, by ( household_id2 )

label variable hh_s12q02 "off- farm income in the  last 12 months? (BIRR)"
label variable hh_s12q02_wiz "off- farm income in the  last 12 months? (BIRR)"
save "$temp${slash}sect12_hh_w3_offincome", replace

}

**Asset

{/*Asset3*/

 *** Asset Indix-sect10_hh_w3
 
use "${raw3}${slash}sect10_hh_w3.dta",clear
gen HHown_item=1 if hh_s10q01>0

replace HHown_item=0 if HHown_item==.
keep household_id2 hh_s10q00 HHown_item
reshape wide HHown_item, i( household_id2 ) j( hh_s10q00 )
save "$temp${slash}sect10_hh_w3_asset", replace

*** Houssing-sec9_hh_w3

use "${raw3}${slash}sect9_hh_w3",clear

keep household_id2 hh_s9q03 hh_s9q04 hh_s9q05 hh_s9q06 hh_s9q07 hh_s9q08 hh_s9q10 hh_s9q12 hh_s9q13 hh_s9q14 hh_s9q04 hh_s9q19_a
rename hh_s9q06 roof
rename hh_s9q07 floor
rename hh_s9q08 Kitchen
rename hh_s9q10 toilet
rename hh_s9q12 solidwastdisp
rename hh_s9q13 drinkwat_sc
rename drinkwat_sc drinkwat_sc_rain
rename hh_s9q14 drinkwat_sc_dry
rename hh_s9q04 no_room
rename hh_s9q19_a lightsource
rename hh_s9q05 wall
rename hh_s9q03 own_house
order no_room,after ( own_house )
for var wall - lightsource: tabulate X , gen(X )

winsor2 no_room , replace cuts(1 99)
save "$temp${slash}sec9_hh_w3_housing", replace

use "$temp${slash}sec9_hh_w3_housing", replace
merge 1:1 household_id2 using "$temp${slash}sect10_hh_w3_asset"
drop _m


drop drinkwat_sc_rain1- drinkwat_sc_dry13

merge 1:1 household_id2 using "${raw3}${slash}sect_cover_hh_w3.dta"

order no_room,after ( HHown_item35 )
pca HHown_item1- no_room , comp(1)
predict asset
sum asset

xtile asset_index=asset, nq(5)
* table asset_index, c(mean asset) // SIHS replaced this line with line below
	* this line is incompatible with Stata 17+ syntax
	* "c()" i.e. "contents()" is no longer a valid command
table asset_index, statistic(mean asset) // SIHS added this line to replace line above
keep household_id2 asset asset_index
compress
save "$temp${slash}Asset_index", replace

***productive-asset

*** asset-only productive asset
 
use "${raw3}${slash}sect10_hh_w3.dta",clear
 
keep if hh_s10q00>=30
 
gen HHown_item=1 if hh_s10q01>0

replace HHown_item=0 if HHown_item==.
keep household_id2 hh_s10q00 HHown_item
reshape wide HHown_item, i( household_id2 ) j( hh_s10q00 )
save "$temp${slash}asset_productiveasset", replace

merge 1:1 household_id2 using "${raw3}${slash}sect_cover_hh_w3.dta"
pca HHown_item30- HHown_item35 , comp(1)
predict asset
sum asset
xtile prod_asset_ndex=asset, nq(5)
* table prod_asset_ndex, c(mean asset) // SIHS commented out this line - Stata version compatibility problem
table prod_asset_ndex, statistic(mean asset) // SIHS added this line to replace the line above
keep household_id2 asset prod_asset_ndex
compress
rename asset asset_prod
save "$temp${slash}prod-asse_index", replace
}

*** merging-HH_DEMO_EDUC_ASSET
{/*merging all the hh level data*/

use "${raw3}${slash}sect_cover_hh_w3", clear 

merge 1:1 household_id2 using "$temp${slash}sect1_hh_w3_demo_hh.dta"
drop _m
merge 1:1 household_id2 using "$temp${slash}Asset_index.dta"
drop _m
merge 1:1 household_id2 using "$temp${slash}prod-asse_index.dta"
drop _m
merge 1:1 household_id2 using "$temp${slash}sect12_hh_w3_offincome.dta"
drop _m

gen HH_DEMO_EDUC_ASSET=.
order HH_DEMO_EDUC_ASSET,after ( hh_saq33_b )

save "$temp${slash}HH_LEVEL_DATA", replace
}

*===============================================================================
** Covariates from ESS3-PP Modules 
*===============================================================================

**PP module-section2, section3

{/*sect2_pp_w3*/

**section2_w3

use "${raw3}${slash}sect2_pp_w3", clear

for var pp_s2q01b pp_s2q04: recode  X (2=0)
lab define Yes_no 1"Yes" 0 "No",replace
for var pp_s2q01b pp_s2q04: lab values X Yes_no
tab pp_s2q15, gen ( pp_s2q15 )
tab pp_s2q14, gen ( pp_s2q14)

collapse (mean) pp_s2q151- pp_s2q146, by  ( household_id2 )

label variable pp_s2q151 "% of plot with good soil quality"
label variable pp_s2q152 "% of plot with fair soil quality"
label variable pp_s2q153 "% of plot with poor soil quality"
label variable pp_s2q141 "% of plot with Leptosol  soiltype"
label variable pp_s2q141 "% of plot with Leptosol  soil type"
label variable pp_s2q142 " % of plot with Cambisol  soil type"
label variable pp_s2q143 "% of plot with Vertisol soil type"
label variable pp_s2q144 "% of plot with Luvisol soil type"
label variable pp_s2q145 "% of plot with mixed soil type"
label variable pp_s2q146 "% of plot with other soil type"

save "$temp${slash}sect2_pp_w3_hh", replace


 
 **section3_w3
use "${raw3}${slash}sect3_pp_w3", clear 
 
 
*local land conversion

**timad

 replace pp_s3q05_a= pp_s3q02_a* 1947.582 if saq01==1 & pp_s3q02_c==3 & pp_s3q05_a==.
 replace pp_s3q05_a= pp_s3q02_a* 1941.238 if saq01==3 & pp_s3q02_c==3 & pp_s3q05_a==.
 replace pp_s3q05_a= pp_s3q02_a* 1472.163 if saq01==4 & pp_s3q02_c==3 & pp_s3q05_a==.
 replace pp_s3q05_a= pp_s3q02_a* 991.1986 if saq01==5 & pp_s3q02_c==3 & pp_s3q05_a==.
 replace pp_s3q05_a= pp_s3q02_a* 1476.523 if saq01==6 & pp_s3q02_c==3 & pp_s3q05_a==.
 replace pp_s3q05_a= pp_s3q02_a* 1205.46 if saq01==7 & pp_s3q02_c==3 & pp_s3q05_a==.
 replace pp_s3q05_a= pp_s3q02_a* 1042.535 if saq01==12 & pp_s3q02_c==3 & pp_s3q05_a==.
 replace pp_s3q05_a= pp_s3q02_a* 570 if saq01==13 & pp_s3q02_c==3 & pp_s3q05_a==.
 replace pp_s3q05_a= pp_s3q02_a* 1051.083 if saq01==15 & pp_s3q02_c==3 & pp_s3q05_a==.
 
 **boy
 
 replace pp_s3q05_a= pp_s3q02_a* 304.4126 if saq01==4 & pp_s3q02_c==4 & pp_s3q05_a==.
 replace pp_s3q05_a= pp_s3q02_a* 172.02 if saq01==5 & pp_s3q02_c==4 & pp_s3q05_a==.
 replace pp_s3q05_a= pp_s3q02_a* 140 if saq01==13 & pp_s3q02_c==4 & pp_s3q05_a==.
 
replace pp_s3q05_a= pp_s3q02_a* 1197.805 if saq01==4 & pp_s3q02_c==5 & pp_s3q05_a==.
replace pp_s3q05_a= pp_s3q02_a* 2113.159 if saq01==4 & pp_s3q02_c==6 & pp_s3q05_a==.
 replace pp_s3q05_a= pp_s3q02_a* 843 if saq01==6 & pp_s3q02_c==6 & pp_s3q05_a==.
 
 
 **
  replace pp_s3q05_a= pp_s3q02_a* 1947.582 if saq01==1 & pp_s3q02_c==3 & pp_s3q05_a==0
 replace pp_s3q05_a= pp_s3q02_a* 1941.238 if saq01==3 & pp_s3q02_c==3 & pp_s3q05_a==0
 replace pp_s3q05_a= pp_s3q02_a* 1472.163 if saq01==4 & pp_s3q02_c==3 & pp_s3q05_a==0
 replace pp_s3q05_a= pp_s3q02_a* 991.1986 if saq01==5 & pp_s3q02_c==3 & pp_s3q05_a==0
 replace pp_s3q05_a= pp_s3q02_a* 1476.523 if saq01==6 & pp_s3q02_c==3 & pp_s3q05_a==0
 replace pp_s3q05_a= pp_s3q02_a* 1205.46 if saq01==7 & pp_s3q02_c==3 & pp_s3q05_a==0
 replace pp_s3q05_a= pp_s3q02_a* 1042.535 if saq01==12 & pp_s3q02_c==3 & pp_s3q05_a==0
 replace pp_s3q05_a= pp_s3q02_a* 570 if saq01==13 & pp_s3q02_c==3 & pp_s3q05_a==0
 replace pp_s3q05_a= pp_s3q02_a* 1051.083 if saq01==15 & pp_s3q02_c==3 & pp_s3q05_a==0
 
 **boy
 
 replace pp_s3q05_a= pp_s3q02_a* 304.4126 if saq01==4 & pp_s3q02_c==4 & pp_s3q05_a==0
 replace pp_s3q05_a= pp_s3q02_a* 172.02 if saq01==5 & pp_s3q02_c==4 & pp_s3q05_a==0
 replace pp_s3q05_a= pp_s3q02_a* 140 if saq01==13 & pp_s3q02_c==4 & pp_s3q05_a==0
 
replace pp_s3q05_a= pp_s3q02_a* 1197.805 if saq01==4 & pp_s3q02_c==5 & pp_s3q05_a==0
replace pp_s3q05_a= pp_s3q02_a* 2113.159 if saq01==4 & pp_s3q02_c==6 & pp_s3q05_a==0
 replace pp_s3q05_a= pp_s3q02_a* 843 if saq01==6 & pp_s3q02_c==6 & pp_s3q05_a==0 

*** add converstion units
**timand
bys saq02:sum pp_s3q05_a if pp_s3q02_a==1 &  pp_s3q02_c==3

replace pp_s3q05_a= pp_s3q02_a *1688.38 if pp_s3q05_a==. & saq02==1 & pp_s3q02_c==3


replace pp_s3q05_a= pp_s3q02_a* 1706.456 if pp_s3q05_a==. & saq02==2 & pp_s3q02_c==3


replace pp_s3q05_a= pp_s3q02_a* 1921.442 if pp_s3q05_a==. & saq02==3 & pp_s3q02_c==3


replace pp_s3q05_a= pp_s3q02_a* 1741.507 if pp_s3q05_a==. & saq02==4 & pp_s3q02_c==3


replace pp_s3q05_a= pp_s3q02_a* 2401.539 if pp_s3q05_a==. & saq02==5 & pp_s3q02_c==3

replace pp_s3q05_a= pp_s3q02_a* 1932.907 if pp_s3q05_a==. & saq02==6 & pp_s3q02_c==3

replace pp_s3q05_a= pp_s3q02_a* 1522.36 if pp_s3q05_a==. & saq02==7 & pp_s3q02_c==3

replace pp_s3q05_a= pp_s3q02_a* 1526.937 if pp_s3q05_a==. & saq02==8 & pp_s3q02_c==3

replace pp_s3q05_a= pp_s3q02_a* 1531.131 if pp_s3q05_a==. & saq02==9 & pp_s3q02_c==3

replace pp_s3q05_a= pp_s3q02_a* 1270.36 if pp_s3q05_a==. & saq02==10 & pp_s3q02_c==3

replace pp_s3q05_a= pp_s3q02_a* 1088.34 if pp_s3q05_a==. & saq02==11 & pp_s3q02_c==3

replace pp_s3q05_a= pp_s3q02_a* 1390.116 if pp_s3q05_a==. & saq02==12 & pp_s3q02_c==3

replace pp_s3q05_a= pp_s3q02_a* 1218.122 if pp_s3q05_a==. & saq02==13 & pp_s3q02_c==3

replace pp_s3q05_a= pp_s3q02_a* 1390.09 if pp_s3q05_a==. & saq02==14 & pp_s3q02_c==3

replace pp_s3q05_a= pp_s3q02_a* 1964.15 if pp_s3q05_a==. & saq02==15 & pp_s3q02_c==3

replace pp_s3q05_a= pp_s3q02_a* 1460.438 if pp_s3q05_a==. & saq02==16 & pp_s3q02_c==3

replace pp_s3q05_a= pp_s3q02_a* 2107.161 if pp_s3q05_a==. & saq02==17 & pp_s3q02_c==3

replace pp_s3q05_a= pp_s3q02_a* 1038.891 if pp_s3q05_a==. & saq02==18 & pp_s3q02_c==3

replace pp_s3q05_a= pp_s3q02_a*  966.5817 if pp_s3q05_a==. & saq02==19 & pp_s3q02_c==3

replace pp_s3q05_a= pp_s3q02_a*  2138.269 if pp_s3q05_a==. & saq02==20 & pp_s3q02_c==3
replace pp_s3q05_a= pp_s3q02_a*  2147.194  if pp_s3q05_a==. & saq02==21 & pp_s3q02_c==3

**tilem
bys saq02:sum pp_s3q05_a if pp_s3q02_a==1 &  pp_s3q02_c==4

replace pp_s3q05_a= pp_s3q02_a * 184.4619  if pp_s3q05_a==. & saq02==1 & pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 218.8295 if pp_s3q05_a==. & saq02==2 & pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 160.1442 if pp_s3q05_a==. & saq02==3 & pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 72.26017 if pp_s3q05_a==. & saq02==4 & pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a*  177.6958 if pp_s3q05_a==. & saq02==5 & pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a*  84.06111 if pp_s3q05_a==. & saq02==6 & pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a*  166.485 if pp_s3q05_a==. & saq02==7 & pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 590.7878 if pp_s3q05_a==. & saq02==8 & pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 232.0731 if pp_s3q05_a==. & saq02==9 & pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 241.6655 if pp_s3q05_a==. & saq02==10 & pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 114.1061  if pp_s3q05_a==. & saq02==11 & pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 252.4734 if pp_s3q05_a==. & saq02==12 & pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a*  198.0058 if pp_s3q05_a==. & saq02==13 & pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 189.3883 if pp_s3q05_a==. & saq02==14 & pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 185.883  if pp_s3q05_a==. & saq02==15 & pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 114.0615  if pp_s3q05_a==. & saq02==16 & pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 79.29238 if pp_s3q05_a==. & saq02==17 & pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 87.36167 if pp_s3q05_a==. & saq02==18 & pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a*  149.0605 if pp_s3q05_a==. & saq02==19 & pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a*  277.1222 if pp_s3q05_a==. & saq02==20 & pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a*  227.6406  if pp_s3q05_a==. & saq02==21 & pp_s3q02_c==4

** medieb

bys saq02:sum pp_s3q05_a if pp_s3q02_a==1 &  pp_s3q02_c==8

replace pp_s3q05_a= pp_s3q02_a * 63.56979   if pp_s3q05_a==. & saq02==1 & pp_s3q02_c==8
replace pp_s3q05_a= pp_s3q02_a* 98.5302 if pp_s3q05_a==. & saq02==2 & pp_s3q02_c==8
replace pp_s3q05_a= pp_s3q02_a* 27.44878 if pp_s3q05_a==. & saq02==3 & pp_s3q02_c==8
replace pp_s3q05_a= pp_s3q02_a* 72.26017 if pp_s3q05_a==. & saq02==4 & pp_s3q02_c==8
replace pp_s3q05_a= pp_s3q02_a*  32.11985 if pp_s3q05_a==. & saq02==5 & pp_s3q02_c==8
replace pp_s3q05_a= pp_s3q02_a*  48.7918 if pp_s3q05_a==. & saq02==6 & pp_s3q02_c==8
replace pp_s3q05_a= pp_s3q02_a*  55.78783  if pp_s3q05_a==. & saq02==7 & pp_s3q02_c==8
replace pp_s3q05_a= pp_s3q02_a*  48.7918 if pp_s3q05_a==. & saq02==8 & pp_s3q02_c==8
replace pp_s3q05_a= pp_s3q02_a*  35.65744  if pp_s3q05_a==. & saq02==9 & pp_s3q02_c==8
replace pp_s3q05_a= pp_s3q02_a* 35.65744  if pp_s3q05_a==. & saq02==10 & pp_s3q02_c==8
replace pp_s3q05_a= pp_s3q02_a* 35.65744   if pp_s3q05_a==. & saq02==11 & pp_s3q02_c==8
replace pp_s3q05_a= pp_s3q02_a* 45.858 if pp_s3q05_a==. & saq02==12 & pp_s3q02_c==8
replace pp_s3q05_a= pp_s3q02_a*  35.05879  if pp_s3q05_a==. & saq02==13 & pp_s3q02_c==8
replace pp_s3q05_a= pp_s3q02_a* 35.05879  if pp_s3q05_a==. & saq02==14 & pp_s3q02_c==8
replace pp_s3q05_a= pp_s3q02_a* 35.05879   if pp_s3q05_a==. & saq02==15 & pp_s3q02_c==8
replace pp_s3q05_a= pp_s3q02_a* 35.05879   if pp_s3q05_a==. & saq02==16 & pp_s3q02_c==8
replace pp_s3q05_a= pp_s3q02_a* 35.05879  if pp_s3q05_a==. & saq02==17 & pp_s3q02_c==8
replace pp_s3q05_a= pp_s3q02_a*  27.86082 if pp_s3q05_a==. & saq02==18 & pp_s3q02_c==8
replace pp_s3q05_a= pp_s3q02_a* 27.86082 if pp_s3q05_a==. & saq02==19 & pp_s3q02_c==8
replace pp_s3q05_a= pp_s3q02_a* 27.86082 if pp_s3q05_a==. & saq02==20 & pp_s3q02_c==8
replace pp_s3q05_a= pp_s3q02_a*  27.86082  if pp_s3q05_a==. & saq02==21 & pp_s3q02_c==8


*** ermija

bys saq02:sum pp_s3q05_a if pp_s3q02_a==1 &  pp_s3q02_c==10

replace pp_s3q05_a= pp_s3q02_a * 15.91462    if pp_s3q05_a==. & saq02==1 & pp_s3q02_c==10
replace pp_s3q05_a= pp_s3q02_a* 15.91462  if pp_s3q05_a==. & saq02==2 & pp_s3q02_c==10
replace pp_s3q05_a= pp_s3q02_a* 15.91462  if pp_s3q05_a==. & saq02==3 & pp_s3q02_c==10
replace pp_s3q05_a= pp_s3q02_a* 15.91462  if pp_s3q05_a==. & saq02==4 & pp_s3q02_c==10
replace pp_s3q05_a= pp_s3q02_a*  15.91462  if pp_s3q05_a==. & saq02==5 & pp_s3q02_c==10
replace pp_s3q05_a= pp_s3q02_a*  15.91462  if pp_s3q05_a==. & saq02==6 & pp_s3q02_c==10
replace pp_s3q05_a= pp_s3q02_a*  15.91462   if pp_s3q05_a==. & saq02==7 & pp_s3q02_c==10
replace pp_s3q05_a= pp_s3q02_a*  15.91462  if pp_s3q05_a==. & saq02==8 & pp_s3q02_c==10
replace pp_s3q05_a= pp_s3q02_a*  15.91462   if pp_s3q05_a==. & saq02==9 & pp_s3q02_c==10
replace pp_s3q05_a= pp_s3q02_a* 15.91462   if pp_s3q05_a==. & saq02==10 & pp_s3q02_c==10
replace pp_s3q05_a= pp_s3q02_a* 15.91462    if pp_s3q05_a==. & saq02==11 & pp_s3q02_c==10
replace pp_s3q05_a= pp_s3q02_a* 15.91462 if pp_s3q05_a==. & saq02==12 & pp_s3q02_c==10
replace pp_s3q05_a= pp_s3q02_a*  15.91462   if pp_s3q05_a==. & saq02==13 & pp_s3q02_c==10
replace pp_s3q05_a= pp_s3q02_a* 15.91462   if pp_s3q05_a==. & saq02==14 & pp_s3q02_c==10
replace pp_s3q05_a= pp_s3q02_a* 15.91462    if pp_s3q05_a==. & saq02==15 & pp_s3q02_c==10
replace pp_s3q05_a= pp_s3q02_a* 15.91462    if pp_s3q05_a==. & saq02==16 & pp_s3q02_c==10
replace pp_s3q05_a= pp_s3q02_a* 15.91462   if pp_s3q05_a==. & saq02==17 & pp_s3q02_c==10
replace pp_s3q05_a= pp_s3q02_a*  15.91462  if pp_s3q05_a==. & saq02==18 & pp_s3q02_c==10
replace pp_s3q05_a= pp_s3q02_a* 15.91462  if pp_s3q05_a==. & saq02==19 & pp_s3q02_c==10
replace pp_s3q05_a= pp_s3q02_a* 15.91462  if pp_s3q05_a==. & saq02==20 & pp_s3q02_c==10
replace pp_s3q05_a= pp_s3q02_a*  15.91462   if pp_s3q05_a==. & saq02==21 & pp_s3q02_c==10

**boy
bys saq02:sum pp_s3q05_a if pp_s3q02_a==1 &  pp_s3q02_c==4

replace pp_s3q05_a= pp_s3q02_a * 149.0605     if pp_s3q05_a==. & saq02==1 &pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 149.0605   if pp_s3q05_a==. & saq02==2 &pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 149.0605   if pp_s3q05_a==. & saq02==3 &pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 149.0605   if pp_s3q05_a==. & saq02==4 &pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a*  149.0605   if pp_s3q05_a==. & saq02==5 &pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a*  149.0605   if pp_s3q05_a==. & saq02==6 &pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a*  149.0605    if pp_s3q05_a==. & saq02==7 &pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a*  149.0605   if pp_s3q05_a==. & saq02==8 &pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a*  149.0605    if pp_s3q05_a==. & saq02==9 &pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 149.0605    if pp_s3q05_a==. & saq02==10 &pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 149.0605     if pp_s3q05_a==. & saq02==11 &pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 149.0605  if pp_s3q05_a==. & saq02==12 &pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 149.0605   if pp_s3q05_a==. & saq02==13 &pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 149.0605    if pp_s3q05_a==. & saq02==14 &pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 149.0605     if pp_s3q05_a==. & saq02==15 &pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 149.0605     if pp_s3q05_a==. & saq02==16 &pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 149.0605    if pp_s3q05_a==. & saq02==17 &pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a*  149.0605   if pp_s3q05_a==. & saq02==18 &pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 149.0605   if pp_s3q05_a==. & saq02==19 &pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 149.0605   if pp_s3q05_a==. & saq02==20 &pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a*  149.0605    if pp_s3q05_a==. & saq02==21 & pp_s3q02_c==4

replace pp_s3q05_a= pp_s3q02_a *1688.38 if pp_s3q05_a==0 & saq02==1 & pp_s3q02_c==3


replace pp_s3q05_a= pp_s3q02_a* 1706.456 if pp_s3q05_a==0 & saq02==2 & pp_s3q02_c==3


replace pp_s3q05_a= pp_s3q02_a* 1921.442 if pp_s3q05_a==0 & saq02==3 & pp_s3q02_c==3


replace pp_s3q05_a= pp_s3q02_a* 1741.507 if pp_s3q05_a==0 & saq02==4 & pp_s3q02_c==3


replace pp_s3q05_a= pp_s3q02_a* 2401.539 if pp_s3q05_a==0 & saq02==5 & pp_s3q02_c==3

replace pp_s3q05_a= pp_s3q02_a* 1932.907 if pp_s3q05_a==0 & saq02==6 & pp_s3q02_c==3

replace pp_s3q05_a= pp_s3q02_a* 1522.36 if pp_s3q05_a==0 & saq02==7 & pp_s3q02_c==3

replace pp_s3q05_a= pp_s3q02_a* 1526.937 if pp_s3q05_a==0 & saq02==8 & pp_s3q02_c==3

replace pp_s3q05_a= pp_s3q02_a* 1531.131 if pp_s3q05_a==0 & saq02==9 & pp_s3q02_c==3

replace pp_s3q05_a= pp_s3q02_a* 1270.36 if pp_s3q05_a==0 & saq02==10 & pp_s3q02_c==3

replace pp_s3q05_a= pp_s3q02_a* 1088.34 if pp_s3q05_a==0 & saq02==11 & pp_s3q02_c==3

replace pp_s3q05_a= pp_s3q02_a* 1390.116 if pp_s3q05_a==0 & saq02==12 & pp_s3q02_c==3

replace pp_s3q05_a= pp_s3q02_a* 1218.122 if pp_s3q05_a==0 & saq02==13 & pp_s3q02_c==3

replace pp_s3q05_a= pp_s3q02_a* 1390.09 if pp_s3q05_a==0 & saq02==14 & pp_s3q02_c==3

replace pp_s3q05_a= pp_s3q02_a* 1964.15 if pp_s3q05_a==0 & saq02==15 & pp_s3q02_c==3

replace pp_s3q05_a= pp_s3q02_a* 1460.438 if pp_s3q05_a==0 & saq02==16 & pp_s3q02_c==3

replace pp_s3q05_a= pp_s3q02_a* 2107.161 if pp_s3q05_a==0 & saq02==17 & pp_s3q02_c==3

replace pp_s3q05_a= pp_s3q02_a* 1038.891 if pp_s3q05_a==0 & saq02==18 & pp_s3q02_c==3

replace pp_s3q05_a= pp_s3q02_a*  966.5817 if pp_s3q05_a==0 & saq02==19 & pp_s3q02_c==3

replace pp_s3q05_a= pp_s3q02_a*  2138.269 if pp_s3q05_a==0 & saq02==20 & pp_s3q02_c==3
replace pp_s3q05_a= pp_s3q02_a*  2147.194  if pp_s3q05_a==0 & saq02==21 & pp_s3q02_c==3

**tilem
replace pp_s3q05_a= pp_s3q02_a * 184.4619  if pp_s3q05_a==0 & saq02==1 & pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 218.8295 if pp_s3q05_a==0 & saq02==2 & pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 160.1442 if pp_s3q05_a==0 & saq02==3 & pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 72.26017 if pp_s3q05_a==0 & saq02==4 & pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a*  177.6958 if pp_s3q05_a==0 & saq02==5 & pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a*  84.06111 if pp_s3q05_a==0 & saq02==6 & pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a*  166.485 if pp_s3q05_a==0 & saq02==7 & pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 590.7878 if pp_s3q05_a==0 & saq02==8 & pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 232.0731 if pp_s3q05_a==0 & saq02==9 & pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 241.6655 if pp_s3q05_a==0 & saq02==10 & pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 114.1061  if pp_s3q05_a==0 & saq02==11 & pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 252.4734 if pp_s3q05_a==0 & saq02==12 & pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a*  198.0058 if pp_s3q05_a==0 & saq02==13 & pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 189.3883 if pp_s3q05_a==0 & saq02==14 & pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 185.883  if pp_s3q05_a==0 & saq02==15 & pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 114.0615  if pp_s3q05_a==0 & saq02==16 & pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 79.29238 if pp_s3q05_a==0 & saq02==17 & pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 87.36167 if pp_s3q05_a==0 & saq02==18 & pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a*  149.0605 if pp_s3q05_a==0 & saq02==19 & pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a*  277.1222 if pp_s3q05_a==0 & saq02==20 & pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a*  227.6406  if pp_s3q05_a==0 & saq02==21 & pp_s3q02_c==4

** medieb

replace pp_s3q05_a= pp_s3q02_a * 63.56979   if pp_s3q05_a==0 & saq02==1 & pp_s3q02_c==8
replace pp_s3q05_a= pp_s3q02_a* 98.5302 if pp_s3q05_a==0 & saq02==2 & pp_s3q02_c==8
replace pp_s3q05_a= pp_s3q02_a* 27.44878 if pp_s3q05_a==0 & saq02==3 & pp_s3q02_c==8
replace pp_s3q05_a= pp_s3q02_a* 72.26017 if pp_s3q05_a==0 & saq02==4 & pp_s3q02_c==8
replace pp_s3q05_a= pp_s3q02_a*  32.11985 if pp_s3q05_a==0 & saq02==5 & pp_s3q02_c==8
replace pp_s3q05_a= pp_s3q02_a*  48.7918 if pp_s3q05_a==0 & saq02==6 & pp_s3q02_c==8
replace pp_s3q05_a= pp_s3q02_a*  55.78783  if pp_s3q05_a==0 & saq02==7 & pp_s3q02_c==8
replace pp_s3q05_a= pp_s3q02_a*  48.7918 if pp_s3q05_a==0 & saq02==8 & pp_s3q02_c==8
replace pp_s3q05_a= pp_s3q02_a*  35.65744  if pp_s3q05_a==0 & saq02==9 & pp_s3q02_c==8
replace pp_s3q05_a= pp_s3q02_a* 35.65744  if pp_s3q05_a==0 & saq02==10 & pp_s3q02_c==8
replace pp_s3q05_a= pp_s3q02_a* 35.65744   if pp_s3q05_a==0 & saq02==11 & pp_s3q02_c==8
replace pp_s3q05_a= pp_s3q02_a* 45.858 if pp_s3q05_a==0 & saq02==12 & pp_s3q02_c==8
replace pp_s3q05_a= pp_s3q02_a*  35.05879  if pp_s3q05_a==0 & saq02==13 & pp_s3q02_c==8
replace pp_s3q05_a= pp_s3q02_a* 35.05879  if pp_s3q05_a==0 & saq02==14 & pp_s3q02_c==8
replace pp_s3q05_a= pp_s3q02_a* 35.05879   if pp_s3q05_a==0 & saq02==15 & pp_s3q02_c==8
replace pp_s3q05_a= pp_s3q02_a* 35.05879   if pp_s3q05_a==0 & saq02==16 & pp_s3q02_c==8
replace pp_s3q05_a= pp_s3q02_a* 35.05879  if pp_s3q05_a==0 & saq02==17 & pp_s3q02_c==8
replace pp_s3q05_a= pp_s3q02_a*  27.86082 if pp_s3q05_a==0 & saq02==18 & pp_s3q02_c==8
replace pp_s3q05_a= pp_s3q02_a* 27.86082 if pp_s3q05_a==0 & saq02==19 & pp_s3q02_c==8
replace pp_s3q05_a= pp_s3q02_a* 27.86082 if pp_s3q05_a==0 & saq02==20 & pp_s3q02_c==8
replace pp_s3q05_a= pp_s3q02_a*  27.86082  if pp_s3q05_a==0 & saq02==21 & pp_s3q02_c==8


*** ermija


replace pp_s3q05_a= pp_s3q02_a * 15.91462    if pp_s3q05_a==0 & saq02==1 & pp_s3q02_c==10
replace pp_s3q05_a= pp_s3q02_a* 15.91462  if pp_s3q05_a==0 & saq02==2 & pp_s3q02_c==10
replace pp_s3q05_a= pp_s3q02_a* 15.91462  if pp_s3q05_a==0 & saq02==3 & pp_s3q02_c==10
replace pp_s3q05_a= pp_s3q02_a* 15.91462  if pp_s3q05_a==0 & saq02==4 & pp_s3q02_c==10
replace pp_s3q05_a= pp_s3q02_a*  15.91462  if pp_s3q05_a==0 & saq02==5 & pp_s3q02_c==10
replace pp_s3q05_a= pp_s3q02_a*  15.91462  if pp_s3q05_a==0 & saq02==6 & pp_s3q02_c==10
replace pp_s3q05_a= pp_s3q02_a*  15.91462   if pp_s3q05_a==0 & saq02==7 & pp_s3q02_c==10
replace pp_s3q05_a= pp_s3q02_a*  15.91462  if pp_s3q05_a==0 & saq02==8 & pp_s3q02_c==10
replace pp_s3q05_a= pp_s3q02_a*  15.91462   if pp_s3q05_a==0 & saq02==9 & pp_s3q02_c==10
replace pp_s3q05_a= pp_s3q02_a* 15.91462   if pp_s3q05_a==0 & saq02==10 & pp_s3q02_c==10
replace pp_s3q05_a= pp_s3q02_a* 15.91462    if pp_s3q05_a==0 & saq02==11 & pp_s3q02_c==10
replace pp_s3q05_a= pp_s3q02_a* 15.91462 if pp_s3q05_a==0 & saq02==12 & pp_s3q02_c==10
replace pp_s3q05_a= pp_s3q02_a*  15.91462   if pp_s3q05_a==0 & saq02==13 & pp_s3q02_c==10
replace pp_s3q05_a= pp_s3q02_a* 15.91462   if pp_s3q05_a==0 & saq02==14 & pp_s3q02_c==10
replace pp_s3q05_a= pp_s3q02_a* 15.91462    if pp_s3q05_a==0 & saq02==15 & pp_s3q02_c==10
replace pp_s3q05_a= pp_s3q02_a* 15.91462    if pp_s3q05_a==0 & saq02==16 & pp_s3q02_c==10
replace pp_s3q05_a= pp_s3q02_a* 15.91462   if pp_s3q05_a==0 & saq02==17 & pp_s3q02_c==10
replace pp_s3q05_a= pp_s3q02_a*  15.91462  if pp_s3q05_a==0 & saq02==18 & pp_s3q02_c==10
replace pp_s3q05_a= pp_s3q02_a* 15.91462  if pp_s3q05_a==0 & saq02==19 & pp_s3q02_c==10
replace pp_s3q05_a= pp_s3q02_a* 15.91462  if pp_s3q05_a==0 & saq02==20 & pp_s3q02_c==10
replace pp_s3q05_a= pp_s3q02_a*  15.91462   if pp_s3q05_a==0 & saq02==21 & pp_s3q02_c==10

**boy

replace pp_s3q05_a= pp_s3q02_a * 149.0605     if pp_s3q05_a==0 & saq02==1 &pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 149.0605   if pp_s3q05_a==0 & saq02==2 &pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 149.0605   if pp_s3q05_a==0 & saq02==3 &pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 149.0605   if pp_s3q05_a==0 & saq02==4 &pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a*  149.0605   if pp_s3q05_a==0 & saq02==5 &pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a*  149.0605   if pp_s3q05_a==0 & saq02==6 &pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a*  149.0605    if pp_s3q05_a==0 & saq02==7 &pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a*  149.0605   if pp_s3q05_a==0 & saq02==8 &pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a*  149.0605    if pp_s3q05_a==0 & saq02==9 &pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 149.0605    if pp_s3q05_a==0 & saq02==10 &pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 149.0605     if pp_s3q05_a==0 & saq02==11 &pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 149.0605  if pp_s3q05_a==0 & saq02==12 &pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 149.0605   if pp_s3q05_a==0 & saq02==13 &pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 149.0605    if pp_s3q05_a==0 & saq02==14 &pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 149.0605     if pp_s3q05_a==0 & saq02==15 &pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 149.0605     if pp_s3q05_a==0 & saq02==16 &pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 149.0605    if pp_s3q05_a==0 & saq02==17 &pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a*  149.0605   if pp_s3q05_a==0 & saq02==18 &pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 149.0605   if pp_s3q05_a==0 & saq02==19 &pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a* 149.0605   if pp_s3q05_a==0 & saq02==20 &pp_s3q02_c==4
replace pp_s3q05_a= pp_s3q02_a*  149.0605    if pp_s3q05_a==0 & saq02==21 & pp_s3q02_c==4


gen parcesizeHA= pp_s3q05_a/10000
replace parcesizeHA= pp_s3q02_a if parcesizeHA==. & pp_s3q02_c==1
replace parcesizeHA= pp_s3q02_a/10000 if parcesizeHA==. & pp_s3q02_c==2
replace parcesizeHA= pp_s3q02_a if parcesizeHA==0 & pp_s3q02_c==1
replace parcesizeHA= pp_s3q02_a/10000 if parcesizeHA==0 & pp_s3q02_c==2

replace parcesizeHA= pp_s3q02_a if parcesizeHA==. & pp_s3q02_c==1
replace parcesizeHA= pp_s3q02_a/10000 if parcesizeHA==. & pp_s3q02_c==2

replace parcesizeHA= pp_s3q02_a if parcesizeHA==0 & pp_s3q02_c==1
replace parcesizeHA= pp_s3q02_a/10000 if parcesizeHA==0 & pp_s3q02_c==2

replace parcesizeHA= pp_s3q02_a/10000 if parcesizeHA==0
replace parcesizeHA= pp_s3q02_a/10000 if parcesizeHA==.

replace parcesizeHA= pp_s3q02_a/10000 if parcesizeHA==0 & pp_s3q02_c==2

order pp_s3q03c pp_s3q11 pp_s3q12 pp_s3q14 pp_s3q15 pp_s3q18 pp_s3q20a_1 pp_s3q20a pp_s3q21 pp_s3q23 pp_s3q25 ,after ( pp_s3q35 )
fre pp_s3q09
fre pp_s3q35
fre pp_s3q03c
for var pp_s3q03c- pp_s3q37: recode X (2=0)

lab define Yes_no 1"Yes" 0 "No",replace
for var pp_s3q03c- pp_s3q37: lab values X Yes_no


***field prepa


gen fild_prp =1 if pp_s3q35<=6
replace fild_prp=0 if pp_s3q35==7
replace fild_prp=0 if pp_s3q35==8

 
tab pp_s3q09, gen ( pp_s3q09 )

gen fied_prpa = pp_s3q35
replace fied_prpa=. if fied_prpa==7
replace fied_prpa=. if fied_prpa==8

recode fied_prpa (2=1)(4=3)


lab define fied_prpa 1 "Tractor" 3 "LIVETSOCK" 5 " DIGGING BY HAND" 6 "other",replace

lab values fied_prpa fied_prpa

tab fied_prpa , gen ( fied_prpa )

order pp_s3q03c pp_s3q11 pp_s3q12 pp_s3q14 pp_s3q21 pp_s3q37,after ( fied_prpa4 )


**ferilizer

gen inorgfer=1 if pp_s3q15==1 | pp_s3q18==1 | pp_s3q20a_1==1| pp_s3q20a==1
replace inorgfer =0 if pp_s3q15==0 & pp_s3q18==0 & pp_s3q20a_1==0 & pp_s3q20a==0
lab define inorgfer  1"Yes" 0 "No",replace
lab values inorgfer inorgfer

label variable pp_s3q14 "Is fertilizer used-organic or inorganic?"
replace inorgfer=0 if pp_s3q14==0
replace pp_s3q21 =0 if pp_s3q14==0

gen fert_orginor_both =1 if pp_s3q21==1 & inorgfer==1
replace fert_orginor_both=0 if inorgfer==0 & pp_s3q21==0
replace fert_orginor_both=0 if inorgfer==1 & pp_s3q21==0
replace fert_orginor_both=0 if inorgfer==0 & pp_s3q21==1
sum fert_orginor_both
order fert_orginor_both,after ( pp_s3q14 )
label variable fert_orginor_both "Is fertilizer used- both organic and inorganic?"

order pp_s3q14 fert_orginor_both inorgfer,after (pp_s3q37)

gen cult = 1 if pp_s3q03==1
replace  cult=0 if pp_s3q03!=1 & pp_s3q03!=.
*edit pp_s3q03c cult pp_s3q03
sort pp_s3q03c cult pp_s3q03
bys pp_s3q03c : fre pp_s3q03
bys cult:fre pp_s3q03c
order cult,after ( fied_prpa4 )

replace pp_s3q03c=. if cult==0
replace pp_s3q11=. if cult==0
replace pp_s3q12=. if cult==0
replace pp_s3q14=. if cult==0
replace pp_s3q21=. if pp_s3q14==.
replace pp_s3q37=0 if cult==1 & pp_s3q37==.

clonevar parcesizeHA_wiz=parcesizeHA
winsor2 parcesizeHA_wiz , replace cuts(1 99)

order parcesizeHA_wiz, after (parcesizeHA)
label variable parcesizeHA "land size in ha"
label variable parcesizeHA_wiz "land size in ha"

save "$temp${slash}sect3_pp_w3_cleaned", replace


use "$temp${slash}sect3_pp_w3_cleaned", replace

collapse (sum) parcesizeHA parcesizeHA_wiz (mean) fied_prpa1 fied_prpa2 fied_prpa3 fied_prpa4 (max)   pp_s3q11 pp_s3q12 pp_s3q14 fert_orginor_both inorgfer , by ( household_id2)

label variable parcesizeHA " average field size in ha"

label variable fied_prpa1 "% of plot prepared by Tractor"
label variable fied_prpa3 "% of plot prepared by Digging hand"
label variable fied_prpa2 "% of plot prepared by Animal"
label variable fied_prpa4 "% of plot prepared by other methods"

label variable pp_s3q11 "Extension Program during the current agricultural season?"
label variable pp_s3q12 " irrigated during the current agricultural season?"
label variable pp_s3q14 "Is fertilizer used on both organiz and inorganic"

label variable pp_s3q14 "Is fertilizer used organiz or inorganic"
label variable inorgfer "inorganic  fertilizer only in this  [Field]"
label variable fert_orginor_both "Is fertilizer used both organic and inorganic in this  [Field]?"

label variable parcesizeHA "land size in ha"
label variable parcesizeHA_wiz "land size in ha"

save "$temp${slash}sect3_pp_w3_hh", replace
}

*Merging PP module-section2, section3,section4 HH_LEVEL_DATA_2015

{/*Merging PP*/

use "$temp${slash}HH_LEVEL_DATA.dta", clear 

merge 1:1 household_id2 using "$temp${slash}sect3_pp_w3_hh.dta"
drop if _merge==2
drop _m
merge 1:1 household_id2 using "$temp${slash}sect2_pp_w3_hh.dta"
drop if _merge==2
drop _m

gen INFORMAION_PLOT_LEVEL =.
order INFORMAION_PLOT_LEVEL, after ( hh_s12q02_wiz )

save "$temp${slash}HH_PP_LEVEL_DATA.dta", replace

}

*===============================================================================
** ** Covariates from ESS3-COMMUNITY Modules 
*===============================================================================

{/* Mereging community modules -S4,S6&S9*/

use "${raw3}${slash}sect04_com_w3.dta", clear 
merge 1:1 ea_id2 using "${raw3}${slash}sect06_com_w3"
drop _m
merge 1:1 ea_id2 using "${raw3}${slash}sect09_com_w3"
drop _m
order cs9q01 cs6q01 cs6q10 cs4q02_1 cs4q08 cs4q09 cs4q11 cs4q12_b1 cs4q14 cs4q15,after ( cs9q14 )
save "$temp${slash}community_S4_S6_S9.dta", replace
use "$temp${slash}community_S4_S6_S9.dta",clear
clonevar cs4q02_1_wiz=cs4q02_1
clonevar cs4q09_wiz=cs4q09
clonevar cs4q12_b1_wiz=cs4q12_b1
clonevar cs4q15_wiz=cs4q15

for var cs4q02_1_wiz- cs4q15_wiz: winsor2 X,replace cuts(1 99)

keep ea_id2 cs9q01 cs6q01 cs6q10 cs4q02_1 cs4q08 cs4q09 cs4q11 cs4q12_b1 cs4q14 cs4q15 cs4q02_1_wiz cs4q09_wiz cs4q12_b1_wiz cs4q15_wiz

save "$temp${slash}community_S4_S6_S9_for_merghh.dta", replace


*** Merge with  HH_PP_LEVEL_DATA.

use "$temp${slash}HH_PP_LEVEL_DATA.dta", clear
merge m:1 ea_id2 using "$temp${slash}community_S4_S6_S9_for_merghh.dta"
drop _merge
gen COMMUNITY=.
order COMMUNITY,after ( pp_s2q146 )

order cs4q09_wiz,after ( cs4q09 )
order cs4q02_1_wiz,after ( cs4q02_1 )
order cs4q12_b1_wiz,after ( cs4q12_b1 )
save "$temp${slash}HH_PP_COM_LEVEL_DATA_2018.dta", replace

*===============================================================================
** ** Covariates from ESS3-CONSUMTION_AGG
*===============================================================================

use "${raw3}${slash}cons_agg_w3.dta", clear

keep household_id2 no_conv no_cons food_cons_ann nonfood_cons_ann educ_cons_ann total_cons_ann price_index_hce nom_totcons_aeq cons_quint

clonevar food_cons_ann_wiz=food_cons_ann
clonevar nonfood_cons_ann_wiz=nonfood_cons_ann
clonevar educ_cons_ann_wiz=educ_cons_ann
clonevar total_cons_ann_wiz=total_cons_ann

for var food_cons_ann_wiz- total_cons_ann_wiz:winsor2 X,replace cuts(1 99)

order food_cons_ann_wiz,after ( food_cons_ann )
order nonfood_cons_ann_wiz,after ( nonfood_cons_ann )
order educ_cons_ann_wiz,after ( educ_cons_ann )
order total_cons_ann_wiz,after ( total_cons_ann )

save "$temp${slash}cons_agg_w3_formerg.dta", replace

*** Mereging with HH_PP_COM_LEVEL_DATA_2018

use "$temp${slash}HH_PP_COM_LEVEL_DATA_2018.dta", clear

merge 1:1 household_id2 using "$temp${slash}cons_agg_w3_formerg.dta"
drop _m

gen CONSUMPTION_AGG =.
order CONSUMPTION_AGG,after ( cs4q15_wiz )
save "$temp${slash}HH_PP_COM_consm_LEVEL_DATA_2018.dta", replace

*===============================================================================
** ** Covariates from ESS3-GEOSPATIAL_VARIABLES
*===============================================================================

use "${raw3}${slash}ETH_HouseholdGeovars_y3.dta", clear                                 

clonevar dist_road_wiz=dist_road
clonevar dist_popcenter_wiz=dist_popcenter
clonevar dist_market_wiz=dist_market
clonevar dist_borderpost_wiz=dist_borderpost
clonevar dist_admctr_wiz=dist_admctr
for var dist_road_wiz- dist_admctr_wiz: winsor2 X,replace cuts(1 99)

order dist_road_wiz,after ( dist_road)
order dist_popcenter_wiz,after ( dist_popcenter)
order dist_market_wiz,after ( dist_market)
order dist_borderpost_wiz,after ( dist_borderpost)
order dist_admctr_wiz,after ( dist_admctr )

save "$temp${slash}HouseholdGeovars_y3formerg.dta", replace

** merge with HH_PP_COM_consm_LEVEL_DATA_2018

use "$temp${slash}HH_PP_COM_consm_LEVEL_DATA_2018.dta", clear

merge 1:1 household_id2 using "$temp${slash}HouseholdGeovars_y3formerg.dta"

gen GEOSPATIAL_VARIABLES=.

order GEOSPATIAL_VARIABLES,after ( cons_quint )
drop _m

save "$temp${slash}HH_LEVEL_DATA_2015.dta", replace

}
