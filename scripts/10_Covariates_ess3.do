********************************************************************************
*                           Ethiopia Synthesis Report 
*                                10_Covariates_ess3
* Country: Ethiopia 
* Data: ESS3 
* Author: Paola Mallia | p.mallia@cgiar.org | paola_mallia@ymail.com 
* STATA Version: SE 16.1
********************************************************************************

****************************
*ESS3 - years of education *
****************************



use "${raw3}${slash}sect2_hh_w3", clear


g       yrseduc=.
replace yrseduc=0 if hh_s2q05==0
replace yrseduc=1 if hh_s2q05==1
replace yrseduc=2 if hh_s2q05==2
replace yrseduc=3 if hh_s2q05==3
replace yrseduc=4 if hh_s2q05==4
replace yrseduc=5 if hh_s2q05==5
replace yrseduc=6 if hh_s2q05==6
replace yrseduc=7 if hh_s2q05==7
replace yrseduc=8 if hh_s2q05==8
replace yrseduc=9 if hh_s2q05==9
replace yrseduc=10 if hh_s2q05==10
replace yrseduc=11 if hh_s2q05==11
replace yrseduc=12 if hh_s2q05==12
replace yrseduc=13 if hh_s2q05==13
replace yrseduc=13 if hh_s2q05==14
replace yrseduc=13 if hh_s2q05==15
replace yrseduc=14 if hh_s2q05==16
replace yrseduc=13 if hh_s2q05==17
replace yrseduc=15 if hh_s2q05==18
replace yrseduc=13 if hh_s2q05==19
replace yrseduc=17 if hh_s2q05==20
replace yrseduc=9  if hh_s2q05==21
replace yrseduc=10 if hh_s2q05==22
replace yrseduc=11 if hh_s2q05==23
replace yrseduc=12 if hh_s2q05==24
replace yrseduc=11 if hh_s2q05==25
replace yrseduc=12 if hh_s2q05==26
replace yrseduc=12 if hh_s2q05==27
replace yrseduc=13 if hh_s2q05==28
replace yrseduc=13 if hh_s2q05==29
replace yrseduc=13 if hh_s2q05==30
replace yrseduc=13 if hh_s2q05==31
replace yrseduc=14 if hh_s2q05==32
replace yrseduc=15 if hh_s2q05==33
replace yrseduc=16 if hh_s2q05==34
replace yrseduc=17 if hh_s2q05==35
replace yrseduc=0 if hh_s2q05==93
replace yrseduc=0 if hh_s2q05==94
replace yrseduc=0 if hh_s2q05==95
replace yrseduc=0 if hh_s2q05==96
replace yrseduc=0 if hh_s2q05==98
lab var yrseduc "HH-head years of education completed"




merge 1:1 household_id2 individual_id2 using "${raw3}${slash}sect1_hh_w3"
keep if _m==3
drop _m
keep if hh_s1q02==1

collapse (max) yrseduc, by(household_id2)
lab var yrseduc "HH-head years of education completed"

replace yrseduc=0 if yrseduc==.

tempfile educ_w3
save `educ_w3'





********************************************************************************
* HH Demo groups
********************************************************************************
use "${raw3}${slash}sect1_hh_w3", clear

bys household_id2 : egen hh_size=count(individual_id2)



bys household_id2 individual_id2: g fadult=_n if hh_s1q03==2 & hh_s1q04a>15
by household_id2: egen fadult2=sum(fadult)
drop fadult
rename fadult2 fadult

bys household_id2 individual_id2: g madult=_n if hh_s1q03==1 & hh_s1q04a>15
by household_id2: egen madult2=sum(madult)
drop madult
rename madult2 madult

lab var fadult "No. of female adults in hh"
lab var madult "No. of male adults in hh"

**********************
* DEMOGRAPHIC GROUPS *
**********************
g age4=(hh_s1q04a<=4)
egen ch4=sum(age4), by (household_id)
la var ch4 "Number of children <=4 yrs old" 
drop age4

g age5=(hh_s1q04a<=5 )
egen ch5=sum(age5), by (household_id)
la var ch5 "Number of children <=5 yrs old" 
drop age5

g age510=(hh_s1q04a>=5 & hh_s1q04a<=10)
egen ch510=sum(age510), by (household_id)
la var ch510 "Number of children 5-10 yrs old" 
drop age510

g age610=(hh_s1q04a>=6 &  hh_s1q04a<=10)
egen ch610=sum(age610), by (household_id)
la var ch610 "Number of children 6-10 yrs old" 
drop age610

g mage1114=(hh_s1q03==1 & (hh_s1q04a>=11 &  hh_s1q04a<=14))
egen m1114=sum(mage1114), by (household_id)
la var m1114 "Number of boys 11-14 yrs old" 
drop mage1114

g fage1114=(hh_s1q03==2 & (hh_s1q04a>=11 & hh_s1q04a<=14))
egen f1114=sum(fage1114), by (household_id)
la var f1114 "Number of girls 11-14 yrs old" 
drop fage1114

g mage1519=(hh_s1q03==1 & (hh_s1q04a>=15 & hh_s1q04a<=19))
egen m1519=sum(mage1519), by (household_id)
la var m1519 "Number of males 15-19 yrs old" 
drop mage1519

g fage1519=(hh_s1q03==2 & (hh_s1q04a>=15 & hh_s1q04a<=19))
egen f1519=sum(fage1519), by (household_id)
la var f1519 "Number of females 15-19 yrs old" 
drop fage1519

g mage2034=(hh_s1q03==1 & (hh_s1q04a>=20 & hh_s1q04a<=34))
egen m2034=sum(mage2034), by (household_id)
la var m2034 "Number of males 20-34 yrs old" 
drop mage2034

g fage2034=(hh_s1q03==2 & (hh_s1q04a>=20 & hh_s1q04a<=34))
egen f2034=sum(fage2034), by (household_id)
la var f2034 "Number of females 20-34 yrs old" 
drop fage2034

g mage3559=(hh_s1q03==1 & (hh_s1q04a>=35 & hh_s1q04a<=59))
egen m3559=sum(mage3559), by (household_id)
la var m3559 "Number of males 35-59 yrs old" 
drop mage3559

g fage3559=(hh_s1q03==2 & (hh_s1q04a>=35 & hh_s1q04a<=59))
egen f3559=sum(fage3559), by (household_id)
la var f3559 "Number of females 35-59 yrs old" 
drop fage3559

g mage60p=(hh_s1q03==1 & hh_s1q04a>=60 & hh_s1q04a<110)
egen m60p=sum(mage60p), by (household_id)
la var m60p "Number of males >=60 yrs old" 
drop mage60p

g fage60p=(hh_s1q03==2 & hh_s1q04a>=60 & hh_s1q04a<110)
egen f60p=sum(fage60p), by (household_id)
la var f60p "Number of females >=60 yrs old" 
drop fage60p


g numadult=m1519+m2034+m3559+m60p+f1519+f2034+f3559+f60p
la var numadult "# of adults (age>=15)"
g numchildren=ch4+ch510+m1114+f1114
la var numchildren "# of children (age<15)"
g numwomen=f1519+f2034+f3559+f60p
la var numwomen "# of women (age>=15)"

g      depend_ratio=(ch4+ch510+m1114+f1114+m60p+f60p)/(m1519+f1519+m2034+f2034+m3559+f3559)
la var depend_ratio "dependency ratio"
note   depend_ratio: constructed by: (sh_0114+sh_60p)/(1-(sh_0114+sh_60p))

g id_ae =.
replace id_ae = 0.33 if hh_s1q04a>=0  & hh_s1q04a<1
replace id_ae = 0.46 if hh_s1q04a>=1  & hh_s1q04a<2
replace id_ae = 0.54 if hh_s1q04a>=2  & hh_s1q04a<3
replace id_ae = 0.62 if hh_s1q04a>=3  & hh_s1q04a<5
replace id_ae = 0.74 if hh_s1q04a>=5  & hh_s1q04a<7  & hh_s1q03==1
replace id_ae = 0.70 if hh_s1q04a>=5  & hh_s1q04a<7  & hh_s1q03==2
replace id_ae = 0.84 if hh_s1q04a>=7  & hh_s1q04a<10 & hh_s1q03==1
replace id_ae = 0.72 if hh_s1q04a>=7  & hh_s1q04a<10 & hh_s1q03==2
replace id_ae = 0.88 if hh_s1q04a>=10 & hh_s1q04a<12 & hh_s1q03==1
replace id_ae = 0.78 if hh_s1q04a>=10 & hh_s1q04a<12 & hh_s1q03==2
replace id_ae = 0.96 if hh_s1q04a>=12 & hh_s1q04a<14 & hh_s1q03==1
replace id_ae = 0.84 if hh_s1q04a>=12 & hh_s1q04a<14 & hh_s1q03==2
replace id_ae = 1.06 if hh_s1q04a>=14 & hh_s1q04a<16 & hh_s1q03==1
replace id_ae = 0.86 if hh_s1q04a>=14 & hh_s1q04a<16 & hh_s1q03==2
replace id_ae = 1.14 if hh_s1q04a>=16 & hh_s1q04a<18 & hh_s1q03==1
replace id_ae = 0.86 if hh_s1q04a>=16 & hh_s1q04a<18 & hh_s1q03==2
replace id_ae = 1.04 if hh_s1q04a>=18 & hh_s1q04a<30 & hh_s1q03==1
replace id_ae = 0.80 if hh_s1q04a>=18 & hh_s1q04a<30 & hh_s1q03==2
replace id_ae = 1    if hh_s1q04a>=30 & hh_s1q04a<60 & hh_s1q03==1
replace id_ae = 0.82 if hh_s1q04a>=30 & hh_s1q04a<60 & hh_s1q03==2
replace id_ae = 0.84 if hh_s1q04a>=60 & hh_s1q03==1
replace id_ae = 0.74 if hh_s1q04a>=60 & hh_s1q03==2


bys household_id: egen hhsize_ae=sum(id_ae)
la var hhsize_ae "Household size in adult equivalent"
drop id_ae


g sh_ch4   = ch4   /hh_size
g sh_ch510 = ch510 /hh_size
g sh_m1114 = m1114 /hh_size
g sh_f1114 = f1114 /hh_size
g sh_m1519 = m1519 /hh_size
g sh_f1519 = f1519 /hh_size
g sh_m2034 = m2034 /hh_size
g sh_f2034 = f2034 /hh_size
g sh_m3559 = m3559 /hh_size
g sh_f3559 = f3559 /hh_size
g sh_m60p  = m60p  /hh_size
g sh_f60p  = f60p  /hh_size
la var sh_ch4   "% (#/hhsize) of children <=4" 
la var sh_ch510 "% (#/hhsize) of children 5-10" 
la var sh_m1114 "% (#/hhsize) of boys 11-14" 
la var sh_f1114 "% (#/hhsize) of girls 11-14" 
la var sh_m1519 "% (#/hhsize) of males 15-19" 
la var sh_f1519 "% (#/hhsize) of females 15-19" 
la var sh_m2034 "% (#/hhsize) of males 20-34" 
la var sh_f2034 "% (#/hhsize) of females 20-34" 
la var sh_m3559 "% (#/hhsize) of males 35-59" 
la var sh_f3559 "% (#/hhsize) of females 35-59" 
la var sh_m60p  "% (#/hhsize) of males >=60" 
la var sh_f60p  "% (#/hhsize) of females >=60" 

g sh_0114= (ch4+ch510+m1114+f1114)/hh_size
g sh_1559= (m1519+f1519+m2034+f2034+m3559+f3559)/hh_size
g sh_60p = (m60p+f60p)/hhsize
la var sh_0114 "% of members aged 0-14" 
la var sh_1559 "% of members aged 15-59" 
la var sh_60p  "% of members aged >=60"

foreach v of varlist fadult madult ch4 ch5 ch510 ch610 m1114 f1114 m1519 f1519 m2034 f2034 m3559 f3559 m60p f60p numadult numchildren numwomen depend_ratio hhsize_ae sh_ch4 sh_ch510 sh_m1114 sh_f1114 sh_m1519 sh_f1519 sh_m2034 sh_f2034 sh_m3559 sh_f3559 sh_m60p sh_f60p sh_0114 sh_1559 sh_60p {                           
local l`v': variable label `v'     
if `"`l`v''"'==""{                                                                    
local l`v' "`v'"                                                                      
}                                                                                     
}

collapse (max) fadult madult ch4 ch5 ch510 ch610 m1114 f1114 m1519 f1519 m2034 f2034 m3559 f3559 m60p f60p numadult numchildren numwomen depend_ratio hhsize_ae sh_ch4 sh_ch510 sh_m1114 sh_f1114 sh_m1519 sh_f1519 sh_m2034 sh_f2034 sh_m3559 sh_f3559 sh_m60p sh_f60p sh_0114 sh_1559 sh_60p hh_size, by(household_id2)




foreach v of varlist fadult madult ch4 ch5 ch510 ch610 m1114 f1114 m1519 f1519 m2034 f2034 m3559 f3559 m60p f60p numadult numchildren numwomen depend_ratio hhsize_ae sh_ch4 sh_ch510 sh_m1114 sh_f1114 sh_m1519 sh_f1519 sh_m2034 sh_f2034 sh_m3559 sh_f3559 sh_m60p sh_f60p sh_0114 sh_1559 sh_60p {                                            
label var `v' "`l`v''"   
} 

do "$do${slash}label_values.do"
foreach var of local list_of_vars_w_valuelables {
   cap label values `var' `varlabel_`var''
}


tempfile agegroup
save `agegroup'


****************************************
* HH farm Labor (in particular female) *
****************************************

* Land preparation, planting, fertilizer application etc. - PP survey
use "${raw3}${slash}sect3_pp_w3", clear

rename pp_s3q27_a pp_s3q27_1
rename pp_s3q27_e pp_s3q27_2
rename pp_s3q27_i pp_s3q27_3
rename pp_s3q27_m pp_s3q27_4


reshape long pp_s3q27_, i(holder_id household_id2 parcel_id field_id) j(membernb)




drop if pp_s3q27_==.a 
drop if pp_s3q27_==.
drop if pp_s3q27_==0


rename  pp_s3q27_ hh_s1q00


merge m:1  household_id2 hh_s1q00 using  "${raw3}${slash}sect1_hh_w3"


drop if _m==2
drop _merge
bys household_id2 parcel_id field_id: egen fhhlab1=count(hh_s1q00) if hh_s1q03==2 & hh_s1q04a>=15
merge m:1 household_id2 using `agegroup', keepusing(hh_size)

drop if _m==2
drop _merge

g  sh_fhhlab1=fhhlab1/hh_size 
bys household_id2 parcel_id field_id: egen sh_fhhlab2=max(sh_fhhlab1)

by household_id2: egen sh_fhhlabmax=max(sh_fhhlab2)
by household_id2: egen sh_fhhlabmin=min(sh_fhhlab2)
by household_id2: egen sh_fhhlabavg=mean(sh_fhhlab2)

collapse (firstnm) sh_fhhlabmax sh_fhhlabmin sh_fhhlabavg, by(household_id2)

rename sh_fhhlabmax sh_fhhlabmax1
rename sh_fhhlabmin sh_fhhlabmin1
rename sh_fhhlabavg sh_fhhlabavg1

lab var sh_fhhlabmax1 "Share of female family labor (>15y.o.) - Max"
lab var sh_fhhlabmin1 "Share of female family labor (>15y.o.) - Min"
lab var sh_fhhlabavg1 "Share of female family labor (>15y.o.) - Avg"


foreach i in sh_fhhlabmax1 sh_fhhlabmin1 sh_fhhlabavg1 {
replace `i' =0 if `i' ==.
}

g       hhd_flab=.
replace hhd_flab=0 if sh_fhhlabavg1<0.5
replace hhd_flab=1 if sh_fhhlabavg1>=0.5
lab var hhd_flab "Share of female family labor >50%"



tempfile  hhfamlab1
save     `hhfamlab1'
 count



********************************************************************************
* Harvest labor same as above *
********************************************************************************
use "${raw3}${slash}sect10_ph_w3", clear

rename ph_s10q02_a ph_s10q02_1
rename ph_s10q02_e ph_s10q02_2
rename ph_s10q02_i ph_s10q02_3
rename ph_s10q02_m ph_s10q02_4


reshape long ph_s10q02_, i(holder_id household_id2 parcel_id field_id crop_code) j(membernb)



drop if ph_s10q02_==.a 
drop if ph_s10q02_==.
drop if ph_s10q02_==0


rename  ph_s10q02_ hh_s1q00


merge m:1  household_id2 hh_s1q00 using  "${raw3}${slash}sect1_hh_w3"


drop if _m==2
drop _merge

bys household_id2 parcel_id field_id crop_code: egen fhhlab1=count(hh_s1q00) if hh_s1q03==2 & hh_s1q04a>=15
merge m:1 household_id2 using `agegroup', keepusing(hh_size)


drop if _m==2
drop _merge

g  sh_fhhlab1=fhhlab1/hh_size 
bys household_id2 parcel_id field_id crop_code: egen sh_fhhlab2=max(sh_fhhlab1)

by household_id2: egen sh_fhhlabmax=max(sh_fhhlab2)
by household_id2: egen sh_fhhlabmin=min(sh_fhhlab2)
by household_id2: egen sh_fhhlabavg=mean(sh_fhhlab2)

collapse (firstnm) sh_fhhlabmax sh_fhhlabmin sh_fhhlabavg, by(household_id2)

rename sh_fhhlabmax sh_fhhlabmax2
rename sh_fhhlabmin sh_fhhlabmin2
rename sh_fhhlabavg sh_fhhlabavg2

lab var sh_fhhlabmax2 "Share of female family labor (>15y.o.) - Max"
lab var sh_fhhlabmin2 "Share of female family labor (>15y.o.) - Min"
lab var sh_fhhlabavg2 "Share of female family labor (>15y.o.) - Avg"

foreach i in sh_fhhlabmax2 sh_fhhlabmin2 sh_fhhlabavg2 {
replace `i' =0 if `i' ==.
} 


tempfile  hhfamlab2
save     `hhfamlab2'

****************************************
* FEMALE LIVESTOCK  MANAGERS *
****************************************


use "${raw3}${slash}sect8_1_ls_w3", clear
*Manager
rename ls_sec_8_1q03_a ls_sec_8_1q03_1 
rename ls_sec_8_1q03_b ls_sec_8_1q03_2


reshape long ls_sec_8_1q03_, i( holder_id household_id2 ls_code) j(membernb)

drop if ls_sec_8_1q03_==.
drop if ls_sec_8_1q03_==.a

rename  ls_sec_8_1q03_ pp_s1q00
merge m:1 holder_id household_id2 pp_s1q00 using  "${raw3}${slash}sect1_pp_w3"
keep if _m==3
drop _merge

g       flivman1=0 
replace flivman1=1 if pp_s1q03==2
bys household_id2: egen flivman=max(flivman1)
drop flivman1




rename   pp_s1q00 ls_sec_8_1q03_
drop membernb

collapse (max) flivman (firstnm)  rural, by(household_id2)
lab var flivman "At least 1 female livestock manager/keeper in the hh"
tempfile flivman
save `flivman'



********************************************************************************
* Covariates produced by Solomon
********************************************************************************

use "${cov3hh}${slash}HH_LEVEL_DATA_2015", clear

lab var sex_head       "HH-head is male"
lab var age_head       "HH-head age in years"
lab var educ_head_att  "HH-head attended school"
lab var educ_head_fr   "HH-head formal education"
rename  Marital_head2 marr_head
lab var marr_head     "HH-head is married"
rename mainoc_head2 agr_head 
lab var agr_head       "HH-head main occupation is agriculture"
lab var adulteq        "HH size in adult equivalent"
rename asset_index asset_quint
lab var asset_quint    "Asset index - quintiles"
rename asset asset_index
lab var asset_index    "Asset index"
rename  asset_prod pssetindex
lab var pssetindex     "Productive asset index"
rename prod_asset_ndex prodasset_quint
lab var prodasset_quint "Productive asset index - quintiles"
rename Non_farmbusin nonfarm_bus
lab var nonfarm_bus    "HH owns non-farm business"
rename receivedofffarm offfarminc
lab var offfarminc     "HH received off-farm income"
lab var income_offfarm "Annual Off-farm income in BIRR"
lab var parcesizeHA    "Total parcels size in HA per hh"


rename nonfood_cons_ann nfoodcann
rename educ_cons_ann educcann
rename total_cons_ann tcann
rename nom_totcons_aeq ntcaeq
rename dist_popcenter dpop
rename dist_market dmkt
rename dist_borderpost dbp

rename wetQ_avgstart wtstart
rename h2015_wetQstart hwtstart


*******Merge with vars produced in this do file *


merge 1:1 household_id2 using `educ_w3'

drop _merge

merge 1:1 household_id2 using `agegroup'
drop _merge

merge 1:1 household_id2 using "${data}${slash}ess3_hh_psnp"
keep if _m==3
drop _m

merge 1:1 household_id2 using `hhfamlab1'
drop if _m==2
drop _merge

merge 1:1 household_id2 using `hhfamlab2'
drop if _m==2
drop _merge


merge 1:1 household_id2 using `flivman'
drop if _m==2
drop _merge

merge 1:1 household_id2 using "${data}${slash}ess3_pp_hhlevel_parcel"
drop if _m==2
drop _m

g consq1=0 if cons_quint>1
replace consq1=1 if cons_quint==1

g consq2=0 if cons_quint>2
replace consq2=1 if cons_quint==1 | cons_quint==2
lab var consq1 "Bottom 1 consumption quintile" 
lab var consq2 "Bottom 1-2 (<40%) consumption quintiles"




save "${data}${slash}HH_LEVEL_DATA_2015_relab", replace

********************************************************************************
*** Innovation dataset
********************************************************************************
use "${data}${slash}ess3_pp_hh", clear

merge 1:1 household_id2  using "${data}${slash}HH_LEVEL_DATA_2015_relab" 
keep if _m==3
drop _m
replace wave=3
drop region
clonevar region=saq01
replace region=0 if region==2 | region==6 | region==15 | region==12 | region==13 | region==5


save "${data}${slash}ess3_pp_cov", replace

********************************************************************************
* PLOT LEVEL - ess3
********************************************************************************


use "${cov3plot}${slash}Merged_plot_level_data", clear 
keep dist_household plot_srtmslp plot_srtm plot_twi holder_id household_id household_id2 rural pw_w3 parcel_id field_id pp_s3q091 pp_s3q092 pp_s3q093 pp_s3q03c fied_prpa1 fied_prpa2 fied_prpa3 fied_prpa4 pp_s4q05 pp_s4q06 pp_s4q07 
lab var pp_s3q091  "Field appearance: Flat"
lab var pp_s3q092  "Field appearance: Sloppy - Moderate"
lab var pp_s3q093  "Field appearance: Sloppy - Steep"
lab var pp_s3q03c  "Field left fallow in the last 10 years"
lab var fied_prpa1 "Field preparation: Tractor"
lab var fied_prpa2 "Field preparation: Animal"
lab var fied_prpa3 "Field preparation: Digging by hand"
lab var fied_prpa4 "Field preparation: other"
lab var pp_s4q05   "Incidence of pesticide use"
lab var pp_s4q06   "Incidence of herbicide"
lab var pp_s4q07   "Incidence of fungicide"



duplicates drop dist_household plot_srtmslp plot_srtm plot_twi holder_id household_id household_id2 rural pw_w3 parcel_id field_id, force


save "${data}${slash}Merged_plot_level_data_final", replace


use "${data}${slash}w3_plotlevel_pp", clear

merge 1:1 household_id2 holder_id parcel_id field_id  using "${data}${slash}Merged_plot_level_data_final" 


drop _merge





g wave=3
drop region
clonevar region=saq01

replace region=0 if region==2 | region==6 | region==15 | region==12 | region==13 | region==5


save "${data}${slash}ess3_pp_cov_plot", replace 


********************************************************************************
* EA level
********************************************************************************

use "${cov3com}${slash}com_level_merged_S3_S4_S6_S9_merged with WAVE1_v2.dta", clear ///Solomon 

merge m:1 ea_id using  "${data}${slash}ess3_pp_ea" //Innovations 

keep if _m==3
drop _m
lab var cs9q01_2015          "PSNP operated in this kebele" //bin
lab var cs9q13               "No. of hhs that graduated from PSNP"
lab var cs9q13_WIZ           "No. of hhs that graduated from PSNP - winsorized"
lab var cs9q14               "% of participants that graduated since Meskerem EC2000"
lab var cs9q14_WIZ			 "% of participants that graduated since Meskerem EC2000 - winsorized"
lab var cs6q01_2015			 "Hhs farm crops or keep livestock in this community" //bin

rename cs9q01_2015 cs9q01
rename cs9q13_WIZ  cs9q13wiz
rename cs9q14_WIZ  cs9q14wiz
rename cs6q01_2015 cs6q01

lab var cs6q10_2015          "Irrigation scheme in the community" //bin
lab var cs6q11               "No. of farmers in community irrigation scheme"
lab var cs6q11_WIZ           "No. of farmers in community irrigation scheme - winsorized"

rename cs6q10_2015 cs6q10
rename cs6q11_WIZ  cs6q10wiz

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


lab var cs4q02_1_2015        "Distance to the nearest tar/asphalt road (KM)"
lab var cs4q02_1_2015_wiz    "Distance to the nearest tar/asphalt road (KM) - winsorized"

rename cs4q02_1_2015 cs4q02
rename cs4q02_1_2015_wiz  cs4q02wiz

lab var dist_roadmedi2015    "HH distance to nearest major road (GPS) -median values"
rename dist_roadmedi2015 droad

lab var cs4q011              "Type of main access road surfarce: tar/asphalt" //bin
lab var cs4q012              "Type of main access road surfarce: graded graveled" //bin
lab var cs4q013              "Type of main access road surfarce: dirt road (maintained)" //bin
lab var cs4q014              "Type of main access road surfarce: dirt track" //bin

lab var cs4q03               "Vehicles pass on the main road throughout the year" //bin


lab var cs4q08               "Community is a woreda town" //bin

lab var cs4q09_2015          "Distance to the nearest Woreda/town (KM)"
rename  cs4q09_2015  cs4q09
lab var cs4q09_2015_wiz      "Distance to the nearest Woreda/town (KM) - winsorized"
rename  cs4q09_2015_wiz cs4q09wiz
lab var cs4q11               "Community is a major urban center (Regional or Zonal Capital)" //bin
lab var cs4q12_b1_2015       "Distance to the major urban center (KM)"
lab var cs4q12_b1_2015_wiz   "Distance to the major urban center (KM) - winsorized" 
rename cs4q12_b1_2015 cs4q12
rename cs4q12_b1_2015_wiz cs4q12wiz
lab var dist_admctrmedi2015  "HH distance to Capital of Zone of residence (KM) - median values"
rename dist_admctrmedi2015 dadm
lab var cs4q14               "Large weekly market in this community" //bin
lab var cs4q150_2015 		 "Distance to the nearest large weekly market (KM)"
rename  cs4q150_2015 cs4q150
lab var cs4q150_2015_wiz	 "Distance to the nearest large weekly market (KM) - winsorized"
rename cs4q150_2015_wiz cs4q150wiz
lab var dist_marketmedi2015  "HH distance to nearest market (KM) - median values"
rename dist_marketmedi2015 dmkt
lab var cs3q02                "Population size in the community"
lab var cs3q02_WiZ            "Population size in the community - winsorized"
rename cs3q02_WiZ cs3q02wiz
lab var csdq54                "Incidence of SACCO in the community" //bin
lab var csdq55                "Distance to the nearest place where there is SACCO (Km)"



rename ead_cross_largerum ead_crlr
rename ead_cross_smallrum ead_crsr
rename ead_cross_poultry  ead_crpo


replace cs4q12=0    if cs4q12==.    & cs4q11==1
replace cs4q12wiz=0 if cs4q12wiz==. & cs4q11==1

replace cs4q150=0 if cs4q150==. & cs4q14==1
replace cs4q150wiz=0 if cs4q150wiz==. & cs4q14==1

replace csdq55=0    if csdq55==.    & csdq54==1
replace cs4q150=cs4q15_2011 if cs4q150==.
replace cs4q150wiz=cs4q15_2011 if cs4q150wiz==.


merge 1:1 ea_id2 using "${data}${slash}ess3_ea_psnp"
keep if _m==3
drop _merge

save "${data}${slash}ess3_pp_cov_ea", replace
