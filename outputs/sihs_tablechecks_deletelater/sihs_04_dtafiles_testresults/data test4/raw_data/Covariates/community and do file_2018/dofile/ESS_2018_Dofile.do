

*** ESS_2018 data

set more off
global indir  "C:\Users\SAlemu\Desktop\ESS4_2018-19\Innovation_2018\covariates_2018\HH_and pltLevel info"
global temp "C:\Users\SAlemu\Desktop\ESS4_2018-19\Innovation_2018\covariates_2018\Analysis"

*** *===============================================================================

** Demographcis

{/*demog_demo.dta*/

use "$indir\sect1_hh_w4_demo", clear


gen sex_head= s1q02 if s1q01==1
gen age_head= s1q03a if s1q01==1
gen Marital_head= s1q09 if s1q01==1
gen mainoc_head= s1q21 if s1q01==1


label variable sex_head "sex_head"
label define sex_head 1 "Male" 0 "Female", replace

lab values sex_head sex_head
recode sex_head (2=0)
label variable age_head "age_head"
label variable Marital_head "Marital_head"

label variable mainoc_head "mainoc_head"

label define s1q09 1 "Never Married" 2 "Married (monogamous)" 3 "Married (polygamous)" 4 "Divorced" 5 "Seperated" 6 "Widowed" 7"CO-HABITING ", replace
lab values Marital_head s1q09 

gen Marital_head2 = Marital_head
recode Marital_head2 (2=1)(3=1)(1=0)(5=0)(4=0)(6=0)(7=0)

lab define Marital_head2 1"Married" 0 "Single",replace
lab values Marital_head2 Marital_head2

gen mainoc_head2 = .
replace mainoc_head2=1 if mainoc_head==1
replace mainoc_head2=0 if mainoc_head>1 & mainoc_head!=.
fre mainoc_head2
fre mainoc_head2
lab define  mainoc_head2 1 "Agriculture " 0 "Non-Agriculture", replace
lab values mainoc_head2 mainoc_head2

save "$temp\sect1_hh_w4_demomod", replace


use "$temp\sect1_hh_w4_demomod", clear

collapse (max) sex_head age_head Marital_head2  mainoc_head2, by ( household_id )
label values sex_head sex_head
lab values Marital_head2 Marital_head2
lab values mainoc_head2 mainoc_head2

label variable sex_head "sex_head"
label variable age_head "age_head"
label variable Marital_head2 "Marital_head2"
label variable mainoc_head2 "mainoc_head2"
save "$temp\sect1_hh_w4_demohh", replace


*****#hh....alreday calculated

*** Education-head- merged with deo

use "$temp\sect1_hh_w4_demomod", clear

egen uni_id = concat( household_id individual_id )
order uni_id
 save "$temp\sect1_hh_w4_demomod", replace

use "$indir\sect2_hh_w4_edc", clear

egen uni_id = concat( household_id individual_id )
order uni_id

merge 1:1 uni_id using "$temp\\sect1_hh_w4_demomod.dta"

save "$temp\educ_demo_merged", replace


gen educ_head= s2q06 if s1q01==1==1
gen educ_head_att= s2q04 if s1q01==1==1

recode educ_head_att (2=0)
fre educ_head

lab values educ_head S2Q06 
fre educ_head
collapse (min) educ_head educ_head_att, by ( household_id)

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

replace educ_head_att=0 if educ_head_fr==.

save "$temp\hh_edcation", replace

**** Activities- non farm 

use "$indir\sect12a_hh_w4_nonfarm", clear 

keep household_id s12aq01__1

recode  s12aq01__1 (2=0)

label define s12aq01__1 1 "Yes" 0 "No", replace

lab values s12aq01__1  s12aq01__1
save "$temp\hh_nonfarmactvitiy", replace

*** farm farm income - no item descripion

use "$indir\sect13_hh_w4_off farm", clear


winsor2 s13q02 , replace cuts(1 99)


recode s13q01 (2=0)
lab define s13q01 1 "Yes" 0 "No", modify

lab values s13q01 s13q01

collapse (max) s13q01 (sum) s13q02, by ( household_id)
lab values s13q01 s13q01
label variable s13q01 "During the last 12 months, received off farm income"
label variable s13q02 "off- farm income in the  last 12 months? (BIRR)"
save "$temp\hh_offfarmincome", replace

*** creidt

use "$indir\sect15a_hh_w4_credit", clear 


keep household_id s15q01
recode s15q01 (2=0)
label define s15q01 1 "Yes" 0 "No", replace
label variable s15q01 "HH who receive credit from outside the HH  or from an institution for business o"

lab values s15q01 s15q01
save "$temp\hh_credit_acc", replace

*** asset index

use "$indir\sect11_hh_w4_asset", clear 

rename s11q00 HHown_item

label define Yes_no 1 "Yes" 0 "No", replace

recode HHown_item (2=0)

lab values HHown_item  Yes_no
keep household_id asset_cd HHown_item
replace HHown_item=0 if HHown_item==.
reshape wide HHown_item, i( household_id) j( asset_cd)
save "$temp\asset_type", replace

*** houseing 

use "$indir\sect10a_hh_w4 HOUSING", clear  


order s10aq08 s10aq09 s10aq10 s10aq12  s10aq27 s10aq21 s10aq20 s10aq06 s10aq07,after ( s10aq38 )
order s10aq34 s10aq38,after ( s10aq07 )
for var s10aq08- s10aq38:replace X=. if X==.a
for var s10aq08 - s10aq38 : tabulate X , gen(X )
save "$temp\asset_houseing_household", replace

merge 1:1 household_id using "C:\Users\SAlemu\Desktop\ESS4_2018-19\Innovation_2018\covariates_2018\Analysis\asset_type.dta"
edit if _merge==1
keep if _merge==3

drop  s10aq271 - s10aq2716
save "$temp\assettype_houseing", replace


pca  s10aq081- HHown_item35  s10aq06 , comp(1)
predict asset
sum asset
xtile asset_index=asset, nq(5)
table asset_index, c(mean asset)
keep household_id asset asset_index
compress
save "$temp\asse_index", replace


***productive-asset

use "$indir\sect11_hh_w4_asset", clear 

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
table prod_asset_index, c(mean asset)
keep household_id asset_prod prod_asset_index
compress

save "$temp\prod-asse_index", replace

**************************************************************

* plot level- W4-S4

* ***her_pes  

use "$indir\sect4_pp_w4", clear 

order s4q04 s4q05 s4q06 s4q07,after ( s4q26 )

for var s4q04 s4q05 s4q06 s4q07: recode  X (2=0)

for var s4q04 s4q05 s4q06 s4q07: label define X 1 "Yes" 0 "No", replace
for var s4q04 s4q05 s4q06 s4q07: label values X X 

save "$temp\her_pes_fung_mod", replace

collapse (max)s4q04 s4q05 s4q06 s4q07, by (household_id)

label variable s4q04 "Was prevention/ precaution measure taken to prevent damage of [CROP]"
label variable s4q05 "Did you use any pesticide to prevent damage of [CROP] on this field?"
label variable s4q06 "Did you use any herbicide to prevent damage of [CROP] on this field?"
label variable s4q07 "Did you use any fungicide to prevent damage of [CROP] on this field?"
 save "$temp\her_pes_fung_hh_level", replace

*** plot level- W4-S2

use "$indir\sect2_pp_w4", clear 

order s2q16,after ( s2q17 )
order s2q03,after ( s2q16_other )
recode s2q16 (7=6)
recode s2q03 (2=0)
label define Yes_no 1 "Yes" 0 "No", replace
lab values s2q03  Yes_no
tabulate s2q17, gen ( s2q17 )
tabulate s2q16, gen ( s2q16)

*** devation from mean- plot level???
 plot level soil quality
egen s2q171_ea = mean ( s2q171 ),by ( ea_id )

egen s2q172_ea = mean ( s2q172 ),by ( ea_id )
egen s2q173_ea = mean ( s2q173 ),by ( ea_id )

gen s2q171_deveam = s2q171_ea - s2q171
gen s2q172_deveam = s2q172_ea - s2q172
gen s2q173_deveam = s2q173_ea - s2q173

 save "$temp\W4_S2_Cleaned", replace
 
 use "$temp\W4_S2_Cleaned", replace
collapse (max) s2q03 (mean) s2q171 s2q172 s2q173 s2q161 s2q162 s2q163 s2q164 s2q165 s2q166, by ( household_id )
label variable s2q03 "Does your household have a document for this [PARCEL], such as a title deed,"
label variable s2q171 "% of plot with good soil quality"
label variable s2q172 "% of plot with fair soil quality"
label variable s2q173 "% of plot with poor soil quality"
label variable s2q161 "% of plot with Leptosol  soil type"
label variable s2q162 "% of plot with Cambisol  soil type"
label variable s2q163 "% of plot with Vertisol soil type"
label variable s2q164 "% of plot with Luvisol soil type"
label variable s2q165 "% of plot with mixed soil type"
label variable s2q166 "% of plot with other soil type"

save "$temp\W4_S2_hhlevel", replace


**** *** plot level- W4-S3

use "$indir\sect3_pp_w4", clear 

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

recode fild_prpa (2=1)(4=3)

tab fild_prpa, gen ( fild_prpa )
order fild_prpa1- fild_prpa4,after ( fild_prp )
order fild_prpa,after ( s3q35 )

order s3q05,after ( fild_prpa6 )
fre s3q05
order s3q16 s3q17,after ( s3q05 )


gen fert_orginor =1 if s3q21==1 | s3q22==1| s3q23==1 | s3q24==1| s3q25==1 |s3q26==1 |s3q27==1
replace fert_orginor =0 if s3q21==2 & s3q22==2 & s3q23==2 & s3q24==2 & s3q25==0 & s3q26==2 & s3q27==2

order s3q03,after ( fild_prpa6 )
order fert_orginor,after ( s3q03 )
order fert_orginor,after ( s3q17 )
order s3q25,after ( fert_orginor )

gen inorgfer =1 if s3q21==1 | s3q22==1| s3q23==1 | s3q24==1
replace inorgfer =0 if s3q21==2 & s3q22==2 & s3q23==2 & s3q24==2


label variable fert_orginor "Is fertilizer used - both org and inorganic"
label variable fert_orginor "Is fertilizer used - both org and inorganic?"
label variable inorgfer "Only inorganic fer"
gen s3q03_Cult= 1 if s3q03==1
replace s3q03_Cult =0 if s3q03!=1 & s3q03!=.a
order s3q03_Cult,after ( s3q03 )
label variable s3q03_Cult "3.During this season, what is the status of this [FIELD]?"
order s3q03,after ( s3q35 )

gen s3q42_redid =1 if s3q42>=3 & s3q42!=.
replace s3q42_redid =0 if s3q42<3
label variable s3q42_redid "Crop Residue Cover"
order s3q42,after ( fild_prpa )

for var s3q05 s3q16 s3q17: recode X (2=0)

label define Yes_no 1 "Yes" 0 "No", replace

for var s3q05 s3q16 s3q17: lab values X Yes_no
order s3q25,after ( inorgfer )

for var s3q25: recode X (2=0)

label define Yes_no 1 "Yes" 0 "No", replace

for var s3q25: lab values X Yes_no

replace s3q05=. if s3q03_Cult==0
replace s3q05=0 if s3q03_Cult==1 & s3q05==.


egen s3q121_ea = mean ( s3q121 ),by ( ea_id )
egen s3q122_ea = mean (s3q122 ),by ( ea_id)
egen s3q123_ea = mean ( s3q123 ),by ( ea_id)

gen s3q121_deveam = s3q121_ea - s3q121
gen s3q122_deveam = s3q122_ea - s3q122
gen s3q123_deveam = s3q123_ea - s3q123

order s3q121_deveam- s3q123_deveam,after ( s3q123 )
drop s3q121_ea- s3q123_ea
label variable fild_prp "Was [FIELD] prepared for planting? yes, no"
save "$temp\W4_S3_cleaned", replace

use "$temp\W4_S3_cleaned", replace

collapse (sum) parcesizeHA (mean) s3q121 s3q122 s3q123 (max) fild_prp (mean) fild_prpa1 fild_prpa2 fild_prpa3 fild_prpa4 (max) s3q03_Cult s3q05 s3q16 s3q17 fert_orginor inorgfer s3q25 s3q42_redid, by ( household_id )


label variable parcesizeHA "parcesizeHA"
label variable s3q121 "% of plot with Flat field appearance"
label variable s3q122 "% of plot with Sloppy - Moderate field appearance"
label variable s3q123 "% of plot with  Sloppy - Steep field appearance"

label variable fild_prp "Was [FIELD] prepared for planting? "

label variable fild_prpa1 "% of plot prepared by Tractor"
label variable fild_prpa2 "% of plot prepared by Animal"
label variable fild_prpa3 "% of plot prepared by Digging hand"
label variable fild_prpa4 "% of plot prepared by other methods"

label variable s3q03_Cult "During this season, what is the status of this [FIELD]?"
label variable s3q05 "Was the field left fallow anytime during the past 5 years?"
label variable s3q16 "Is  [FIELD] under Extension Program during the current agricultural season?"
label variable s3q17 "Is [FIELD] irrigated during the current agricultural season?"
label variable fert_orginor "Is fertilizer used   both org and inorganic?"
label variable inorgfer "Only inorganic fert"
label variable s3q25 "Do you use any manure on [FIELD] in this agricultural season?"
label variable s3q42_redid "Crop Residue cover"
save "$temp\W4_S3_hhlevel", replace


*** ESS4- HH LEVEL DATA- SOILE QULAITY


egen s2q171_ea = mean ( s2q171 ),by ( ea_id )

egen s2q172_ea = mean ( s2q172 ),by ( ea_id )
egen s2q173_ea = mean ( s2q173 ),by ( ea_id )

gen s2q171_deveam = s2q171_ea - s2q171
gen s2q172_deveam = s2q172_ea - s2q172
gen s2q173_deveam = s2q173_ea - s2q173


*** ESS4- HH LEVEL DATA- file apperance

egen s3q121_ea = mean ( s3q121 ),by ( ea_id )
egen s3q122_ea = mean (s3q122 ),by ( ea_id)
egen s3q123_ea = mean ( s3q123 ),by ( ea_id)

gen s3q121_deveam = s3q121_ea - s3q121
gen s3q122_deveam = s3q122_ea - s3q122
gen s3q123_deveam = s3q123_ea - s3q123


** merging plot level
*w4_s3

egen uni_id = concat( holder_id Parcelroster__id Fieldroster__id )
order uni_id
duplicates report uni_id
duplicates drop uni_id, force
duplicates report uni_id
label variable uni_id "concat( holder_id Parcelroster__id Fieldroster__id )"
egen uni_id2 = concat( holder_id Parcelroster__id )
order uni_id2
label variable uni_id2 " concat( holder_id Parcelroster__id )"
duplicates report uni_id2

use "C:\Users\SAlemu\Desktop\ESS4_2018-19\Innovation_2018\covariates_2018\Analysis\plot_level\merging\W4_S3_S4.dta"
merge m:1 uni_id2 using "C:\Users\SAlemu\Desktop\ESS4_2018-19\Innovation_2018\covariates_2018\Analysis\plot_level\merging\W4_S2_Cleaned_v2.dta"
keep if _merge==3
fre _merge
order s2q17 s2q16,after ( s2q16_other )
order  PLOT_LEVEL parcesizeHA s3q121 s3q122 s3q123 s3q121_deveam s3q122_deveam s3q123_deveam fild_prp fild_prpa1 fild_prpa2 fild_prpa3 fild_prpa4 s3q03_Cult s3q05 s3q16 s3q17 fert_orginor inorgfer s3q25 s3q42_redid,after ( s2q16 )
order s4q04- s4q07,after ( s2q166 )


*** gen region and regio2

gen region = 1 if saq01 ==1 | saq01==3 | saq01==4 | saq01==7
replace region = 2 if region==.
lab define region 1 "Four main regions" 2 "Other regions",replace
lab values region region
fre region



**region2

gen region2= saq01
order region2, after ( saq01 )
fre region2
fre saq01
replace region2=.
replace region2 =1 if saq01==1
replace region2 =2 if saq01==3
replace region2 =3 if saq01==4
replace region2 =4 if saq01==7

replace region2=5 if region==2
lab define region2 1 "Tigray" 2 "Amhara" 3 "Oromia" 4 "snnp " 5 "other regions", replace
lab values region2 region2
fre region2
order region, after (region2)

}

{/* descripitve part HH _LEVEL*/

winsor2 age_head , replace cuts(1 99)

winsor2 hh_size , replace cuts(1 99)

*** correction
replace inorgfer=. if fert_orginor==0
replace s3q25 =. if fert_orginor==0

replace s3q42_redid=. if s3q03_Cult==0
replace s3q42_redid =0 if s3q03_Cult==1 & s3q42_redid ==.

** comm
for var cs9q01 cs6q01 cs6q10 cs4q08 cs4q11 cs4q14: recode X (2=0)
for var cs9q01 cs6q01 cs6q10 cs4q08 cs4q11 cs4q14: label define X 1 "Yes" 0 "No", replace
for var cs9q01 cs6q01 cs6q10 cs4q08 cs4q11 cs4q14: label values X X


gen Plot_owned = 0 if saq14==2
order  Plot_owned ,after ( INFORMAION_PLOT_LEVEL )
fre Plot_owned
replace Plot_owned=0 if
fre s3q03_Cult
replace Plot_owned = o if s3q03_Cult==.
replace Plot_owned = 0 if s3q03_Cult==.
replace Plot_owned = 1 if Plot_owned ==.
fre Plot_owned
sum Plot_owned


**************************************************comments from Karen


** pest and her
for var s4q05- s4q07: replace X =0 if s4q04==0
sum s4q04 s4q05 s4q06 s4q07

*** for fertilizer

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


replace s3q35_other = subinstr(s3q35_other, " ", "", .)

label variable fild_prpa1 "fild_prpa==1. USING OWN/rented TRACTOR"
label variable fild_prpa2 "fild_prpa==3. USING OWNED/rented/borrowed LIVESTOCK"

replace fild_prpa= 3 if s3q35_other == "BORROWEDOXEN"
replace fild_prpa= 3 if s3q35_other == "PARENTS/RELATIVESOXEN"
replace fild_prpa= 3 if s3q35_other == "RENTEDOXEN(HAYWILLBEGIVENTOTHEOWNER)"
replace fild_prpa= 3 if s3q35_other == "SHAREDOXEN"
replace fild_prpa= 3 if s3q35_other == "USINGLANDLORD'SOXEN"
replace fild_prpa= 3 if s3q35_other == "USINGOTHERLIVESTOCKS(HOURSE)"
replace fild_prpa= 5 if s3q35_other == "HANDTOOLS"

drop fild_prpa1 fild_prpa2 fild_prpa3 fild_prpa4
tab fild_prpa, gen ( fild_prpa )
order fild_prpa1- fild_prpa4,after ( fild_prp )
order fild_prpa,after ( s3q35 )

label variable parcesizeHA "FieldsizeHA"

** community level- plot level info

*W4_S3_Cleaned- for Community level

collapse  (mean) parcesizeHA s3q121 s3q122 s3q123 (max) fild_prp (mean) fild_prpa1 fild_prpa2 fild_prpa3 fild_prpa4 (max) s3q03_Cult s3q05 s3q16 s3q17 fert_orginor fert_orginor_both inorgfer s3q25 s3q42_redid, by (ea_id )

** lables

label variable parcesizeHA "Average field size in ha"
label variable s3q121 "% of plot with Flat field appearance"
label variable s3q122 "% of plot with Sloppy - Moderate field appearance"
label variable s3q123 "% of plot with  Sloppy - Steep field appearance"

label variable fild_prp "Was [FIELD] prepared for planting? "

label variable fild_prpa1 "% of plot prepared by Tractor"
label variable fild_prpa2 "% of plot prepared by Animal"
label variable fild_prpa3 "% of plot prepared by Digging hand"
label variable fild_prpa4 "% of plot prepared by other methods"

label variable s3q03_Cult "During this season, what is the status of this [FIELD]?"
label variable s3q05 "Was the field left fallow anytime during the past 5 years?"
label variable s3q16 "Is  [FIELD] under Extension Program during the current agricultural season?"
label variable s3q17 "Is [FIELD] irrigated during the current agricultural season?"
label variable fert_orginor_both "Is fertilizer used both org and  inorganic?"
label variable fert_orginor "Is fertilizer used org or inorganic?"
label variable inorgfer "Only inorganic fert"
label variable s3q25 "Do you use any manure on [FIELD] in this agricultural season?"
label variable s3q42_redid "Crop Residue cover"


***W4_S2_Cleaned- for Community level

collapse (max) s2q03 (mean) s2q171 s2q172 s2q173 s2q161 s2q162 s2q163 s2q164 s2q165 s2q166, by ( ea_id  )
label variable s2q03 "Does your household have a document for this [PARCEL], such as a title deed,"
label variable s2q171 "% of plot with good soil quality"
label variable s2q172 "% of plot with fair soil quality"
label variable s2q173 "% of plot with poor soil quality"
label variable s2q161 "% of plot with Leptosol  soil type"
label variable s2q162 "% of plot with Cambisol  soil type"
label variable s2q163 "% of plot with Vertisol soil type"
label variable s2q164 "% of plot with Luvisol soil type"
label variable s2q165 "% of plot with mixed soil type"
label variable s2q166 "% of plot with other soil type"

****W4_S2_Cleaned- for Community level

collapse (max)s4q04 s4q05 s4q06 s4q07, by ( ea_id)

label variable s4q04 "Was prevention/ precaution measure taken to prevent damage of [CROP]"
label variable s4q05 "Did you use any pesticide to prevent damage of [CROP] on this field?"
label variable s4q06 "Did you use any herbicide to prevent damage of [CROP] on this field?"
label variable s4q07 "Did you use any fungicide to prevent damage of [CROP] on this field?"
