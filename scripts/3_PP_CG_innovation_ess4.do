********************************************************************************
********************************************************************************
*                           Ethiopia Synthesis Report 
*                                3_PP_CG_innovation_ess4
* Country: Ethiopia 
* Data:  ESS 4 - Post-Planting survey
* Author: Paola Mallia | p.mallia@cgiar.org | paola_mallia@ymail.com 
* STATA Version: SE 16.1
* OUTPUT: Build variables for CGIAR INNOVATIONS
********************************************************************************

********************************************************************************
* COVER HH 
********************************************************************************
use "${raw4}${slash}HH${slash}sect_cover_hh_w4", clear

keep household_id ea_id saq14 pw_w4 saq01 saq02a saq02b saq03a saq03b saq04a saq04b saq05 saq06a saq06b saq07a saq07b saq08 
tempfile hh_sectcover
save `hh_sectcover'
save "${data}${slash}w4_coverHH", replace

********************************************************************************
* COVER - PP
******************************************************************************** 

use "${raw4new}${slash}PP${slash}sect_cover_pp_w4", clear
count //2,939
tostring saq12, force replace
destring saq16, force replace
tab saq14
/*
        14. |
  Location: |
     rural, |
town, small |
       town |      Freq.     Percent        Cum.
------------+-----------------------------------
      RURAL |      2,939      100.00      100.00
------------+-----------------------------------
      Total |      2,939      100.00
*/

tab saq01

/*

      Region code |      Freq.     Percent        Cum.
------------------+-----------------------------------
           TIGRAY |        388       13.20       13.20
             AFAR |        324       11.02       24.23
           AMHARA |        484       16.47       40.69
           OROMIA |        486       16.54       57.23
           SOMALI |         56        1.91       59.14
BENISHANGUL GUMUZ |        215        7.32       66.45
             SNNP |        424       14.43       80.88
          GAMBELA |        209        7.11       87.99
            HARAR |        191        6.50       94.49
        DIRE DAWA |        162        5.51      100.00
------------------+-----------------------------------
            Total |      2,939      100.00
*/


* UNIQUE IDENTIFIER IS: - INTERVIEW__ID
*						- HOLDER_ID AND HOUSEHOLD_ID


*Nb. of households per EA from PP cover
egen hh_ea=count(household_id), by(ea_id)
lab var hh_ea "Nb. of hh per EA"

duplicates drop household_id  ea_id saq01 saq02 saq03 saq04 saq05 saq06 saq07 saq08 , force

tempfile w4_coverPP
save `w4_coverPP'

save "${data}${slash}w4_coverPP_new", replace

********************************************************************************
* PP - SECT. 1
********************************************************************************
use "${raw4new}${slash}PP${slash}sect1_pp_w4", clear

* NOTHING TO RECOVER

********************************************************************************
* PP - SECT. 2
********************************************************************************
use "${raw4new}${slash}PP${slash}sect2_pp_w4", clear
preserve
* Parcel title
g title=s2q03==1


*Reshape for parcel title hh member listed
reshape long s2q04b_, i(holder_id household_id parcel_id) j(membernb)
drop if s2q04b_==.a & title==1
rename  s2q04b_ s1q00
* Individual characteristics
merge m:1 holder_id household_id s1q00 using  "${raw4new}${slash}PP${slash}sect1_pp_w4"

keep if _m==3
drop _merge

g fow=1 if s1q03==2
bys household_id holder_id parcel_id: egen fowner=max(fow) if title==1
replace fowner=0 if fowner==. & s1q03==1
drop fow


rename s1q00  s2q04b_
drop s1*
collapse (max) fowner title saq15, by(household_id holder_id parcel_id)
lab var fowner "At lest 1 female hh-member listed as owner in parcel title"
lab var title "HH has title for the parcel"
tempfile fowner
save  `fowner'
restore


preserve
reshape long s2q07_, i(holder_id household_id parcel_id) j(membernb)

drop if s2q07_==.a & s2q06==1

rename  s2q07_ s1q00
merge m:1 holder_id household_id s1q00 using  "${raw4new}${slash}PP${slash}sect1_pp_w4"
keep if _m==3

drop _merge
g fow=1 if s1q03==2
bys household_id holder_id parcel_id: egen frsell=max(fow) if s2q06==1
replace frsell=0 if frsell==. & s1q03==1
drop fow


rename s1q00  s2q07_
drop s1*


drop membernb
collapse (max) frsell saq15, by(household_id holder_id parcel_id)
lab var frsell "At lest 1 female hh-member has the right to sell the parcel"
tempfile frsell 
save `frsell'
restore

tab s2q05, g(acqparc)
lab var acqparc1 "Parcel granted by local leaders"
lab var acqparc2 "Parcel acquired as gift/inherited"
lab var acqparc3 "Parcel rented"
lab var acqparc7 "Parcel purchased"
g acqparcoth=0
replace acqparcoth=1 if acqparc4==1 | acqparc5==1 | acqparc8==1
lab var acqparcoth "Parcel acquired through: other means"

lab var acqparc6 "Parcel shared crop"

tab s2q17, g(soilq)
lab var soilq1 "Soil quality: Good"
lab var soilq2 "Soil quality: Fair"
lab var soilq3 "Soil quality: Poor"


tab s2q16, g(soilt)
lab var soilt1 "Soil type: Leptosol"
lab var soilt2 "Soil type: Cambisol"
lab var soilt3 "Soil type: Vertisol"
lab var soilt4 "Soil type: Luvisol"
lab var soilt5 "Soil type: Mixed type"
lab var soilt6 "Soil type: other"

merge 1:1 household_id parcel_id holder_id using `frsell'
drop _merge
merge 1:1 household_id parcel_id holder_id using `fowner'
drop _merge


keep   holder_id household_id parcel_id ea_id title fowner  frsell acqparc1 acqparc2 acqparc3 acqparc4 acqparc5 acqparc6 acqparc7 acqparc8 acqparcoth soilq1 soilq2 soilq3 soilt1 soilt2 soilt3 soilt4 soilt5 soilt6 saq01 saq15

preserve
collapse (max) title fowner frsell , by(household_id)
lab var frsell "At lest 1 female hh-member has the right to sell the parcel"
lab var fowner "At lest 1 female hh-member listed as owner in parcel title"
lab var title "HH has title for the parcel"
save "${data}${slash}ess4_pp_hhlevel_parcel_new", replace
restore

save "${data}${slash}w4_sect2_pp_parcel_new", replace

********************************************************************************
*** PP_Sec.3 - NRM - 
********************************************************************************


use "${raw4new}${slash}PP${slash}sect3_pp_w4", clear

count //19,339

* Nb of hh: 2,879 (household_id)
* Nb of hh: 2,915 (Interview__id)

tab s3q03
/*
  3.During this season, what is |
     the status of this [FIELD]? |      Freq.     Percent        Cum.
---------------------------------+-----------------------------------
                   1. Cultivated |     13,377       69.17       69.17
                      2. Pasture |      1,098        5.68       74.85
                       3. Fallow |        445        2.30       77.15
                       4. Forest |        418        2.16       79.32
5. Land Prepared for Belg Season |        298        1.54       80.86
               6. Home/Homestead |      3,059       15.82       96.67
               7. Other(Specify) |        643        3.33      100.00
---------------------------------+-----------------------------------
                           Total |     19,338      100.00

*/

tab s3q03b
/*
  3.During this season, what is |
    the status of this [FIELD]? |      Freq.     Percent        Cum.
--------------------------------+-----------------------------------
              1. Temporary crop |      9,020       67.43       67.43
              2. Permanent crop |      3,217       24.05       91.48
3. Temporary and permanent crop |      1,140        8.52      100.00
--------------------------------+-----------------------------------
                          Total |     13,377      100.00
*/

* Plot is irrigated*
g plotirr=.
replace plotirr=1 if s3q17==1


* IRRIGATION: LIMITING TO CULTIVATED PLOTS AS PER ENABLING CONDITION 
g       rdisp=.
replace rdisp=0 if (s3q20!=. | s3q17==2) & s3q03==1 //not this irrigation or no irrigation at all
replace rdisp=1 if s3q20==1              & s3q03==1 
replace rdisp=1 if s3q20_os=="Diverting spring" | s3q20_os=="diverting"
 
g       treadle=.
replace treadle=0 if (s3q20!=. | s3q17==2) & s3q03==1 //not this irrigation or no irrigation at all.
replace treadle=1 if  s3q20==2             & s3q03==1 

g       motorpump=.
replace motorpump=0 if (s3q20!=. | s3q17==2) & s3q03==1  //not this irrigation or no irrigation at all.
replace motorpump=1 if  s3q20==3           & s3q03==1 
g motorpum2=0
replace motorpum2=1 if  s3q20==3
* LEGUME ROTATION ask if plot cultivated

g       rotlegume=.
replace rotlegume=0 if s3q34!=. &  s3q03==1
replace rotlegume=1 if s3q34==1 &  s3q03==1 

* CROP RESIDUE:  
* Two versions of variables: 1. using single select question (Only if 1. Cultivated,  2. Pasture, 3. Fallow, 4. Forest, 5. Land Prepared for Belg Season )
* 							 2. using visual aid. (limited to cultivated plot with  1. Temporary crop || 3. Temporary and permanent crop
g       cresidue1=.
replace cresidue1=0 if                         (s3q03>=1 &  s3q03<=5)
replace cresidue1=1 if s3q41==2 & s3q40==1  &  (s3q03>=1 &  s3q03<=5)

g       cresidue2=.
replace cresidue2=0 if s3q42!=.  &  s3q03==1 &  (s3q03b==1 | s3q03b==3)
replace cresidue2=1 if  s3q42>=3 &  s3q03==1 &  (s3q03b==1 | s3q03b==3)

* MINIMUM TILLAGE: cultivated plot with  1. Temporary crop || 3. Temporary and permanent crop

g       mintillage=.
replace mintillage=0 if  s3q03==1 &  (s3q03b==1 | s3q03b==3) & (s3q35>=1 & s3q35<=6)
replace mintillage=1 if  (s3q36==1 | s3q36==2 | s3q36==5) & s3q03==1 &  (s3q03b==1 | s3q03b==3) & (s3q35>=1 & s3q35<=6)

g 		zerotill=.
replace zerotill=0 if                         s3q03==1 &  (s3q03b==1 | s3q03b==3) & (s3q35>=1 & s3q35<=6)
replace zerotill=1 if (s3q36==1 | s3q36==5) & s3q03==1 &  (s3q03b==1 | s3q03b==3) & (s3q35>=1 & s3q35<=6)


* SWC : Only if 1. Cultivated,  2. Pasture, 3. Fallow, 4. Forest, 5. Land Prepared for Belg Season 

g       swc=.
replace swc=0 if (s3q03>=1 &  s3q03<=5) 
replace swc=1 if (s3q39==1 | s3q39==2| s3q39==3 | s3q39==4) & (s3q03>=1 &  s3q03<=5)

g       terr=.
replace terr=0 if (s3q03>=1 &  s3q03<=5) 
replace terr=1 if (s3q39==1) & (s3q03>=1 &  s3q03<=5)

g       wcatch=.
replace wcatch=0 if (s3q03>=1 &  s3q03<=5) 
replace wcatch=1 if (s3q39==2) & (s3q03>=1 &  s3q03<=5)

g       affor=.
replace affor=0 if (s3q03>=1 &  s3q03<=5) 
replace affor=1 if (s3q39==3) & (s3q03>=1 &  s3q03<=5)


g       ploc=.
replace ploc=0 if (s3q03>=1 &  s3q03<=5) 
replace ploc=1 if (s3q39==4) & (s3q03>=1 &  s3q03<=5)


g swc2=0
replace swc2=1 if (s3q39==1 | s3q39==2| s3q39==3 | s3q39==4)


* CONSERVATION AGRICULTURE - with minimum tillage

g 		consag1=.
replace consag1=0 if (rotlegume!=1 | cresidue2!=1 | mintillage!=1) & (s3q03>=1 &  s3q03<=5)
replace consag1=1 if (rotlegume==1 & cresidue2==1 & mintillage==1) & (s3q03>=1 &  s3q03<=5)

* CONSERVATION AGRICULTURE - with zero tillage

g 		consag2=.
replace consag2=0 if (rotlegume!=1 | cresidue2!=1 | zerotill!=1) & (s3q03>=1 &  s3q03<=5)
replace consag2=1 if (rotlegume==1 & cresidue2==1 & zerotill==1) & (s3q03>=1 &  s3q03<=5)


* No. of plots per HH - total
egen hh_plot_nb=count(field_id), by(household_id)
lab var hh_plot_nb "Number of plots per household"

* No. of plots per EA -total
egen ea_plot_nb=count(field_id), by(ea_id)
lab var ea_plot_nb "Number of plots per EA"

* No. of plots IRRIGATED and CULTIVATED per HH
egen hh_plot_irr_nb=count(field_id) if s3q03==1 & s3q17==1, by(household_id)
lab var hh_plot_irr_nb "Number of plots irrigated per household"

egen ea_plot_irr_nb=count(field_id) if s3q03==1 & s3q17==1, by(ea_id)
lab var ea_plot_irr_nb "Number of plots irrigated per EA"

*No. of plots CULTIVATED per HH
egen hh_plot_cult_nb=count(field_id) if s3q03==1, by(household_id)
lab var hh_plot_cult_nb "Number of plots cultivated per household"
egen ea_plot_cult_nb=count(field_id) if s3q03==1, by(ea_id)
lab var ea_plot_cult_nb "Number of plots cultivated per EA"

* No. of plots: CULTIVATED, PASTURE, FALLOW, FOREST, LAND PREPARED FOR BELG SEASON
egen hh_plot_uses_nb=count(field_id) if (s3q03>=1 &  s3q03<=5), by(household_id)
lab var hh_plot_uses_nb "Number of plots cultivated, pasture, fallow, forest etc. per household"

egen ea_plot_uses_nb=count(field_id) if (s3q03>=1 &  s3q03<=5), by(ea_id)
lab var ea_plot_uses_nb "Number of plots cultivated, pasture, fallow, forest etc. per EA"

*No. of plots WITH EROSION PREVENTION per HH (on cultivated, fallow, pasture etc.)
egen hh_plot_eros_nb=count(field_id) if (s3q03>=1 &  s3q03<=5) & s3q38==1, by(household_id)
lab var hh_plot_eros_nb "Number of plots with erosion prevention structures per household"
egen ea_plot_eros_nb=count(field_id) if (s3q03>=1 &  s3q03<=5) & s3q38==1, by(ea_id)
lab var ea_plot_eros_nb "Number of plots  with erosion prevention structures per EA"

*No. of plots CULTIVATED AND TEMPORARY CROP PLANTED
egen hh_plot_cplus_nb=count(field_id) if s3q03==1 &  (s3q03b==1 | s3q03b==3), by(household_id)
lab var hh_plot_cplus_nb "Number of plots cultivated and land prep per household"
egen ea_plot_cplus_nb=count(field_id) if s3q03==1 &  (s3q03b==1 | s3q03b==3), by(ea_id)
lab var ea_plot_cplus_nb "Number of plots cultivated and temp. crop planted per EA"

* No. of plots CULTIVATED, TEMP. CROP AND LAND PREPARATION. 

egen hh_plot_lprep_nb=count(field_id) if s3q03==1 &  (s3q03b==1 | s3q03b==3) & (s3q35>=1 & s3q35<=6), by(household_id)
lab var hh_plot_cplus_nb "Number of plots cultivated and land prep per household"
egen ea_plot_lprep_nb=count(field_id) if s3q03==1 &  (s3q03b==1 | s3q03b==3) & (s3q35>=1 & s3q35<=6), by(ea_id)
lab var ea_plot_cplus_nb "Number of plots cultivated and land prep per EA"

* HOUSEHOLD MEASURE : - UNCONDITIONAL
foreach i in treadle motorpump  rotlegume cresidue1 cresidue2 mintillage zerotill consag1 consag2 swc swc2 terr wcatch affor ploc rdisp {
egen hhd_`i'=max(`i'), by(household_id)
egen hhs_`i'=sum(`i'), by(household_id) 
g sh_plothh_`i'=(hhs_`i'/hh_plot_nb)*100 if hhs_`i'!=. & hhd_`i'==1

} 


* 1. Conditional on plot cultivated 
* 2. Conditional on plot irrigated & cultivated
* 3. Conditional on plot cultivated, pasture, fallow, forest etc.
* 4. Conditional on using soil erosion preventing measures & use
* 5. Cultivated and temporary crop planted
* 6. Cultivated and temporary crop and land preparation
foreach i in treadle motorpump rdisp rotlegume cresidue1 cresidue2   mintillage zerotill consag1 consag2 swc swc2 terr wcatch affor ploc {

g sh_plothh_`i'_cond1=(hhs_`i'/hh_plot_cult_nb)*100  if `i'!=. & hhd_`i'==1
g sh_plothh_`i'_cond2=(hhs_`i'/hh_plot_irr_nb)*100   if `i'!=. & hhd_`i'==1
g sh_plothh_`i'_cond3=(hhs_`i'/hh_plot_uses_nb)*100  if `i'!=. & hhd_`i'==1
g sh_plothh_`i'_cond4=(hhs_`i'/hh_plot_eros_nb)*100  if `i'!=. & hhd_`i'==1
g sh_plothh_`i'_cond5=(hhs_`i'/hh_plot_cplus_nb)*100 if `i'!=. & hhd_`i'==1
g sh_plothh_`i'_cond6=(hhs_`i'/hh_plot_lprep_nb)*100 if `i'!=. & hhd_`i'==1
} 
 
* Plot size (by SR and GPS)
*Change names of vars.


g zone=substr(saq02, -2, .)
g woreda=substr(saq03, -2, .)


rename saq01 region
rename saq04 city
rename saq05 subcity
rename saq06 kebele


destring region zone woreda city subcity kebele, force replace

merge m:1 region zone woreda using "${rawdata}${slash}Auxiliary_data${slash}ESS3_ET_local_area_unit_conversion"

/*
Result	#	of obs.
		
not matched		12,865
from master		12,721	(_merge==1)
from using		144	(_merge==2)

matched		6,618	(_merge==3)
		
*/


drop if _m==2
drop _merge
*SR

g       plotarea_sr=.
replace plotarea_sr=s3q02a                       if s3q02b==1 //ha
replace plotarea_sr=s3q02a/10000                 if (s3q02b==2 | s3q2b_os=="METER" | s3q2b_os=="SQUIRE METER") //sq meters
replace plotarea_sr=(s3q02a*conv_timad  )/10000  if s3q02b==3 & conv_timad!=.
replace plotarea_sr=(s3q02a*conv_timad_z)/10000  if s3q02b==3 & conv_timad==.
replace plotarea_sr=(s3q02a*conv_timad_r)/10000  if s3q02b==3 & conv_timad_z==. & conv_timad==. //timad
replace plotarea_sr=(s3q02a*0.25)                if s3q02b==3 & conv_timad_r==. & conv_timad_z==. & conv_timad==.


replace plotarea_sr=(s3q02a*conv_boy  )/10000 if (s3q02b==4 | s3q2b_os=="BOY") & conv_boy!=.
replace plotarea_sr=(s3q02a*conv_boy_z)/10000 if (s3q02b==4 | s3q2b_os=="BOY")  & conv_boy==.
replace plotarea_sr=(s3q02a*conv_boy_r)/10000 if (s3q02b==4 | s3q2b_os=="BOY")  & conv_boy_z==. & conv_boy==. //boy
replace plotarea_sr=(s3q02a*227.76)/10000     if (s3q02b==4 | s3q2b_os=="BOY") & conv_boy_r==. & conv_boy_z==. & conv_boy==.

replace plotarea_sr=(s3q02a*conv_senga  )/10000 if s3q02b==5 & conv_senga!=.
replace plotarea_sr=(s3q02a*conv_senga_z)/10000 if s3q02b==5 & conv_senga==.
replace plotarea_sr=(s3q02a*conv_senga_r)/10000 if s3q02b==5 & conv_senga_z==. & conv_senga==. //senga
replace plotarea_sr=(s3q02a*1339.289)/10000 if s3q02b==5 & conv_senga_r==. & conv_senga_z==. & conv_senga==.



replace plotarea_sr=(s3q02a*conv_kert  )/10000 if s3q02b==6 & conv_kert!=.
replace plotarea_sr=(s3q02a*conv_kert_z)/10000 if s3q02b==6 & conv_kert==.
replace plotarea_sr=(s3q02a*conv_kert_r)/10000 if s3q02b==6 & conv_kert_z==. & conv_kert==. //kert

replace plotarea_sr=(s3q02a*0.25)/10000 if s3q02b==6 & conv_kert_r==. & conv_kert_z==. & conv_kert==. 


replace plotarea_sr=(s3q02a* 204.4169)/10000 if s3q02b==7 //tilm
replace plotarea_sr=(s3q02a*69.28191)/10000  if s3q02b==8 //medeb
*replace plotarea_sr=pp_s3q02_a if pp_s3q02_c==9 //rope
replace plotarea_sr=(s3q02a*6176.3808)/10000 if s3q02b==10 //ermija


lab var plotarea_sr "Plot area in HA - Self-reported"

* Compass and rope // N/A

* GPS
g       plotarea_gps=.
replace plotarea_gps=s3q08/10000
lab var plotarea_gps "Plot area in HA - GPS"

* Variable without missing: order of importance: 1.Rope and compass, 2. GPS, 3. Self-reported

g plotarea_full=plotarea_gps 
replace plotarea_full=plotarea_sr if plotarea_gps==.
lab var plotarea_full "Plot area: GPS imputed with SR"
*Crop type


tab s3q03b, g(cropt)
lab var cropt1 "Plot with temporary crop"
lab var cropt2 "Plot with permanent crop"
lab var cropt3 "Plot with temporary and permanent crop"

tab s3q04, g(cropm)
lab var cropm1 "Purestand"
lab var cropm2 "Mixed crop"

g falloq=.
replace falloq=1 if s3q05==1
replace falloq=0 if s3q05==2
lab var falloq "Plot left fallow in the last 5 years"

rename  s3q13 s1q00
 merge m:1 holder_id household_id s1q00 using  "${raw4new}${slash}PP${slash}sect1_pp_w4"
drop if _m==2
drop _m
 
 
g       fplotm=.
replace fplotm=0 if s1q03==1
replace fplotm=1 if s1q03==2
lab var fplotm "Plot manager is female"
rename s1q00 s3q13

drop s1*


*One obs reporting negative plot area SR
drop if plotarea_sr<0




g       extprog=.
replace extprog=0 if s3q16==2
replace extprog=1 if s3q16==1 
lab var extprog "Plot under Extension Program"

g       irr=.
replace irr=0 if s3q17==2
replace irr=1 if s3q17==1
lab var irr "Plot is irrigated"

tab s3q19, g(irrm)
lab var irrm1 "Source of water for irrigation is: river"
 
g       urea=.
replace urea=1 if s3q21==1
replace urea=0 if s3q21==2
lab var urea "Urea use on plot"


g dap=.
replace dap=1 if s3q22==1
replace dap=0 if s3q22==2
lab var dap "Use of DAP on plot"

g nps=.
replace nps=1 if s3q23==1
replace nps=0 if s3q23==2
lab var nps "Use of NPS on plot"


g othfert=.
replace othfert=1 if s3q24==1
replace othfert=0 if s3q24==2
lab var othfert "Use of other chemical fert. on plot"

g manure=.
replace manure=1 if s3q25==1
replace manure=0 if s3q25==2
lab var manure "Use of manure on plot"

g hiredlab=.
replace hiredlab=0 if s3q30a==0 & s3q30d==0 & s3q30g==0
replace hiredlab=1 if (s3q30a>0 & s3q30a!=.) | (s3q30d>0 & s3q30d!=.) | (s3q30g>0 & s3q30g!=.)
lab var hiredlab     "Hired labor used"

g lprep=.
replace lprep=1 if s3q35!=.
replace lprep=0 if s3q35==.
lab var lprep "Plot prepared for planting"
g soiler=.
replace soiler=1 if s3q38==1
replace soiler=0 if s3q38==2
lab var soiler "Plot prevented from soil erosion"


lab var swc        "Soil Water Conservation practices"
lab var terr       "Terracing"
lab var wcatch     "Water catchments"
lab var affor      "Afforestation"
lab var ploc	   "Plough along the contour"
lab var mintillage "Minimum tillage"
lab var zerotill   "Zero tillage"
lab var cresidue1  "Crop residue cover - Farmer's elicitation"
lab var cresidue2  "Crop residue cover - visual aid"
lab var rotlegume  "Crop rotation with a legume"
lab var consag1    "Conservation Agriculture - using Minimum tillage"
lab var consag2    "Conservation Agriculture - using Zero tillage"
lab var rdisp      "River dispersion"
lab var treadle    "Treadle pump used for irrigation"
lab var motorpump  "Motor pump used for irrigation"




*Plot level - NRM
preserve 
keep   holder_id household_id ea_id saq01 region saq02 saq03 city subcity kebele saq07 saq08 saq09 saq14 saq15 parcel_id field_id rdisp treadle motorpump rotlegume cresidue1 cresidue2 mintillage zerotill swc terr wcatch affor ploc consag1 consag2 hh_plot_nb ea_plot_nb hh_plot_irr_nb ea_plot_irr_nb hh_plot_cult_nb ea_plot_cult_nb hh_plot_uses_nb ea_plot_uses_nb hh_plot_eros_nb ea_plot_eros_nb hh_plot_cplus_nb ea_plot_cplus_nb hh_plot_lprep_nb ea_plot_lprep_nb plotarea_sr plotarea_gps plotarea_full cropt1 cropt2 cropt3 cropm1 cropm2 falloq fplotm extprog irr irrm1 urea dap nps othfert manure hiredlab lprep soiler plotirr
save "${data}${slash}ess4_pp_nrm_plot_new", replace
restore

* COLLAPSE AT HH-LEVEL
collapse (max) hhd_treadle hhd_motorpump  hhd_rotlegume hhd_cresidue1 hhd_cresidue2 hhd_mintillage hhd_zerotill  hhd_consag* hhd_swc hhd_swc2 hhd_terr hhd_wcatch hhd_affor hhd_ploc hhd_rdisp sh_plothh_* hh_plot_nb hh_plot_irr_nb hh_plot_cult_nb plotirr (firstnm) holder_id saq14 , by(household_id )

* HH dummy
lab var hhd_swc        "Soil Water Conservation practices"
lab var hhd_terr       "Terracing"
lab var hhd_wcatch     "Water catchments"
lab var hhd_affor      "Afforestation"
lab var hhd_ploc	   "Plough along the contour"
lab var hhd_mintillage "Minimum tillage"
lab var hhd_zerotill   "Zero tillage"
lab var hhd_cresidue1  "Crop residue cover"
lab var hhd_cresidue2  "Crop residue cover"
lab var hhd_rotlegume  "Crop rotation with a legume"
lab var hhd_consag1    "Conservation Agriculture - using Minimum tillage"
lab var hhd_consag2    "Conservation Agriculture - using Zero tillage"
lab var hhd_rdisp      "River dispersion"
lab var hhd_treadle    "Treadle pump used for irrigation"
lab var hhd_motorpump  "Motor pump used for irrigation"

lab var hh_plot_nb       "Number of plots per household"
lab var hh_plot_irr_nb   "Number of irrigated plots per household"
lab var hh_plot_cult_nb   "Number of cultivated plots per household"

foreach i in hh_plot_nb hh_plot_irr_nb hh_plot_cult_nb {
replace `i'=0 if `i' ==.
}


* Share of plots per hh

lab var sh_plothh_treadle            "Treadle pump used for irrigation"
forvalues x=1/6{
lab var sh_plothh_treadle_cond`x'    "Treadle pump used for irrigation conditional on `x'* (see notes)"
}

lab var sh_plothh_motorpump          "Motor pump used for irrigation"
forvalues x=1/6 {
lab var sh_plothh_motorpump_cond`x'  "Motor pump used for irrigation conditional on `x'* (see notes)"
}

lab var sh_plothh_rotlegume          "Crop rotation with a legume"
forvalues x=1/6 {
lab var sh_plothh_rotlegume_cond`x'  "Crop rotation with a legume conditional on `x'* (see notes)"
}

forvalues x=1/6 {
lab var sh_plothh_cresidue1`z'        "Crop residue cover - farmer elicitation"
lab var sh_plothh_cresidue2`z'        "Crop residue cover - visual aid"


lab var sh_plothh_cresidue1_cond`x' "Crop residue cover - farmer alicitation conditional on `x'* (see notes)"
lab var sh_plothh_cresidue2_cond`x' "Crop residue cover - visual aid conditional on `x'* (see notes)"
}

lab var sh_plothh_mintillage         "Minimum tillage"
forvalues x=1/6 {
lab var sh_plothh_mintillage_cond`x' "Minimum tillage conditional on `x'* (see notes)"
}

lab var sh_plothh_zerotill         "Zero tillage"
forvalues x=1/6 {
lab var sh_plothh_zerotill_cond`x' "Zero tillage conditional on `x'* (see notes)"
}


lab var sh_plothh_consag1             "Conservation Agriculture - using Minimum tillage"
forvalues x=1/6 {
lab var sh_plothh_consag1_cond`x'     "Conservation Agriculture - using Minimum tillage conditional on `x'* (see notes)"
}
lab var sh_plothh_consag2            "Conservation Agriculture - using Zero tillage"
forvalues x=1/6 {
lab var sh_plothh_consag2_cond`x'    "Conservation Agriculture - using Zero tillage conditional on `x'* (see notes)"
}

lab var sh_plothh_swc                "Soil Water Conservation practices"
forvalues x=1/6 {
lab var sh_plothh_swc_cond`x'        "Soil Water Conservation practices conditional on `x'* (see notes)"
}

lab var sh_plothh_rdisp              "River dispersion"
forvalues x=1/6 {
lab var sh_plothh_rdisp_cond`x'      "River dispersion conditional on `x'* (see notes)"
}

lab var sh_plothh_terr         "Terracing"
forvalues x=1/6 {
lab var sh_plothh_terr_cond`x'  "Terracing conditional on `x'* (see notes)"
}

lab var sh_plothh_wcatch         "Water catchments"
forvalues x=1/6 {
lab var sh_plothh_wcatch_cond`x'   "Water catchments conditional on `x'* (see notes)"
}

lab var sh_plothh_affor         "Afforestation"
forvalues x=1/6 {
lab var sh_plothh_affor_cond`x'   "Afforestation conditional on `x'* (see notes)"
}
lab var sh_plothh_ploc           "Plough along the contour"
forvalues x=1/6 {
lab var sh_plothh_ploc_cond`x'   "Plough along the contour conditional on `x'* (see notes)"
}

#delimit ;
global conditional sh_plothh_cresidue1_cond`x' sh_plothh_cresidue2_cond`x' 
	    sh_plothh_mintillage_cond`x' sh_plothh_zerotill_cond`x' sh_plothh_consag1_cond`x' 
		sh_plothh_consag2_cond`x' sh_plothh_swc_cond`x' sh_plothh_rdisp_cond`x' 
		sh_plothh_terr_cond`x' sh_plothh_wcatch_cond`x' sh_plothh_affor_cond`x'
        sh_plothh_ploc_cond`x' 
;
#delimit cr

foreach var in  $conditional {
forvalues x=1/6 {
note `var'`x': Conditional on: ///
				                1. Plot cultivated, ///
								2. Plot irrigated & cultivated, ///
								3. Plot cultivated, pasture, fallow, forest etc., ///
								4. Using soil erosion preventing measures & use, ///
								5. Cultivated and temporary crop planted, ///
								6. Cultivated and temporary crop and land preparation.
}
}

tempfile  PP_W4S3
save     `PP_W4S3'


********************************************************************************
* SECTION 4 - PP - CROP VARIETY
********************************************************************************

use "${raw4new}${slash}PP${slash}sect4_pp_w4", clear
merge m:1   holder_id household_id parcel_id field_id using "${raw4new}${slash}PP${slash}sect3_pp_w4", keepusing(s3q03 s3q03b) 

/*

    Result                           # of obs.
    -----------------------------------------
    not matched                         5,967
        from master                         0  (_merge==1)
        from using                      5,967  (_merge==2)

    matched                            16,913  (_merge==3)
    -----------------------------------------
*/
keep if _m==3
drop _merge
*ONLY cultivated plots

g sp_ofsp=s4q25==2
lab var sp_ofsp "SP - OFSP"


g sp_awassa83=s4q25==1 & s4q26==2
lab var sp_awassa83 "SP- Awassa83"

g avocado=s4q01b==84
g mango=s4q01b==46
g papaya=s4q01b==48
g sweetpotato=s4q01b==62
g fieldp=s4q01b==15

*Crop type *

g improv=.
replace improv=1 if s4q11==2 | s4q11==3 | s4q11==4
replace improv=0 if s4q11==1
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
g cr16=0
g cr17=0
g cr18=0
g cr19=0
g cr20=0
g cr23=0
g cr24=0
g cr25=0
g cr26=0
g cr27=0
g cr28=0
g cr33=0
g cr34=0
g cr36=0
g cr37=0
g cr38=0
g cr39=0
g cr40=0
g cr41=0
g cr42=0
g cr44=0
g cr45=0
g cr46=0
g cr47=0
g cr48=0
g cr49=0
g cr50=0
g cr51=0
g cr52=0
g cr53=0
g cr54=0
g cr55=0
g cr56=0
g cr57=0
g cr58=0
g cr59=0
g cr60=0
g cr61=0
g cr62=0
g cr63=0
g cr64=0
g cr65=0
g cr66=0
g cr69=0
g cr71=0
g cr72=0
g cr73=0
g cr74=0
g cr75=0
g cr76=0
g cr78=0
g cr79=0
g cr80=0
g cr81=0
g cr82=0
g cr83=0
g cr84=0
g cr85=0
g cr86=0
g cr98=0
g cr99=0
g cr108=0
g cr112=0
g cr114=0
g cr115=0
g cr117=0
g cr118=0
g cr119=0
g cr120=0
g cr123=0

replace cr1=1 if s4q01b==1
replace cr2=1 if s4q01b==2
replace cr3=1 if s4q01b==3
replace cr4=1 if s4q01b==4
replace cr5=1 if s4q01b==5
replace cr6=1 if s4q01b==6
replace cr7=1 if s4q01b==7
replace cr8=1 if s4q01b==8
replace cr9=1 if s4q01b==9
replace cr10=1 if s4q01b==10
replace cr11=1 if s4q01b==11
replace cr12=1 if s4q01b==12
replace cr13=1 if s4q01b==13
replace cr14=1 if s4q01b==14
replace cr15=1 if s4q01b==15
replace cr16=1 if s4q01b==16
replace cr17=1 if s4q01b==17
replace cr18=1 if s4q01b==18
replace cr19=1 if s4q01b==19
replace cr20=1 if s4q01b==20
replace cr23=1 if s4q01b==23
replace cr24=1 if s4q01b==24
replace cr25=1 if s4q01b==25
replace cr26=1 if s4q01b==26
replace cr27=1 if s4q01b==27
replace cr28=1 if s4q01b==28
replace cr33=1 if s4q01b==33
replace cr34=1 if s4q01b==34
replace cr36=1 if s4q01b==36
replace cr37=1 if s4q01b==37
replace cr38=1 if s4q01b==38
replace cr39=1 if s4q01b==39
replace cr40=1 if s4q01b==40
replace cr41=1 if s4q01b==41
replace cr42=1 if s4q01b==42
replace cr44=1 if s4q01b==44
replace cr45=1 if s4q01b==45
replace cr46=1 if s4q01b==46
replace cr47=1 if s4q01b==47
replace cr48=1 if s4q01b==48
replace cr49=1 if s4q01b==49
replace cr50=1 if s4q01b==50
replace cr51=1 if s4q01b==51
replace cr52=1 if s4q01b==52
replace cr53=1 if s4q01b==53
replace cr54=1 if s4q01b==54
replace cr55=1 if s4q01b==55
replace cr56=1 if s4q01b==56
replace cr57=1 if s4q01b==57
replace cr58=1 if s4q01b==58
replace cr59=1 if s4q01b==59
replace cr60=1 if s4q01b==60
replace cr61=1 if s4q01b==61
replace cr62=1 if s4q01b==62
replace cr63=1 if s4q01b==63
replace cr64=1 if s4q01b==64
replace cr65=1 if s4q01b==65
replace cr66=1 if s4q01b==66
replace cr69=1 if s4q01b==69
replace cr71=1 if s4q01b==71
replace cr72=1 if s4q01b==72
replace cr73=1 if s4q01b==73
replace cr74=1 if s4q01b==74
replace cr75=1 if s4q01b==75
replace cr76=1 if s4q01b==76
replace cr78=1 if s4q01b==78
replace cr79=1 if s4q01b==79
replace cr80=1 if s4q01b==80
replace cr81=1 if s4q01b==81
replace cr82=1 if s4q01b==82
replace cr83=1 if s4q01b==83
replace cr84=1 if s4q01b==84
replace cr85=1 if s4q01b==85
replace cr86=1 if s4q01b==86
replace cr98=1 if s4q01b==98
replace cr99=1 if s4q01b==99
replace cr108=1 if s4q01b==108
replace cr112=1 if s4q01b==112
replace cr114=1 if s4q01b==114
replace cr115=1 if s4q01b==115
replace cr117=1 if s4q01b==117
replace cr118=1 if s4q01b==118
replace cr119=1 if s4q01b==119
replace cr120=1 if s4q01b==120
replace cr123=1 if s4q01b==123

foreach i in cr1 cr2 cr3 cr4 cr5 cr6 cr7 cr8 cr9 cr10 cr11 cr12 cr13 cr14 cr15 cr18 cr19 cr23 cr24 cr25 cr26 cr27 cr42 cr49 cr60 cr62 cr71 cr72  {
g       imp`i'=0 if `i'==1
replace imp`i'=1 if `i'==1 & improv==1
}



g       impveg=.
replace impveg=0 if cr34==1 | cr38==1 | cr52==1 | cr54==1 | cr55==1 | cr56==1 | cr57==1 | cr58==1 | cr59==1 | cr61==1 | cr63==1 | cr69==1 | cr79==1 | cr80==1 | cr82==1 | cr83==1 | cr117==1

replace impveg=1 if (cr34==1 | cr38==1 | cr52==1 | cr54==1 | cr55==1 | cr56==1 | cr57==1 | cr58==1 | cr59==1 | cr61==1 | cr63==1 | cr69==1 | cr79==1 | cr80==1 | cr82==1 | cr83==1 | cr117==1) & improv==1

g       impftr=.
replace impftr=0 if  cr41==1 | cr44==1 | cr45==1 | cr46==1 | cr47==1 | cr48==1 | cr50==1 | cr65==1 | cr66==1 | cr75==1 | cr84==1 | cr112==1 | cr115==1  
replace impftr=1 if (cr41==1 | cr44==1 | cr45==1 | cr46==1 | cr47==1 | cr48==1 | cr50==1 | cr65==1 | cr66==1 | cr75==1 | cr84==1 | cr112==1 | cr115==1 ) & improv==1


g       improot=.
replace improot=0 if  cr51==1 | cr53==1 | cr74==1
replace improot=1 if (cr51==1 | cr53==1 | cr74==1) & improv==1

g       impccr=.
replace impccr=0 if  cr76==1
replace impccr=1 if (cr76==1 & improv==1)


foreach i in sp_ofsp sp_awassa83 avocado mango papaya sweetpotato fieldp impcr1 impcr2 impcr3 impcr4 impcr5 impcr6 impcr7 impcr8 impcr9 impcr10 impcr11 impcr12 impcr13 impcr14 impcr15 impcr18 impcr19 impcr23 impcr24 impcr25 impcr26 impcr27 impcr42 impcr49 impcr60 impcr62 impcr71 impcr72  impveg impftr improot impccr {
egen `i'max=max(`i'), by(household_id)
}


foreach i in avocado mango papaya sweetpotato fieldp impcr1 impcr2 impcr3 impcr4 impcr5 impcr6 impcr7 impcr8 impcr9 impcr10 impcr11 impcr12 impcr13 impcr14 impcr15 impcr18 impcr19 impcr23 impcr24 impcr25 impcr26 impcr27 impcr42 impcr49 impcr60 impcr62 impcr71 impcr72  impveg impftr improot impccr {

egen hhd_`i'=max(`i')         if `i'max!=., by(household_id)    // HH dummy 
egen ead_`i'=max(`i')         if `i'max!=., by(ea_id)           // Ea dummy  
egen `i'_sumhh=sum(`i')       if `i'max!=., by(household_id)    // Sum of crop per HH
egen `i'_sumea=sum(`i')       if `i'max!=., by(ea_id)           // Sum of crop per EA
egen `i'_sumhhea=sum(hhd_`i') if `i'max!=., by(ea_id)           // Sum of hh per EA
}

foreach i in ofsp awassa83 {
egen hhd_`i'=max(sp_`i')      if sp_ofspmax!=., by(household_id)    // HH dummy 
egen ead_`i'=max(sp_`i')      if sp_ofspmax!=., by(ea_id)           // Ea dummy  
egen `i'_sumhh=sum(sp_`i')    if sp_ofspmax!=., by(household_id)    // Sum of crop per HH
egen `i'_sumea=sum(sp_`i')    if sp_ofspmax!=., by(ea_id)           // Sum of crop per EA
egen `i'_sumhhea=sum(hhd_`i') if sp_ofspmax!=., by(ea_id)           // Sum of hh per EA
}






egen ea_plot1=count(field_id)      if sp_ofspmax!=.  , by(ea_id)          //Tot no of plot per EA
       
egen hh_plot1=count(field_id)      if sp_ofspmax!=.  , by(household_id)  // Tot no of plots per HH

egen hh_ea1=count(household_id)           if sp_ofspmax!=.  , by(ea_id)           		// Tot no of hh per EA

egen ea_plot2=count(field_id)      if s4q01b!=.  , by(ea_id)          //Tot no of plot per EA
       
egen hh_plot2=count(field_id)      if s4q01b!=.  , by(household_id)  // Tot no of plots per HH

egen hh_ea2=count(household_id)           if s4q01b!=.  , by(ea_id)           		// Tot no of hh per EA




foreach i in ofsp awassa83 {
g sh_plothh_`i'=(`i'_sumhh/hh_plot1)*100 if `i'_sumhh!=.   & hhd_`i'==1 //Share of plots per HH
g sh_plotea_`i'=(`i'_sumea/ea_plot1)*100 if `i'_sumea!=.   & hhd_`i'==1 // Share of plots per EA
g sh_hhea_`i'  =(`i'_sumhhea/hh_ea1)*100 if `i'_sumhhea!=. & hhd_`i'==1 //Share of HH per EA
}


foreach i in avocado mango papaya sweetpotato fieldp impcr1 impcr2 impcr3 impcr4 impcr5 impcr6 impcr7 impcr8 impcr9 impcr10 impcr11 impcr12 impcr13 impcr14 impcr15 impcr18 impcr19 impcr23 impcr24 impcr25 impcr26 impcr27 impcr42 impcr49 impcr60 impcr62 impcr71 impcr72  impveg impftr improot impccr {

g sh_plothh_`i'=(`i'_sumhh/hh_plot2)*100 if `i'_sumhh!=.   & hhd_`i'==1 //Share of plots per HH
g sh_plotea_`i'=(`i'_sumea/ea_plot2)*100 if `i'_sumea!=.   & hhd_`i'==1 // Share of plots per EA
g sh_hhea_`i'  =(`i'_sumhhea/hh_ea2)*100 if `i'_sumhhea!=. & hhd_`i'==1 //Share of HH per EA
}







* Crop damage cause
tab  s4q09, g(cdam)

g cdamoth=.
replace cdamoth=1 if cdam6==1 | cdam7==1 | cdam8==1 | cdam9==1 | cdam10==1 | cdam11==1 | cdam12==1 | cdam13==1 | cdam14==1 | cdam15==1 | cdam16==1 
foreach i in 1 2 3 4 5 oth {
replace cdam`i' =0 if s4q08==2
}
replace cdamoth=0 if cdamoth==. & s4q08!=.

* Intention to sell the harvest
g hsell=.
replace hsell=1 if s4q22==1
replace hsell=0 if s4q22==2

* Merge with plot area to gen % of plot area under maize, sorghum and barley
merge m:1 parcel_id field_id   holder_id household_id ea_id using "${data}${slash}ess4_pp_nrm_plot_new", keepusing(plotarea_full)
/*

    Result                           # of obs.
    -----------------------------------------
    not matched                         5,967
        from master                         0  (_merge==1)
        from using                      5,967  (_merge==2)

    matched                            16,913  (_merge==3)
    -----------------------------------------
*/


keep if _m==3
drop _merge

g       m_plotarea=plotarea_full              if s4q01b==2 &  s4q02==1
replace m_plotarea=plotarea_full*(s4q03/100)  if s4q01b==2 &  s4q02==2

g       s_plotarea=plotarea_full              if s4q01b==6 &  s4q02==1
replace s_plotarea=plotarea_full*(s4q03/100)  if s4q01b==6 &  s4q02==2

g       b_plotarea=plotarea_full              if s4q01b==1 &  s4q02==1
replace b_plotarea=plotarea_full*(s4q03/100)  if s4q01b==1 &  s4q02==2

clonevar region=saq01
replace region=0 if region==2 | region==6 | region==15 | region==12 | region==13 | region==5

foreach i in m s b {
replace `i'_plotarea=0 if `i'_plotarea==. 
foreach x in 1 3 4 7 0  {

egen `i'_plotarea`x'=sum(`i'_plotarea) if region==`x'
}
}

foreach x in 1 3 4 7 0  {
egen tot_plotarea`x'=sum(plotarea_full) if region==`x'
foreach i in m s b {

g sh_`i'area`x'=`i'_plotarea`x'/tot_plotarea`x'

}
}


	
*Plot level - Crop variety
preserve 
keep  saq01 sp_ofsp sp_awassa83 avocado mango papaya sweetpotato fieldp improv cdam1 cdam2 cdam3 cdam4 cdam5 cdamoth hsell  parcel_id field_id crop_id   holder_id household_id ea_id impcr2 impcr1 pw_w4
collapse (max) saq01 sp_ofsp sp_awassa83 improv avocado mango papaya sweetpotato fieldp  cdam1 cdam2 cdam3 cdam4 cdam5 cdamoth hsell impcr2 impcr1  (firstnm) pw_w4, by(parcel_id field_id   holder_id household_id ea_id)

lab var improv      "Improved crop used"
lab var cdam1       "Crop damage due to: Too Much Rain "
lab var cdam2       "Crop damage due to: Too Little Rain"
lab var cdam3       "Crop damage due to: Insects"
lab var cdam4       "Crop damage due to: Crop Disease "
lab var cdam5       "Crop damage due to: Weeds"
lab var cdamoth     "Crop damage due to: Other "
lab var hsell       "Farmer intends to sell parts of the harvest"
lab var sp_ofsp     "Orange Fleshed sweet potato"
lab var sp_awassa83 "Awassa83 sweet potato"
lab var avocado     "Avocado tree"
lab var mango       "Mango tree"
lab var papaya      "Papaya tree"
lab var sweetpotato "Sweetpotato SR"
lab var fieldp		"Field peas"

save "${data}${slash}ess4_pp_cropvar_plot_new", replace
restore



collapse (max) cr1 cr2 cr6 hhd_ofsp ead_ofsp hhd_awassa83 ead_awassa83 hhd_avocado ead_avocado hhd_mango ead_mango ead_papaya hhd_papaya hhd_sweetpotato ead_sweetpotato  ead_fieldp hhd_fieldp sh_plothh_ofsp sh_plotea_ofsp sh_hhea_ofsp sh_plothh_awassa83 sh_plotea_awassa83 sh_hhea_awassa83 sh_plothh_avocado sh_plotea_avocado sh_hhea_avocado sh_plothh_mango sh_plotea_mango sh_hhea_mango sh_plothh_papaya sh_plotea_papaya sh_hhea_papaya sh_plothh_sweetpotato sh_plotea_sweetpotato sh_hhea_sweetpotato sh_plothh_fieldp sh_plotea_fieldp sh_hhea_fieldp  *impcr*  *impveg *impftr *improot *impccr ///
(firstnm) saq01 saq14  ea_id , by(household_id)

foreach i in impcr1 impcr2 impcr3 impcr4 impcr5 impcr6 impcr7 impcr8 impcr9 impcr10 impcr11 impcr12 impcr13 impcr14 impcr15 impcr18 impcr19 impcr23 impcr24 impcr25 impcr26 impcr27 impcr42 impcr49 impcr60 impcr62 impcr71 impcr72  impveg impftr improot impccr  {
replace sh_plothh_`i'=. if hhd_`i'==0
replace sh_plotea_`i'=. if ead_`i'==0
replace sh_hhea_`i'=. if ead_`i'==0
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
lab var `i' "Sweet potato OFSP variety"
}

foreach i in hhd_awassa83 ead_awassa83 sh_plothh_awassa83 sh_plotea_awassa83 sh_hhea_awassa83 {
lab var `i' "Sweet potato Awassa83 variety"
}

foreach i in hhd_avocado ead_avocado sh_plothh_avocado sh_plotea_avocado sh_hhea_avocado {
lab var `i' "Avocado tree"
}

foreach i in hhd_mango ead_mango sh_plothh_mango sh_plotea_mango sh_hhea_mango {
lab var `i' "Mango tree"
}

foreach i in hhd_papaya ead_papaya sh_plothh_papaya sh_plotea_papaya sh_hhea_papaya {
lab var `i' "Papaya tree"
}
foreach i in hhd_sweetpotato ead_sweetpotato sh_plothh_sweetpotato sh_plotea_sweetpotato sh_hhea_sweetpotato {
lab var `i' "Sweetpotato"
}
foreach i in hhd_fieldp ead_fieldp sh_plothh_fieldp sh_plotea_fieldp sh_hhea_fieldp {
lab var `i' "Field peas"
}
foreach i of varlist *impcr1{
	lab var `i' "Improved   BARLEY-SR"
	}
foreach i of varlist *impcr2{
	lab var `i' "Improved   MAIZE-SR"
	}
foreach i of varlist *impcr3{
	lab var `i' "Improved   MILLET-SR"
	}
foreach i of varlist *impcr4{
	lab var `i' "Improved   OATS-SR"
	}
foreach i of varlist *impcr5{
	lab var `i' "Improved   RICE-SR"
	}
foreach i of varlist *impcr6{
	lab var `i' "Improved   SORGHUM-SR"
	}
foreach i of varlist *impcr7{
	lab var `i' "Improved   TEFF-SR"
	}
foreach i of varlist *impcr8{
	lab var `i' "Improved   WHEAT-SR"
	}
foreach i of varlist *impcr9{
	lab var `i' "Improved   Mung Bean/ MASHO-SR"
	}
foreach i of varlist *impcr10{
	lab var `i' "Improved   CASSAVA-SR"
	}
foreach i of varlist *impcr11{
	lab var `i' "Improved   CHICK PEAS-SR"
	}
foreach i of varlist *impcr12{
	lab var `i' "Improved   HARICOT BEANS-SR"
	}
foreach i of varlist *impcr13{
	lab var `i' "Improved   HORSE BEANS-SR"
	}
foreach i of varlist *impcr14{
	lab var `i' "Improved   LENTILS-SR"
	}
foreach i of varlist *impcr15{
	lab var `i' "Improved   FIELD PEAS-SR"
	}
foreach i of varlist *impcr18{
	lab var `i' "Improved   SOYA BEANS-SR"
	}
foreach i of varlist *impcr19{
	lab var `i' "Improved   RED KIDENY BEANS-SR"
	}
foreach i of varlist *impcr23{
	lab var `i' "Improved   LINESEED-SR"
	}
foreach i of varlist *impcr24{
	lab var `i' "Improved   GROUND NUTS-SR"
	}
foreach i of varlist *impcr25{
	lab var `i' "Improved   NUEG-SR"
	}
foreach i of varlist *impcr26{
	lab var `i' "Improved   RAPE SEED-SR"
	}
foreach i of varlist *impcr27{
	lab var `i' "Improved   SESAME-SR"
	}
foreach i of varlist *impcr42{
	lab var `i' "Improved   BANANAS-SR"
	}
foreach i of varlist *impcr49{
	lab var `i' "Improved   PINAPPLES-SR"
	}
foreach i of varlist *impcr60{
	lab var `i' "Improved   POTATOES-SR"
	}
foreach i of varlist *impcr62{
	lab var `i' "Improved   SWEET POTATO-SR"
	}
foreach i of varlist *impcr71{
	lab var `i' "Improved   CHAT-SR"
	}
foreach i of varlist *impcr72{
	lab var `i' "Improved   COFFEE-SR"
	}
	
tempfile pp_w4s4
save `pp_w4s4'



********************************************************************************
*** LS - Sec.8_1 - Crossbred animals
********************************************************************************
use "${raw4new}${slash}LS${slash}sect8_1_ls_w4", clear

g       ls_type=1 if ls_code>=1 & ls_code<=6
replace ls_type=2 if ls_code==7 | ls_code==8
replace ls_type=3 if ls_code==9
replace ls_type=4 if ls_code>=10 & ls_code<=12
replace ls_type=5 if ls_code>=13 & ls_code<=15
replace ls_type=6 if ls_code==16


merge m:1 household_id ls_type holder_id using "${raw4new}${slash}LS${slash}sect8_3_ls_w4"

/*

    Result                           # of obs.
    -----------------------------------------
    not matched                             0
    matched                            42,784  (_merge==3)
    -----------------------------------------

*/

drop _merge

merge 1:1 household_id ls_code holder_id using "${raw4new}${slash}LS${slash}sect8_4_ls_w4"

/*

    Result                           # of obs.
    -----------------------------------------
    not matched                             0
    matched                            42,784  (_merge==3)
    -----------------------------------------

*/


drop _merge



* Dummy for hh owning at least 1 livestock type (large ruminant, small ruminant or poultry)
g       hh_livx=0
replace hh_livx=1 if (ls_type==1 | ls_type==2 | ls_type==4) & ls_s8_1q01>0 & ls_s8_1q01!=.
egen hh_liv=max(hh_livx), by(household_id)
drop hh_livx




g largerum_x=0
replace largerum_x=1 if ls_type==1  & ls_s8_1q01>0 & ls_s8_1q01!=.
egen largerum_d=max(largerum_x), by(household_id)
drop largerum_x

g smallrum_x=0
replace smallrum_x=1 if ls_type==2  & ls_s8_1q01>0 & ls_s8_1q01!=.
egen smallrum_d=max(smallrum_x), by(household_id)
drop smallrum_x

g poultry_x=0
replace poultry_x=1 if ls_type==4  & ls_s8_1q01>0 & ls_s8_1q01!=.
egen poultry_d=max(poultry_x), by(household_id)
drop poultry_x




* Total no. of ... per household: KEEP vs. OWN

* Large ruminants
g ls_s8_1q02bis=ls_s8_1q01-ls_s8_1q02

egen largerum_nbhh_k= sum(ls_s8_1q01) if ls_type==1, by(household_id) // livestock kept +owned

egen largerum_nbhh_o= sum(ls_s8_1q02bis) if ls_type==1 & ls_s8_1q01>0, by(household_id) // livestock owned


egen largerum_cross=sum(ls_s8_1q03) if ls_type==1 & ls_s8_1q01>0, by(household_id) // crossbred animals

* Small ruminants
egen smallrum_nbhh_k= sum(ls_s8_1q01) if ls_type==2, by(household_id) // livestock kept

egen smallrum_nbhh_o= sum(ls_s8_1q02bis) if ls_type==2 & ls_s8_1q01>0, by(household_id) // livestock owned


egen smallrum_cross=sum(ls_s8_1q03) if ls_type==2 & ls_s8_1q01>0, by(household_id) // crossbred animals

* Poultry
egen poultry_nbhh_k= sum(ls_s8_1q01) if ls_type==4, by(household_id) // livestock holded/owned

egen poultry_nbhh_o= sum(ls_s8_1q02bis) if ls_type==4, by(household_id) // livestock holded/owned

egen poultry_cross=sum(ls_s8_1q03) if ls_type==4 & ls_s8_1q01>0, by(household_id) // crossbred animals


*Sheep 
egen sheep_nbhh_o= sum(ls_s8_1q02bis) if ls_code==8 & ls_s8_1q01>0, by(household_id) // livestock owned

*Goats
egen goat_nbhh_o= sum(ls_s8_1q02bis) if ls_code==7 & ls_s8_1q01>0, by(household_id) // livestock owned

*Horses
egen horse_nbhh_o= sum(ls_s8_1q02bis) if ls_code==13 & ls_s8_1q01>0, by(household_id) // livestock owned
*donkeys
egen donkey_nbhh_o= sum(ls_s8_1q02bis) if (ls_code==15 | ls_code==14) &  ls_s8_1q01>0, by(household_id) // livestock owned

gen cfcattle   = 0.6
gen cfsheep    = 0.1
gen cfgoats    = 0.1
gen cfchicken  = 0.01
gen cfhorses   = 0.65
gen cfyaks     = 0.7
gen cfdonkeys  = 0.5




* Max number of crossbred animals
foreach i in largerum smallrum poultry {
egen `i'_crossm=max(`i'_cross), by(household_id)
}
* Nb. of animals owned, kept, and crossbred
foreach i in largerum smallrum poultry {

replace `i'_nbhh_k=0   if `i'_nbhh_k==.  &  hh_liv!=.
replace `i'_nbhh_o=0   if `i'_nbhh_o==.  &  hh_liv!=.
replace `i'_crossm=0   if `i'_cross==.   &  `i'_d==1
replace `i'_cross=`i'_crossm 
drop `i'_crossm
}


* Dummy for owning at least 1 crossbred animal per hh
g       hhd_cross=.
replace hhd_cross=0 if hh_liv==1 
replace hhd_cross=1 if             (largerum_cross>0 & largerum_cross!=.) | (smallrum_cross>0 & smallrum_cross!=.) | (poultry_cross>0 & poultry_cross!=.)

foreach i in largerum smallrum poultry {
g       hhd_cross_`i'=. if hh_liv==0
replace hhd_cross_`i'=0 if hh_liv==1 
replace hhd_cross_`i'=1 if hh_liv==1 & `i'_cross>0 & `i'_cross!=.
}

* Shares of livestock per HH 
foreach i in largerum smallrum poultry {

* Share of crossbred per hh HOLDED/OWNED
g       sh_hh_`i'_k=(`i'_cross/`i'_nbhh_k)*100 // household level
replace sh_hh_`i'_k=0 if `i'_cross==0 & `i'_nbhh_k==0 & hh_liv==1



g       sh_hh_`i'_o=(`i'_cross/`i'_nbhh_o)*100 // household level
replace sh_hh_`i'_o=0 if `i'_cross==0 & `i'_nbhh_o==0 & hh_liv==1
}

* Dummy for artificial insemination by hh
g       livIA=.
replace livIA=0 if (ls_s8_3q02!=5 | ls_s8_3q01==2) & hh_liv==1
replace livIA=1 if ls_s8_3q02==5
lab var livIA "Livestock AI"


egen hhd_livIA=max(livIA), by(household_id)



* Dummy artificial insemination by livestock type
g       lr_livIA=.
replace lr_livIA=0 if (ls_s8_3q02!=5 | ls_s8_3q01==2) &     ls_type==1 & ls_s8_1q01>0 & ls_s8_1q01!=. //large ruminants
replace lr_livIA=1 if  ls_s8_3q02==5               &     ls_type==1 & ls_s8_1q01>0 & ls_s8_1q01!=. //large ruminants

g       sr_livIA=.
replace sr_livIA=0 if (ls_s8_3q02!=5 | ls_s8_3q01==2) &     ls_type==2 & ls_s8_1q01>0 & ls_s8_1q01!=. //smallruminants
replace sr_livIA=1 if  ls_s8_3q02==5               &     ls_type==2 & ls_s8_1q01>0 & ls_s8_1q01!=. //smallruminants

g       po_livIA=.
replace po_livIA=0 if (ls_s8_3q02!=5 | ls_s8_3q01==2) &    ls_type==4 & ls_s8_1q01>0 & ls_s8_1q01!=. //poultry
replace po_livIA=1 if  ls_s8_3q02==5               &    ls_type==4 & ls_s8_1q01>0 & ls_s8_1q01!=. //poultry


* Feed and forages

g       elepgrass=.
replace elepgrass=0 if (ls_s8_3q16==2 | ls_s8_3q17!=1) & hh_liv==1
replace elepgrass=1 if ls_s8_3q17==1


g       gaya=.
replace gaya=0 if (ls_s8_3q16==2 | ls_s8_3q17!=2) & hh_liv==1
replace gaya=1 if ls_s8_3q17==2

g       sasbaniya=.
replace sasbaniya=0 if (ls_s8_3q16==2 | ls_s8_3q17!=3) & hh_liv==1
replace sasbaniya=1 if ls_s8_3q17==3


g       alfa=.
replace alfa=0 if (ls_s8_3q16==2 | ls_s8_3q17!=6) & hh_liv==1
replace alfa=1 if ls_s8_3q17==6


g       indprod      =.
replace indprod=0 if (ls_s8_3q16==2 | ls_s8_3q17!=6) & hh_liv==1
replace indprod=1 if ls_s8_3q17==7

g       grass=.
replace grass=0   if (ls_s8_3q16==2 | ls_s8_3q17!=3) & hh_liv==1
replace grass=1 if elepgrass==1 | gaya==1 | sasbaniya==1 | alfa==1

foreach i in  elepgrass gaya sasbaniya alfa indprod grass {
*Dummy for hh 
egen hhd_`i'=max(`i'), by(household_id)

*Dummy by livestock type
g lr_`i'=`i' if ls_type==1 & ls_s8_1q01>0 & ls_s8_1q01!=.   //large ruminants
g sr_`i'=`i' if ls_type==2 & ls_s8_1q01>0 & ls_s8_1q01!=.   //small ruminants
g po_`i'=`i' if ls_type==4 & ls_s8_1q01>0 & ls_s8_1q01!=.   //poultry
}   



*Plot level - Animal agriculture
preserve 
save "${data}${slash}ess4_pp_livestock_plot_new", replace
restore

* Collapse at the hh-level
collapse (max) hh_liv largerum_nbhh* largerum_cross smallrum_nbhh* smallrum_cross sh*  lr* sr* po* hhd*  goat_nbhh_o horse_nbhh_o donkey_nbhh_o cfcattle cfsheep cfgoats cfchicken cfhorses cfyaks cfdonkeys, by(household_id)

gen TLU_cattle = largerum_nbhh_o*cfcattle   
gen TLU_horses = horse_nbhh_o*cfhorses  
gen TLU_donkeys= donkey_nbhh_o*cfdonkeys

gen TLU_chicken= poultry_nbhh_o*cfchicken
gen TLU_goats  = goat_nbhh_o*cfgoats    
gen TLU_sheep  = sheep_nbhh_o*cfsheep   

egen TLU_total = rsum(TLU_*)

lab var TLU_total "Total Livestock owned by the household (TLU)"

drop goat_nbhh_o horse_nbhh_o donkey_nbhh_o cfcattle cfsheep cfgoats cfchicken cfhorses cfyaks cfdonkeys TLU_cattle TLU_horses TLU_donkeys TLU_chicken TLU_goats TLU_sheep

lab var hhd_cross			  "At least 1 crossbred animal in hh"
lab var hhd_cross_largerum    "Crossbred large ruminants"
lab var largerum_cross        "Large ruminants"
lab var largerum_nbhh_k       "No. of LARGE RUMINANTS per hh - kept"
lab var largerum_nbhh_o       "No. of LARGE RUMINANTS per hh - owned"
lab var hhd_cross_smallrum	 "Crossbred small ruminants"
lab var smallrum_cross        "Small ruminants" 
lab var smallrum_nbhh_k       "No. of SMALL RUMINANTS per hh - kept"
lab var smallrum_nbhh_o       "No. of SMALL RUMINANTS per hh - owned"
lab var hhd_cross_poultry	  "Crossbred poultry"
lab var poultry_cross         "Poultry"
lab var poultry_nbhh_k        "No. of POULTRY per hh - kept"
lab var poultry_nbhh_o        "No. of POULTRY per hh - owned"

lab var hhd_livIA             "AI on any livestock type"
lab var lr_livIA              "Large ruminants: AI"
lab var sr_livIA              "Small ruminants: AI"
lab var po_livIA              "Poultry: AI"

lab var hhd_elepgrass        "Feed and Forage: Elephant Grass"
lab var hhd_gaya             "Feed and Forage: Gaya"
lab var hhd_sasbaniya        "Feed and Forage: Sasbaniya"
lab var hhd_alfa             "Feed and Forage: Alfalfa"
lab var hhd_indprod			 "Feed and Forage: Industry by-products"
lab var hhd_grass            "Elephant grass, gaya, sasbaniya, alfalfa"

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

tempfile PP_W4S81
save `PP_W4S81'

********************************************************************************
* MERGE DIFFERENT MODULES *
********************************************************************************

use `w4_coverPP', clear

merge 1:1 household_id using `PP_W4S3'
/*

    Result                           # of obs.
    -----------------------------------------
    not matched                            20
        from master                        20  (_merge==1)
        from using                          0  (_merge==2)

    matched                             2,879  (_merge==3)
    -----------------------------------------

*/

drop _merge

merge 1:1 household_id using `PP_W4S81'
/*


    Result                           # of obs.
    -----------------------------------------
    not matched                           262
        from master                       262  (_merge==1)
        from using                          0  (_merge==2)

    matched                             2,637  (_merge==3)
    -----------------------------------------
*/

drop _merge

merge 1:1 household_id using `pp_w4s4'
/*
   Result                           # of obs.
    -----------------------------------------
    not matched                           700
        from master                       700  (_merge==1)
        from using                          0  (_merge==2)

    matched                             2,199  (_merge==3)
    -----------------------------------------
*/

drop _m 
/*
*MERGE WITH HH-COVER FOR WEIGHTS
merge 1:1 household_id using `hh_sectcover'

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                         4,109
        from master                       110  (_merge==1)
        from using                      3,999  (_merge==2)

    matched                             2,789  (_merge==3)
    -----------------------------------------
*/
keep if _m==3
*/
lab var sh_hh_largerum_k "Large ruminants - kept" 
lab var sh_hh_largerum_o "Large ruminants - owned" 
lab var sh_hh_smallrum_k "Small ruminants - kept"
lab var sh_hh_smallrum_o "Small ruminants - owned"
lab var sh_hh_poultry_k  "Poultry - kept"
lab var sh_hh_poultry_o  "Poultry - owned"

lab var hhd_cross_largerum "Crossbred LARGE RUMINANTS"
lab var hhd_cross_smallrum "Crossbred SMALL RUMINANTS"
lab var hhd_cross_poultry  "Crossbred POULTRY"


g wave=4	
clonevar region=saq01

replace region=0 if saq01==2 | saq01==6 | saq01==15 | saq01==12 | saq01==13 | saq01==5

g othregion=0
replace othregion=saq01 if  saq01==2 | saq01==6 | saq01==15 | saq01==12 | saq01==13 | saq01==5

local hhd hhd_*  po_livIA po_elepgrass po_gaya po_sasbaniya po_alfa lr_livIA lr_elepgrass lr_gaya lr_sasbaniya lr_alfa sr_livIA sr_elepgrass sr_gaya sr_sasbaniya sr_alfa
foreach var of varlist `hhd' {
replace `var'=`var'*100	

}

foreach i in cr1 cr2 cr6 {
    replace `i'=0 if `i'==.
}

*Cleaning intermediate variables
drop impcr*max impcr*_sum*  sh_plothh_swc2_cond*

save "${data}${slash}wave4_hh_new", replace
save "${data}${slash}ess4_pp_hh_new", replace
********************************************************************************
* EA - LEVEL ANALYSIS *
********************************************************************************



foreach i in  treadle motorpump rotlegume cresidue1 cresidue2 mintillage zerotill consag1 consag2 swc terr wcatch affor ploc rdisp livIA elepgrass gaya sasbaniya alfa indprod cross grass {
g ead_`i'=.
replace ead_`i'=0 if hhd_`i'==0
replace ead_`i'=1 if hhd_`i'==100

egen nbhhd_`i'=sum(hhd_`i'), by(ea_id)
g sh_ea_`i'=(nbhhd_`i'/hh_ea) if nbhhd_`i'!=.  
}


g ead_feed=0
replace ead_feed=1 if nbhhd_elepgrass>0 | nbhhd_gaya>0 | nbhhd_sasbaniya>0 | nbhhd_alfa>0 | nbhhd_indprod>0


rename sh_hhea_ofsp        sh_ea_ofsp
rename sh_hhea_awassa83    sh_ea_awassa83
rename sh_hhea_avocado     sh_ea_avocado
rename sh_hhea_mango       sh_ea_mango
rename sh_hhea_papaya      sh_ea_papaya
rename sh_hhea_sweetpotato sh_ea_sweetpotato
rename sh_hhea_fieldp      sh_ea_fieldp


foreach i in impcr1 impcr2 impcr3 impcr4 impcr5 impcr6 impcr7 impcr8 impcr9 impcr10 impcr11 impcr12 impcr13 impcr14 impcr15 impcr18 impcr19 impcr23 impcr24 impcr25 impcr26 impcr27 impcr42 impcr49 impcr60 impcr62 impcr71 impcr72  impveg impftr improot impccr {
rename sh_hhea_`i'  sh_ea_`i' 
}





*Livestock
foreach i in largerum smallrum poultry {
g       ead_cross_`i'=.
replace ead_cross_`i'=0 if hhd_cross_`i'==0
replace ead_cross_`i'=1 if hhd_cross_`i'==100

egen eanb_`i'_cross=sum(`i'_cross), by(ea_id)
egen eanb_`i'_k=sum(`i'_nbhh_k), by(ea_id)
egen eanb_`i'_o=sum(`i'_nbhh_o), by(ea_id)

g   sh_ea_`i'_k=(eanb_`i'_cross/eanb_`i'_k) if eanb_`i'_cross!=.
g   sh_ea_`i'_o=(eanb_`i'_cross/eanb_`i'_o) if eanb_`i'_cross!=.
}


local ead ead* 
foreach var of varlist `ead' {
replace `var'=`var'*100
}


collapse (max)  ead* sh_plotea* sh_ea_* wave  region othregion (firstnm) pw_w4, by(ea_id)

foreach i in treadle motorpump rotlegume cresidue1 cresidue2 mintillage zerotill consag1 consag2 swc terr wcatch affor ploc rdisp livIA elepgrass gaya sasbaniya alfa indprod cross  ofsp awassa83 avocado mango fieldp papaya sweetpotato impcr1 impcr2 impcr3 impcr4 impcr5 impcr6 impcr7 impcr8 impcr9 impcr10 impcr11 impcr12 impcr13 impcr14 impcr15 impcr18 impcr19 impcr23 impcr24 impcr25 impcr26 impcr27 impcr42 impcr49 impcr60 impcr62 impcr71 impcr72  impveg impftr improot impccr {
replace ead_`i' =0 if ead_`i' ==.

replace sh_ea_`i'=. if ead_`i'==0 


}

foreach i in ofsp awassa83  {
replace sh_plotea_`i'=. if ead_`i'==0
}


foreach i in largerum smallrum poultry {
replace ead_cross_`i' =0 if ead_cross_`i' ==.
 replace sh_ea_`i'_o=. if ead_cross_`i'==0 
 replace sh_ea_`i'_k=. if ead_cross_`i'==0 

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


foreach i in ead_ofsp sh_plotea_ofsp sh_ea_ofsp {
lab var `i' "Sweet potato OFSP variety"
}

foreach i in  ead_awassa83  sh_plotea_awassa83 sh_ea_awassa83 {
lab var `i' "Sweet potato Awassa83 variety"
}

foreach i in ead_avocado sh_plotea_avocado sh_ea_avocado {
lab var `i' "Avocado tree"
}
foreach i in ead_papaya sh_plotea_papaya sh_ea_papaya {
lab var `i' "Papaya tree"
}
foreach i in ead_sweetpotato sh_plotea_sweetpotato sh_ea_sweetpotato {
lab var `i' "Sweetpotato"
}
foreach i in ead_fieldp sh_plotea_fieldp sh_ea_fieldp {
lab var `i' "Field peas"
}
foreach i in ead_mango sh_plotea_mango sh_ea_mango {
lab var `i' "Mango tree"
}
foreach i of varlist *impcr1{
	lab var `i' "Improved   BARLEY-SR"
	}
foreach i of varlist *impcr2{
	lab var `i' "Improved   MAIZE-SR"
	}
foreach i of varlist *impcr3{
	lab var `i' "Improved   MILLET-SR"
	}
foreach i of varlist *impcr4{
	lab var `i' "Improved   OATS-SR"
	}
foreach i of varlist *impcr5{
	lab var `i' "Improved   RICE-SR"
	}
foreach i of varlist *impcr6{
	lab var `i' "Improved   SORGHUM-SR"
	}
foreach i of varlist *impcr7{
	lab var `i' "Improved   TEFF-SR"
	}
foreach i of varlist *impcr8{
	lab var `i' "Improved   WHEAT-SR"
	}
foreach i of varlist *impcr9{
	lab var `i' "Improved   Mung Bean/ MASHO-SR"
	}
foreach i of varlist *impcr10{
	lab var `i' "Improved   CASSAVA-SR"
	}
foreach i of varlist *impcr11{
	lab var `i' "Improved   CHICK PEAS-SR"
	}
foreach i of varlist *impcr12{
	lab var `i' "Improved   HARICOT BEANS-SR"
	}
foreach i of varlist *impcr13{
	lab var `i' "Improved   HORSE BEANS-SR"
	}
foreach i of varlist *impcr14{
	lab var `i' "Improved   LENTILS-SR"
	}
foreach i of varlist *impcr15{
	lab var `i' "Improved   FIELD PEAS-SR"
	}
foreach i of varlist *impcr18{
	lab var `i' "Improved   SOYA BEANS-SR"
	}
foreach i of varlist *impcr19{
	lab var `i' "Improved   RED KIDENY BEANS-SR"
	}
foreach i of varlist *impcr23{
	lab var `i' "Improved   LINESEED-SR"
	}
foreach i of varlist *impcr24{
	lab var `i' "Improved   GROUND NUTS-SR"
	}
foreach i of varlist *impcr25{
	lab var `i' "Improved   NUEG-SR"
	}
foreach i of varlist *impcr26{
	lab var `i' "Improved   RAPE SEED-SR"
	}
foreach i of varlist *impcr27{
	lab var `i' "Improved   SESAME-SR"
	}
foreach i of varlist *impcr42{
	lab var `i' "Improved   BANANAS-SR"
	}
foreach i of varlist *impcr49{
	lab var `i' "Improved   PINAPPLES-SR"
	}
foreach i of varlist *impcr60{
	lab var `i' "Improved   POTATOES-SR"
	}
foreach i of varlist *impcr62{
	lab var `i' "Improved   SWEET POTATO-SR"
	}
foreach i of varlist *impcr71{
	lab var `i' "Improved   CHAT-SR"
	}
foreach i of varlist *impcr72{
	lab var `i' "Improved   COFFEE-SR"
	}
	/*
foreach i of varlist *impcr108{
	lab var `i' "Improved   AMBOSHIKA-SR"
	}
*/

lab var ead_treadle     "Treadle pump" 
lab var ead_motorpump   "Motor pump"
lab var ead_rdisp       "River dispersion" 
lab var ead_rotlegume   "Crop rotation with a legume"
lab var ead_cresidue1   "Crop residue cover - farmer elicitation"
lab var ead_cresidue2   "Crop residue cover - visual aid"
lab var ead_mintillage  "Minimum tillage"
lab var ead_zerotill    "Zero tillage"
lab var ead_consag1     "Conservation Agriculture - using minimum tillage"
lab var ead_consag2     "Conservation Agriculture - using zero tillage"
lab var ead_swc         "Soil Water Conservation practices" 
lab var ead_terr        "Terracing"
lab var ead_wcatch      "Water catchments"
lab var ead_affor       "Afforestation"
lab var ead_ploc        "Plough along the contour"

lab var ead_livIA       "Livestock AI"
lab var ead_elepgrass   "Feed and Forage: Elephant Grass"
lab var ead_gaya        "Feed and Forage: Gaya"
lab var ead_sasbaniya   "Feed and Forage: Sasbaniya"
lab var ead_alfa        "Feed and Forage: Alfalfa"
lab var ead_indprod     "Feed and Forage: Industry by-product"
lab var ead_feed		"Feed and forages"
lab var ead_grass        "Elephant grass, gaya, sasbaniya, alfalfa"

lab var sh_ea_treadle    "Treadle pump" 
lab var sh_ea_motorpump  "Motor pump"
lab var sh_ea_rdisp      "River dispersion" 
lab var sh_ea_rotlegume  "Crop rotation with a legume"
lab var sh_ea_cresidue1  "Crop residue cover - farmer elicitation"
lab var sh_ea_cresidue2  "Crop residue cover - visual aid"
lab var sh_ea_mintillage "Minimum tillage"
lab var sh_ea_consag1    "Conservation Agriculture - using minimum tillage"
lab var sh_ea_consag2    "Conservation Agriculture - using zero tillage"
lab var sh_ea_swc        "Soil Water Conservation practices" 
lab var sh_ea_terr       "Terracing"
lab var sh_ea_wcatch     "Water catchments"
lab var sh_ea_affor      "Afforestation"
lab var sh_ea_ploc       "Plough along the contour"



lab var sh_ea_livIA      "Livestock AI"
lab var sh_ea_elepgrass  "Feed and Forage: Elephant Grass"
lab var sh_ea_gaya       "Feed and Forage: Gaya"
lab var sh_ea_sasbaniya  "Feed and Forage: Sasbaniya"
lab var sh_ea_alfa       "Feed and Forage: Alfalfa"
lab var sh_ea_indprod    "Feed and Forage: Industry by-products"

lab var ead_cross          "Crossbreeding of large ruminants, small ruminants and poultry"
lab var ead_cross_largerum "Large ruminants crossbred"
lab var ead_cross_smallrum "Small ruminants crossbred"
lab var ead_cross_poultry  "Poultry crossbred"

lab var sh_ea_cross       "Crossbreeding of large ruminants, small ruminants and/or poultry"
lab var sh_ea_largerum_k  "Large ruminants crossbred"
lab var sh_ea_smallrum_k  "Small ruminants crossbred"
lab var sh_ea_poultry_k   "Poultry crossbred"

lab var sh_ea_largerum_o  "Large ruminants crossbred"
lab var sh_ea_smallrum_o  "Small ruminants crossbred"
lab var sh_ea_poultry_o   "Poultry crossbred"



merge 1:1 ea_id using "${data}${slash}ess4_community_new"
/*

    Result                           # of obs.
    -----------------------------------------
    not matched                           285
        from master                        11  (_merge==1)
        from using                        274  (_merge==2)

    matched                               253  (_merge==3)
    -----------------------------------------


*/

drop if _m==2
drop _merge

save "${data}${slash}wave4_ea_new", replace
save "${data}${slash}ess4_pp_ea_new", replace

********************************************************************************
* MERGING PLOT LEVEL DATA
********************************************************************************

use "${data}${slash}ess4_pp_cropvar_plot_new", clear


merge 1:1 holder_id household_id parcel_id field_id using "${data}${slash}ess4_pp_nrm_plot_new"
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                         5,967
        from master                         0  (_merge==1)
        from using                      5,967  (_merge==2)

    matched                            13,372  (_merge==3)
    -----------------------------------------
*/

drop _merge


merge m:1  holder_id household_id parcel_id using "${data}${slash}w4_sect2_pp_parcel_new"
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                           519
        from master                         1  (_merge==1)
        from using                        518  (_merge==2)

    matched                            19,337  (_merge==3)
    -----------------------------------------

*/

drop _merge

drop pw_w4
merge m:1 household_id using "${data}${slash}w4_coverPP_new"
keep if _m==3
drop _merge


collapse (max) sp_ofsp sp_awassa83 improv avocado mango papaya sweetpotato fieldp cdam1 cdam2 cdam3 cdam4 cdam5 cdamoth hsell impcr2 impcr1 saq14  plotirr rdisp treadle motorpump rotlegume cresidue1 cresidue2 mintillage zerotill swc terr wcatch affor ploc consag1 consag2 hh_plot_nb ea_plot_nb hh_plot_irr_nb ea_plot_irr_nb hh_plot_cult_nb ea_plot_cult_nb hh_plot_uses_nb ea_plot_uses_nb hh_plot_eros_nb ea_plot_eros_nb hh_plot_cplus_nb ea_plot_cplus_nb hh_plot_lprep_nb ea_plot_lprep_nb plotarea_sr plotarea_gps plotarea_full cropt1 cropt2 cropt3 cropm1 cropm2 falloq fplotm extprog irr irrm1 urea dap nps othfert manure hiredlab lprep soiler acqparc1 acqparc2 acqparc3 acqparc4 acqparc5 acqparc6 acqparc7 acqparc8 acqparcoth soilq1 soilq2 soilq3 soilt1 soilt2 soilt3 soilt4 soilt5 soilt6 frsell fowner title region  (firstnm)   pw_w4 saq01 ea_id, by(household_id parcel_id field_id)



save "${data}${slash}w4_plotlevel_pp_new", replace
