********************************************************************************
********************************************************************************
*                           Ethiopia Synthesis Report 
*                                4_PP_CG_innovation_ess3
* Country: Ethiopia 
* Data: ESS 3 
* Author: Paola Mallia | p.mallia@cgiar.org | paola_mallia@ymail.com 
* STATA Version: SE 16.1
* OUTPUT: Build variables for CGIAR INNOVATIONS
********************************************************************************

********************************************************************************

********************************************************************************
*LOCAL COVERSION UNIT FOR ESS3
********************************************************************************
use "${raw3}${slash}ET_local_area_unit_conversion.dta", clear

reshape wide conversion, i(region zone woreda) j(local_unit)
rename conversion3 conv_timad
rename conversion4 conv_boy
rename conversion5 conv_senga
rename conversion6 conv_kert


foreach i in timad boy senga kert {
bys region zone: egen conv_`i'_z=mean(conv_`i')
bys region: egen conv_`i'_r=mean(conv_`i')
}

save "${rawdata}${slash}Auxiliary_data${slash}ESS3_ET_local_area_unit_conversion", replace

********************************************************************************
* COVER - PP
******************************************************************************** 
use "${raw3}${slash}sect_cover_pp_w3", clear
count
//  3,830 - 3722 hhs - unique id: holder_id household_id2
// Rural hh:             3235
// Small town hh:         417
// Med and large town hh:  70

* Total No. of HH per EA
egen hh_ea=count(household_id2), by(ea_id)
lab var hh_ea "Nb. of hh per EA"
egen hh_ea_r=count(household_id2) if rural==1, by(ea_id)
lab var hh_ea_r "Nb. of hh per EA - RURAL"

keep household_id household_id2 holder_id rural pw_w3 ea_id saq01 saq02 saq03 saq04 saq05 saq06  hh_ea hh_ea_r

duplicates drop household_id household_id2 rural pw_w3 ea_id saq01 saq02 saq03 saq04 saq05 saq06 hh_ea hh_ea_r, force


tempfile w3_coverPP
save `w3_coverPP'
save "${data}${slash}w3_coverpp", replace


********************************************************************************
* PP - SECT. 2
********************************************************************************
use "${raw3}${slash}sect2_pp_w3", clear

g title=pp_s2q04==1
lab var title "HH has title for the parcel"


rename pp_s2q06_a pp_s2q06_0
rename pp_s2q06_b pp_s2q06_1


reshape long pp_s2q06_, i(holder_id household_id household_id2 parcel_id) j(membernb)

drop if pp_s2q06_==.a & title==1
rename  pp_s2q06_ pp_s1q00

merge m:1 holder_id household_id2 pp_s1q00 using  "${raw3}${slash}sect1_pp_w3"

drop if _m==2
drop _merge

g fow=1 if pp_s1q03==2
bys household_id pp_s1q00 parcel_id: egen fowner=max(fow) if title==1
replace fowner=0 if fowner==. & pp_s1q03==1
drop fow
lab var fowner "At lest 1 female hh-member listed as owner in parcel title"

rename pp_s1q00  pp_s2q06_
drop pp_s1*

keep if membernb==0
drop membernb
***

rename pp_s2q03c_a pp_s2q03c_0
rename pp_s2q03c_b pp_s2q03c_1

reshape long pp_s2q03c_, i(holder_id household_id household_id2 parcel_id) j(membernb)

drop if pp_s2q03c_==.a & pp_s2q03b==1

rename  pp_s2q03c_ pp_s1q00
merge m:1 holder_id household_id2 pp_s1q00 using "${raw3}${slash}sect1_pp_w3"
drop if _m==2
drop _merge

g fow=1 if pp_s1q03==2
bys household_id pp_s1q00 parcel_id: egen frsell=max(fow) if pp_s2q03b==1
replace frsell=0 if frsell==. & pp_s2q03b==1
drop fow
lab var frsell "At lest 1 female hh-member has the right to sell the parcel"

rename pp_s1q00  pp_s2q03c_
drop pp_s1*

keep if membernb==0
drop membernb


tab pp_s2q03, g(acqparc)
lab var acqparc1 "Parcel granted by local leaders"
lab var acqparc2 "Parcel acquired as gift/inherited"
lab var acqparc3 "Parcel rented"
lab var acqparc7 "Parcel purchased"
g acqparcoth=0
replace acqparcoth=1 if acqparc4==1 | acqparc5==1 | acqparc8==1
lab var acqparcoth "Parcel acquired through: other means"
lab var acqparc6   "Parcel shared crop"

tab pp_s2q15, g(soilq)
lab var soilq1 "Soil quality: Good"
lab var soilq2 "Soil quality: Fair"
lab var soilq3 "Soil quality: Poor"

tab pp_s2q14, g(soilt)
lab var soilt1 "Soil type: Leptosol"
lab var soilt2 "Soil type: Cambisol"
lab var soilt3 "Soil type: Vertisol"
lab var soilt4 "Soil type: Luvisol"
lab var soilt5 "Soil type: Mixed type"
lab var soilt6 "Soil type: other"

keep holder_id household_id household_id2 parcel_id pw_w3 pp_s2q00 title fowner frsell acqparc1 acqparc2 acqparc3 acqparc4 acqparc5 acqparc6 acqparc7 acqparc8 acqparcoth soilq1 soilq2 soilq3 soilt1 soilt2 soilt3 soilt4 soilt5 soilt6 saq01
preserve
collapse (max) title fowner frsell (firstnm) household_id pw_w3, by(household_id2)
lab var frsell "At lest 1 female hh-member has the right to sell the parcel"
lab var fowner "At lest 1 female hh-member listed as owner in parcel title"
lab var title "HH has title for the parcel"
save "${data}${slash}ess3_pp_hhlevel_parcel", replace
restore
save "${data}${slash}w3_sect2_pp_parcel", replace



********************************************************************************
*** PP_Sec.3 - NRM - 
********************************************************************************
*use "${raw3}${slash}PP_w3S3", clear
use "${raw3}${slash}sect3_pp_w3", clear


* Plot irrigated
g       plotirr=0
replace plotirr=1 if pp_s3q12==1

* IRRIGATION: LIMITING TO CULTIVATED PLOTS AS PER ENABLING CONDITION (IF IMPLEMENTED IN RIGHT WAY)
g       rdisp=.
replace rdisp=0 if (pp_s3q13b!=. | pp_s3q12==2) & pp_s3q03==1 //not this irrigation or no irrigation at all
replace rdisp=1 if pp_s3q13b==1                 & pp_s3q03==1 
 
g       treadle=.
replace treadle=0 if (pp_s3q13b!=. | pp_s3q12==2) & pp_s3q03==1 //not this irrigation or no irrigation at all.
replace treadle=1 if  pp_s3q13b==2                & pp_s3q03==1 

g       motorpump=.
replace motorpump=0 if (pp_s3q13b!=.  | pp_s3q12==2) & pp_s3q03==1  //not this irrigation or no irrigation at all.
replace motorpump=1 if  pp_s3q13b==3                 & pp_s3q03==1 
**************************************
* LEGUME ROTATION asked for all plots excluding homestead and other (q03)
g       rotlegume=.
replace rotlegume=0 if pp_s3q33a!=. &  (pp_s3q03>=1 & pp_s3q03<=5)
replace rotlegume=1 if pp_s3q33a==1 &  (pp_s3q03>=1 & pp_s3q03<=5) 


*CROP RESIDUE
* Only if cultivated(q03) & permanent crop planted in this meher season(q35) 
* Farmers elicitation
g       cresidue1=.
replace cresidue1=0 if (pp_s3q37==2 | pp_s3qm8<30) & pp_s3q03==1  &  (pp_s3q35>=1 &  pp_s3q35<7)
replace cresidue1=1 if pp_s3qm8>=30 & pp_s3qm8!=. &   pp_s3q03==1 & (pp_s3q35>=1 &  pp_s3q35<7) 

* Visual Aid
g       cresidue2=.
replace cresidue2=0 if pp_s3q36a!=. & pp_s3q36a<3  & pp_s3q03==1  &  (pp_s3q35>=1 &  pp_s3q35<7)
replace cresidue2=1 if pp_s3q36a>=3 & pp_s3q36a!=. &   pp_s3q03==1 & (pp_s3q35>=1 &  pp_s3q35<7) // limiting to cultivated plot for comparison with wave 4

*MINIMUM TILLAGE
* Only if cultivated(q03) & permanent crop planted in this meher season(q35)
g       mintillage=.
replace mintillage=0 if (pp_s3q36>1  & pp_s3q36!=.)  & pp_s3q03==1 & (pp_s3q35>=1 &  pp_s3q35<7)
replace mintillage=1 if (pp_s3q36<=1 & pp_s3q36!=.)  & pp_s3q03==1 & (pp_s3q35>=1 &  pp_s3q35<7) // limiting to cultivated plot for comparison with wave 4


g       zerotill=.
replace zerotill=0 if (pp_s3q36>0  & pp_s3q36!=.)  & pp_s3q03==1 & (pp_s3q35>=1 &  pp_s3q35<7)
replace zerotill=1 if (pp_s3q36==0 & pp_s3q36!=.)  & pp_s3q03==1 & (pp_s3q35>=1 &  pp_s3q35<7) 

*SWC
* Skip if home/homestead or Other is q03
g       swc=.
replace swc=0 if (pp_s3q33!=. | pp_s3q32==2) & (pp_s3q03>=1 & pp_s3q03<=5)
replace swc=1 if (pp_s3q33==1 | pp_s3q33==2| pp_s3q33==3 | pp_s3q33==4) & (pp_s3q03>=1 & pp_s3q03<=5)

g       terr=.
replace terr=0 if (pp_s3q33!=. | pp_s3q32==2) & (pp_s3q03>=1 & pp_s3q03<=5)
replace terr=1 if (pp_s3q33==1)               & (pp_s3q03>=1 & pp_s3q03<=5)

g       wcatch=.
replace wcatch=0 if (pp_s3q33!=. | pp_s3q32==2) & (pp_s3q03>=1 & pp_s3q03<=5)
replace wcatch=1 if (pp_s3q33==2)               & (pp_s3q03>=1 & pp_s3q03<=5)

g       affor=.
replace affor=0 if (pp_s3q33!=. | pp_s3q32==2) & (pp_s3q03>=1 & pp_s3q03<=5)
replace affor=1 if (pp_s3q33==3)               & (pp_s3q03>=1 & pp_s3q03<=5)


g       ploc=.
replace ploc=0 if (pp_s3q33!=. | pp_s3q32==2) & (pp_s3q03>=1 & pp_s3q03<=5)
replace ploc=1 if (pp_s3q33==4)               & (pp_s3q03>=1 & pp_s3q03<=5)





* CA with minimum tillage
g 		consag1=.
replace consag1=0 if (rotlegume!=1 | cresidue2!=1 | mintillage!=1) & (pp_s3q03>=1 & pp_s3q03<=5)
replace consag1=1 if (rotlegume==1 & cresidue2==1 & mintillage==1) & (pp_s3q03>=1 & pp_s3q03<=5)

* CA with zero tillage
g 		consag2=.
replace consag2=0 if (rotlegume!=1 | cresidue2!=1 | zerotill!=1) & (pp_s3q03>=1 & pp_s3q03<=5)
replace consag2=1 if (rotlegume==1 & cresidue2==1 & zerotill==1) & (pp_s3q03>=1 & pp_s3q03<=5)

* Broad Bed Maker: 

g       bbm=.
replace bbm=0 if                pp_s3q03==1 & (pp_s3q35>=1 &  pp_s3q35<7)
replace bbm=1 if pp_s3q35a==2 & pp_s3q03==1 & (pp_s3q35>=1 &  pp_s3q35<7) // limiting to cultivated plot for comparison with wave 4

lab var swc         "Soil Water Conservation practices"
lab var mintillage  "Minimum tillage"
lab var zerotill    "Zero tillage"
lab var cresidue1  "Crop residue cover - Farmer's elicitation"
lab var cresidue2  "Crop residue cover - visual aid"
lab var rotlegume   "Crop rotation with a legume"
lab var consag1     "Conservation Agriculture - using Minimum tillage"
lab var consag2     "Conservation Agriculture - using Zero tillage"
lab var rdisp       "River dispersion"
lab var treadle     "Treadle pump used for irrigation"
lab var motorpump   "Motor pump used for irrigation"
lab var bbm			"Broad Bed Maker"



* No. of plots per HH - total
egen hh_plot_nb=count(field_id), by(household_id2)
egen hh_plot_nb_rural=count(field_id) if rural==1, by(household_id2)
lab var hh_plot_nb "Number of plots per household"

egen ea_plot_nb=count(field_id), by(ea_id)
egen ea_plot_nb_rural=count(field_id) if rural==1, by(ea_id)
lab var ea_plot_nb "Number of plots per EA"

* No. of plots IRRIGATED and CULTIVATED per HH
egen hh_plot_irr_nb=count(field_id) if pp_s3q12==1 & pp_s3q03==1, by(household_id2)
egen hh_plot_irr_nb_rural=count(field_id) if pp_s3q12==1 & pp_s3q03==1 & rural==1, by(household_id2)
lab var hh_plot_irr_nb "Number of plots irrigated per household"

egen ea_plot_irr_nb=count(field_id) if pp_s3q12==1 & pp_s3q03==1, by(ea_id)
egen ea_plot_irr_nb_rural=count(field_id) if pp_s3q12==1 & pp_s3q03==1 & rural==1, by(ea_id)
lab var ea_plot_irr_nb "Number of plots irrigated per EA"

*No. of plots CULTIVATED per HH
egen hh_plot_cult_nb=count(field_id) if pp_s3q03==1, by(household_id2)
egen hh_plot_cult_nb_rural=count(field_id) if pp_s3q03==1 & rural==1, by(household_id2)
lab var hh_plot_cult_nb "Number of plots cultivated per household"

egen ea_plot_cult_nb=count(field_id) if pp_s3q03==1, by(ea_id)
egen ea_plot_cult_nb_rural=count(field_id) if pp_s3q03==1 & rural==1, by(ea_id)
lab var ea_plot_cult_nb "Number of plots cultivated per EA"

* No. of plots: CULTIVATED, PASTURE, FALLOW, FOREST, LAND PREPARED FOR BELG SEASON

egen hh_plot_uses_nb=count(field_id) if pp_s3q03==1 | pp_s3q03==2 | pp_s3q03==3 | pp_s3q03==4 | pp_s3q03==5, by(household_id2)
egen hh_plot_uses_nb_rural=count(field_id) if pp_s3q03==1 | pp_s3q03==2 | pp_s3q03==3 | pp_s3q03==4 | pp_s3q03==5 & rural==1, by(household_id2)
lab var hh_plot_uses_nb "Number of plots cultivated, pasture, fallow, forest etc. per household"

egen ea_plot_uses_nb=count(field_id) if pp_s3q03==1 | pp_s3q03==2 | pp_s3q03==3 | pp_s3q03==4 | pp_s3q03==5 , by(ea_id)
egen ea_plot_uses_nb_rural=count(field_id) if pp_s3q03==1 | pp_s3q03==2 | pp_s3q03==3 | pp_s3q03==4 | pp_s3q03==5 & rural==1, by(ea_id)
lab var ea_plot_uses_nb "Number of plots cultivated, pasture, fallow, forest etc. per EA"

*No. of plots WITH EROSION PREVENTION per HH
egen hh_plot_eros_nb=count(field_id) if pp_s3q32==1 & pp_s3q03==1 | pp_s3q03==2 | pp_s3q03==3 | pp_s3q03==4 | pp_s3q03==5, by(household_id2)
egen hh_plot_eros_nb_rural=count(field_id) if pp_s3q32==1 & pp_s3q03==1 | pp_s3q03==2 | pp_s3q03==3 | pp_s3q03==4 | pp_s3q03==5 & rural==1, by(household_id2)
lab var hh_plot_eros_nb "Number of plots with erosion prevention structures per household"

egen ea_plot_eros_nb=count(field_id) if pp_s3q32==1 & pp_s3q03==1 | pp_s3q03==2 | pp_s3q03==3 | pp_s3q03==4 | pp_s3q03==5, by(ea_id)
egen ea_plot_eros_nb_rural=count(field_id) if pp_s3q32==1 & pp_s3q03==1 | pp_s3q03==2 | pp_s3q03==3 | pp_s3q03==4 | pp_s3q03==5 & rural==1, by(ea_id)
lab var ea_plot_eros_nb "Number of plots  with erosion prevention structures per EA"

*No. of plots CULTIVATED AND LAND PREP per HH
egen hh_plot_cplus_nb=count(field_id) if pp_s3q35!=7 & pp_s3q03==1, by(household_id2)
egen hh_plot_cplus_nb_rural=count(field_id) if pp_s3q35!=7 & pp_s3q03==1 & rural==1, by(household_id2)
lab var hh_plot_cplus_nb "Number of plots cultivated and land prep per household"

egen ea_plot_cplus_nb=count(field_id) if pp_s3q35!=7 & pp_s3q03==1, by(ea_id)
egen ea_plot_cplus_nb_rural=count(field_id) if pp_s3q35!=7 & pp_s3q03==1 & rural==1, by(ea_id)

lab var ea_plot_cplus_nb "Number of plots cultivated and land prep per EA"


* HOUSEHOLD MEASURE : 
foreach i in treadle motorpump rotlegume cresidue1 cresidue2 mintillage zerotill consag1 consag2 swc terr wcatch affor ploc  rdisp bbm{
egen hhd_`i'=max(`i'), by(household_id2)
egen hhd_`i'_r=max(`i') if rural==1, by(household_id2)
egen hhs_`i'=sum(`i'), by(household_id2) 
egen hhs_`i'_r=sum(`i') if rural==1, by(household_id2) 

g sh_plothh_`i'=(hhs_`i'/hh_plot_nb)*100 if hhs_`i'!=. & hhd_`i'==1
g sh_plothh_`i'_r=(hhs_`i'_r/hh_plot_nb_r)*100 if hhs_`i'_r!=. & hhd_`i'_r==1

} 

rename sh_plothh_mintillage_r sh_plothh_mintil_r

* 1. Conditional on plot cultivated 
* 2. Conditional on plot irrigated & cultivated
* 3. Conditional on plot cultivated, pasture, fallow, forest etc.
* 4. Conditional on using soil erosion preventing measures & use
* 5. Cultivated and land preparation per household 
foreach i in treadle motorpump rdisp rotlegume cresidue1 cresidue2  mintillage zerotill consag1 consag2 swc terr wcatch affor ploc  bbm {

g sh_plothh_`i'_cond1=(hhs_`i'/hh_plot_cult_nb)*100  if `i'!=. & hhd_`i'==1
g sh_plothh_`i'_cond2=(hhs_`i'/hh_plot_irr_nb)*100   if `i'!=. & hhd_`i'==1
g sh_plothh_`i'_cond3=(hhs_`i'/hh_plot_uses_nb)*100  if `i'!=. & hhd_`i'==1
g sh_plothh_`i'_cond4=(hhs_`i'/hh_plot_eros_nb)*100  if `i'!=. & hhd_`i'==1
g sh_plothh_`i'_cond5=(hhs_`i'/hh_plot_cplus_nb)*100 if `i'!=. & hhd_`i'==1


g sh_plothh_`i'_cond1_r=(hhs_`i'_r/hh_plot_cult_nb_r)*100  if `i'!=. & rural==1 & hhd_`i'==1
g sh_plothh_`i'_cond2_r=(hhs_`i'_r/hh_plot_irr_nb_r)*100   if `i'!=. & rural==1 & hhd_`i'==1
g sh_plothh_`i'_cond3_r=(hhs_`i'_r/hh_plot_uses_nb_r)*100  if `i'!=. & rural==1 & hhd_`i'==1
g sh_plothh_`i'_cond4_r=(hhs_`i'_r/hh_plot_eros_nb_r)*100  if `i'!=. & rural==1 & hhd_`i'==1
g sh_plothh_`i'_cond5_r=(hhs_`i'_r/hh_plot_cplus_nb_r)*100 if `i'!=. & rural==1 & hhd_`i'==1
} 

forvalues x=1/5 {
rename sh_plothh_mintillage_cond`x'_r sh_plothh_mintil_cond`x'_r
}


* Plot size (by SR and GPS)
*Change names of vars.


rename saq01 region
rename saq02 zone	
rename saq03 woreda
rename saq04 city
rename saq05 subcity
rename saq06 kebele



destring region zone woreda city subcity kebele, force replace

merge m:1 region zone woreda using "${rawdata}${slash}Auxiliary_data${slash}ESS3_ET_local_area_unit_conversion"
drop if _m==2
drop _merge

*SR
g       plotarea_sr=.
replace plotarea_sr=pp_s3q02_a                       if pp_s3q02_c==1 //ha
replace plotarea_sr=pp_s3q02_a/10000                 if pp_s3q02_c==2 //sq meters
replace plotarea_sr=(pp_s3q02_a*conv_timad  )/10000     if pp_s3q02_c==3 & conv_timad!=.
replace plotarea_sr=(pp_s3q02_a*conv_timad_z)/10000   if pp_s3q02_c==3 & conv_timad==.
replace plotarea_sr=(pp_s3q02_a*conv_timad_r)/10000   if pp_s3q02_c==3 & conv_timad_z==. & conv_timad==. //timad


replace plotarea_sr=(pp_s3q02_a*conv_boy  )/10000 if pp_s3q02_c==4 & conv_boy!=.
replace plotarea_sr=(pp_s3q02_a*conv_boy_z)/10000 if pp_s3q02_c==4 & conv_boy==.
replace plotarea_sr=(pp_s3q02_a*conv_boy_r)/10000 if pp_s3q02_c==4 & conv_boy_z==. & conv_boy==. //boy



replace plotarea_sr=(pp_s3q02_a*conv_senga  )/10000 if pp_s3q02_c==5 & conv_senga!=.
replace plotarea_sr=(pp_s3q02_a*conv_senga_z)/10000 if pp_s3q02_c==5 & conv_senga==.
replace plotarea_sr=(pp_s3q02_a*conv_senga_r)/10000 if pp_s3q02_c==5 & conv_senga_z==. & conv_senga==. //senga

replace plotarea_sr=(pp_s3q02_a*conv_kert  )/10000 if pp_s3q02_c==6 & conv_kert!=.
replace plotarea_sr=(pp_s3q02_a*conv_kert_z)/10000 if pp_s3q02_c==6 & conv_kert==.
replace plotarea_sr=(pp_s3q02_a*conv_kert_r)/10000 if pp_s3q02_c==6 & conv_kert_z==. & conv_kert==. //kert

replace plotarea_sr=(pp_s3q02_a* 204.4169)/10000 if pp_s3q02_c==7 //tilm
replace plotarea_sr=(pp_s3q02_a*69.28191)/10000 if pp_s3q02_c==8 //medeb
*replace plotarea_sr=pp_s3q02_a if pp_s3q02_c==9 //rope
replace plotarea_sr=(pp_s3q02_a*6176.3808)/10000 if pp_s3q02_c==10 //ermija


*non missing: 24,047 obs - 16,844 of cultivated plots (total cultivated plots 23,244)
lab var plotarea_sr "Plot area in HA - Self-reported"
* Compass and rope
g       plotarea_cr=.
replace plotarea_cr=pp_s3q08_b/10000
lab var plotarea_cr "Plot area in HA - Compass and Rope"

* GPS
g       plotarea_gps=.
replace plotarea_gps=pp_s3q05_a/10000
lab var plotarea_gps "Plot area in HA - GPS"

* Variable without missing: order of importance: 1.Rope and compass, 2. GPS, 3. Self-reported
g plotarea_full=plotarea_cr
replace plotarea_full=plotarea_gps if plotarea_cr==.
replace plotarea_full=plotarea_sr if plotarea_gps==. & plotarea_cr==.

lab var plotarea_full "Plot area: GPS imputed with SR"
******

*Crop type

tab pp_s3q03b, g(cropm)
lab var cropm1 "Purestand"
lab var cropm2 "Mixed crop"

g falloq=.
replace falloq=1 if pp_s3q03c==1
replace falloq=0 if pp_s3q03c==2
lab var falloq "Plot left fallow in the last 10 years"

rename  pp_s3q10a pp_s1q00
merge m:1 holder_id household_id2 pp_s1q00 using "${raw3}${slash}sect1_pp_w3"
drop if _m==2
drop _m
 
 
g fplotm=.
replace fplotm=0 if pp_s1q03==1
replace fplotm=1 if pp_s1q03==2
lab var fplotm "Plot manager is female"
rename pp_s1q00 pp_s3q10a

drop pp_s1*

g extprog=.
replace extprog=0 if pp_s3q11==2
replace extprog=1 if pp_s3q11==1 
lab var extprog "Plot under Extension Program"

g irr=.
replace irr=0 if pp_s3q12==2
replace irr=1 if pp_s3q12==1
lab var irr "Plot is irrigated"

tab pp_s3q13, g(irrm)
lab var irrm1 "Source of water for irrigation is: river"
 
g urea=.
replace urea=1 if pp_s3q15==1
replace urea=0 if pp_s3q15==2 | pp_s3q14==2
lab var urea "Urea use on plot"


g dap=.
replace dap=1 if pp_s3q18==1
replace dap=0 if pp_s3q18==2  | pp_s3q14==2
lab var dap "Use of DAP on plot"

g nps=.
replace nps=1 if pp_s3q20a_1==1
replace nps=0 if pp_s3q20a_1==2  | pp_s3q14==2
lab var nps "Use of NPS on plot"


g othfert=.
replace othfert=1 if pp_s3q20a==1
replace othfert=0 if pp_s3q20a==2  | pp_s3q14==2
lab var othfert "Use of other chemical fert. on plot"

g manure=.
replace manure=1 if pp_s3q21==1
replace manure=0 if pp_s3q21==2  | pp_s3q14==2
lab var manure "Use of manure on plot"

g hiredlab=.
replace hiredlab=0 if pp_s3q28_a==0 & pp_s3q28_d==0 & pp_s3q28_g==0
replace hiredlab=1 if (pp_s3q28_a>0 & pp_s3q28_a!=.) | (pp_s3q28_d>0 & pp_s3q28_d!=.) | (pp_s3q28_g>0 & pp_s3q28_g!=.)
lab var hiredlab     "Hired labor used"



g lprep=.
replace lprep=1 if pp_s3q35!=.
replace lprep=0 if pp_s3q35==.
lab var lprep "Plot prepared for planting"
g soiler=.
replace soiler=1 if pp_s3q32==1
replace soiler=0 if pp_s3q32==2
lab var soiler "Plot prevented from soil erosion"



*PLOT level dataset - NRM
preserve
keep holder_id household_id household_id2 rural pw_w3 parcel_id field_id ea_id region zone woreda kebele subcity kebele pp_saq07 pp_s3q00 pp_s3q0a pp_s3q01 rdisp treadle motorpump rotlegume cresidue1 cresidue2 mintillage zerotill swc terr wcatch affor ploc consag1 consag2 bbm hh_plot_irr_nb hh_plot_nb hh_plot_cult_nb hh_plot_uses_nb hh_plot_eros_nb hh_plot_cplus_nb plotarea* fplotm extprog irr irrm1 urea dap nps othfert manure hiredlab lprep soiler saq01 plotirr

save "${data}${slash}ess3_pp_nrm_plot", replace 
restore

* COLLAPSE AT HH-LEVEL
collapse (max) hhd_treadle* hhd_motorpump* hhd_rotlegume* hhd_cresidue* hhd_mintillage* hhd_consag* hhd_swc* hhd_rdisp* sh_plothh_* hhd_zerotill* hhd_bbm* hhd_terr* hhd_wcatch* hhd_affor* hhd_ploc*  hh_plot_nb hh_plot_irr_nb hh_plot_cult_nb plotirr (firstnm) ea_id holder_id rural pw_w3, by(household_id2 )

*Household dummy
lab var hhd_swc           "Soil Water Conservation practices"
lab var hhd_terr          "Terracing"
lab var hhd_wcatch        "Water catchments"
lab var hhd_affor         "Afforestation"
lab var hhd_ploc	      "Plough along the contour"
lab var hhd_mintillage    "Minimum tillage"
lab var hhd_zerotill      "Zero tillage"
lab var hhd_cresidue1     "Crop residue cover -farmer elicitation"
lab var hhd_cresidue2     "Crop residue cover -visual aid"
lab var hhd_rotlegume     "Crop rotation with a legume"
lab var hhd_consag1       "Conservation Agriculture - using Minimum tillage"
lab var hhd_consag2       "Conservation Agriculture - using Zero tillage"
lab var hhd_rdisp         "River dispersion"
lab var hhd_treadle       "Treadle pump used for irrigation"
lab var hhd_motorpump     "Motor pump used for irrigation"
lab var hhd_bbm			  "Broad Bed Maker"

lab var hhd_swc_r         "Soil Water Conservation practices - rural"
lab var hhd_terr_r        "Terracing - rural"
lab var hhd_wcatch_r      "Water catchments - rural"
lab var hhd_affor_r       "Afforestation - rural"
lab var hhd_ploc_r	      "Plough along the contour - rural"
lab var hhd_mintillage_r  "Minimum tillage - rural"
lab var hhd_zerotill_r    "Zero tillage - rural"
lab var hhd_cresidue1_r   "Crop residue cover -farmer elicitation - rural"
lab var hhd_cresidue2_r   "Crop residue cover -visual aid - rural"
lab var hhd_rotlegume_r   "Crop rotation with a legume - rural"
lab var hhd_consag1_r     "Conservation Agriculture - using Minimum tillage - rural"
lab var hhd_consag2_r     "Conservation Agriculture - using Zero tillage - rural"
lab var hhd_rdisp_r       "River dispersion - rural"
lab var hhd_treadle_r     "Treadle pump used for irrigation - rural"
lab var hhd_motorpump_r   "Motor pump used for irrigation - rural"
lab var hhd_bbm_r		  "Broad Bed Maker - rural"


lab var hh_plot_nb       "Number of plots per household"
lab var hh_plot_irr_nb   "Number of irrigated plots per household"
lab var hh_plot_cult_nb   "Number of cultivated plots per household"

foreach i in hh_plot_nb hh_plot_irr_nb hh_plot_cult_nb {
replace `i'=0 if `i' ==.
}




* Sh_plothh : share of plots per hh
lab var sh_plothh_treadle              "Treadle pump used for irrigation"
lab var sh_plothh_treadle_r            "Treadle pump used for irrigation - rural"

forvalues x=1/5 {
lab var sh_plothh_treadle_cond`x'      "Treadle pump used for irrigation conditional on `x'* (see notes)"
lab var sh_plothh_treadle_cond`x'_r    "Treadle pump used for irrigation - rural conditional on `x'* (see notes)"
}


lab var sh_plothh_motorpump            "Motor pump used for irrigation"
lab var sh_plothh_motorpump_r          "Motor pump used for irrigation - rural"

forvalues x=1/5 {
lab var sh_plothh_motorpump_cond`x'    "Motor pump used for irrigation conditional on `x'* (see notes)"
lab var sh_plothh_motorpump_cond`x'_r  "Motor pump used for irrigation- rural conditional on `x'* (see notes)"

}

lab var sh_plothh_rotlegume            "Crop rotation with a legume"
lab var sh_plothh_rotlegume_r          "Crop rotation with a legume - rural"

forvalues x=1/5 {
lab var sh_plothh_rotlegume_cond`x'    "Crop rotation with a legume conditional on `x'* (see notes)"
lab var sh_plothh_rotlegume_cond`x'_r  "Crop rotation with a legume - rural  conditional on `x'* (see notes)"
}


lab var sh_plothh_cresidue1             "Crop residue cover-farmer elicitation"
lab var sh_plothh_cresidue1_r           "Crop residue cover-farmer elicitation - rural"

forvalues x=1/5 {
lab var sh_plothh_cresidue1_cond`x'     "Crop residue cover-farmer elicitation  conditional on `x'* (see notes)"
lab var sh_plothh_cresidue1_cond`x'_r   "Crop residue cover-farmer elicitation - rural conditional on `x'* (see notes)"

}
lab var sh_plothh_cresidue2              "Crop residue cover -visual aid"
lab var sh_plothh_cresidue2_r            "Crop residue cover -visual aid - rural"

forvalues x=1/5 {
lab var sh_plothh_cresidue2_cond`x'      "Crop residue cover -visual aid conditional on `x'* (see notes)"
lab var sh_plothh_cresidue2_cond`x'_r    "Crop residue cover -visual aid- rural conditional on `x'* (see notes)"

}


lab var sh_plothh_mintillage             "Minimum tillage"
lab var sh_plothh_mintil_r               "Minimum tillage - rural"

forvalues x=1/5 {
lab var sh_plothh_mintillage_cond`x'     "Minimum tillage conditional on `x'* (see notes)"
lab var sh_plothh_mintil_cond`x'_r       "Minimum tillage - rural conditional on `x'* (see notes)"

}

lab var sh_plothh_zerotill               "Zero tillage"
lab var sh_plothh_zerotill_r             "Zero tillage - rural"

forvalues x=1/5 {
lab var sh_plothh_zerotill_cond`x'       "Zero tillage conditional on `x'* (see notes)"
lab var sh_plothh_zerotill_cond`x'_r     "Zero tillage - rural conditional on `x'* (see notes)"

}


lab var sh_plothh_consag1               "Conservation Agriculture - using Minimum tillage"
lab var sh_plothh_consag1_r             "Conservation Agriculture - using Minimum tillage - rural"

forvalues x=1/5 {
lab var sh_plothh_consag1_cond`x'       "Conservation Agriculture - using Minimum tillage conditional on `x'* (see notes)"
lab var sh_plothh_consag1_cond`x'_r     "Conservation Agriculture - using Minimum tillage - rural conditional on `x'* (see notes)"

} 
lab var sh_plothh_consag2               "Conservation Agriculture - using Zero tillage"
lab var sh_plothh_consag2_r             "Conservation Agriculture - using Zero tillage - rural"

forvalues x=1/5 {
lab var sh_plothh_consag2_cond`x'       "Conservation Agriculture - using Zero tillage conditional on `x'* (see notes)"
lab var sh_plothh_consag2_cond`x'_r     "Conservation Agriculture - using Zero tillage - rural conditional on `x'* (see notes)"

}

lab var sh_plothh_swc                  "Soil Water Conservation practices"
lab var sh_plothh_swc_r                "Soil Water Conservation practices - rural"

forvalues x=1/5 {
lab var sh_plothh_swc_cond`x'          "Soil Water Conservation practices conditional on `x'* (see notes)"
lab var sh_plothh_swc_cond`x'_r        "Soil Water Conservation practices - rural conditional on `x'* (see notes)"

}

lab var sh_plothh_terr               "Terracing"
lab var sh_plothh_terr_r             "Terracing - rural"
forvalues x=1/5 {
lab var sh_plothh_terr_cond`x'       "Terracing conditional on `x'* (see notes)"
lab var sh_plothh_terr_cond`x'_r     "Terracing - rural conditional on `x'* (see notes)"
}

lab var sh_plothh_wcatch             "Water catchments"
lab var sh_plothh_wcatch_r           "Water catchments - rural"
forvalues x=1/5 {
lab var sh_plothh_wcatch_cond`x'     "Water catchments conditional on `x'* (see notes)"
lab var sh_plothh_wcatch_cond`x'_r   "Water catchments - rural conditional on `x'* (see notes)"
}

lab var sh_plothh_affor              "Afforestation"
lab var sh_plothh_affor_r            "Afforestation - rural"
forvalues x=1/5 {  
lab var sh_plothh_affor_cond`x'      "Afforestation conditional on `x'* (see notes)"
lab var sh_plothh_affor_cond`x'_r    "Afforestation - rural conditional on `x'* (see notes)"
}

lab var sh_plothh_ploc               "Plough along the contour"
lab var sh_plothh_ploc_r             "Plough along the contour - rural"
forvalues x=1/5 {  
lab var sh_plothh_ploc_cond`x'       "Plough along the contour conditional on `x'* (see notes)"
lab var sh_plothh_ploc_cond`x'_r     "Plough along the contour - rural conditional on `x'* (see notes)"
}


lab var sh_plothh_rdisp              "River dispersion"
lab var sh_plothh_rdisp_r            "River dispersion - rural"
forvalues x=1/5 { 
lab var sh_plothh_rdisp_cond`x'      "River dispersion conditional on `x'* (see notes)"
lab var sh_plothh_rdisp_cond`x'_r    "River dispersion - rural conditional on `x'* (see notes)"

}

lab var sh_plothh_bbm				 "Broad Bed Maker"
lab var sh_plothh_bbm_r				 "Broad Bed Maker - rural"
forvalues x=1/5 {
lab var sh_plothh_bbm_cond`x'        "Broad Bed Maker conditional on `x'* (see notes)"
lab var sh_plothh_bbm_cond`x'_r      "Broad Bed Maker - rural conditional on `x'* (see notes)"

}

#delimit ;
global conditional sh_plothh_treadle_cond`x' sh_plothh_motorpump_cond`x' sh_plothh_rotlegume_cond`x' 
	sh_plothh_cresidue1_cond`x' sh_plothh_cresidue2_cond`x' sh_plothh_zerotill_cond`x' 
	sh_plothh_consag1_cond`x' sh_plothh_consag2_cond`x' sh_plothh_swc_cond`x' sh_plothh_terr_cond`x'    
	sh_plothh_wcatch_cond`x' sh_plothh_affor_cond`x' sh_plothh_ploc_cond`x' sh_plothh_rdisp_cond`x'    
	sh_plothh_bbm_cond`x'        
;
#delimit cr

foreach var in  $conditional {
forvalues x=1/5 {
note `var'`x': Conditional on: ///
				                1. Plot cultivated, ///
								2. Plot irrigated & cultivated, ///
								3. Plot cultivated, pasture, fallow, forest etc., ///
								4. Using soil erosion preventing measures & use, ///
								5. Cultivated and land preparation per household.
}
}

tempfile  PP_W3S3
save     `PP_W3S3'

********************************************************************************
* SECTION 4 - PP - CROP VARIETY
********************************************************************************
* Merge with pp-cover to retrieve plot status
use "${raw3}${slash}sect4_pp_w3", clear
merge m:1 holder_id household_id household_id2 parcel_id field_id using "${raw3}${slash}sect3_pp_w3", keepusing(pp_s3q03)
keep if _m==3
drop _merge
*LIMITING TO CULTIVATED PLOTS
keep if pp_s3q03==1

g sp_ofsp=pp_s4q18==2
lab var sp_ofsp "SP - OFSP"


g sp_awassa83=pp_s4q18==1 & pp_s4q19==2
lab var sp_awassa83 "SP- Awassa83"

g desi_d=pp_s4q12c==1
g kabuli_d=pp_s4q12c==2



g avocado=    pp_s4q01_b==84
g mango=      pp_s4q01_b==46
g papaya=     pp_s4q01_b==48
g sweetpotato=pp_s4q01_b==62
g fieldp=     pp_s4q01_b==15

*Crop type *

g improv=.
replace improv=1 if pp_s4q11==2
replace improv=0 if pp_s4q11==1
lab var improv "Improved crop used"


* Improved by crop *
g cr1=0
g cr2=0
g cr3=0
g cr4=0
g cr5=0
g cr6=0
g cr7=0
g cr8=0
g cr9=0
g cr10=0
g cr11=0
g cr12=0
g cr13=0
g cr14=0
g cr15=0
g cr18=0
g cr19=0
g cr23=0
g cr24=0
g cr25=0
g cr26=0
g cr27=0
g cr42=0
g cr49=0
g cr60=0
g cr62=0
g cr71=0
g cr72=0

replace cr1=1 if pp_s4q01_b==1
replace cr2=1 if pp_s4q01_b==2
replace cr3=1 if pp_s4q01_b==3
replace cr4=1 if pp_s4q01_b==4
replace cr5=1 if pp_s4q01_b==5
replace cr6=1 if pp_s4q01_b==6
replace cr7=1 if pp_s4q01_b==7
replace cr8=1 if pp_s4q01_b==8
replace cr9=1 if pp_s4q01_b==9
replace cr10=1 if pp_s4q01_b==10
replace cr11=1 if pp_s4q01_b==11
replace cr12=1 if pp_s4q01_b==12
replace cr13=1 if pp_s4q01_b==13
replace cr14=1 if pp_s4q01_b==14
replace cr15=1 if pp_s4q01_b==15
replace cr18=1 if pp_s4q01_b==18
replace cr19=1 if pp_s4q01_b==19
replace cr23=1 if pp_s4q01_b==23
replace cr24=1 if pp_s4q01_b==24
replace cr25=1 if pp_s4q01_b==25
replace cr26=1 if pp_s4q01_b==26
replace cr27=1 if pp_s4q01_b==27
replace cr42=1 if pp_s4q01_b==42
replace cr49=1 if pp_s4q01_b==49
replace cr60=1 if pp_s4q01_b==60
replace cr62=1 if pp_s4q01_b==62
replace cr71=1 if pp_s4q01_b==71
replace cr72=1 if pp_s4q01_b==72

*Veg
g cr34=0
g cr38=0
g cr52=0
g cr55=0
g cr56=0
g cr57=0
g cr58=0
g cr59=0
g cr61=0
g cr63=0
g cr69=0
g cr79=0
g cr80=0
g cr82=0
g cr83=0
g cr116=0
g cr117=0


replace cr34=1 if pp_s4q01_b==34
replace cr38=1 if pp_s4q01_b==38
replace cr52=1 if pp_s4q01_b==52
replace cr55=1 if pp_s4q01_b==55
replace cr56=1 if pp_s4q01_b==56
replace cr57=1 if pp_s4q01_b==57
replace cr58=1 if pp_s4q01_b==58
replace cr59=1 if pp_s4q01_b==59
replace cr61=1 if pp_s4q01_b==61
replace cr63=1 if pp_s4q01_b==63
replace cr69=1 if pp_s4q01_b==69
replace cr79=1 if pp_s4q01_b==79
replace cr80=1 if pp_s4q01_b==80
replace cr82=1 if pp_s4q01_b==82
replace cr83=1 if pp_s4q01_b==83
replace cr116=1 if pp_s4q01_b==116
replace cr117=1 if pp_s4q01_b==117


*Trees
g cr41=0
g cr44=0
g cr45=0
g cr46=0
g cr47=0
g cr48=0
g cr50=0
g cr65=0
g cr66=0
g cr75=0
g cr84=0
g cr112=0
g cr115=0

replace cr41=1 if pp_s4q01_b==41
replace cr44=1 if pp_s4q01_b==44
replace cr45=1 if pp_s4q01_b==45
replace cr46=1 if pp_s4q01_b==46
replace cr47=1 if pp_s4q01_b==47
replace cr48=1 if pp_s4q01_b==48
replace cr50=1 if pp_s4q01_b==50
replace cr65=1 if pp_s4q01_b==65
replace cr66=1 if pp_s4q01_b==66
replace cr75=1 if pp_s4q01_b==75
replace cr84=1 if pp_s4q01_b==84
replace cr112=1 if pp_s4q01_b==112
replace cr115=1 if pp_s4q01_b==115


*roots
g cr51=0
g cr53=0
g cr74=0

replace cr51=1 if pp_s4q01_b==51
replace cr53=1 if pp_s4q01_b==53
replace cr74=1 if pp_s4q01_b==74


g cr76=0
replace cr76=1 if pp_s4q01_b==76




foreach i in cr1 cr2 cr3 cr4 cr5 cr6 cr7 cr8 cr9 cr10 cr11 cr12 cr13 cr14 cr15 cr18 cr19 cr23 cr24 cr25 cr26 cr27 cr42 cr49 cr60 cr62 cr71 cr72  {
g imp`i'=0       if `i'==1
replace imp`i'=1 if `i'==1 & improv==1
}



g       impveg=.
replace impveg=0 if cr34==1 | cr38==1 | cr52==1 | cr55==1 | cr56==1 | cr57==1 | cr58==1 | cr59==1 | cr61==1 | cr63==1 | cr69==1 | cr79==1 | cr80==1 | cr82==1 | cr83==1 | cr116==1 | cr117==1 
replace impveg=1 if (cr34==1 | cr38==1 | cr52==1 | cr55==1 | cr56==1 | cr57==1 | cr58==1 | cr59==1 | cr61==1 | cr63==1 | cr69==1 | cr79==1 | cr80==1 | cr82==1 | cr83==1 | cr116==1 | cr117==1) & improv==1

g       impftr=.
replace impftr=0 if cr41==1 | cr44==1 | cr45==1 | cr46==1 | cr47==1 | cr48==1 | cr50==1 | cr65==1 | cr66==1 | cr75==1 | cr84==1 | cr112==1 | cr115==1        
replace impftr=1 if (cr41==1 | cr44==1 | cr45==1 | cr46==1 | cr47==1 | cr48==1 | cr50==1 | cr65==1 | cr66==1 | cr75==1 | cr84==1 | cr112==1 | cr115==1) & improv==1


g       improot=.
replace improot=0 if  cr51==1 | cr53==1 | cr74==1
replace improot=1 if (cr51==1 | cr53==1 | cr74==1) & improv==1

g       impccr=.
replace impccr=0 if cr76==1
replace impccr=1 if cr76==1 & improv==1


foreach i in sp_ofsp sp_awassa83 desi kabuli avocado mango papaya sweetpotato fieldp  impcr1 impcr2 impcr3 impcr4 impcr5 impcr6 impcr7 impcr8 impcr9 impcr10 impcr11 impcr12 impcr13 impcr14 impcr15 impcr18 impcr19 impcr23 impcr24 impcr25 impcr26 impcr27 impcr42 impcr49 impcr60 impcr62 impcr71 impcr72 impveg impftr improot impccr {
egen `i'max=max(`i'), by(household_id2)
}


foreach i in ofsp awassa83 {
egen hhd_`i'=max(sp_`i')      if sp_ofspmax!=., by(household_id2)     
egen ead_`i'=max(sp_`i')      if sp_ofspmax!=., by(ea_id)             
egen `i'_sumhh=sum(sp_`i')    if sp_ofspmax!=., by(household_id2)   
egen `i'_sumea=sum(sp_`i')    if sp_ofspmax!=., by(ea_id)           
egen `i'_sumhhea=sum(hhd_`i') if sp_ofspmax!=., by(ea_id) 

egen hhd_`i'_r=max(sp_`i')      if sp_ofspmax!=. & rural==1, by(household_id2)     
egen ead_`i'_r=max(sp_`i')      if sp_ofspmax!=. & rural==1, by(ea_id)             
egen `i'_sumhh_r=sum(sp_`i')    if sp_ofspmax!=. & rural==1, by(household_id2)   
egen `i'_sumea_r=sum(sp_`i')    if sp_ofspmax!=. & rural==1, by(ea_id)           
egen `i'_sumhhea_r=sum(hhd_`i') if sp_ofspmax!=. & rural==1, by(ea_id)  

       
}



foreach i in avocado mango papaya sweetpotato fieldp   impcr1 impcr2 impcr3 impcr4 impcr5 impcr6 impcr7 impcr8 impcr9 impcr10 impcr11 impcr12 impcr13 impcr14 impcr15 impcr18 impcr19 impcr23 impcr24 impcr25 impcr26 impcr27 impcr42 impcr49 impcr60 impcr62 impcr71 impcr72  impveg impftr improot impccr {
egen hhd_`i'=max(`i')         if `i'max!=., by(household_id2)    // HH dummy 
egen ead_`i'=max(`i')         if `i'max!=., by(ea_id)           // Ea dummy  
egen `i'_sumhh=sum(`i')       if `i'max!=., by(household_id2)    // Sum of crop per HH
egen `i'_sumea=sum(`i')       if `i'max!=., by(ea_id)           // Sum of crop per EA
egen `i'_sumhhea=sum(hhd_`i') if `i'max!=., by(ea_id)           // Sum of hh per EA


egen hhd_`i'_r=max(`i')         if `i'max!=. & rural==1, by(household_id2)    // HH dummy 
egen ead_`i'_r=max(`i')         if `i'max!=. & rural==1, by(ea_id)           // Ea dummy  
egen `i'_sumhh_r=sum(`i')       if `i'max!=. & rural==1, by(household_id2)    // Sum of crop per HH
egen `i'_sumea_r=sum(`i')       if `i'max!=. & rural==1, by(ea_id)           // Sum of crop per EA
egen `i'_sumhhea_r=sum(hhd_`i') if `i'max!=. & rural==1, by(ea_id)           // Sum of hh per EA
}





foreach i in desi kabuli {
egen hhd_`i'=max(`i'_d)         if desimax!=. , by(household_id2)  
egen ead_`i'=max(`i'_d)         if desimax!=.,  by(ea_id)          
egen `i'_sumhh=sum(`i'_d)       if desimax!=. , by(household_id2)  
egen `i'_sumea=sum(`i'_d)       if desimax!=. , by(ea_id)          
egen `i'_sumhhea=sum(hhd_`i')   if desimax!=. , by(ea_id)  

egen hhd_`i'_r=max(`i'_d)         if desimax!=. & rural==1, by(household_id2)  
egen ead_`i'_r=max(`i'_d)         if desimax!=. & rural==1,  by(ea_id)          
egen `i'_sumhh_r=sum(`i'_d)       if desimax!=. & rural==1, by(household_id2)  
egen `i'_sumea_r=sum(`i'_d)       if desimax!=. & rural==1, by(ea_id)          
egen `i'_sumhhea_r=sum(hhd_`i')   if desimax!=. & rural==1, by(ea_id)
        
}

egen ea_plot1=count(field_id)      if sp_ofspmax!=.  , by(ea_id)          
egen ea_plot2=count(field_id)      if desimax!=.     , by(ea_id)         
egen hh_plot1=count(field_id)      if sp_ofspmax!=.  , by(household_id2)  
egen hh_plot2=count(field_id)      if desimax!=.     , by(household_id2) 
egen hh_ea1=count(household_id2)   if sp_ofspmax!=.  , by(ea_id)           
egen hh_ea2=count(household_id2)   if desimax!=.     , by(ea_id)         

egen ea_plot1_r=count(field_id)      if sp_ofspmax!=. & rural==1 , by(ea_id)          
egen ea_plot2_r=count(field_id)      if desimax!=.    & rural==1 , by(ea_id)         
egen hh_plot1_r=count(field_id)      if sp_ofspmax!=. & rural==1 , by(household_id2)  
egen hh_plot2_r=count(field_id)      if desimax!=.    & rural==1 , by(household_id2) 
egen hh_ea1_r=count(household_id2)   if sp_ofspmax!=. & rural==1 , by(ea_id)           
egen hh_ea2_r=count(household_id2)   if desimax!=.    & rural==1 , by(ea_id)         


egen ea_plot3=count(field_id)      if pp_s4q01_b!=.  , by(ea_id)          //Tot no of plot per EA
       
egen hh_plot3=count(field_id)      if pp_s4q01_b!=.  , by(household_id)  // Tot no of plots per HH

egen hh_ea3=count(household_id2)  if pp_s4q01_b!=.  , by(ea_id)           		// Tot no of hh per EA


egen ea_plot3_r=count(field_id)      if pp_s4q01_b!=. & rural==1 , by(ea_id)          //Tot no of plot per EA
       
egen hh_plot3_r=count(field_id)      if pp_s4q01_b!=. & rural==1 , by(household_id)  // Tot no of plots per HH

egen hh_ea3_r=count(household_id2)  if pp_s4q01_b!=. & rural==1 , by(ea_id)           		// Tot no of hh per EA






foreach i in ofsp awassa83 {
g sh_plothh_`i'=(`i'_sumhh/hh_plot1)*100 if `i'_sumhh!=.   & hhd_`i'==1
g sh_plotea_`i'=(`i'_sumea/ea_plot1)*100 if `i'_sumea!=.   & hhd_`i'==1
g sh_hhea_`i'  =(`i'_sumhhea/hh_ea1)*100 if `i'_sumhhea!=. & hhd_`i'==1

g sh_plothh_`i'_r=(`i'_sumhh_r/hh_plot1_r)*100 if `i'_sumhh_r!=.   & hhd_`i'==1
g sh_plotea_`i'_r=(`i'_sumea_r/ea_plot1_r)*100 if `i'_sumea_r!=.   & hhd_`i'==1
g sh_hhea_`i'_r  =(`i'_sumhhea_r/hh_ea1_r)*100 if `i'_sumhhea_r!=. & hhd_`i'==1
}

foreach i in desi kabuli {
g sh_plothh_`i'=(`i'_sumhh/hh_plot2)*100 if `i'_sumhh!=.       & hhd_`i'==1
g sh_plotea_`i'=(`i'_sumea/ea_plot2)*100 if `i'_sumea!=.       & hhd_`i'==1
g sh_hhea_`i'  =(`i'_sumhhea/hh_ea2)*100 if `i'_sumhhea!=.     & hhd_`i'==1

g sh_plothh_`i'_r=(`i'_sumhh_r/hh_plot2_r)*100 if `i'_sumhh_r!=.   & hhd_`i'_r==1
g sh_plotea_`i'_r=(`i'_sumea_r/ea_plot2_r)*100 if `i'_sumea_r!=.   & hhd_`i'_r==1
g sh_hhea_`i'_r  =(`i'_sumhhea_r/hh_ea2_r)*100 if `i'_sumhhea_r!=. & hhd_`i'_r==1
}


foreach i in avocado mango papaya sweetpotato fieldp    impcr1 impcr2 impcr3 impcr4 impcr5 impcr6 impcr7 impcr8 impcr9 impcr10 impcr11 impcr12 impcr13 impcr14 impcr15 impcr18 impcr19 impcr23 impcr24 impcr25 impcr26 impcr27 impcr42 impcr49 impcr60 impcr62 impcr71 impcr72  impveg impftr improot impccr {
g sh_plothh_`i'=(`i'_sumhh/hh_plot3)*100 if `i'_sumhh!=.    & hhd_`i'==1
g sh_plotea_`i'=(`i'_sumea/ea_plot3)*100 if `i'_sumea!=.    & hhd_`i'==1
g sh_hhea_`i'  =(`i'_sumhhea/hh_ea3)*100 if `i'_sumhhea!=.  & hhd_`i'==1

g sh_plothh_`i'_r=(`i'_sumhh_r/hh_plot3_r)*100 if `i'_sumhh_r!=.   & hhd_`i'_r==1
g sh_plotea_`i'_r=(`i'_sumea_r/ea_plot3_r)*100 if `i'_sumea_r!=.   & hhd_`i'_r==1
g sh_hhea_`i'_r  =(`i'_sumhhea_r/hh_ea3_r)*100 if `i'_sumhhea_r!=. & hhd_`i'_r==1
}




* Crop damage cause
tab  pp_s4q09, g(cdam)

g cdamoth=.

replace cdamoth=1 if cdam6==1 | cdam7==1 | cdam8==1 | cdam9==1 | cdam10==1 | cdam11==1 | cdam12==1 | cdam13==1 | cdam14==1 | cdam15==1 | cdam16==1 
foreach i in 1 2 3 4 5 oth {
replace cdam`i' =0 if pp_s4q08==2

}
replace cdamoth=0 if cdamoth==. & pp_s4q08!=.
* Intention to sell the harvest
g hsell=.
replace hsell=1 if pp_s4q21==1
replace hsell=0 if pp_s4q21==2



*Plot level data - Crop variety
preserve
keep saq01 holder_id-pp_s4q01_b sp_ofsp sp_awassa83 desi_d kabuli_d avocado mango papaya sweetpotato fieldp improv improv cdam1 cdam2 cdam3 cdam4 cdam5 cdamoth hsell 
collapse (max) saq01 sp_ofsp sp_awassa83 desi_d kabuli_d avocado mango papaya sweetpotato fieldp improv cdam1 cdam2 cdam3 cdam4 cdam5 cdamoth hsell , by(parcel_id field_id   holder_id household_id2 ea_id)

lab var improv      "Improved crop used"
lab var cdam1       "Crop damage due to: Too Much Rain "
lab var cdam2       "Crop damage due to: Too Little Rain"
lab var cdam3       "Crop damage due to: Insects"
lab var cdam4       "Crop damage due to: Crop Disease "
lab var cdam5       "Crop damage due to: Weeds"
lab var cdamoth     "Crop damage due to: Other "
lab var hsell       "Farmer intends to sell parts of the harvest"
lab var improv      "Improved crop used"


lab var sp_ofsp     "Orange Fleshed sweet potato"
lab var sp_awassa83 "Awassa83 sweet potato"
lab var desi_d      "Desi chickpea"
lab var kabuli_d    "Kabuli chickpea"
lab var avocado     "Avocado tree"
lab var mango       "Mango tree"
lab var papaya      "Papaya tree"
lab var sweetpotato "Sweetpotato SR"
lab var fieldp		"Field peas"






save "${data}${slash}ess3_pp_cropvar_plot", replace
restore


* Collapse at HH - level 
collapse (max) hhd_ofsp* ead_ofsp* hhd_awassa83* ead_awassa83* hhd_desi* ead_desi* hhd_kabuli* ead_kabuli* hhd_avocado* ead_avocado* hhd_mango* ead_mango* ead_papaya* hhd_papaya* hhd_sweetpotato* ead_sweetpotato*  ead_fieldp* hhd_fieldp*  sh_plothh_ofsp* sh_plotea_ofsp* sh_hhea_ofsp* sh_plothh_awassa83* sh_plotea_awassa83* sh_hhea_awassa83* sh_plothh_desi* sh_plotea_desi* sh_hhea_desi* sh_plothh_kabuli* sh_plotea_kabuli* sh_hhea_kabuli* sh_plothh_avocado* sh_plotea_avocado* sh_hhea_avocado* sh_plothh_mango* sh_plotea_mango* sh_hhea_mango* sh_plothh_papaya* sh_plotea_papaya* sh_hhea_papaya* sh_plothh_sweetpotato* sh_plotea_sweetpotato* sh_hhea_sweetpotato* sh_plothh_fieldp* sh_plotea_fieldp* sh_hhea_fieldp* *impcr* *impveg* *impftr* *improot* *impccr*  ///
(firstnm) saq01 rural pw_w3 ea_id , by(household_id2)




foreach i in impcr1 impcr2 impcr3 impcr4 impcr5 impcr6 impcr7 impcr8 impcr9 impcr10 impcr11 impcr12 impcr13 impcr14 impcr15 impcr18 impcr19 impcr23 impcr24 impcr25 impcr26 impcr27 impcr42 impcr49 impcr60 impcr62 impcr71 impcr72  impveg impftr improot impccr {
replace sh_plothh_`i'=. if hhd_`i'==0
replace sh_plotea_`i'=. if ead_`i'==0
replace sh_hhea_`i'=.   if ead_`i'==0
}







foreach i of varlist *impveg* {
lab var `i' "Improved (SR) vegetables and herbs" 
}
foreach i of varlist *impftr* {
lab var `i' "Improved (SR) fruit trees" 
}
foreach i of varlist *improot* {
lab var `i' "Improved (SR) other roots"
} 
foreach i of varlist *impccr* {
lab var `i' "Improved (SR) cash crop" 
}



foreach i in hhd_ofsp ead_ofsp sh_plothh_ofsp sh_plotea_ofsp sh_hhea_ofsp {
lab var `i'   "Sweet potato OFSP variety"
lab var `i'_r "Sweet potato OFSP variety"
}

foreach i in hhd_awassa83 ead_awassa83 sh_plothh_awassa83 sh_plotea_awassa83 sh_hhea_awassa83 {
lab var `i'   "Sweet potato Awassa83 variety"
lab var `i'_r "Sweet potato Awassa83 variety - rural"

}

foreach i in hhd_avocado ead_avocado sh_plothh_avocado sh_plotea_avocado sh_hhea_avocado {
lab var `i'   "Avocado tree"
lab var `i'_r "Avocado tree - rural"
}

foreach i in hhd_mango ead_mango sh_plothh_mango sh_plotea_mango sh_hhea_mango {
lab var `i'   "Mango tree"
lab var `i'_r "Mango tree - rural"
}

foreach i in hhd_papaya ead_papaya sh_plothh_papaya sh_plotea_papaya sh_hhea_papaya {
lab var `i'   "Papaya tree"
lab var `i'_r "Papaya tree - rural"
}
foreach i in hhd_sweetpotato ead_sweetpotato sh_plothh_sweetpotato sh_plotea_sweetpotato sh_hhea_sweetpotato {
lab var `i'   "Sweetpotato"
lab var `i'_r "Sweetpotato - rural"
}
foreach i in hhd_fieldp ead_fieldp sh_plothh_fieldp sh_plotea_fieldp sh_hhea_fieldp {
lab var `i'   "Field peas"
lab var `i'_r "Field peas - rural"
}

foreach i in hhd_desi ead_desi sh_plothh_desi sh_plotea_desi sh_hhea_desi {
lab var `i'   "Desi chickpea type"
lab var `i'_r "Desi chickpea type - rural"

}

foreach i in hhd_kabuli ead_kabuli sh_plothh_kabuli sh_plotea_kabuli sh_hhea_kabuli {
lab var `i'   "Kabuli chickpea type"
lab var `i'_r "Kabuli chickpea type - rural"

}

foreach i of varlist *impcr1*{
    lab var `i' "Improved  BARLEY-SR"
	}
foreach i of varlist *impcr2*{
    lab var `i' "Improved  MAIZE-SR"
	}
foreach i of varlist *impcr3*{
    lab var `i' "Improved  MILLET-SR"
	}
foreach i of varlist *impcr4*{
    lab var `i' "Improved  OATS-SR"
	}
foreach i of varlist *impcr5*{
    lab var `i' "Improved  RICE-SR"
	}
foreach i of varlist *impcr6*{
    lab var `i' "Improved  SORGHUM-SR"
	}
foreach i of varlist *impcr7*{
    lab var `i' "Improved  TEFF-SR"
	}
foreach i of varlist *impcr8*{
    lab var `i' "Improved  WHEAT-SR"
	}
foreach i of varlist *impcr9*{
    lab var `i' "Improved  Mung Bean/ MASHO-SR"
	}
foreach i of varlist *impcr10*{
    lab var `i' "Improved  CASSAVA-SR"
	}
foreach i of varlist *impcr11*{
    lab var `i' "Improved  CHICK PEAS-SR"
	}
foreach i of varlist *impcr12*{
    lab var `i' "Improved  HARICOT BEANS-SR"
	}
foreach i of varlist *impcr13*{
    lab var `i' "Improved  HORSE BEANS-SR"
	}
foreach i of varlist *impcr14*{
    lab var `i' "Improved  LENTILS-SR"
	}
foreach i of varlist *impcr15*{
    lab var `i' "Improved  FIELD PEAS-SR"
	}
foreach i of varlist *impcr18*{
    lab var `i' "Improved  SOYA BEANS-SR"
	}
foreach i of varlist *impcr19*{
    lab var `i' "Improved  RED KIDENY BEANS-SR"
	}
foreach i of varlist *impcr23*{
    lab var `i' "Improved  LINESEED-SR"
	}
foreach i of varlist *impcr24*{
    lab var `i' "Improved  GROUND NUTS-SR"
	}
foreach i of varlist *impcr25*{
    lab var `i' "Improved  NUEG-SR"
	}
foreach i of varlist *impcr26*{
    lab var `i' "Improved  RAPE SEED-SR"
	}
foreach i of varlist *impcr27*{
    lab var `i' "Improved  SESAME-SR"
	}
foreach i of varlist *impcr42*{
    lab var `i' "Improved  BANANAS-SR"
	}
foreach i of varlist *impcr49*{
    lab var `i' "Improved  PINAPPLES-SR"
	}
foreach i of varlist *impcr60*{
    lab var `i' "Improved  POTATOES-SR"
	}
foreach i of varlist *impcr62*{
    lab var `i' "Improved  SWEET POTATO-SR"
	}
foreach i of varlist *impcr71*{
    lab var `i' "Improved  CHAT-SR"
	}
foreach i of varlist *impcr72*{
    lab var `i' "Improved  COFFEE-SR"
	}






tempfile pp_w3s4
save `pp_w3s4'



********************************************************************************
*** PP - Sec.8_1 - Crossbred animals
********************************************************************************
use "${raw3}${slash}sect8_1_ls_w3", clear

merge m:1 household_id2 ls_sec_8_type_code holder_id using "${raw3}${slash}sect8_3_ls_w3"
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                             0
    matched                            88,090  (_merge==3)
    -----------------------------------------
*/
drop _merge


merge m:1 household_id2 ls_sec_8_type_code holder_id using "${raw3}${slash}sect8_4_ls_w3"
/* 


    Result                           # of obs.
    -----------------------------------------
    not matched                             0
    matched                            88,090  (_merge==3)
    -----------------------------------------
*/
drop _merge


* Dummy for hh owning at least 1 livestock type (large ruminant, small ruminant or poultry)
g       hh_livx=0
replace hh_livx=1 if (ls_sec_8_type_code==1 | ls_sec_8_type_code==2 | ls_sec_8_type_code==4) & ls_sec_8_1q01>0 & ls_sec_8_1q01!=.
egen    hh_liv=  max(hh_livx),             by(household_id2)
egen    hh_liv_r=max(hh_livx) if rural==1, by(household_id2)

drop hh_livx


g       largerum_x=0
replace largerum_x=1 if ls_sec_8_type_code==1  & ls_sec_8_1q01>0 & ls_sec_8_1q01!=.
egen    largerum_d=  max(largerum_x),             by(household_id)
egen    largerum_d_r=max(largerum_x) if rural==1, by(household_id)

drop largerum_x

g       smallrum_x=0
replace smallrum_x=1 if ls_sec_8_type_code==2  & ls_sec_8_1q01>0 & ls_sec_8_1q01!=.
egen    smallrum_d=  max(smallrum_x),             by(household_id)
egen    smallrum_d_r=max(smallrum_x) if rural==1, by(household_id)

drop smallrum_x

g       poultry_x=0
replace poultry_x=1 if ls_sec_8_type_code==4  & ls_sec_8_1q01>0 & ls_sec_8_1q01!=.
egen    poultry_d=  max(poultry_x),             by(household_id)
egen    poultry_d_r=max(poultry_x) if rural==1, by(household_id)

drop poultry_x


* Total no. of ... per household:

* Large ruminants
egen largerum_nbhh= sum(ls_sec_8_1q01) if ls_sec_8_type_code==1,                   by(household_id2) // livestock holded/owned
egen largerum_cross=sum(ls_sec_8_1q02) if ls_sec_8_type_code==1 & ls_sec_8_1q01>0, by(household_id2) // crossbred animals

egen largerum_nbhh_r= sum(ls_sec_8_1q01) if ls_sec_8_type_code==1 & rural==1,                   by(household_id2) // livestock holded/owned
egen largerum_cross_r=sum(ls_sec_8_1q02) if ls_sec_8_type_code==1 & ls_sec_8_1q01>0 & rural==1, by(household_id2) // crossbred animals


* Small ruminants
egen smallrum_nbhh= sum(ls_sec_8_1q01) if ls_sec_8_type_code==2,                   by(household_id2) // livestock holded/owned
egen smallrum_cross=sum(ls_sec_8_1q02) if ls_sec_8_type_code==2 & ls_sec_8_1q01>0, by(household_id2) // crossbred animals

egen smallrum_nbhh_r= sum(ls_sec_8_1q01) if ls_sec_8_type_code==2 & rural==1,                  by(household_id2) // livestock holded/owned
egen smallrum_cross_r=sum(ls_sec_8_1q02) if ls_sec_8_type_code==2 & ls_sec_8_1q01>0 & rural==1, by(household_id2) // crossbred animals

* Poultry
egen poultry_nbhh= sum(ls_sec_8_1q01) if ls_sec_8_type_code==4,                   by(household_id2) // livestock holded/owned
egen poultry_cross=sum(ls_sec_8_1q02) if ls_sec_8_type_code==4 & ls_sec_8_1q01>0, by(household_id2) // crossbred animals

egen poultry_nbhh_r= sum(ls_sec_8_1q01) if ls_sec_8_type_code==4 & rural==1,                   by(household_id2) // livestock holded/owned
egen poultry_cross_r=sum(ls_sec_8_1q02) if ls_sec_8_type_code==4 & ls_sec_8_1q01>0 & rural==1, by(household_id2) // crossbred animals


* Max number of crossbred animals
foreach i in largerum smallrum poultry {
egen `i'_crossm=max(`i'_cross), by(household_id2)
egen `i'_crossm_r=max(`i'_cross_r), by(household_id2)

}
* Nb. of animals owned/kept, and crossbred
foreach i in largerum smallrum poultry {

replace `i'_nbhh=0     if `i'_nbhh==.    &  hh_liv!=.
replace `i'_crossm=0   if `i'_cross==.   &  `i'_d==1
replace `i'_cross=`i'_crossm 
drop `i'_crossm

replace `i'_nbhh_r=0     if `i'_nbhh_r==.    &  hh_liv_r!=.
replace `i'_crossm_r=0   if `i'_cross_r==.   &  `i'_d_r==1
replace `i'_cross_r=`i'_crossm_r 
drop `i'_crossm_r



}

* Dummy for owning at least 1 crossbred animal per hh
g       hhd_cross=.
replace hhd_cross=0 if hh_liv==1 
replace hhd_cross=1 if             (largerum_cross>0 & largerum_cross!=.) | (smallrum_cross>0 & smallrum_cross!=.) | (poultry_cross>0 & poultry_cross!=.)

g       hhd_cross_r=.
replace hhd_cross_r=0 if hh_liv_r==1 
replace hhd_cross_r=1 if             (largerum_cross_r>0 & largerum_cross_r!=.) | (smallrum_cross_r>0 & smallrum_cross_r!=.) | (poultry_cross_r>0 & poultry_cross_r!=.)



foreach i in largerum smallrum poultry {
g       hhd_cross_`i'=. if hh_liv==0
replace hhd_cross_`i'=0 if hh_liv==1 
replace hhd_cross_`i'=1 if hh_liv==1 & `i'_cross>0  & `i'_cross!=.

g       hhd_cross_`i'_r=. if hh_liv_r==0
replace hhd_cross_`i'_r=0 if hh_liv_r==1 
replace hhd_cross_`i'_r=1 if hh_liv_r==1 & `i'_cross_r>0  & `i'_cross_r!=.

}


* Shares of livestock per HH 
foreach i in largerum smallrum poultry {

* Share of crossbred per hh HOLDED/OWNED
g       sh_hh_`i'=(`i'_cross/`i'_nbhh)*100 // household level
replace sh_hh_`i'=0 if `i'_cross==0 & `i'_nbhh==0 & hh_liv==1

g       sh_hh_`i'_r=(`i'_cross_r/`i'_nbhh_r)*100 // household level
replace sh_hh_`i'_r=0 if `i'_cross_r==0 & `i'_nbhh_r==0 & hh_liv_r==1



}

* Dummy for artificial insemination by hh
g       livIA=.
replace livIA=0 if (ls_sec_8_3q02!=5 | ls_sec_8_3q01==2) & hh_liv==1
replace livIA=1 if ls_sec_8_3q02==5
lab var livIA "Livestock AI"

g       livIA_r=.
replace livIA_r=0 if (ls_sec_8_3q02!=5 | ls_sec_8_3q01==2) & hh_liv_r==1 & rural==1
replace livIA_r=1 if ls_sec_8_3q02==5 & rural==1
lab var livIA_r "Livestock AI"




egen hhd_livIA=max(livIA), by(household_id2)
egen hhd_livIA_r=max(livIA) if rural==1, by(household_id2)

* Dummy artificial insemination by livestock type
g       lr_livIA=.
replace lr_livIA=0 if (ls_sec_8_3q02!=5 | ls_sec_8_3q01==2) & ls_sec_8_type_code==1 & ls_sec_8_1q01>0 & ls_sec_8_1q01!=. //large ruminants
replace lr_livIA=1 if  ls_sec_8_3q02==5                     & ls_sec_8_type_code==1 & ls_sec_8_1q01>0 & ls_sec_8_1q01!=. //large ruminants

g       sr_livIA=.
replace sr_livIA=0 if (ls_sec_8_3q02!=5 | ls_sec_8_3q01==2) & ls_sec_8_type_code==2 & ls_sec_8_1q01>0 & ls_sec_8_1q01!=. //smallruminants
replace sr_livIA=1 if  ls_sec_8_3q02==5                     & ls_sec_8_type_code==2 & ls_sec_8_1q01>0 & ls_sec_8_1q01!=. //smallruminants

g       po_livIA=.
replace po_livIA=0 if (ls_sec_8_3q02!=5 | ls_sec_8_3q01==2) & ls_sec_8_type_code==4 & ls_sec_8_1q01>0 & ls_sec_8_1q01!=. //poultry
replace po_livIA=1 if  ls_sec_8_3q02==5                     & ls_sec_8_type_code==4 & ls_sec_8_1q01>0 & ls_sec_8_1q01!=. //poultry
 
** Rural
g       lr_livIA_r=.
replace lr_livIA_r=0 if rural==1 & (ls_sec_8_3q02!=5 | ls_sec_8_3q01==2) & ls_sec_8_type_code==1 & ls_sec_8_1q01>0 & ls_sec_8_1q01!=. //large ruminants
replace lr_livIA_r=1 if rural==1 & ls_sec_8_3q02==5                     & ls_sec_8_type_code==1 & ls_sec_8_1q01>0 & ls_sec_8_1q01!=. //large ruminants

g       sr_livIA_r=.
replace sr_livIA_r=0 if  rural==1 & (ls_sec_8_3q02!=5 | ls_sec_8_3q01==2) & ls_sec_8_type_code==2 & ls_sec_8_1q01>0 & ls_sec_8_1q01!=. //smallruminants
replace sr_livIA_r=1 if  rural==1 &  ls_sec_8_3q02==5                     & ls_sec_8_type_code==2 & ls_sec_8_1q01>0 & ls_sec_8_1q01!=. //smallruminants

g       po_livIA_r=.
replace po_livIA_r=0 if rural==1 & (ls_sec_8_3q02!=5 | ls_sec_8_3q01==2) & ls_sec_8_type_code==4 & ls_sec_8_1q01>0 & ls_sec_8_1q01!=. //poultry
replace po_livIA_r=1 if rural==1 &  ls_sec_8_3q02==5                     & ls_sec_8_type_code==4 & ls_sec_8_1q01>0 & ls_sec_8_1q01!=. //poultry
 

* Feed and forages

g       elepgrass =.
replace elepgrass=0 if (ls_sec_8_4q10==2 | ls_sec_8_4q11!=1) & hh_liv==1
replace elepgrass=1 if ls_sec_8_4q11==1

g       elepgrass_r =.
replace elepgrass_r=0 if rural==1 & (ls_sec_8_4q10==2 | ls_sec_8_4q11!=1) & hh_liv_r==1
replace elepgrass_r=1 if rural==1 & ls_sec_8_4q11==1


g       gaya=.
replace gaya=0 if (ls_sec_8_4q10==2 | ls_sec_8_4q11!=2) & hh_liv==1
replace gaya=1 if ls_sec_8_4q11==2

g       gaya_r=.
replace gaya_r=0 if rural==1 & (ls_sec_8_4q10==2 | ls_sec_8_4q11!=2) & hh_liv_r==1
replace gaya_r=1 if rural==1 & ls_sec_8_4q11==2


g       sasbaniya =.
replace sasbaniya=0 if (ls_sec_8_4q10==2 | ls_sec_8_4q11!=3) & hh_liv==1
replace sasbaniya=1 if ls_sec_8_4q11==3

g       sasbaniya_r=.
replace sasbaniya_r=0 if rural==1 & (ls_sec_8_4q10==2 | ls_sec_8_4q11!=3) & hh_liv==1
replace sasbaniya_r=1 if rural==1 & ls_sec_8_4q11==3


g alfa      =.
replace alfa=0 if (ls_sec_8_4q10==2 | ls_sec_8_4q11!=6) & hh_liv==1
replace alfa=1 if ls_sec_8_4q11==6

g       alfa_r=.
replace alfa_r=0 if rural==1 & (ls_sec_8_4q10==2 | ls_sec_8_4q11!=6) & hh_liv==1
replace alfa_r=1 if rural==1 & ls_sec_8_4q11==6


g       indprod      =.
replace indprod=0 if (ls_sec_8_4q10==2 | ls_sec_8_4q11!=6) & hh_liv==1
replace indprod=1 if ls_sec_8_4q11==7

g       indprod_r=.
replace indprod_r=0 if rural==1 & (ls_sec_8_4q10==2 | ls_sec_8_4q11!=6) & hh_liv==1
replace indprod_r=1 if rural==1 & ls_sec_8_4q11==7

g       grass      =.
replace grass=0 if (ls_sec_8_4q10==2 | ls_sec_8_4q11!=6) & hh_liv==1
replace grass=1 if elepgrass==1 | gaya==1 | sasbaniya==1 | alfa==1



g       grass_r=.
replace grass_r=0 if rural==1 & (ls_sec_8_4q10==2 | ls_sec_8_4q11!=6) & hh_liv==1
replace grass_r=1 if rural==1 & elepgrass==1 | gaya==1 | sasbaniya==1 | alfa==1





foreach i in  elepgrass gaya sasbaniya alfa indprod grass {
*Dummy for hh 
egen hhd_`i'=max(`i'), by(household_id2)
egen hhd_`i'_r=max(`i'_r), by(household_id2)

*Dummy by livestock type
g lr_`i'=`i' if ls_sec_8_type_code==1 & ls_sec_8_1q01>0 & ls_sec_8_1q01!=.   //large ruminants
g sr_`i'=`i' if ls_sec_8_type_code==2 & ls_sec_8_1q01>0 & ls_sec_8_1q01!=.   //small ruminants
g po_`i'=`i' if ls_sec_8_type_code==4 & ls_sec_8_1q01>0 & ls_sec_8_1q01!=.   //poultry

g lr_`i'_r=`i'_r if ls_sec_8_type_code==1 & ls_sec_8_1q01>0 & ls_sec_8_1q01!=.   //large ruminants
g sr_`i'_r=`i'_r if ls_sec_8_type_code==2 & ls_sec_8_1q01>0 & ls_sec_8_1q01!=.   //small ruminants
g po_`i'_r=`i'_r if ls_sec_8_type_code==4 & ls_sec_8_1q01>0 & ls_sec_8_1q01!=.   //poultry



}   

* Plot level data - Animal Agriculture
preserve
save "${data}${slash}ess3_pp_livestock_plot", replace
restore

* Collapse at the hh-level
collapse (max) hh_liv* largerum_nbhh* largerum_cross* smallrum_nbhh* smallrum_cross* sh*  lr* sr* po* hhd*, by(household_id2)

lab var hhd_cross			 "At least 1 crossbred animal in hh"
lab var largerum_cross       "Crossbred large ruminants"
lab var largerum_nbhh        "No. of LARGE RUMINANTS per hh - HOLD"
lab var smallrum_cross       "Crossbred small ruminants" 
lab var smallrum_nbhh        "No. of SMALL RUMINANTS per hh - HOLD"
lab var poultry_cross        "Crossbred poultry"
lab var poultry_nbhh         "No. of POULTRY per hh - HOLD"


lab var hhd_livIA            "AI on any livestock type"
lab var lr_livIA             "Large ruminants: AI"
lab var sr_livIA             "Small ruminants: AI"
lab var po_livIA             "Poultry: AI"

lab var hhd_elepgrass        "Feed and Forage: Elephant Grass"
lab var hhd_gaya             "Feed and Forage: Gaya"
lab var hhd_sasbaniya        "Feed and Forage: Sasbaniya"
lab var hhd_alfa             "Feed and Forage: Alfalfa"
lab var hhd_indprod			 "Feed and Forage: Industry by-products"
lab var hhd_grass			 "Elephant grass, gaya, sasbaniya, alfalfa"
lab var lr_elepgrass         "Large ruminants: Elephant Grass"
lab var lr_gaya              "Large ruminants: Gaya"
lab var lr_sasbaniya         "Large ruminants: Sasbaniya"
lab var lr_alfa              "Large ruminants: Alfalfa"
lab var lr_indprod			 "Large ruminants: Industry by-products"

lab var sr_elepgrass         "Small ruminants: Elephant Grass"
lab var sr_gaya              "Small ruminants: Gaya"
lab var sr_sasbaniya         "Small ruminants: Sasbaniya"
lab var sr_alfa              "Small ruminants: Alfalfa"
lab var sr_indprod			 "Small ruminants: Industry by-products"

lab var po_elepgrass         "Poultry: Elephant Grass"
lab var po_gaya              "Poultry: Gaya"
lab var po_sasbaniya         "Poultry: Sasbaniya"
lab var po_alfa              "Poultry: Alfalfa"
lab var po_indprod			 "Poultry: Industry by-products"

*RURAL
lab var hhd_cross_r			 "At least 1 crossbred animal in hh - rural"
lab var largerum_cross_r     "Crossbred large ruminants - rural"
lab var largerum_nbhh_r      "No. of LARGE RUMINANTS per hh - HOLD - rural"
lab var smallrum_cross_r     "Crossbred small ruminants - rural" 
lab var smallrum_nbhh_r      "No. of SMALL RUMINANTS per hh - HOLD - rural"
lab var poultry_cross_r      "Crossbred poultry - rural"
lab var poultry_nbhh_r       "No. of POULTRY per hh - HOLD - rural"


lab var hhd_livIA_r          "AI on any livestock type - rural"
lab var lr_livIA_r           "Large ruminants: AI - rural"
lab var sr_livIA_r           "Small ruminants: AI - rural"
lab var po_livIA_r           "Poultry: AI - rural"

lab var hhd_elepgrass_r      "Feed and Forage: Elephant Grass - rural"
lab var hhd_gaya_r           "Feed and Forage: Gaya - rural"
lab var hhd_sasbaniya_r      "Feed and Forage: Sasbaniya - rural"
lab var hhd_alfa_r           "Feed and Forage: Alfalfa - rural"
lab var hhd_indprod_r		 "Feed and Forage: Industry by-products - rural"

lab var lr_elepgrass_r       "Large ruminants: Elephant Grass - rural"
lab var lr_gaya_r            "Large ruminants: Gaya - rural"
lab var lr_sasbaniya_r       "Large ruminants: Sasbaniya - rural"
lab var lr_alfa_r            "Large ruminants: Alfalfa - rural"
lab var lr_indprod_r	     "Large ruminants: Industry by-products - rural"

lab var sr_elepgrass_r       "Small ruminants: Elephant Grass - rural"
lab var sr_gaya_r            "Small ruminants: Gaya - rural"
lab var sr_sasbaniya_r       "Small ruminants: Sasbaniya - rural"
lab var sr_alfa_r            "Small ruminants: Alfalfa - rural"
lab var sr_indprod_r	     "Small ruminants: Industry by-products - rural"

lab var po_elepgrass_r       "Poultry: Elephant Grass - rural"
lab var po_gaya_r            "Poultry: Gaya - rural"
lab var po_sasbaniya_r       "Poultry: Sasbaniya - rural"
lab var po_alfa_r            "Poultry: Alfalfa - rural"
lab var po_indprod_r	     "Poultry: Industry by-products - rural"





tempfile PP_W3S81
save `PP_W3S81'

********************************************************************************
* MERGE DIFFERENT MODULES *
********************************************************************************


use `w3_coverPP', clear

merge 1:1 household_id2 using `PP_W3S3'

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                            79
        from master                        79  (_merge==1)
        from using                          0  (_merge==2)

    matched                             3,643  (_merge==3)
    -----------------------------------------
*/
drop _merge

merge 1:1 household_id2 using `PP_W3S81'
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                             0
    matched                             3,722  (_merge==3)
    -----------------------------------------

*/
drop _merge

merge 1:1 household_id2 using `pp_w3s4'
/*
  Result                           # of obs.
    -----------------------------------------
    not matched                           654
        from master                       654  (_merge==1)
        from using                          0  (_merge==2)

    matched                             3,068  (_merge==3)
    -----------------------------------------

*/
drop _m 


merge 1:1 household_id2 using "${raw3}${slash}sect_cover_hh_w3.dta"

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                         1,286
        from master                        27  (_merge==1)
        from using                      1,259  (_merge==2)

    matched                             3,695  (_merge==3)
    -----------------------------------------
*/
drop if _m==2
drop _m




lab var sh_hh_largerum "Crossbred large ruminants" 
lab var sh_hh_smallrum "Crossbred small ruminants"
lab var sh_hh_poultry  "Crossbred poultry"

lab var sh_hh_largerum_r "Crossbred large ruminants - rural" 
lab var sh_hh_smallrum_r "Crossbred small ruminants - rural"
lab var sh_hh_poultry_r  "Crossbred poultry - rural"


* RECAP
* NRM: INTENSIVE MARGIN:  (DUMMY PER HH)
* 	- 	hh_treadle hh_motorpump hh_rotlegume hh_cresidue hh_mintillage hh_consag hh_swc hh_rdisp
* 		EXTENSIVE MARGIN (SHARE OF PLOT PER HH)
*   -   sh_plothh_treadle sh_plothh_motorpump sh_plothh_rotlegume sh_plothh_cresidue sh_plothh_mintillage sh_plothh_consag sh_plothh_swc sh_plothh_rdisp

* ANIMAL AGRICULTURE:
*  CROSSBRED ANIMAL
*  INTENSIVE MARGIN (DUMMY PER HH) : hh_cross_largerum hh_cross_smallrum hh_cross_poultry
*  EXTENSIVE MARGIN : % OF CROSSBRED ANIMAL PER HH
* 				sh_hh_largerum sh_hh_smallrum sh_hh_poultry			 
* 

g wave=3	
clonevar region=saq01
replace region=0 if region==2 | region==6 | region==15 | region==12 | region==13 | region==5


lab var hhd_cross_poultry    "Crossbred poultry"
lab var hhd_cross_largerum   "Crossbred large ruminants"
lab var hhd_cross_smallrum   "Crossbred small ruminants"

lab var hhd_cross_poultry_r  "Crossbred poultry - rural"
lab var hhd_cross_largerum_r "Crossbred large ruminants - rural"
lab var hhd_cross_smallrum_r "Crossbred small ruminants - rural"


local hhd hhd_* 
foreach var of varlist `hhd' {
replace `var'=`var'*100	

}

* Cleaning intermediate variables
drop impcr*max impcr*_sum*

save "${data}${slash}ess3_pp_hh", replace
save "${data}${slash}wave3_hh", replace

********************************************************************************
* EA - LEVEL ANALYSIS *
********************************************************************************
use "${data}${slash}wave3_hh", clear


foreach i in  treadle motorpump rotlegume cresidue1 cresidue2 mintillage zerotill consag1 consag2 swc terr wcatch affor ploc rdisp bbm livIA elepgrass gaya sasbaniya alfa indprod cross grass {
g       ead_`i'=.
replace ead_`i'=0 if hhd_`i'==0
replace ead_`i'=1 if hhd_`i'==100

egen nbhhd_`i'=sum(hhd_`i'), by(ea_id)
g sh_ea_`i'=(nbhhd_`i'/hh_ea) if nbhhd_`i'!=.  


g       ead_`i'_r=.
replace ead_`i'_r=0 if hhd_`i'_r==0
replace ead_`i'_r=1 if hhd_`i'_r==100

egen nbhhd_`i'_r=sum(hhd_`i'_r), by(ea_id)
g sh_ea_`i'_r=(nbhhd_`i'_r/hh_ea_r) if nbhhd_`i'_r!=.  



}

rename sh_hhea_ofsp     sh_ea_ofsp
rename sh_hhea_awassa83 sh_ea_awassa83
rename sh_hhea_avocado  sh_ea_avocado
rename sh_hhea_mango    sh_ea_mango
rename sh_hhea_papaya   sh_ea_papaya
rename sh_hhea_sweetpotato sh_ea_sweetpotato
rename sh_hhea_fieldp   sh_ea_fieldp
rename sh_hhea_desi     sh_ea_desi
rename sh_hhea_kabuli   sh_ea_kabuli

rename sh_hhea_ofsp_r     sh_ea_ofsp_r
rename sh_hhea_awassa83_r sh_ea_awassa83_r
rename sh_hhea_avocado_r  sh_ea_avocado_r
rename sh_hhea_mango_r    sh_ea_mango_r
rename sh_hhea_papaya_r   sh_ea_papaya_r
rename sh_hhea_sweetpotato_r sh_ea_sweetpotato_r
rename sh_hhea_fieldp_r   sh_ea_fieldp_r
rename sh_hhea_desi_r     sh_ea_desi_r
rename sh_hhea_kabuli_r   sh_ea_kabuli_r

foreach i in impcr1 impcr2 impcr3 impcr4 impcr5 impcr6 impcr7 impcr8 impcr9 impcr10 impcr11 impcr12 impcr13 impcr14 impcr15 impcr18 impcr19 impcr23 impcr24 impcr25 impcr26 impcr27 impcr42 impcr49 impcr60 impcr62 impcr71 impcr72 impveg impftr improot impccr {
rename sh_hhea_`i'  sh_ea_`i' 
rename sh_hhea_`i'_r  sh_ea_`i'_r 
}

g       ead_feed=0
replace ead_feed=1 if nbhhd_elepgrass>0 | nbhhd_gaya>0 | nbhhd_sasbaniya>0 | nbhhd_alfa>0 | nbhhd_indprod>0

*Livestock
foreach i in largerum smallrum poultry {
g       ead_cross_`i'=.
replace ead_cross_`i'=0 if hhd_cross_`i'==0
replace ead_cross_`i'=1 if hhd_cross_`i'==100

egen eanb_`i'_cross=sum(`i'_cross), by(ea_id)
egen eanb_`i'=sum(`i'_nbhh), by(ea_id)
g   sh_ea_`i'=(eanb_`i'_cross/eanb_`i') if eanb_`i'_cross!=.


g       ead_cross_`i'_r=.
replace ead_cross_`i'_r=0 if hhd_cross_`i'_r==0
replace ead_cross_`i'_r=1 if hhd_cross_`i'_r==100

egen eanb_`i'_cross_r=sum(`i'_cross_r), by(ea_id)
egen eanb_`i'_r=sum(`i'_nbhh_r), by(ea_id)
g   sh_ea_`i'_r=(eanb_`i'_cross_r/eanb_`i'_r) if eanb_`i'_cross_r!=.



}

collapse (max) sh_plotea*  ead* sh_ea_* wave pw_w3 region (firstnm) rural ea_id2,  by(ea_id)

foreach i in treadle motorpump rotlegume cresidue1 cresidue2 mintillage zerotill consag1 consag2 swc terr wcatch affor ploc rdisp livIA elepgrass gaya sasbaniya alfa indprod cross grass {

replace ead_`i' =0  if ead_`i' ==.
replace sh_ea_`i'=. if ead_`i'==0 

replace ead_`i'_r =0  if ead_`i'_r ==. & rural==1
replace sh_ea_`i'_r=. if ead_`i'_r==0 & rural==1




}

foreach i in ofsp awassa83 desi kabuli avocado mango fieldp papaya sweetpotato  impcr1 impcr2 impcr3 impcr4 impcr5 impcr6 impcr7 impcr8 impcr9 impcr10 impcr11 impcr12 impcr13 impcr14 impcr15 impcr18 impcr19 impcr23 impcr24 impcr25 impcr26 impcr27 impcr42 impcr49 impcr60 impcr62 impcr71 impcr72 impveg impftr improot impccr {
replace sh_plotea_`i'=.   if ead_`i'==0
replace sh_plotea_`i'_r=. if ead_`i'_r==0 & rural==1

replace ead_`i' =0        if ead_`i'==.
replace sh_ea_`i'=.       if ead_`i'==0 

*replace ead_`i'_r =0      if ead_`i'_r ==. & rural==1
*replace sh_ea_`i'_r=.     if ead_`i'_r==0  & rural==1


}

foreach i in largerum smallrum poultry {
replace ead_cross_`i'   =0 if ead_cross_`i' ==.
replace ead_cross_`i'_r =0 if ead_cross_`i'_r ==. & rural==1

replace sh_ea_`i'=.   if ead_cross_`i'==0 
replace sh_ea_`i'_r=. if ead_cross_`i'==0 & rural==1

}




local ead ead*
foreach var of varlist `ead' {
replace `var'=`var'*100
}



foreach i in ead_ofsp sh_plotea_ofsp sh_ea_ofsp {
lab var `i'     "Sweet potato OFSP variety"
lab var `i'_r   "Sweet potato OFSP variety - rural"

}

foreach i in  ead_awassa83  sh_plotea_awassa83 sh_ea_awassa83 {
lab var `i'     "Sweet potato Awassa83 variety"
lab var `i'_r   "Sweet potato Awassa83 variety - rural"

}

foreach i in  ead_desi sh_plotea_desi sh_ea_desi {
lab var `i'     "Desi chickpea type"
lab var `i'_r   "Desi chickpea type - rural"

}

foreach i in  ead_kabuli sh_plotea_kabuli sh_ea_kabuli {
lab var `i'    "Kabuli chickpea type"
lab var `i'_r  "Kabuli chickpea type - rural"

}


foreach i in ead_avocado sh_plotea_avocado sh_ea_avocado {
lab var `i'   "Avocado tree"
lab var `i'_r "Avocado tree - rural"
}
foreach i in ead_papaya sh_plotea_papaya sh_ea_papaya {
lab var `i'   "Papaya tree"
lab var `i'_r "Papaya tree - rural"
}
foreach i in ead_sweetpotato sh_plotea_sweetpotato sh_ea_sweetpotato {
lab var `i'   "Sweetpotato"
lab var `i'_r "Sweetpotato - rural"
}
foreach i in ead_fieldp sh_plotea_fieldp sh_ea_fieldp {
lab var `i' "Field peas"
lab var `i'_r "Field peas - rural"
}
foreach i in ead_mango sh_plotea_mango sh_ea_mango {
lab var `i'   "Mango tree"
lab var `i'_r "Mango tree - rural"
}


foreach i of varlist *impcr1*{
    lab var `i' "Improved  BARLEY-SR"
	}
foreach i of varlist *impcr2*{
    lab var `i' "Improved  MAIZE-SR"
	}
foreach i of varlist *impcr3*{
    lab var `i' "Improved  MILLET-SR"
	}
foreach i of varlist *impcr4*{
    lab var `i' "Improved  OATS-SR"
	}
foreach i of varlist *impcr5*{
    lab var `i' "Improved  RICE-SR"
	}
foreach i of varlist *impcr6*{
    lab var `i' "Improved  SORGHUM-SR"
	}
foreach i of varlist *impcr7*{
    lab var `i' "Improved  TEFF-SR"
	}
foreach i of varlist *impcr8*{
    lab var `i' "Improved  WHEAT-SR"
	}
foreach i of varlist *impcr9*{
    lab var `i' "Improved  Mung Bean/ MASHO-SR"
	}
foreach i of varlist *impcr10*{
    lab var `i' "Improved  CASSAVA-SR"
	}
foreach i of varlist *impcr11*{
    lab var `i' "Improved  CHICK PEAS-SR"
	}
foreach i of varlist *impcr12*{
    lab var `i' "Improved  HARICOT BEANS-SR"
	}
foreach i of varlist *impcr13*{
    lab var `i' "Improved  HORSE BEANS-SR"
	}
foreach i of varlist *impcr14*{
    lab var `i' "Improved  LENTILS-SR"
	}
foreach i of varlist *impcr15*{
    lab var `i' "Improved  FIELD PEAS-SR"
	}
foreach i of varlist *impcr18*{
    lab var `i' "Improved  SOYA BEANS-SR"
	}
foreach i of varlist *impcr19*{
    lab var `i' "Improved  RED KIDENY BEANS-SR"
	}
foreach i of varlist *impcr23*{
    lab var `i' "Improved  LINESEED-SR"
	}
foreach i of varlist *impcr24*{
    lab var `i' "Improved  GROUND NUTS-SR"
	}
foreach i of varlist *impcr25*{
    lab var `i' "Improved  NUEG-SR"
	}
foreach i of varlist *impcr26*{
    lab var `i' "Improved  RAPE SEED-SR"
	}
foreach i of varlist *impcr27*{
    lab var `i' "Improved  SESAME-SR"
	}
foreach i of varlist *impcr42*{
    lab var `i' "Improved  BANANAS-SR"
	}
foreach i of varlist *impcr49*{
    lab var `i' "Improved  PINAPPLES-SR"
	}
foreach i of varlist *impcr60*{
    lab var `i' "Improved  POTATOES-SR"
	}
foreach i of varlist *impcr62*{
    lab var `i' "Improved  SWEET POTATO-SR"
	}
foreach i of varlist *impcr71*{
    lab var `i' "Improved  CHAT-SR"
	}
foreach i of varlist *impcr72*{
    lab var `i' "Improved  COFFEE-SR"
	}





lab var ead_treadle          "Treadle pump" 
lab var ead_motorpump        "Motor pump"
lab var ead_rdisp            "River dispersion" 
lab var ead_rotlegume        "Crop rotation with a legume"
lab var ead_cresidue1        "Crop residue cover - farmer elicitation"
lab var ead_cresidue2        "Crop residue cover - visual aid"
lab var ead_mintillage       "Minimum tillage"
lab var ead_zerotill         "Zero tillage"
lab var ead_consag1          "Conservation Agriculture - using minimum tillage"
lab var ead_consag2          "Conservation Agriculture - using zero tillage"
lab var ead_swc              "Soil Water Conservation practices"
lab var ead_terr             "Terracing"
lab var ead_wcatch           "Water catchments"
lab var ead_affor            "Afforestation"
lab var ead_ploc             "Plough along the contour" 
lab var ead_bbm 		     "Broad Bed Maker"


lab var ead_livIA            "Livestock AI"
lab var ead_elepgrass        "Feed and Forage: Elephant Grass"
lab var ead_gaya             "Feed and Forage: Gaya"
lab var ead_sasbaniya        "Feed and Forage: Sasbaniya"
lab var ead_alfa             "Feed and Forage: Alfalfa"
lab var ead_indprod          "Feed and Forage: Industry by-product"
lab var ead_grass 			 "Elephant grass, gaya, sasbaniya, alfalfa"
lab var sh_ea_treadle        "Treadle pump" 
lab var sh_ea_motorpump      "Motor pump"
lab var sh_ea_rdisp          "River dispersion" 
lab var sh_ea_rotlegume      "Crop rotation with a legume"
lab var sh_ea_cresidue1      "Crop residue cover - farmer elicitation"
lab var sh_ea_cresidue2      "Crop residue cover - visual aid"
lab var sh_ea_mintillage     "Minimum tillage"
lab var sh_ea_zerotill		 "Zero tillage"
lab var sh_ea_consag1        "Conservation Agriculture - using minimum tillage"
lab var sh_ea_consag2        "Conservation Agriculture - using zero tillage"
lab var sh_ea_swc            "Soil Water Conservation practices"
lab var sh_ea_terr           "Terracing"
lab var sh_ea_wcatch         "Water catchments"
lab var sh_ea_affor          "Afforestation"
lab var sh_ea_ploc           "Plough along the contour" 
lab var sh_ea_bbm            "Broad Bed Maker"

lab var sh_ea_livIA          "Livestock AI"
lab var sh_ea_elepgrass      "Feed and Forage: Elephant Grass"
lab var sh_ea_gaya           "Feed and Forage: Gaya"
lab var sh_ea_sasbaniya      "Feed and Forage: Sasbaniya"
lab var sh_ea_alfa           "Feed and Forage: Alfalfa"
lab var sh_ea_indprod        "Feed and Forage: Industry by-products"

lab var ead_cross            "Crossbreeding of large ruminants, small ruminants and poultry"
lab var ead_cross_largerum   "Crossbred large ruminants"
lab var ead_cross_smallrum   "Crossbred small ruminants"
lab var ead_cross_poultry    "Crossbred poultry"

lab var sh_ea_cross          "Crossbreeding of large ruminants, small ruminants and/or poultry"
lab var sh_ea_largerum       "Crossbred large ruminants"
lab var sh_ea_smallrum       "Crossbred small ruminants"
lab var sh_ea_poultry        "Crossbred poultry"

* Rural
lab var ead_treadle_r        "Treadle pump - rural" 
lab var ead_motorpump_r      "Motor pump - rural"
lab var ead_rdisp_r          "River dispersion - rural" 
lab var ead_rotlegume_r      "Crop rotation with a legume - rural"
lab var ead_cresidue1_r      "Crop residue cover - farmer elicitation - rural"
lab var ead_cresidue2_r      "Crop residue cover - visual aid - rural"
lab var ead_mintillage_r     "Minimum tillage - rural"
lab var ead_consag1_r        "Conservation Agriculture - using minimum tillage - rural"
lab var ead_consag2_r        "Conservation Agriculture - using zero tillage - rural"
lab var ead_swc_r            "Soil Water Conservation practices - rural" 
lab var ead_terr_r           "Terracing - rural"
lab var ead_wcatch_r         "Water catchments - rural"
lab var ead_affor_r          "Afforestation - rural"
lab var ead_ploc_r           "Plough along the contour - rural" 
lab var ead_bbm_r 		     "Broad Bed Maker - rural"


lab var ead_livIA_r          "Livestock AI - rural"
lab var ead_elepgrass_r      "Feed and Forage: Elephant Grass - rural"
lab var ead_gaya_r           "Feed and Forage: Gaya - rural"
lab var ead_sasbaniya_r      "Feed and Forage: Sasbaniya - rural"
lab var ead_alfa_r           "Feed and Forage: Alfalfa - rural"
lab var ead_indprod_r        "Feed and Forage: Industry by-product - rural"

lab var sh_ea_treadle_r      "Treadle pump - rural" 
lab var sh_ea_motorpump_r    "Motor pump - rural"
lab var sh_ea_rdisp_r        "River dispersion - rural" 
lab var sh_ea_rotlegume_r    "Crop rotation with a legume - rural"
lab var sh_ea_cresidue1_r    "Crop residue cover - farmer elicitation - rural"
lab var sh_ea_cresidue2_r    "Crop residue cover - visual aid - rural"
lab var sh_ea_mintillage_r   "Minimum tillage - rural"
lab var sh_ea_consag1_r      "Conservation Agriculture - using minimum tillage - rural"
lab var sh_ea_consag2_r      "Conservation Agriculture - using zero tillage - rural"
lab var sh_ea_swc_r          "Soil Water Conservation practices - rural" 
lab var sh_ea_terr_r         "Terracing - rural"
lab var sh_ea_wcatch_r       "Water catchments - rural"
lab var sh_ea_affor_r        "Afforestation - rural"
lab var sh_ea_ploc_r         "Plough along the contour - rural" 
lab var sh_ea_bbm_r          "Broad Bed Maker - rural"

lab var sh_ea_livIA_r        "Livestock AI - rural"
lab var sh_ea_elepgrass_r    "Feed and Forage: Elephant Grass - rural"
lab var sh_ea_gaya_r         "Feed and Forage: Gaya - rural"
lab var sh_ea_sasbaniya_r    "Feed and Forage: Sasbaniya - rural"
lab var sh_ea_alfa_r         "Feed and Forage: Alfalfa - rural"
lab var sh_ea_indprod_r      "Feed and Forage: Industry by-products - rural"

lab var ead_cross_r          "Crossbreeding of large ruminants, small ruminants and poultry - rural"
lab var ead_cross_largerum_r "Crossbred large ruminants - rural"
lab var ead_cross_smallrum_r "Crossbred small ruminants - rural"
lab var ead_cross_poultry_r  "Crossbred poultry - rural"

lab var sh_ea_cross_r        "Crossbreeding of large ruminants, small ruminants and/or poultry - rural"
lab var sh_ea_largerum_r     "Crossbred large ruminants - rural"
lab var sh_ea_smallrum_r     "Crossbred small ruminants - rural"
lab var sh_ea_poultry_r      "Crossbred poultry - rural"

 
merge 1:1 ea_id2 using "${rawdata}${slash}Auxiliary_data${slash}ess3_community"
drop if _m==2
drop _merge


save "${data}${slash}wave3_ea", replace
save "${data}${slash}ess3_pp_ea", replace

********************************************************************************
* MERGING PLOT LEVEL DATA
********************************************************************************
use "${data}${slash}ess3_pp_cropvar_plot", clear

merge 1:1 holder_id household_id2 parcel_id field_id using  "${data}${slash}ess3_pp_nrm_plot"

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                x        10,296
        from master                         0  (_merge==1)
        from using                     10,296  (_merge==2)

    matched                            23,009  (_merge==3)
    -----------------------------------------
*/
drop _m 
 
merge m:1 holder_id household_id2 parcel_id using "${data}${slash}w3_sect2_pp_parcel"

/*

    Result                           # of obs.
    -----------------------------------------
    not matched                         3,363
        from master                       214  (_merge==1)
        from using                      3,149  (_merge==2)

    matched                            33,091  (_merge==3)
    -----------------------------------------
*/
drop if _m==2
drop _merge

save "${data}${slash}w3_plotlevel_pp", replace

