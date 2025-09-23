
clear all
clear matrix
capture log close
set more off

********************************************************************************
*                            Covariates - ESSW4-2018               
********************************************************************************
* Country: ETHIOPIA                                                            
* Created by: Solomon Alemu - S.Alemu@cgiar.org        
* Date:  MAY,2020                                                               
********************************************************************************


*===============================================================================
** Covariates from ESS4-HH modules 
*===============================================================================

** Demographics and Education-sect1& 2_hh_w4

{/*Demographics-sect1_hh_w4.dta*/

use "${raw4new}${slash}HH${slash}sect1_hh_w4", clear
gen age_head= s1q03a if s1q01==1
save "$temp${slash}sect1_hh_w4_demo", replace
use "$temp${slash}sect1_hh_w4_demo", clear
collapse (max) age_head , by ( household_id )
label variable age_head "age_head"
clonevar age_head_wiz= age_head
winsor2 age_head_wiz , replace cuts(1 99)
order age_head_wiz,after ( age_head)
save "$temp${slash}sect1_hh_w4_demohh", replace

}


**Non-farm enterprise and Other income- section 12 & 13

{ /*Non-farm enterprise-sect12a_hh_w4*/

use "${raw4new}${slash}HH${slash}sect13_hh_w4", clear
sort s13q02
replace s13q02 = . if s13q02 ==2000000
winsor2 s13q02 , replace cuts(1 99)
collapse (sum) s13q02, by ( household_id)
label variable s13q02 "off- farm income in the  last 12 months? (BIRR)"
winsor2 s13q02 , replace cuts(1 99)
save "$temp${slash}sect13_hh_w4_offincome", replace

}

**Section 11 asset

{/*credit-sect15a_hh_w4*/

**Asset index-sect11_hh_w4

use "${raw4new}${slash}HH${slash}sect11_hh_w4", clear 

rename s11q00 HHown_item

label define Yes_no 1 "Yes" 0 "No", replace

recode HHown_item (2=0)

lab values HHown_item  Yes_no
keep household_id asset_cd HHown_item
replace HHown_item=0 if HHown_item==.
reshape wide HHown_item, i( household_id) j( asset_cd)
save "$temp${slash}sect11_hh_w4_asset", replace

*** Houssing-sect10a_hh_w4

use "${raw4new}${slash}HH${slash}sect10a_hh_w4", clear  

order s10aq08 s10aq09 s10aq10 s10aq12  s10aq27 s10aq21 s10aq20 s10aq06 s10aq07,after ( s10aq38 )
order s10aq34 s10aq38,after ( s10aq07 )
for var s10aq08- s10aq38:replace X=. if X==.a
for var s10aq08 - s10aq38 : tabulate X , gen(X )
save "$temp${slash}sect10a_hh_w4_houseing", replace

*merge 1:1 household_id using "C:\Users\SAlemu\Desktop\ESS_4_2018_May\ESS4_Analysis\sect11_hh_w4_asset.dta" // sihs note below
	* this line left commented out by author 
	* unclear to me if I should try to use this merge or leave it commented
merge 1:1 household_id using "$temp${slash}sect11_hh_w4_asset.dta"
*edit if _merge==1
keep if _merge==3
drop  s10aq271 - s10aq2716
save "$temp${slash}asset_houseing", replace

drop s10aq081-s10aq3813
winsor2 s10aq06 , replace cuts(1 99)
drop _merge
order s10aq06,after (HHown_item35)
pca HHown_item1- s10aq06 , comp(1)
predict asset
sum asset
xtile asset_index=asset, nq(5)
* table asset_index, c(mean asset) // SIHS commented out this line, incompatible with new Stata versions
table asset_index, statistic(mean asset) // SIHS added this line to replace line above
keep household_id asset asset_index
compress
save "$temp${slash}asse_index", replace

***productive-asset

use "${raw4new}${slash}HH${slash}sect11_hh_w4", clear 

rename s11q00 HHown_item

label define Yes_no 1 "Yes" 0 "No", replace

recode HHown_item (2=0)

lab values HHown_item  Yes_no

keep if asset_cd>=29

keep household_id asset_cd HHown_item
replace HHown_item=0 if HHown_item==.
reshape wide HHown_item, i( household_id) j( asset_cd)
pca HHown_item29- HHown_item35 , comp(1)
predict asset_prod
sum asset_prod
xtile prod_asset_index=asset, nq(5)
* table prod_asset_index, c(mean asset) // SIHS commented out this line, incompatible with new Stata versions
table prod_asset_index, statistic(mean asset) // SIHS added this line to replace line above
keep household_id asset_prod prod_asset_index
compress
save "$temp${slash}prod-asse_index", replace
}



*** merging
{/*merging all the hh level data*/

use "${raw4new}${slash}HH${slash}sect_cover_hh_w4", clear 

merge 1:1 household_id using "$temp${slash}sect1_hh_w4_demohh.dta"
drop _m

merge 1:1 household_id using "$temp${slash}asse_index.dta"
drop _m
merge 1:1 household_id using "$temp${slash}prod-asse_index.dta"
drop _m
merge 1:1 household_id using "$temp${slash}sect13_hh_w4_offincome.dta"
drop _m

gen HH_DEMO_EDUC_ASSET=.
order HH_DEMO_EDUC_ASSET,after ( saq21 )

save "$temp${slash}HH_LEVEL_DATA", replace
}

*===============================================================================
** ** Covariates from ESS4-PP Modules 
*===============================================================================

**PP module-section2 and section3

 {/*sect2_pp_w4*/
 
 *sect2_pp_w4


use "${raw4}${slash}PP${slash}sect2_pp_w4",clear

order s2q16,after ( s2q17 )
*order s2q03,after ( s2q16_os)
recode s2q16 (7=6)
recode s2q03 (2=0)
label define Yes_no 1 "Yes" 0 "No", replace
lab values s2q03  Yes_no
tabulate s2q17, gen ( s2q17 )
tabulate s2q16, gen ( s2q16)

save "$temp${slash}sect2_pp_w4_Cleaned", replace

use "$temp${slash}sect2_pp_w4_Cleaned", replace

collapse (mean) s2q171 s2q172 s2q173 s2q161 s2q162 s2q163 s2q164 s2q165 s2q166, by ( household_id )

label variable s2q171 "% of plot with good soil quality"
label variable s2q172 "% of plot with fair soil quality"
label variable s2q173 "% of plot with poor soil quality"
label variable s2q161 "% of plot with Leptosol  soil type"
label variable s2q162 "% of plot with Cambisol  soil type"
label variable s2q163 "% of plot with Vertisol soil type"
label variable s2q164 "% of plot with Luvisol soil type"
label variable s2q165 "% of plot with mixed soil type"
label variable s2q166 "% of plot with other soil type"
save "$temp${slash}sect2_pp_w4_hh", replace



*sect3_pp_w4



use "${raw4}${slash}PP${slash}sect3_pp_w4",clear

order saq15 s3q02a s3q02b s3q03 s3q03b s3q04 s3q05 s3q07 s3q08 s3q16 s3q17 s3q21 s3q22 s3q23 s3q24 s3q25 s3q42,after ( s3q41 )
gen Plot_level=.
order Plot_level,after ( s3q41 )

gen parcesizeHA = s3q08/10000
order parcesizeHA,after ( Plot_level )

replace parcesizeHA = s3q02a/10000 if s3q02b==2 & parcesizeHA==.

replace parcesizeHA = s3q02a if s3q02b==1 & parcesizeHA==.

replace parcesizeHA = s3q02a *0.25 if s3q02b==3 & parcesizeHA==.

replace parcesizeHA = s3q02a *0.25 if s3q02b==6 & parcesizeHA==.

sum s3q08 if s3q02b==4 & s3q02a==1 & s3q07==1
sum s3q08 if s3q02b==5 & s3q02a==1 & s3q07==1
sum s3q08 if s3q02b==7 & s3q02a==1 & s3q07==1
sum s3q08 if s3q02b==8 & s3q02a==1 & s3q07==1
sum s3q08 if s3q02b==10 & s3q02a==1 & s3q07==1
replace parcesizeHA = (s3q02a * 227.76)/10000 if s3q02b==4 & parcesizeHA==.
replace parcesizeHA = (s3q02a * 1339.289)/10000 if s3q02b==5 & parcesizeHA==.
replace parcesizeHA = (s3q02a * 204.4169)/10000 if s3q02b==7 & parcesizeHA==.
replace parcesizeHA = (s3q02a * 69.28191 )/10000 if s3q02b==8 & parcesizeHA==.
replace parcesizeHA = (s3q02a * 6176.3808 )/10000 if s3q02b==10 & parcesizeHA==.
replace parcesizeHA=. if parcesizeHA==0
winsor2 parcesizeHA , replace cuts(1 99)

label variable parcesizeHA "FieldsizeHA"

order s3q02a s3q02b s3q07 s3q08,after ( s3q41 )
order s3q12,after ( parcesizeHA )

tab s3q12, gen ( s3q12 )
order s3q121 s3q122 s3q123,after ( parcesizeHA )
order s3q12,after ( s3q08 )

order s3q35,after ( s3q12 )

gen fild_prp =1 if s3q35<=6
replace fild_prp=0 if s3q35==7
replace fild_prp=0 if s3q35==8
order s3q34,after ( s3q12 )
replace s3q35=0 if s3q35==8

gen fild_prpa = s3q35
order fild_prpa,after ( fild_prp )
lab values fild_prpa  s3q35
fre fild_prpa
replace fild_prpa=. if fild_prpa==7
replace fild_prpa=. if fild_prpa==8

*replace s3q35_os = subinstr(s3q35_os, " ", "", .)
replace s3q35_o = subinstr(s3q35_o, " ", "", .)								// (!) IMPORTANT CHANGE DOUBLE-CHECK

replace fild_prpa= 3 if s3q35_o == "BORROWEDOXEN"
replace fild_prpa= 3 if s3q35_o == "PARENTS/RELATIVESOXEN"
replace fild_prpa= 3 if s3q35_o == "RENTEDOXEN(HAYWILLBEGIVENTOTHEOWNER)"
replace fild_prpa= 3 if s3q35_o == "SHAREDOXEN"
replace fild_prpa= 3 if s3q35_o == "USINGLANDLORD'SOXEN"
replace fild_prpa= 3 if s3q35_o == "USINGOTHERLIVESTOCKS(HOURSE)"
replace fild_prpa= 5 if s3q35_o == "HANDTOOLS"

recode fild_prpa (2=1)(4=3)

replace fild_prpa=. if fild_prpa==0


tab fild_prpa, gen ( fild_prpa )
order fild_prpa1- fild_prpa4,after ( fild_prp )
order fild_prpa,after ( s3q35 )

label variable fild_prpa1 "fild_prpa==1. USING OWN/rented TRACTOR"
label variable fild_prpa2 "fild_prpa==3. USING OWNED/rented/borrowed LIVESTOCK"

order fild_prpa1- fild_prpa4,after ( fild_prp )
order fild_prpa,after ( s3q35 )

for var fild_prpa1- fild_prpa4: replace X=0 if fild_prp==0
sum fild_prp- fild_prpa4

order s3q16 s3q17,after ( s3q05 )
gen fert_orginor =1 if s3q21==1 | s3q22==1| s3q23==1 | s3q24==1| s3q25==1 |s3q26==1 |s3q27==1
replace fert_orginor =0 if s3q21==2 & s3q22==2 & s3q23==2 & s3q24==2 & s3q25==0 & s3q26==2 & s3q27==2

order s3q03,after ( fild_prpa4 )
order fert_orginor,after ( s3q03 )
order fert_orginor,after ( s3q17 )
order s3q25,after ( fert_orginor )

gen inorgfer =1 if s3q21==1 | s3q22==1| s3q23==1 | s3q24==1
replace inorgfer =0 if s3q21==2 & s3q22==2 & s3q23==2 & s3q24==2

label variable fert_orginor "Is fertilizer used - both org and inorganic"
label variable fert_orginor "Is fertilizer used - both org and inorganic?"
label variable inorgfer "Only inorganic fer"

label variable fert_orginor "Is fertilizer used-organic or inorganic?"

replace inorgfer=0 if fert_orginor==0
replace s3q25 =0 if fert_orginor==0

gen fert_orginor_both =1 if s3q25==1 & inorgfer==1
replace fert_orginor_both=0 if inorgfer==0 & s3q25==0
replace fert_orginor_both=0 if inorgfer==1 & s3q25==0
replace fert_orginor_both=0 if inorgfer==0 & s3q25==1
sum fert_orginor_both
order fert_orginor_both,after ( fert_orginor )
label variable fert_orginor_both "Is fertilizer used- both organic and inorganic?"


save "$temp${slash}sect3_pp_w4_cleaned", replace

use "$temp${slash}sect3_pp_w4_cleaned", replace

collapse (sum) parcesizeHA  (max) fild_prp (mean) fild_prpa1 fild_prpa2 fild_prpa3 fild_prpa4 (max) s3q16 s3q17 fert_orginor inorgfer, by ( household_id )

label variable parcesizeHA "parcesizeHA"

label variable fild_prp "Was [FIELD] prepared for planting? "

label variable fild_prpa1 "% of plot prepared by Tractor"
label variable fild_prpa2 "% of plot prepared by Animal"
label variable fild_prpa3 "% of plot prepared by Digging hand"
label variable fild_prpa4 "% of plot prepared by other methods"

label variable s3q16 "Is  [FIELD] under Extension Program during the current agricultural season?"
label variable s3q17 "Is [FIELD] irrigated during the current agricultural season?"
label variable fert_orginor "Is fertilizer used   both org and inorganic?"
label variable inorgfer "Only inorganic fert"


save "$temp${slash}sect3_pp_w4_hh", replace

}

*Merging PP module-section2, section3,section4 HH_LEVEL_DATA_2018

{/*Merging plot level data*/

use "$temp${slash}HH_LEVEL_DATA.dta", clear 

merge 1:1 household_id using "$temp${slash}sect3_pp_w4_hh.dta"
drop if _merge==2
drop _m
merge 1:1 household_id using "$temp${slash}sect2_pp_w4_hh.dta"
drop if _merge==2
drop _m
gen INFORMAION_PLOT_LEVEL =.
order INFORMAION_PLOT_LEVEL ,after ( s13q02 )
save "$temp${slash}HH_PP_LEVEL_DATA.dta", replace

}

*===============================================================================
** ** Covariates from ESS4-COMMUNITY Modules 
*===============================================================================

{/* Mereging community modules -S4,S6&S9*/



use "${raw4new}${slash}COMMUNITY${slash}sect04_com_w4.dta", clear

merge 1:1 ea_id using "${raw4new}${slash}COMMUNITY${slash}sect06_com_w4.dta"
drop _m
merge 1:1 ea_id using "${raw4new}${slash}COMMUNITY${slash}sect09_com_w4.dta"
drop _m
order cs9q01 cs6q01 cs6q10 cs4q02 cs4q08 cs4q09 cs4q11 cs4q12b cs4q14 cs4q15,after ( cs9q14 )
save "$temp${slash}community_S4_S6_S9.dta", replace

use "$temp${slash}community_S4_S6_S9.dta",clear

clonevar cs4q02_wiz=cs4q02
clonevar cs4q09_wiz=cs4q09
clonevar cs4q12b_wiz=cs4q12b
clonevar cs4q15_wiz=cs4q15
for var cs4q02_wiz- cs4q15_wiz: winsor2 X,replace cuts(1 99)
keep ea_id cs9q01 cs6q01 cs6q10 cs4q02 cs4q08 cs4q09 cs4q11 cs4q12b cs4q14 cs4q15 cs4q02_wiz cs4q09_wiz cs4q12b_wiz cs4q15_wiz

order cs4q02_wiz,after ( cs4q02)
order cs4q09_wiz,after ( cs4q09)
order cs4q12b_wiz,after ( cs4q12b)

for var cs9q01 cs6q01 cs6q10 cs4q08 cs4q11 cs4q14: recode X (2=0)
for var cs9q01 cs6q01 cs6q10 cs4q08 cs4q11 cs4q14: label define X 1 "Yes" 0 "No", replace
for var cs9q01 cs6q01 cs6q10 cs4q08 cs4q11 cs4q14: label values X X

save "$temp${slash}community_S4_S6_S9_for_merghh.dta", replace

*** Merge with  HH_PP_LEVEL_DATA.

use "$temp${slash}HH_PP_LEVEL_DATA.dta", clear
merge m:1 ea_id using "$temp${slash}community_S4_S6_S9_for_merghh.dta"
drop _merge
gen COMMUNITY=.
order COMMUNITY,after (s2q166)
save "$temp${slash}HH_PP_LEVEL_DATA_2018.dta", replace

}
