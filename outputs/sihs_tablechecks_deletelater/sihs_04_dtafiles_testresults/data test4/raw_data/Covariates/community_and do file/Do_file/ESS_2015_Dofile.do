


*** ESS_2015 data

set more off
global indir  "C:\Users\SAlemu\Desktop\Big work_ESS_DATA\ESS datasets\ESS3_2015-16\Data\Innovation_2015\covariates_2015"
global temp "C:\Users\SAlemu\Desktop\Big work_ESS_DATA\ESS datasets\ESS3_2015-16\Data\Innovation_2015\covariates_2015\analysis"

*** *===============================================================================

{/*sect1_hh_w3_demo.dta*/

use "$indir\sect1_hh_w3_demo", clear

gen sex_head= hh_s1q03 if hh_s1q02==1
gen age_head= hh_s1q04a if hh_s1q02==1
gen Marital_head= hh_s1q08 if hh_s1q02==1
gen mainoc_head= hh_s1q20 if hh_s1q02==1


label variable sex_head "sex_head"
 label define HH_S1Q03 1 "Male" 0 "Female", replace
label variable age_head "age_head"
label variable Marital_head "Marital_head"
recode sex_head (2=0)
label variable mainoc_head "mainoc_head"

label define HH_S1Q08 1 "Never Married" 2 "Married (monogamous)" 3 "Married (polygamous)" 4 "Divorced" 5 "Seperated" 6 "Widowed" 7"CO-HABITING ", replace

gen Marital_head2 = Marital_head
recode Marital_head2 (2=1)(3=1)(1=0)(5=0)(4=0)(6=0)

lab define Marital_head2 1"Married" 0 "Single",replace
lab values Marital_head2 Marital_head2

gen mainoc_head2 = .
replace mainoc_head2=1 if mainoc_head==1
replace mainoc_head2=0 if mainoc_head>1 & mainoc_head!=.
fre mainoc_head2
fre mainoc_head2
lab define  mainoc_head2 1 "Agriculture " 0 "Non-Agriculture", replace
lab values mainoc_head2 mainoc_head2

save "$temp\sect1_hh_w3_demo_mod", replace

collapse (max) sex_head age_head Marital_head2  mainoc_head2, by ( household_id2 )
label values sex_head HH_S1Q03
lab values Marital_head2 Marital_head2
lab values mainoc_head2 mainoc_head2


save "$temp\sect1_hh_w3_demo_athh_level", replace

** number of  hh
use "$indir\sect1_hh_w3_demo", clear

gen h_size=1
egen size = sum (h_size), by (household_id2)
collapse (mean) size, by (household_id2)
winsor2 size , replace cuts(1 99)
label variable size "hh size"


save "$temp\#hh_memeber", replace

*** Education-head
use "$indir\educ_demo_merged", clear 

gen educ_head= hh_s2q05 if hh_s1q02==1
gen educ_head_att= hh_s2q03 if hh_s1q02==1
recode educ_head_att (2=0)
fre educ_head
lab values educ_head HH_S2Q05
fre educ_head
collapse (min) educ_head educ_head_att, by ( household_id2 )

lab define educ_head_att 1 " Attended school" 0 "Not Attended school", replace
lab values educ_head_att educ_head_att

label variable educ_head "Head- the highest grade  completed "
label variable educ_head_att "Head ever attended school?"

gen educ_head_fr= 1 if educ_head < 93
replace educ_head_fr=0 if educ_head >=93 & educ_head !=.
lab define educ_head_att 1 " Yes" 0 "No", replace
lab values educ_head_fr educ_head_fr
fre educ_head_fr
lab define educ_head_fr 1 " formal" 0 "informal", replace
lab values educ_head_fr educ_head_fr
label variable educ_head_fr "Head- school formal or informal edcuation attended"
save "$temp\hh_edcation", replace

**** Activities- non farm 
use "$indir\sect11a_hh_w3_non farm", clear 

keep household_id2 hh_s11aq01
save "$temp\hh_nonfarmactvitiy", replace

*** Non-farm income

use "$indir\sect12_hh_w3 off farm income", clear 

winsor2 hh_s12q02 , replace cuts(1 99)
recode hh_s12q01 (2=0)
lab define hh_s12q01 1 "Yes" 0 "No", modify
recode hh_s12q01 (2=0)
lab values hh_s12q01 hh_s12q01
collapse (max) hh_s12q01 (sum) hh_s12q02, by ( household_id2 )
lab values hh_s12q01 hh_s12q01
label variable hh_s12q01 "During the last 12 months, received off farm income"
label variable hh_s12q02 "off- farm income in the  last 12 months? (BIRR)"
save "$temp\hh_offfarmincome", replace


*** credit access-

use "$indir\sect14a_hh_w3 credit", clear 
keep household_id2 hh_s14q01
recode hh_s14q01 (2=0)
label define HH_S14Q01 1 "Yes" 0 "No", replace
label variable hh_s14q01 "HH who receive credit from outside the HH  or from an institution for business o"
save "$temp\hh_credit_acc", replace

*** land size- gps and farmers eliciation



use "$indir\sect3_pp_w3_landszie", clear  



**  local land conversion

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
 
 
gen parcesizeHA= pp_s3q05_a/10000
replace parcesizeHA= pp_s3q02_a if parcesizeHA==. & pp_s3q02_c==1
replace parcesizeHA= pp_s3q02_a/10000 if parcesizeHA==. & pp_s3q02_c==2

replace parcesizeHA= pp_s3q02_a if parcesizeHA==0 & pp_s3q02_c==1
replace parcesizeHA= pp_s3q02_a/10000 if parcesizeHA==0 & pp_s3q02_c==2

collapse (sum) parcesizeHA, by ( household_id2 )
winsor2 parcesizeHA , replace cuts(1 99)
label variable parcesizeHA "land size in ha"
 save "$temp\land_size_ha_hh_level", replace
 
 
 ****** other agr practises- fert,weeding...
 
 use "$indir\sect3_pp_w3_landszie", clear  

recode pp_s3q14 (2=0)
edit pp_s3q14
label define PP_S3Q14 1 "Yes" 0 "No", replace
collapse (min) pp_s3q14, by ( household_id2 )
label values pp_s3q14 PP_S3Q14
label variable pp_s3q14 "Is fertilizer used on [FIELD]? (Organic or inorganic fetilizer) (chemical and na"
 save "$temp\fer_used_hh_level", replace
 
 
 ***her_pes
 use "$indir\sect4_pp_w3_her_pes", clear  
 
for var pp_s4q05 pp_s4q06 pp_s4q07: recode X (2=0)
for var pp_s4q05 pp_s4q06 pp_s4q07: lab define X 1 "Yes" 0 "No", modify
for var pp_s4q05 pp_s4q06 pp_s4q07: lab values X X

collapse (max) pp_s4q05 pp_s4q06 pp_s4q07, by ( household_id2 )
for var pp_s4q05 pp_s4q06 pp_s4q07: lab values X X
label variable pp_s4q05 "Did you use any pesticide to prevent damage of [Crop] on this field?"
label variable pp_s4q06 "Did you use any herbicide to prevent damage of [Crop] on this field?"
label variable pp_s4q07 "Did you use any fungicide to prevent damage of [Crop] on this [Field]?"
label variable pp_s4q04 "Was prevention measures taken to prevent damage of [Crop]?"


 save "$temp\her_pes_fung_hh_level", replace

 
 ***Soil_c*x
 
 use "$indir\sect2_pp_w3_soil_cxn", clear  
 
 
 
 collapse (min) pp_s2q14 pp_s2q15, by ( household_id2 )
label values pp_s2q14 PP_S2Q14
label values pp_s2q15 PP_S2Q15

label variable pp_s2q14 "What is the predominant soil type "
label variable pp_s2q15 "What is the soil quality "
save "$temp\soil_cxr_hh_level", replace


 
 *** Asset Indix*
use "$indir\sect10_hh_w3_asset.dta",clear
gen HHown_item=1 if hh_s10q01>0

replace HHown_item=0 if HHown_item==.
keep household_id2 hh_s10q00 HHown_item
reshape wide HHown_item, i( household_id2 ) j( hh_s10q00 )
save "$temp\asset_type", replace

*** houseing 

use "$indir\sec9_hh_w3_house type",clear
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
save "$temp\asset_houseing_household", replace


use "$temp\asset_household", replace
merge 1:1 household_id2 using "$temp\asset_type"
drop _m

drop drinkwat_sc_rain1- drinkwat_sc_dry13

merge 1:1 household_id2 using "C:\Users\SAlemu\Desktop\Big work_ESS_DATA\ESS datasets\ESS3_2015-16\Data\Innovation_2015\covariates_2015\sect_cover_hh_w3_idefn.dta"
pca wall1 - HHown_item35 own_house no_room , comp(1)
predict asset
sum asset
xtile asset_index=asset, nq(5)
table asset_index, c(mean asset)
keep household_id2 asset asset_index
compress
save "$temp\Asset_index", replace
}

{/******* addtional variables from plot level data*/

**section2_w3

use "$indir\sect2_pp_w3", clear

for var pp_s2q01b pp_s2q04: recode  X (2=0)
lab define Yes_no 1"Yes" 0 "No",replace
for var pp_s2q01b pp_s2q04: lab values X Yes_no
tab pp_s2q15, gen ( pp_s2q15 )
tab pp_s2q14, gen ( pp_s2q14)

collapse (max) pp_s2q01b pp_s2q04 pp_s2q151- pp_s2q145, by  ( household_id2 )


label variable pp_s2q01b "Is this parcel still owned or rented in by the holder"
label variable pp_s2q04 "Does your HH have a certificate for this [Parcel?"
label variable pp_s2q15 "What is the soil quality of this?"
label variable pp_s2q151 "Good"
label variable pp_s2q151 " soil_qltGood"
label variable pp_s2q151 "good soil quality"
label variable pp_s2q152 "Fair soil quality"
label variable pp_s2q153 "Poor soil quality"
label variable pp_s2q141 "Leptosol"
label variable pp_s2q142 "Cambisol"
label variable pp_s2q143 "Vertisol."
label variable pp_s2q144 "Luvisol"
label variable pp_s2q145 "Mixed type"
label variable pp_s2q01a "Is this a new parcel added on this visit -during 2015?"
label variable pp_s2q146 "Soil type-other soil type"
save "$temp\soil_cxr_new", replace

**section3_w3
use "$indir\sect3_pp_w3_landszie", clear  

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


**********************




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


**********************




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

gen inorgfer=1 if pp_s3q15==1 | pp_s3q18==1 | pp_s3q20a_1==1| pp_s3q20a==1
replace inorgfer =0 if pp_s3q15==0 & pp_s3q18==0 & pp_s3q20a_1==0 & pp_s3q20a==0
lab define inorgfer  1"Yes" 0 "No",replace
 lab values inorgfer inorgfer
 
tab pp_s3q09, gen ( pp_s3q09 )
 
lab define fied_prpa 1 "Tractor"2 "Animal" 5 "Digging hand" 6 "other" 7 "PERMANENT CROP NOT PLANTE",replace

lab values fied_prpa fied_prpa

tab fied_prpa , gen ( fied_prpa )

 save "$temp\land_size_cleaned", replace
 
 **
 use "$temp\land_size_cleaned", replace
 
 collapse (max) pp_s3q091- pp_s3q37 (sum) parcesizeHA, by ( household_id2)
 
label variable pp_s3q091 "Flat"
label variable pp_s3q092 "Sloppy - Moderate"
label variable pp_s3q093 "Sloppy - Steep"
label variable fied_prpa1 "Tractor"
label variable fied_prpa2 "Animal"
label variable fied_prpa3 "Digging hand"
label variable pp_s3q03c " left fallow anytime during the past 10 years?"
label variable pp_s3q11 "r Extension Program during the current agricultural season?"
label variable pp_s3q11 "Extension Program during the current agricultural season?"
label variable pp_s3q12 " irrigated during the current agricultural season?"
label variable pp_s3q14 "Is fertilizer used on both organiz and inorganic"
label variable inorgfer "inorganic"
label variable pp_s3q21 "manure on [Field]?"
label variable pp_s3q37 "crop residue (mulch) used on [FIELD] surface after planting in this agri"

label variable pp_s3q03c "left fallow anytime during the past 10 years?"
label variable fied_prpa4 "Other methods"
label variable cult "During this season, what is the status of this [FIELD]- "
label variable fild_prp "Was [FIELD] prepared for planting? :1, 0 otherwise"

winsor2 parcesizeHA , replace cuts(1 99)

save "$temp\ se3_w3_plot_new", replace
 
 
 *** asset-only productive asset
 
 use "$indir\sect10_hh_w3_asset.dta",clear
 
keep if hh_s10q00>=30
 
gen HHown_item=1 if hh_s10q01>0

replace HHown_item=0 if HHown_item==.
keep household_id2 hh_s10q00 HHown_item
reshape wide HHown_item, i( household_id2 ) j( hh_s10q00 )



save "$temp\asset_productiveasset", replace

merge 1:1 household_id2 using "C:\Users\SAlemu\Desktop\Big work_ESS_DATA\ESS datasets\ESS3_2015-16\Data\Innovation_2015\covariates_2015\sect_cover_hh_w3_idefn.dta"
pca HHown_item30- HHown_item35 , comp(1)
predict asset
sum asset
xtile prod_asset_ndex=asset, nq(5)
table prod_asset_ndex, c(mean asset)
keep household_id2 asset_prod prod_asset_ndex
compress

save "$temp\Asset_productiveindex", replace

}


******************************************************************************************


{/* descripitve part HH _LEVEL*/

use "C:\Users\SAlemu\Desktop\Big work_ESS_DATA\ESS datasets\ESS3_2015-16\Data\Innovation_2015\covariates_2015\analysis\ready for merging_hhlevel\new_version_march7\ESS_2015_HH_LEVE covariates_March8_v2.dta", replace
 winsor2 hh_size , replace cuts(1 99)
 order adulteq hh_size,after ( HH_size )
 drop HH_size
 winsor2 adulteq , replace cuts(1 99)

 replace income_offfarm = 7290.929 if  income_offfarm> 82000
 winsor2 income_offfarm , replace cuts(1 99)
 
 keep if saq01 ==1 | saq01==3 | saq01==4 | saq01==7
 
 

 *** do for only four regions
 
 use "C:\Users\SAlemu\Desktop\Big work_ESS_DATA\ESS datasets\ESS3_2015-16\Data\Innovation_2015\covariates_2015\analysis\ready for merging_hhlevel\new_version_march7\ESS_2015_HH_LEVE covariates_March8_v2_4 regions.dta"
 
 sum sex_head age_head educ_head_att educ_head_fr Marital_head2 mainoc_head2 adulteq hh_size Non_farmbusin receivedofffarm income_offfarm creditacc
 
**
 winsor2 parcesizeHA , replace cuts(1 99)
 
 *** plot-level anaysos
 
 sum parcesizeHA- fungicide
 
 ** consumtion aggreagte
 

 sum food_cons_ann nonfood_cons_ann educ_cons_ann total_cons_ann price_index_hce nom_totcons_aeq
 
for var food_cons_ann nonfood_cons_ann educ_cons_ann total_cons_ann price_index_hce nom_totcons_aeq: winsor2 X , replace cuts(1 99)


*** by region


bys saq01:sum sex_head age_head educ_head_att educ_head_fr Marital_head2 mainoc_head2 adulteq hh_size Non_farmbusin receivedofffarm income_offfarm creditacc


bys saq01: sum parcesizeHA- fungicide
bys saq01: sum food_cons_ann nonfood_cons_ann educ_cons_ann total_cons_ann price_index_hce nom_totcons_aeq

*** Plot_level-w3_s2_cleaned_4

 keep if saq01 ==1 | saq01==3 | saq01==4 | saq01==7
 
 use "C:\Users\SAlemu\Desktop\Big work_ESS_DATA\ESS datasets\ESS3_2015-16\Data\Innovation_2015\covariates_2015\analysis\ready for merging_hhlevel\new_version_march7\for plot_level\w3_s2_cleaned_4 regions.dta", replace

sum pp_s2q01b - pp_s2q145

bys saq01: sum pp_s2q01b - pp_s2q145

* Plot_level-w3_s3_cleaned_4

use "C:\Users\SAlemu\Desktop\Big work_ESS_DATA\ESS datasets\ESS3_2015-16\Data\Innovation_2015\covariates_2015\analysis\ready for merging_hhlevel\new_version_march7\for plot_level\w3_s3_cleaned_4regions_v2.dta", replace
winsor2 parcesizeHA , replace cuts(1 99)
 
 sum parcesizeHA- pp_s3q37
 
bys saq01: sum parcesizeHA- pp_s3q37

**** plot_level-w3_s4_cleaned_4
use "C:\Users\SAlemu\Desktop\Big work_ESS_DATA\ESS datasets\ESS3_2015-16\Data\Innovation_2015\covariates_2015\analysis\ready for merging_hhlevel\new_version_march7\for plot_level\w3_s4_cleaned_4regions.dta",replace
 
sum pp_s4q05 pp_s4q06 pp_s4q07
bys saq01:sum pp_s4q05 pp_s4q06 pp_s4q07


**** dec-asset-4 regions

use "$temp\asset_household", replace
merge 1:1 household_id2 using "$temp\asset_type"
drop _m

drop drinkwat_sc_rain1- drinkwat_sc_dry13

merge 1:1 household_id2 using "C:\Users\SAlemu\Desktop\Big work_ESS_DATA\ESS datasets\ESS3_2015-16\Data\Innovation_2015\covariates_2015\sect_cover_hh_w3_idefn.dta"

 keep if saq01 ==1 | saq01==3 | saq01==4 | saq01==7
pca wall1 - HHown_item35 own_house no_room , comp(1)
predict asset
sum asset
xtile asset_index=asset, nq(5)
table asset_index, c(mean asset)
keep household_id2 asset asset_index
compress
save "$temp\Asset_index_for4region", replace


*** produc asset-  regions

use "$temp\asset_productiveasset", replace

merge 1:1 household_id2 using "C:\Users\SAlemu\Desktop\Big work_ESS_DATA\ESS datasets\ESS3_2015-16\Data\Innovation_2015\covariates_2015\sect_cover_hh_w3_idefn.dta"

 keep if saq01 ==1 | saq01==3 | saq01==4 | saq01==7
pca HHown_item30- HHown_item35 , comp(1)
predict asset_prod
sum asset_prod
xtile prod_asset_ndex=asset_prod, nq(5)
table prod_asset_ndex, c(mean asset_prod)
keep household_id2 asset_prod prod_asset_ndex
compress

save "$temp\Asset_productiveindex_4regions", replace


*** descrptive asset
bys saq01:sum asset asset_prod
bys saq01:sum prod_asset_ndex


table prod_asset_ndex, c(mean asset_prod)
table asset_index, c(mean asset)


*** soil*crx by ea
use "C:\Users\SAlemu\Desktop\Big work_ESS_DATA\ESS datasets\ESS3_2015-16\Data\Innovation_2015\covariates_2015\analysis\ready for merging_hhlevel\new_version_march7\for plot_level\w3_s2_cleaned_4 regions.dta",replace

collapse (max) pp_s2q151 pp_s2q152 pp_s2q153, by ( ea_id saq01 )

bys saq01:sum pp_s2q151 pp_s2q152 pp_s2q153


**** grpahs



****b)	Relationship between HDDS and education

histogram age_head , normal

histogram age_head if saq01==1 , normal saving(ga)

histogram age_head if saq01==3 , normal saving(gb)
histogram age_head if saq01==4 , normal saving(gc)
histogram age_head if saq01==7 , normal saving(gd)

gr combine ga.gph gb.gph gc.gph gd.gph

*** correction

*** land size*** plot

use  "C:\Users\SAlemu\Desktop\Big work_ESS_DATA\ESS datasets\ESS3_2015-16\Data\Innovation_2015\covariates_2015\analysis\ready for merging_hhlevel\new_version_march7\for plot_level\w3_s3_cleaned_4regions_v3_laddropped.dta",replace

winsor2 parcesizeHA , replace cuts(1 99)
save "C:\Users\SAlemu\Desktop\Big work_ESS_DATA\ESS datasets\ESS3_2015-16\Data\Innovation_2015\covariates_2015\analysis\ready for merging_hhlevel\new_version_march7\for plot_level\w3_s3_cleaned_4regions_v3_laddropped.dta", replace

bys saq01 :sum parcesizeHA
sum parcesizeHA

*** 

histogram parcesizeHA2, normal

histogram parcesizeHA2 if saq01==1 , normal saving(ge1)

histogram parcesizeHA2 if saq01==3 , normal saving(gf1)
histogram parcesizeHA2 if saq01==4 , normal saving(gg1)
histogram parcesizeHA2 if saq01==7 , normal saving(gh1)

gr combine ge1.gph gf1.gph gg1.gph gh1.gph

*** mean devation from EA
egen pp_s2q151_ea = mean ( pp_s2q151 ),by ( ea_id )
gen X = pp_s2q151_ea- pp_s2q151
br pp_s2q151 pp_s2q151_ea
br pp_s2q151 pp_s2q151_ea X
sum X

collapse (mean) X, by ( household_id2 )

gen region = 1 if saq01 ==1 | saq01==3 | saq01==4 | saq01==7
replace region = 2 if region==.
lab define region 1 "Four main regions" 2 "Other regions",replace
lab values region region
fre region


**** Devation from ea average

egen good_soil_ea = mean ( good_soil ),by ( ea_id2 )

egen Fairsoil_ea = mean ( Fairsoil ),by ( ea_id2 )
egen poor_soil_ea = mean ( poor_soil ),by ( ea_id2 )

gen goodsoil_deveam = good_soil_ea - good_soil
gen Fairsoil_deveam = Fairsoil_ea - Fairsoil
gen poorsoil_deveam = poor_soil_ea - poor_soil



***GEOSPATIAL_VARIABLES

for var dist_road- dist_admctr: winsor2 X , replace cuts(1 99)

***comunity-level

for  var cs9q01 cs6q10: recode  X (2=0)
lab define Yes_no 1"Yes" 0 "No",replace
for var cs9q01 cs6q10: lab values X Yes_no
for var cs4q02_1- cs4q15:winsor2 X , replace cuts(1 99)


*** ESS_W3_S3,S4& geo special data are pacel and filed level while S2 is at parcel level

*** trying to merge the plots
egen uni_id = concat( holder_id parcel_id field_id )
order uni_id
label variable uni_id "holder_id parcel_id field_id"

**w3_s2_cleaned

label variable uni_id2 "concat( holder_id parcel_id)"


**** CORRECTION
collapse (max) fild_prp (mean) fied_prpa1 fied_prpa2 fied_prpa3 fied_prpa4, by ( household_id2 )

label variable fied_prpa1 "Tractor"
label variable fied_prpa2 "Animal"
label variable fied_prpa3 "Digging hand"

label variable fied_prpa4 "others"
label variable fild_prp "Was [FIELD] prepared for planting? "

*** plot level- mean devation from ea average - Appearance

egen pp_s3q091_ea = mean ( pp_s3q091 ),by ( ea_id )

egen pp_s3q092_ea = mean ( pp_s3q092 ),by ( ea_id)
egen pp_s3q093_ea = mean ( pp_s3q093 ),by ( ea_id)

gen pp_s3q091_deveam = pp_s3q091_ea - pp_s3q091
gen pp_s3q092_deveam = pp_s3q092_ea - pp_s3q092
gen pp_s3q093_deveam = pp_s3q093_ea - pp_s3q093


gen cult = 1 if pp_s3q03==1
replace  cult=0 if pp_s3q03!=1 & pp_s3q03!=.
edit pp_s3q03c cult pp_s3q03
sort pp_s3q03c cult pp_s3q03
bys pp_s3q03c : fre pp_s3q03
bys cult:fre pp_s3q03c
order cult,after ( fied_prpa4 )
label variable cult " During this season, what is the status of this [FIELD]?"
replace pp_s3q03c=. if cult==0
replace pp_s3q11=. if cult==0
replace pp_s3q12=. if cult==0
replace pp_s3q14=. if cult==0
replace pp_s3q21=. if pp_s3q14==.
replace pp_s3q37=0 if cult==1 & pp_s3q37==.


recode pp_s4q04 (2=0)
label define PP_S4Q04 1 "Yes" 0 "No", replace

recode pp_s2q01a (2=0)
edit pp_s2q01a
label define PP_S2Q01A 1 "Yes" 0 "No", replace

** plot level soil quality


egen pp_s2q151_ea = mean ( pp_s2q151 ),by ( ea_id )

egen pp_s2q152_ea = mean ( pp_s2q152 ),by ( ea_id )
egen pp_s2q153_ea = mean ( pp_s2q153 ),by ( ea_id )

gen pp_s2q151_deveam = pp_s2q151_ea - pp_s2q151
gen pp_s2q152_deveam = pp_s2q152_ea - pp_s2q152
gen pp_s2q153_deveam = pp_s2q153_ea - pp_s2q153


label variable pp_s2q151 "% of plot with good soil quality"
label variable pp_s2q152 "% of plot with fair soil quality"
label variable pp_s2q153 "% of plot with poor soil quality"
label variable pp_s2q141 "% of plot with Leptosol type"
label variable pp_s2q142 " % of plot with Cambisol type"
label variable pp_s2q143 "% of plot with Vertisol type"
label variable pp_s2q144 "% of plot with Luvisol type"
label variable pp_s2q145 "% of plot with mixed soil type"

label variable pp_s2q141 "% of plot with Leptosol  soiltype"
label variable pp_s2q141 "% of plot with Leptosol  soil type"
label variable pp_s2q142 " % of plot with Cambisol  soil type"
label variable pp_s2q143 "% of plot with Vertisol soil type"
label variable pp_s2q144 "% of plot with Luvisol soil type"
label variable pp_s2q146 "% of plot with other soil type"


label variable pp_s3q091 "% of plot with Flat field appearance "
label variable pp_s3q092 "% of plot with Sloppy - Moderate field appearance  "
label variable pp_s3q093 "% of plot with  Sloppy - Steep field appearance  "

label variable fied_prpa1 "% of plot prepared by Tractor"

label variable fied_prpa3 "% of plot prepared by Digging hand"
label variable fied_prpa2 "% of plot prepared by Animal"
label variable fied_prpa4 "% of plot prepared by other methods"



**** correction

gen rural2= 1 if rural==1
replace rural2 =1 if rural==2
order rural2, after (rural)



** fertilizer

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

label variable inorgfer "in organic fer only"
label variable inorgfer "inorganic fer only"


*** pesticides

for var pp_s4q05- pp_s4q07: replace X =0 if pp_s4q04==0


{/* descripitve part HH _LEVEL*/

use "C:\Users\SAlemu\Desktop\Big work_ESS_DATA\ESS datasets\ESS3_2015-16\Data\Innovation_2015\covariates_2015\analysis\ready for merging_hhlevel\new_version_march7\ESS_2015_HH_LEVE covariates_March8_v2.dta", replace
 winsor2 hh_size , replace cuts(1 99)
 order adulteq hh_size,after ( HH_size )
 drop HH_size
 winsor2 adulteq , replace cuts(1 99)

 replace income_offfarm = 7290.929 if  income_offfarm> 82000
 winsor2 income_offfarm , replace cuts(1 99)
 
 keep if saq01 ==1 | saq01==3 | saq01==4 | saq01==7
 
 

 *** do for only four regions
 
 use "C:\Users\SAlemu\Desktop\Big work_ESS_DATA\ESS datasets\ESS3_2015-16\Data\Innovation_2015\covariates_2015\analysis\ready for merging_hhlevel\new_version_march7\ESS_2015_HH_LEVE covariates_March8_v2_4 regions.dta"
 
 sum sex_head age_head educ_head_att educ_head_fr Marital_head2 mainoc_head2 adulteq hh_size Non_farmbusin receivedofffarm income_offfarm creditacc
 
**
 winsor2 parcesizeHA , replace cuts(1 99)
 
 *** plot-level anaysos
 
 sum parcesizeHA- fungicide
 
 ** consumtion aggreagte
 

 sum food_cons_ann nonfood_cons_ann educ_cons_ann total_cons_ann price_index_hce nom_totcons_aeq
 
for var food_cons_ann nonfood_cons_ann educ_cons_ann total_cons_ann price_index_hce nom_totcons_aeq: winsor2 X , replace cuts(1 99)


*** by region


bys saq01:sum sex_head age_head educ_head_att educ_head_fr Marital_head2 mainoc_head2 adulteq hh_size Non_farmbusin receivedofffarm income_offfarm creditacc


bys saq01: sum parcesizeHA- fungicide
bys saq01: sum food_cons_ann nonfood_cons_ann educ_cons_ann total_cons_ann price_index_hce nom_totcons_aeq

*** Plot_level-w3_s2_cleaned_4

 keep if saq01 ==1 | saq01==3 | saq01==4 | saq01==7
 
 use "C:\Users\SAlemu\Desktop\Big work_ESS_DATA\ESS datasets\ESS3_2015-16\Data\Innovation_2015\covariates_2015\analysis\ready for merging_hhlevel\new_version_march7\for plot_level\w3_s2_cleaned_4 regions.dta", replace

sum pp_s2q01b - pp_s2q145

bys saq01: sum pp_s2q01b - pp_s2q145

* Plot_level-w3_s3_cleaned_4

use "C:\Users\SAlemu\Desktop\Big work_ESS_DATA\ESS datasets\ESS3_2015-16\Data\Innovation_2015\covariates_2015\analysis\ready for merging_hhlevel\new_version_march7\for plot_level\w3_s3_cleaned_4regions_v2.dta", replace
winsor2 parcesizeHA , replace cuts(1 99)
 
 sum parcesizeHA- pp_s3q37
 
bys saq01: sum parcesizeHA- pp_s3q37

**** plot_level-w3_s4_cleaned_4
use "C:\Users\SAlemu\Desktop\Big work_ESS_DATA\ESS datasets\ESS3_2015-16\Data\Innovation_2015\covariates_2015\analysis\ready for merging_hhlevel\new_version_march7\for plot_level\w3_s4_cleaned_4regions.dta",replace
 
sum pp_s4q05 pp_s4q06 pp_s4q07
bys saq01:sum pp_s4q05 pp_s4q06 pp_s4q07


**** dec-asset-4 regions

use "$temp\asset_household", replace
merge 1:1 household_id2 using "$temp\asset_type"
drop _m

drop drinkwat_sc_rain1- drinkwat_sc_dry13

merge 1:1 household_id2 using "C:\Users\SAlemu\Desktop\Big work_ESS_DATA\ESS datasets\ESS3_2015-16\Data\Innovation_2015\covariates_2015\sect_cover_hh_w3_idefn.dta"

 keep if saq01 ==1 | saq01==3 | saq01==4 | saq01==7
pca wall1 - HHown_item35 own_house no_room , comp(1)
predict asset
sum asset
xtile asset_index=asset, nq(5)
table asset_index, c(mean asset)
keep household_id2 asset asset_index
compress
save "$temp\Asset_index_for4region", replace


*** produc asset-  regions

use "$temp\asset_productiveasset", replace

merge 1:1 household_id2 using "C:\Users\SAlemu\Desktop\Big work_ESS_DATA\ESS datasets\ESS3_2015-16\Data\Innovation_2015\covariates_2015\sect_cover_hh_w3_idefn.dta"

 keep if saq01 ==1 | saq01==3 | saq01==4 | saq01==7
pca HHown_item30- HHown_item35 , comp(1)
predict asset_prod
sum asset_prod
xtile prod_asset_ndex=asset_prod, nq(5)
table prod_asset_ndex, c(mean asset_prod)
keep household_id2 asset_prod prod_asset_ndex
compress

save "$temp\Asset_productiveindex_4regions", replace


*** descrptive asset
bys saq01:sum asset asset_prod
bys saq01:sum prod_asset_ndex


table prod_asset_ndex, c(mean asset_prod)
table asset_index, c(mean asset)


*** soil*crx by ea
use "C:\Users\SAlemu\Desktop\Big work_ESS_DATA\ESS datasets\ESS3_2015-16\Data\Innovation_2015\covariates_2015\analysis\ready for merging_hhlevel\new_version_march7\for plot_level\w3_s2_cleaned_4 regions.dta",replace

collapse (max) pp_s2q151 pp_s2q152 pp_s2q153, by ( ea_id saq01 )

bys saq01:sum pp_s2q151 pp_s2q152 pp_s2q153


**** grpahs



****b)	Relationship between HDDS and education

histogram age_head , normal

histogram age_head if saq01==1 , normal saving(ga)

histogram age_head if saq01==3 , normal saving(gb)
histogram age_head if saq01==4 , normal saving(gc)
histogram age_head if saq01==7 , normal saving(gd)

gr combine ga.gph gb.gph gc.gph gd.gph

*** correction

*** land size*** plot

use  "C:\Users\SAlemu\Desktop\Big work_ESS_DATA\ESS datasets\ESS3_2015-16\Data\Innovation_2015\covariates_2015\analysis\ready for merging_hhlevel\new_version_march7\for plot_level\w3_s3_cleaned_4regions_v3_laddropped.dta",replace

winsor2 parcesizeHA , replace cuts(1 99)
save "C:\Users\SAlemu\Desktop\Big work_ESS_DATA\ESS datasets\ESS3_2015-16\Data\Innovation_2015\covariates_2015\analysis\ready for merging_hhlevel\new_version_march7\for plot_level\w3_s3_cleaned_4regions_v3_laddropped.dta", replace

bys saq01 :sum parcesizeHA
sum parcesizeHA

*** 

histogram parcesizeHA2, normal

histogram parcesizeHA2 if saq01==1 , normal saving(ge1)

histogram parcesizeHA2 if saq01==3 , normal saving(gf1)
histogram parcesizeHA2 if saq01==4 , normal saving(gg1)
histogram parcesizeHA2 if saq01==7 , normal saving(gh1)

gr combine ge1.gph gf1.gph gg1.gph gh1.gph

*** mean devation from EA
egen pp_s2q151_ea = mean ( pp_s2q151 ),by ( ea_id )
gen X = pp_s2q151_ea- pp_s2q151
br pp_s2q151 pp_s2q151_ea
br pp_s2q151 pp_s2q151_ea X
sum X

collapse (mean) X, by ( household_id2 )

gen region = 1 if saq01 ==1 | saq01==3 | saq01==4 | saq01==7
replace region = 2 if region==.
lab define region 1 "Four main regions" 2 "Other regions",replace
lab values region region
fre region


**** Devation from ea average

egen good_soil_ea = mean ( good_soil ),by ( ea_id2 )

egen Fairsoil_ea = mean ( Fairsoil ),by ( ea_id2 )
egen poor_soil_ea = mean ( poor_soil ),by ( ea_id2 )

gen goodsoil_deveam = good_soil_ea - good_soil 
gen Fairsoil_deveam = Fairsoil_ea - Fairsoil
gen poorsoil_deveam = poor_soil_ea - poor_soil



***GEOSPATIAL_VARIABLES

for var dist_road- dist_admctr: winsor2 X , replace cuts(1 99)


sum  parcesizeHA3 Flat Sloppy_Moderate Sloppy_Steep ownrentland landcertfic good_soil Fairsoil poor_soil  goodsoil_deveam Fairsoil_deveam poorsoil_deveam Leptosol Cambisol Vertisol Luvisol Mixed_type Tractor Animal Digging_hand left_fallow Exteserv irrigatedlnd fert_orginor inorgfer Manure mulch pesticide herbicide fungicide

*** by region



gen region2= saq01
order region2, after ( saq01 )
fre region2
fre saq01
replace region2=.
replace region2 =1 if saq01==1
replace region2 =5 if saq01==2
replace region2 =2 if saq01==3
replace region2 =3 if saq01==4
replace region2 =4 if saq01==7
fre region2
fre saq01
replace region2 =5 if saq01==5 | saq01==6 | saq01==12 | saq01==13 | saq01==14 | saq01==15
fre region2
fre saq01
fre region2
lab define region2 1 "Tigray" 2 "Amhara" 3 "Oromia" 4 "snnp " 5 "other regions", replace
lab values region2 region2
fre region2

gen region = 1 if saq01 ==1 | saq01==3 | saq01==4 | saq01==7
replace region = 2 if region==.
lab define region 1 "Four main regions" 2 "Other regions",replace
lab values region region
fre region
order region,after (region2)

bys region:


bys region2:sum sex_head age_head educ_head_att educ_head_fr Marital_head2 mainoc_head2 adulteq hh_size Non_farmbusin receivedofffarm income_offfarm creditacc

bys region2 : sum food_cons_ann nonfood_cons_ann educ_cons_ann total_cons_ann price_index_hce nom_totcons_aeq

bys region2 :sum  parcesizeHA3 Flat Sloppy_Moderate Sloppy_Steep ownrentland landcertfic good_soil Fairsoil poor_soil Leptosol Cambisol Vertisol Luvisol Mixed_type Tractor Animal Digging_hand left_fallow Exteserv irrigatedlnd fert_orginor inorgfer Manure mulch pesticide herbicide fungicide



***** 
***GEOSPATIAL_VARIABLES

for var dist_road- dist_admctr: winsor2 X , replace cuts(1 99)

for var cs4q02_1- cs4q15:winsor2 X , replace cuts(1 99)
use "C:\Users\SAlemu\Desktop\Big work_ESS_DATA\ESS datasets\ESS3_2015-16\Data\Innovation_2015\covariates_2015\analysis\ETH_PlotGeovariables_Y3_v2.dta",replace
collapse (mean) dist_household plot_srtmslp plot_srtm plot_twi , by ( household_id2 )
duplicates report household_id2
sum dist_household- plot_twi

label variable dist_household "Plot Distance in (KMs) to HH"
label variable plot_srtmslp "Plot Slope (percent)"
label variable plot_srtm "Plot Elevation (m)"
label variable plot_twi "Plot Potential Wetness Index"


*** ea mean for  dist_road and dist_market

egen dist_road_ea = mean ( dist_road ),by ( ea_id2 )

egen dist_market_ea = mean ( dist_market ),by ( ea_id2 )


*** devation from mean ea
gen dist_road_deveam = dist_road_ea - dist_road
gen dist_market_deveam = dist_market_ea - dist_market



label variable dist_road_ea "Dis road EA Average"

label variable dist_market_ea "Dis market EA Average"

label variable dist_road_deveam "Road distance deviation from mean EA"

label variable dist_market_deveam "Market distance deviation from mean EA"
. order dist_road_deveam,after ( dist_road )

. order dist_market_deveam, after ( dist_market)



**** dev from URBAND CENTER

egen dist_admctr_ea = mean ( dist_admctr ),by ( ea_id2 )

*** devation from mean ea
gen dist_admctr_deveam = dist_admctr_ea - dist_admctr

label variable dist_market_deveam "Market distance deviation from mean EA"
. order dist_road_deveam,after ( dist_road )


***** Community level- PLOT information

collapse (mean) parcesizeHA (mean) pp_s3q091 pp_s3q092 pp_s3q093 (max) fild_prp (mean) fied_prpa1 fied_prpa2 fied_prpa3 fied_prpa4 (max) cult pp_s3q03c pp_s3q11 pp_s3q12 pp_s3q14 fert_orginor_both inorgfer pp_s3q21 pp_s3q37 (mean) dist_household plot_srtmslp plot_srtm plot_twi , by ( ea_id )




label variable pp_s3q091 "Flat"
label variable pp_s3q092 "Sloppy - Moderate"
label variable pp_s3q093 "Sloppy - Steep"
label variable fied_prpa1 "Tractor"
label variable fied_prpa2 "Animal"
label variable fied_prpa3 "Digging hand"
label variable pp_s3q03c " left fallow anytime during the past 10 years?"
label variable pp_s3q11 "r Extension Program during the current agricultural season?"
label variable pp_s3q11 "Extension Program during the current agricultural season?"
label variable pp_s3q12 " irrigated during the current agricultural season?"
label variable pp_s3q14 "Is fertilizer used on both organiz and inorganic"
label variable inorgfer "inorganic"
label variable pp_s3q21 "manure on [Field]?"
label variable pp_s3q37 "crop residue (mulch) used on [FIELD] surface after planting in this agri"

label variable pp_s3q03c "left fallow anytime during the past 10 years?"
label variable fied_prpa4 "Other methods"
label variable cult "During this season, what is the status of this [FIELD]- "
label variable fild_prp "Was [FIELD] prepared for planting? :1, 0 otherwise"

label variable parcesizeHA " average field size in ha"
label variable fert_orginor_both "Is fertilizer used on both organiz and inorganic"
label variable pp_s3q14 "Is fertilizer used on both organiz or inorganic"
label variable pp_s3q14 "Is fertilizer used organiz or inorganic"
label variable pp_s3q14 "Is fertilizer used organic or inorganic"
label variable inorgfer "inorganic  fertilizer only"
label variable inorgfer "inorganic  fertilizer only in this  [Field]?"
label variable inorgfer "inorganic  fertilizer only in this  [Field]"
label variable pp_s3q14 "Is fertilizer used organic or inorganic  [Field]?"
label variable fert_orginor_both "Is fertilizer used on both organiz and inorganic  [Field]?"
label variable pp_s3q14 "Is fertilizer used organic or inorganic in this  [Field]?"
label variable fert_orginor_both "Is fertilizer used on both organiz and inorganic in this  [Field]?"
label variable fert_orginorboth "Is fertilizer used both organic and inorganic in this  [Field]?"



label variable pp_s3q091 "% of plot with Flat field appearance "
label variable pp_s3q092 "% of plot with Sloppy - Moderate field appearance  "
label variable pp_s3q093 "% of plot with  Sloppy - Steep field appearance  "

label variable fied_prpa1 "% of plot prepared by Tractor"

label variable fied_prpa3 "% of plot prepared by Digging hand"
label variable fied_prpa2 "% of plot prepared by Animal"
label variable fied_prpa4 "% of plot prepared by other methods"


label variable dist_household "Plot Distance in (KMs) to HH"
label variable plot_srtmslp "Plot Slope (percent)"
label variable plot_srtm "Plot Elevation (m)"
label variable plot_twi "Plot Potential Wetness Index"


***com_s2_w3

collapse (max) pp_s2q01a pp_s2q01b pp_s2q04 (mean) pp_s2q151 pp_s2q152 pp_s2q153 pp_s2q141 pp_s2q142 pp_s2q143 pp_s2q144 pp_s2q145 pp_s2q146, by( ea_id )



label variable pp_s2q01b "Is this parcel still owned or rented in by the holder"
label variable pp_s2q04 "Does your HH have a certificate for this [Parcel?"
label variable pp_s2q15 "What is the soil quality of this?"
label variable pp_s2q151 "% of plot with good soil quality"
label variable pp_s2q152 "% of plot with fair soil quality"
label variable pp_s2q153 "% of plot with poor soil quality"
label variable pp_s2q141 "% of plot with Leptosol type"
label variable pp_s2q142 " % of plot with Cambisol type"
label variable pp_s2q143 "% of plot with Vertisol type"
label variable pp_s2q144 "% of plot with Luvisol type"
label variable pp_s2q145 "% of plot with mixed soil type"

label variable pp_s2q141 "% of plot with Leptosol  soiltype"
label variable pp_s2q141 "% of plot with Leptosol  soil type"
label variable pp_s2q142 " % of plot with Cambisol  soil type"
label variable pp_s2q143 "% of plot with Vertisol soil type"
label variable pp_s2q144 "% of plot with Luvisol soil type"
label variable pp_s2q146 "% of plot with other soil type"

**comS4-w3

collapse (max) pp_s4q04 pp_s4q05 pp_s4q06 pp_s4q07, by ( ea_id )

label variable pp_s4q05 "Did you use any pesticide to prevent damage of [Crop] on this field?"
label variable pp_s4q06 "Did you use any herbicide to prevent damage of [Crop] on this field?"
label variable pp_s4q07 "Did you use any fungicide to prevent damage of [Crop] on this [Field]?"
label variable pp_s4q04 "Was prevention measures taken to prevent damage of [Crop]?"



**** 2011 GEO and community level data


*** ea mean for  dist_road and dist_market

egen dist_road_ea2011 = mean ( dist_road2011 ),by ( ea_id2 )

egen dist_market_ea2011 = mean ( dist_market2011 ),by ( ea_id2 )
egen dist_admctr_ea2011 = mean ( dist_admctr2011 ),by ( ea_id2 )

*** devation from mean ea
gen dist_road_deveam2011 = dist_road_ea2011 - dist_road2011
gen dist_market_deveam2011 = dist_market_ea2011 - dist_market2011

gen dist_admctr_deveam2011 = dist_admctr_ea2011 - dist_admctr2011


label variable dist_road_ea2011 "Dis road EA Average"

label variable dist_market_ea2011 "Dis market EA Average"

label variable dist_road_deveam2011 "Road distance deviation from mean EA"

label variable dist_market_deveam2011 "Market distance deviation from mean EA"
. order dist_road_deveam2011,after ( dist_road2011 )

. order dist_market_deveam2011, after ( dist_market2011)


label variable dist_market_deveam2011 "Market distance deviation from mean EA"
. order dist_road_deveam2011,after ( dist_road2011 )
order dist_admctr_deveam2011, after ( dist_admctr2011)

** medaian distance
egen dist_roadmedi2011 = median ( dist_road2011 ), by ( ea_id )
order dist_roadmedi2011,after ( dist_road_deveam2011 )

egen dist_marketmedi2011 = median ( dist_market2011 ), by ( ea_id2 )
order dist_marketmedi2011,after ( dist_market_deveam2011 )

egen dist_admctrmedi2011 = median ( dist_admctr2011 ), by ( ea_id2 )
order dist_admctrmedi2011,after ( dist_admctr_deveam2011 )

label variable dist_road_deveam2011 "Road distance deviation from mean EA"
label variable dist_roadmedi2011 "(p 50) dist_road - median values"

label variable dist_market_deveam2011 "Market distance deviation from mean EA"
label variable dist_marketmedi2011 "(p 50) dist_market  - median values"
label variable dist_admctr_deveam2011 "Capital of zone distance deviation from mean EA"
label variable dist_admctrmedi2011 "(p 50) dist_admctr  - median values"

** new distance for 2015

egen dist_road_ea2015 = mean ( dist_road2015 ),by ( ea_id2 )

egen dist_market_ea2015 = mean ( dist_market2015 ),by ( ea_id2 )
egen dist_admctr_ea2015 = mean ( dist_admctr2015 ),by ( ea_id2 )

*** devation from mean ea
gen dist_road_deveam2015 = dist_road_ea2015 - dist_road2015
gen dist_market_deveam2015 = dist_market_ea2015 - dist_market2015

gen dist_admctr_deveam2015 = dist_admctr_ea2015 - dist_admctr2015


label variable dist_road_ea2015 "Dis road EA Average"

label variable dist_market_ea2015 "Dis market EA Average"

label variable dist_road_deveam2015 "Road distance deviation from mean EA"

label variable dist_market_deveam2015 "Market distance deviation from mean EA"
. order dist_road_deveam2015,after ( dist_road2015 )

. order dist_market_deveam2015, after ( dist_market2015)


label variable dist_market_deveam2015 "Market distance deviation from mean EA"
. order dist_road_deveam2015,after ( dist_road2015 )
order dist_admctr_deveam2015, after ( dist_admctr2015)

** medaian distance
egen dist_roadmedi2015 = median ( dist_road2015 ), by ( ea_id )
order dist_roadmedi2015,after ( dist_road_deveam2015 )

egen dist_marketmedi2015 = median ( dist_market2015 ), by ( ea_id2 )
order dist_marketmedi2015,after ( dist_market_deveam2015 )

egen dist_admctrmedi2015 = median ( dist_admctr2015 ), by ( ea_id2 )
order dist_admctrmedi2015,after ( dist_admctr_deveam2015 )

label variable dist_road_deveam2015 "Road distance deviation from mean EA"
label variable dist_roadmedi2015 "(p 50) dist_road - median values"

label variable dist_market_deveam2015 "Market distance deviation from mean EA"
label variable dist_marketmedi2015 "(p 50) dist_market  - median values"
label variable dist_admctr_deveam2015 "Capital of zone distance deviation from mean EA"
label variable dist_admctrmedi2015 "(p 50) dist_admctr  - median values"

****** April_15 version correction and clarfication


** Age group of family member

*** age chatagories 
clonevar hh_s1q04a2=hh_s1q04a

replace hh_s1q04a2=1 if hh_s1q04a2<5 
replace hh_s1q04a2=2 if hh_s1q04a2<=17 & hh_s1q04a2 >=5

replace hh_s1q04a2=3 if hh_s1q04a2<=29 & hh_s1q04a2 >=15 // according to FDRI youth policy (https://www.usaid.gov/sites/default/files/documents/1860/Fact_Sheet_Developing_Ethiopias_Youth_Jul_2017.pdf)
replace hh_s1q04a2=4 if hh_s1q04a2<=40 & hh_s1q04a2 >=30
replace hh_s1q04a2=5 if hh_s1q04a2<=55 & hh_s1q04a2 >=41
replace hh_s1q04a2=6 if hh_s1q04a2>=56 & hh_s1q04a2!=.

label define hh_s1q04a2  1 "<5" 2 "5-17"  3"15-29" 4 "30-40" 5 "41-55" 6 ">55", modify
label val hh_s1q04a2 hh_s1q04a2
ta hh_s1q04a2
ta hh_s1q04a2, gen(hh_s1q04a2)


