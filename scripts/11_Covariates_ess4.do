********************************************************************************
*                           Ethiopia Synthesis Report 
*                                11_Covariates_ess4
* Country: Ethiopia 
* Data: ESS4 
* Author: Paola Mallia | p.mallia@cgiar.org | paola_mallia@ymail.com 
* STATA Version: SE 16.1
********************************************************************************

********* Importing dashboard locations ****************************************
import excel "${rawdata}${slash}Dashboard locations${slash}Dashboard_distances_toimport.xlsx", sheet("ESS.Distances") firstrow allstring clear

foreach i in Dist_CG_LargeR N_20_CG_LargeR N_50_CG_LargeR N_100_CG_LargeR Dist_CG_SmallR N_20_CG_SmallR N_50_CG_SmallR N_100_CG_SmallR Dist_CG_chicken N_20_CG_chicken N_50_CG_chicken N_100_CG_chicken Dist_CG_Avocado N_20_CG_Avocado N_50_CG_Avocado N_100_CG_Avocado Dist_CG_DTMZ N_20_CG_DTMZ N_50_CG_DTMZ N_100_CG_DTMZ Dist_CG_CA N_20_CG_CA N_50_CG_CA N_100_CG_CA Dist_CG_OFSP N_20_CG_OFSP N_50_CG_OFSP N_100_CG_OFSP Dist_CG_NUME N_20_CG_NUME N_50_CG_NUME N_100_CG_NUME Dist_CG_SLM N_20_CG_SLM N_50_CG_SLM N_100_CG_SLM Dist_CG_Barley N_20_CG_Barley N_50_CG_Barley N_100_CG_Barley Dist_CG_Sorghum N_20_CG_Sorghum N_50_CG_Sorghum N_100_CG_Sorghum {
    
destring `i', force replace

}

lab var Dist_CG_chicken "Distance to closest area of CG activitiies - Poultry crossbred"
lab var Dist_CG_LargeR  "Distance to closest area of CG activitiies - Large ruminants crossbred"
lab var Dist_CG_SmallR  "Distance to closest area of CG activitiies - Small ruminants crossbred"
lab var Dist_CG_Barley  "Distance to closest area of CG activitiies - Public Private Partnership for barley seed dissemination"
lab var Dist_CG_Sorghum "Distance to closest area of CG activitiies - Improved sorghum varieties"
lab var Dist_CG_DTMZ    "Distance to closest area of CG activitiies - DTMZ varieties"
lab var Dist_CG_NUME    "Distance to closest area of CG activitiies - QPM varieties"
lab var Dist_CG_OFSP    "Distance to closest area of CG activitiies - OFSP"
lab var Dist_CG_Avocado "Distance to closest area of CG activitiies - Avocado trees"
lab var Dist_CG_CA      "Distance to closest area of CG activitiies - Conservation Agriculture"
lab var Dist_CG_SLM     "Distance to closest area of CG activitiies - Watershed level SLM"


drop saq01


save "${data}${slash}dashboard_locations", replace

****************************
*ESS4 - years of education *
****************************

use "${raw4}${slash}HH${slash}sect2_hh_w4", clear

g       yrseduc=.
replace yrseduc=0  if s2q06==0
replace yrseduc=1  if s2q06==1
replace yrseduc=2  if s2q06==2
replace yrseduc=3  if s2q06==3
replace yrseduc=4  if s2q06==4
replace yrseduc=5  if s2q06==5
replace yrseduc=6  if s2q06==6
replace yrseduc=7  if s2q06==7
replace yrseduc=8  if s2q06==8
replace yrseduc=9  if s2q06==9
replace yrseduc=10 if s2q06==10
replace yrseduc=11 if s2q06==11
replace yrseduc=12 if s2q06==12
replace yrseduc=13 if s2q06==13
replace yrseduc=13 if s2q06==14
replace yrseduc=13 if s2q06==15
replace yrseduc=14 if s2q06==16
replace yrseduc=13 if s2q06==17
replace yrseduc=15 if s2q06==18
replace yrseduc=13 if s2q06==19
replace yrseduc=17 if s2q06==20
replace yrseduc=9  if s2q06==21
replace yrseduc=10 if s2q06==22
replace yrseduc=11 if s2q06==23
replace yrseduc=12 if s2q06==24
replace yrseduc=11 if s2q06==25
replace yrseduc=12 if s2q06==26
replace yrseduc=12 if s2q06==27
replace yrseduc=13 if s2q06==28
replace yrseduc=13 if s2q06==29
replace yrseduc=13 if s2q06==30
replace yrseduc=13 if s2q06==31
replace yrseduc=14 if s2q06==32
replace yrseduc=15 if s2q06==33
replace yrseduc=16 if s2q06==34
replace yrseduc=17 if s2q06==35
replace yrseduc=0  if s2q06==93
replace yrseduc=0  if s2q06==94
replace yrseduc=0  if s2q06==95
replace yrseduc=0  if s2q06==96
replace yrseduc=0  if s2q06==98
lab var yrseduc "HH-head years of education completed"


keep household_id individual_id yrseduc


merge 1:1 household_id individual_id using "${raw4}${slash}HH${slash}sect1_hh_w4"
keep if _m==3
drop _merge

keep if s1q01==1

collapse (max) yrseduc, by(household_id)
lab var yrseduc "HH-head years of education completed"


replace yrseduc=0 if yrseduc==.

tempfile educ_w4
save `educ_w4'


*******************************************************************************
* HH Demo groups
********************************************************************************
use "${raw4}${slash}HH${slash}sect1_hh_w4", clear
bys household_id : egen hh_size=count(individual_id)

collapse (max)   hh_size, by(household_id)

tempfile agegroup
save `agegroup'


****************************************
* Female family farm Labor             *
****************************************

* Land preparation, planting, fertilizer application etc. - PP survey
use "${raw4}${slash}PP${slash}sect3_pp_w4", clear

rename s3q29a s3q29_1
rename s3q29e s3q29_2
rename s3q29i s3q29_3
rename s3q29m s3q29_4


reshape long s3q29_, i(holder_id household_id parcel_id field_id) j(membernb)

drop if s3q29_==.a & (s3q28==. | s3q28==0 )

rename  s3q29_ s1q00
merge m:1 holder_id household_id s1q00 using  "${raw4}${slash}PP${slash}sect1_pp_w4"

drop if _m==2
drop _merge

bys household_id parcel_id field_id: egen fhhlab1=count(s1q00) if s1q03==2 & s1q02>=15

merge m:1 household_id using `agegroup', keepusing(hh_size)
drop if _m==2
drop _merge

g  sh_fhhlab1=fhhlab1/hh_size 
bys household_id parcel_id field_id: egen sh_fhhlab2=max(sh_fhhlab1)

by household_id: egen sh_fhhlabmax=max(sh_fhhlab2)
by household_id: egen sh_fhhlabmin=min(sh_fhhlab2)
by household_id: egen sh_fhhlabavg=mean(sh_fhhlab2)

collapse (firstnm) sh_fhhlabmax sh_fhhlabmin sh_fhhlabavg, by(household_id)


rename sh_fhhlabmax sh_fhhlabmax1
rename sh_fhhlabmin sh_fhhlabmin1
rename sh_fhhlabavg sh_fhhlabavg1

lab var sh_fhhlabmax1 "Share of female family labor - Land prep., planting,etc - Max"
lab var sh_fhhlabmin1 "Share of female family labor - Land prep., planting,etc - Min"
lab var sh_fhhlabavg1 "Share of female family labor - Land prep., planting,etc - Avg"


foreach i in sh_fhhlabmax1 sh_fhhlabmin1 sh_fhhlabavg1 {
replace `i' =0 if `i' ==.
}

g       hhd_flab=.
replace hhd_flab=0 if sh_fhhlabavg1<0.5
replace hhd_flab=1 if sh_fhhlabavg1>=0.5
lab var hhd_flab "Share of female family labor >50%"



tempfile  hhfamlab1
save     `hhfamlab1'


****************************************
* FEMALE LIVESTOCK OWNERS AND MANAGERS *
****************************************


use "${raw4}${slash}LS${slash}sect8_1_ls_w4", clear
*Owner
preserve
reshape long  ls_s8_1q04_, i(holder_id household_id ls_code) j(membernb)

drop if ls_s8_1q04_==.
drop if ls_s8_1q04_==.a

rename  ls_s8_1q04_ s1q00
merge m:1 holder_id household_id s1q00 using  "${raw4}${slash}PP${slash}sect1_pp_w4"
keep if _m==3
drop _merge

g flivown1=0 
replace flivown1=1 if s1q03==2
bys household_id: egen flivown=max(flivown1)
drop flivown1
lab var flivown "Female livestock owner"

rename   s1q00 ls_s8_1q04__
drop membernb
collapse (max) flivown (firstnm) ea_id  saq14, by(household_id)
lab var flivown "Female livestock owner"
tempfile flivown

save `flivown'
restore

*Manager
reshape long ls_s8_1q05_, i( holder_id household_id ls_code) j(membernb)

drop if ls_s8_1q05_==.
drop if ls_s8_1q05_==.a

rename  ls_s8_1q05_ s1q00
merge m:1 holder_id household_id s1q00 using  "${raw4}${slash}PP${slash}sect1_pp_w4"

keep if _m==3
drop _merge

g       flivman1=.
replace flivman1=0 if s1q03==1
replace flivman1=1 if s1q03==2
bys household_id: egen flivman=max(flivman1)
drop flivman1




rename   s1q00 ls_s8_1q05_
drop membernb

collapse (max) flivman (firstnm) ea_id  saq14, by(household_id)

lab var flivman "At least 1 female livestock manager/keeper in the hh"
tempfile flivman
save `flivman'




********************************************************************************
* Covariates produced by Solomon
********************************************************************************
use "${cov4hh}${slash}HH_LEVEL_DATA_2018", clear

* Variable labelling
lab var sex_head      "HH-head is male"
lab var age_head      "HH-head age in years"
lab var educ_head_att "HH-head attended school"
lab var educ_head_fr  "HH-head formal education"
rename  Marital_head2 marr_head
lab var marr_head     "HH-head is married"
rename  mainoc_head2 agr_head 
lab var agr_head      "HH-head main occupation is agriculture"
rename  asset_index asset_quint
lab var asset_quint   "Asset index - quintiles"
rename  asset asset_index
lab var asset_index   "Asset index"
rename  asset_prod pssetindex
lab var pssetindex    "Productive asset index"
rename  prod_asset_index prodasset_quint
lab var prodasset_quint "Productive asset index - quintiles"
rename s12aq01__1 nonfarm_bus
lab var nonfarm_bus   "HH owns non-farm business"
rename s13q01 offfarminc
lab var offfarminc    "HH received off-farm income"
rename s13q02 income_offfarm
lab var income_offfarm "Annual Off-farm income in BIRR"
lab var parcesizeHA   "Total parcels size in HA per hh"

g       fem_head=.
replace fem_head=0 if sex_head==1
replace fem_head=1 if sex_head==0

lab var fem_head "HH-head is female"

*******Merge with vars produced in this do file *

merge 1:1 household_id using `educ_w4'
drop _merge


merge 1:1 household_id using `agegroup'
drop _merge

merge 1:1 household_id using "${data}${slash}ess4_hh_psnp"
keep if _m==3
drop _m


*Add consumption aggregates *
merge 1:1 household_id using "${raw4}${slash}HH${slash}cons_agg_w4"

drop _merge


merge 1:1 household_id using "${data}${slash}ess4_pp_hhlevel_parcel_new"
drop if _m==2
drop _m

g consq1=0 if cons_quint>1
replace consq1=1 if cons_quint==1

g consq2=0 if cons_quint>2
replace consq2=1 if cons_quint==1 | cons_quint==2
lab var consq1 "Bottom 1 consumption quintile" 
lab var consq2 "Bottom 1-2 (<40%) consumption quintiles"




save "${data}${slash}HH_LEVEL_DATA_2018_relab", replace

********************************************************************************
*** Innovation dataset: produced in 3_PP_CG_innovation_ess4
********************************************************************************

use "${data}${slash}ess4_pp_hh_new", clear //INNOVATIONS DATASET 
merge 1:1 household_id using `hhfamlab1'
drop if _m==2
drop _merge

merge 1:1 household_id using `flivown'
drop if _m==2
drop _merge

merge 1:1 household_id using `flivman'
drop if _m==2
drop _m

drop  saq13
merge 1:1 household_id using  "${data}${slash}HH_LEVEL_DATA_2018_relab" // Data created in : Do ESS4_2018_dofile__Public

keep if _m==3 | _m==1
drop _m
replace wave=4
drop region
clonevar region=saq01

replace region=0 if region==2 | region==6 | region==15 | region==12 | region==13 | region==5

rename hhd_cross_largerum hhd_crlr
rename hhd_cross_smallrum hhd_crsr
rename hhd_cross_poultry  hhd_crpo
g       hhd_feed=.
replace hhd_feed=0 if hhd_elepgrass==0 & hhd_gaya==0 & hhd_sasbaniya==0 & hhd_alfa==0
replace hhd_feed=100 if hhd_elepgrass==100 | hhd_gaya==100 | hhd_sasbaniya==100 | hhd_alfa==100

merge 1:1 household_id using "${data}${slash}ess4_dna_hh_new" 


drop if _m==2
drop _m

*Winsorize
sum total_cons_ann, d
g total_cons_ann_win=total_cons_ann
sum total_cons_ann, d
replace total_cons_ann_win=r(p99) if total_cons_ann_win>r(p99)

lab var total_cons_ann_win "Total annual consumption - winsorize"

save "${data}${slash}ess4_pp_cov_new", replace // HH-level 



********************************************************************************
* PLOT LEVEL - ess4
********************************************************************************
use "${cov4plot}${slash}Merged_PP_data_2018", clear // Solomon data
rename Parcelroster__id parcel_id	
rename Fieldroster__id field_id

collapse (max) s3q121 s3q122 s3q123  s3q05 fild_prpa1 fild_prpa2 fild_prpa3 fild_prpa4 s4q05 s4q06 s4q07, by(household_id parcel_id field_id)

lab var s3q121         "Field appearance: Flat"
lab var s3q122         "Field appearance: Sloppy - Moderate"
lab var s3q123         "Field appearance: Sloppy - Steep"
lab var s3q05          "Field left fallow in the last 10 years"
lab var fild_prpa1     "Field preparation: Tractor"
lab var fild_prpa2     "Field preparation: Animal"
lab var fild_prpa3     "Field preparation: Digging by hand"
lab var fild_prpa4     "Field preparation: other" 
lab var s4q05          "Incidence of pesticide use"
lab var s4q06          "Incidence of herbicide use"
lab var s4q07          "Incidence of fungicide use"

merge 1:1  household_id parcel_id field_id using  "${data}${slash}w4_plotlevel_pp_new"


drop if _m==1
drop _merge


* Plot level data ready

g wave=4
drop region
clonevar region=saq01

replace region=0 if region==2 | region==6 | region==15 | region==12 | region==13 | region==5

* INNOVATIONS *

save "${data}${slash}ess4_pp_cov_plot_new", replace




********************************************************************************
* EA level
********************************************************************************


use "${cov4com}${slash}com_level_S3_S4_S6_S9_APRIL16_V2.dta", clear

merge 1:1 ea_id using "${data}${slash}ess4_pp_ea_new"
keep if _m==3
drop _m

lab var cs9q01               "PSNP operated in this kebele" //bin
lab var cs9q13               "No. of hhs that graduated from PSNP"
lab var cs9q13_WIZ           "No. of hhs that graduated from PSNP - winsorized"
rename cs9q13_WIZ cs9q13wiz
lab var cs9q14               "% of hhs that graduated from PSNP"

lab var cs6q01               "Hhs farm crops or keep livestock in this community" 

lab var cs6q10               "Irrigation scheme in the community"
lab var cs6q11               "No. of farmers in community irrigation scheme"   
lab var cs6q11_WIZ           "No. of farmers in community irrigation scheme - winsorized"
rename cs6q11_WIZ cs6q11wiz
lab var cs6q12_11            "Major source of fertilizer in the community: Government" //bin
lab var cs6q12_12            "Major source of fertilizer in the community: Private dealer" //bin
lab var cs6q12_13            "Major source of fertilizer in the community: Union" //bin
lab var cs6q12_14            "Major source of fertilizer in the community: Other" //bin

lab var cs6q13_11            "Major source of pesticides/herbicides in the community: Government" //bin
lab var cs6q13_12            "Major source of pesticides/herbicides in the community: Private dealer" //bin
lab var cs6q13_13            "Major source of pesticides/herbicides in the community: Union" //bin
lab var cs6q13_14            "Major source of pesticides/herbicides in the community: Other" //bin


lab var cs6q14_11            "Major source of hybrid seeds in the community: Government" //bin
lab var cs6q14_12            "Major source of hybrid seeds in the community: Private dealer" //bin
lab var cs6q14_13            "Major source of hybrid seeds in the community: Union" //bin
lab var cs6q14_14            "Major source of hybrid seeds in the community: Other" //bin

lab var cs6q15_11            "Type of facility used to store crops prior to sale: traditional" //bin
lab var cs6q15_12            "Type of facility used to store crops prior to sale: modern" //bin
lab var cs6q15_13            "Type of facility used to store crops prior to sale: other" //bin


lab var cs4q02               "Distance to the nearest tar/asphalt road (KM)"
lab var cs4q02_wiz           "Distance to the nearest tar/asphalt road (KM) - winsorized"
rename cs4q02_wiz cs4q02wiz
lab var cs4q011              "Type of main access road surfarce: tar/asphalt" //bin
lab var cs4q012              "Type of main access road surfarce: graded graveled" //bin
lab var cs4q013              "Type of main access road surfarce: dirt road (maintained)" //bin
lab var cs4q014              "Type of main access road surfarce: dirt track" //bin

lab var cs4q03               "Vehicles pass on the main road throughout the year" //bin

lab var cs4q08               "Community is a woreda town"                                //bin
lab var cs4q09               "Distance to the nearest Woreda/town (KM)"
lab var cs4q09_wiz           "Distance to the nearest Woreda/town (KM) - winsorized"
rename  cs4q09_wiz cs4q09wiz
lab var cs4q11               "Community is a major urban center (Regional or Zonal Capital)" //bin
lab var cs4q12b              "Distance to the major urban center (KM)"
lab var cs4q12b_wiz          "Distance to the major urban center (KM) - winsorized" 
rename  cs4q12b_wiz cs4q12bwiz
lab var cs4q14               "Large weekly market in this community" //bin
lab var cs4q15 				 "Distance to the nearest large weekly market (KM)"
lab var cs4q15_wiz 			 "Distance to the nearest large weekly market (KM) - winsorized"
rename  cs4q15_wiz cs4q15wiz

lab var cs3q02                "Population size in the community"
lab var cs3q02_WIZ            "Population size in the community - winsorized"
rename  cs3q02_WIZ cs3q02wiz
lab var cs4q52               "Incidence of SACCO in the community" //bin
lab var cs4q53               "Distance to the nearest place where there is SACCO (Km)"
lab var cs4q53_WIZ           "Distance to the nearest place where there is SACCO (Km) - winsorized"
rename  cs4q53_WIZ csdq53wiz

rename ead_cross_largerum ead_crlr
rename ead_cross_smallrum ead_crsr
rename ead_cross_poultry  ead_crpo

*Merging with info on PSNP created in do: 5_psnp
merge 1:1 ea_id using "${data}${slash}ess4_ea_psnp"

keep if _m==3
drop _m

* Merging with Locations and Distances of CG activities
merge 1:1 ea_id using  "${data}${slash}dashboard_locations"

drop if _m==2
drop _m
* Merging with DNA data created in do: 9_Crop varietal identification"
merge 1:1 ea_id using "${data}${slash}ess4_dna_ea_new"                         

drop if _m==2
drop _merge

foreach i in LargeR SmallR chicken Avocado DTMZ CA OFSP NUME SLM Barley Sorghum {
	
g       d25_`i'=0 if Dist_CG_`i'>25 & Dist_CG_`i'!=.  //25
replace d25_`i'=1 if Dist_CG_`i'<=25 & Dist_CG_`i'!=.	

g       d50_`i'=0 if Dist_CG_`i'>50 & Dist_CG_`i'!=.  //50
replace d50_`i'=1 if Dist_CG_`i'<=50 & Dist_CG_`i'!=.

g       d75_`i'=0 if Dist_CG_`i'>75 & Dist_CG_`i'!=.  //75
replace d75_`i'=1 if Dist_CG_`i'<=75 & Dist_CG_`i'!=.

g       d100_`i'=0 if Dist_CG_`i'>100 & Dist_CG_`i'!=.  //100
replace d100_`i'=1 if Dist_CG_`i'<=100 & Dist_CG_`i'!=.

g       d125_`i'=0 if Dist_CG_`i'>125 & Dist_CG_`i'!=.  //100
replace d125_`i'=1 if Dist_CG_`i'<=125 & Dist_CG_`i'!=.

g       d150_`i'=0 if Dist_CG_`i'>150 & Dist_CG_`i'!=.  //100
replace d150_`i'=1 if Dist_CG_`i'<=150 & Dist_CG_`i'!=.




}


lab var d25_LargeR      "Distance < 25 Km to CG activity - Large ruminants crossbred"
lab var d50_LargeR      "Distance < 50 Km to CG activity - Large ruminants crossbred"
lab var d75_LargeR      "Distance  < 75 Km to CG activity - Large ruminants crossbred"
lab var d100_LargeR     "Distance < 100 Km to CG activity - Large ruminants crossbred"
lab var d125_LargeR     "Distance < 125 Km to CG activity - Large ruminants crossbred"
lab var d150_LargeR     "Distance < 150 Km to CG activity - Large ruminants crossbred"



lab var d25_SmallR      "Distance < 25  Km to CG activity - Small ruminants crossbred" 
lab var d50_SmallR      "Distance < 50  Km to CG activity - Small ruminants crossbred" 
lab var d75_SmallR      "Distance < 75  Km to CG activity - Small ruminants crossbred" 
lab var d100_SmallR     "Distance < 100 Km to CG activity - Small ruminants crossbred" 
lab var d125_SmallR     "Distance < 125 Km to CG activity - Small ruminants crossbred" 
lab var d150_SmallR     "Distance < 150 Km to CG activity - Small ruminants crossbred" 


lab var d25_chicken     "Distance < 25 Km to CG activity - Poultry crossbred" 
lab var d50_chicken     "Distance < 50  Km to CG activity - Poultry crossbred" 
lab var d75_chicken     "Distance < 75  Km to CG activity - Poultry crossbred" 
lab var d100_chicken    "Distance < 100 Km to CG activity - Poultry crossbred" 
lab var d125_chicken    "Distance < 125 Km to CG activity - Poultry crossbred" 
lab var d150_chicken    "Distance < 150 Km to CG activity - Poultry crossbred" 


lab var d25_Avocado     "Distance  < 25 Km to CG activity - Avocado trees" 
lab var d50_Avocado     "Distance  < 50 Km to CG activity - Avocado trees" 
lab var d75_Avocado     "Distance  < 75 Km to CG activity - Avocado trees" 
lab var d100_Avocado    "Distance < 100 Km to CG activity - Avocado trees" 
lab var d125_Avocado    "Distance < 125 Km to CG activity - Avocado trees" 
lab var d150_Avocado    "Distance < 150 Km to CG activity - Avocado trees" 



lab var d25_DTMZ        "Distance < 25 Km to CG activity - DTMZ varieties" 
lab var d50_DTMZ        "Distance < 50 Km to CG activity - DTMZ varieties" 
lab var d75_DTMZ        "Distance < 75 Km to CG activity - DTMZ varieties" 
lab var d100_DTMZ       "Distance < 100 Km to CG activity - DTMZ varieties" 
lab var d125_DTMZ       "Distance < 125 Km to CG activity - DTMZ varieties" 
lab var d150_DTMZ       "Distance < 150 Km to CG activity - DTMZ varieties" 


lab var d25_CA          "Distance < 25 Km to CG activity -  Conservation Agriculture" 
lab var d50_CA          "Distance < 50 Km to CG activity - Conservation Agriculture" 
lab var d75_CA          "Distance < 75 Km to CG activity -  Conservation Agriculture" 
lab var d100_CA         "Distance < 100 Km to CG activity - Conservation Agriculture" 
lab var d125_CA         "Distance < 125 Km to CG activity -  Conservation Agriculture" 
lab var d150_CA         "Distance < 150 Km to CG activity - Conservation Agriculture" 


lab var d25_OFSP       "Distance  < 25  Km to CG activity - OFSP" 
lab var d50_OFSP       "Distance  < 50  Km to CG activity - OFSP"
lab var d75_OFSP       "Distance  < 75  Km to CG activity - OFSP" 
lab var d100_OFSP       "Distance < 100 Km to CG activity - OFSP"
lab var d125_OFSP       "Distance < 125 Km to CG activity - OFSP" 
lab var d150_OFSP       "Distance < 150 Km to CG activity - OFSP"




lab var d25_NUME       "Distance < 25 Km to CG activity - QPM varieties"
lab var d50_NUME       "Distance < 50 Km to CG activity - QPM varieties"
lab var d75_NUME       "Distance < 75 Km to CG activity - QPM varieties"
lab var d100_NUME       "Distance < 100 Km to CG activity - QPM varieties"
lab var d125_NUME       "Distance < 125 Km to CG activity - QPM varieties"
lab var d150_NUME       "Distance < 150 Km to CG activity - QPM varieties"


lab var d25_SLM        "Distance < 25  Km to CG activity - Watershed level SLM"
lab var d50_SLM        "Distance < 50  Km to CG activity - Watershed level SLM"
lab var d75_SLM        "Distance < 75  Km to CG activity - Watershed level SLM"
lab var d100_SLM       "Distance < 100 Km to CG activity - Watershed level SLM"
lab var d125_SLM       "Distance < 125 Km to CG activity - Watershed level SLM"
lab var d150_SLM       "Distance < 150 Km to CG activity - Watershed level SLM"



lab var d25_Barley     "Distance < 25  Km to CG activity - Public Private Partnership for barley"
lab var d50_Barley     "Distance < 50  Km to CG activity -Public Private Partnership for barley"
lab var d75_Barley     "Distance < 75  Km to CG activity - Public Private Partnership for barley"
lab var d100_Barley     "Distance < 100 Km to CG activity -Public Private Partnership for barley"
lab var d125_Barley     "Distance < 125 Km to CG activity - Public Private Partnership for barley"
lab var d150_Barley     "Distance < 150 Km to CG activity -Public Private Partnership for barley"





lab var d25_Sorghum    "Distance < 25 Km to CG activity - Improved sorghum varieties"
lab var d50_Sorghum    "Distance < 50 Km to CG activity -Improved sorghum varieties"
lab var d75_Sorghum    "Distance < 75 Km to CG activity - Improved sorghum varieties"
lab var d100_Sorghum   "Distance < 100 Km to CG activity -Improved sorghum varieties"
lab var d125_Sorghum   "Distance < 125 Km to CG activity - Improved sorghum varieties"
lab var d150_Sorghum   "Distance < 150 Km to CG activity -Improved sorghum varieties"
 

save "${data}${slash}ess4_pp_cov_ea_new", replace
