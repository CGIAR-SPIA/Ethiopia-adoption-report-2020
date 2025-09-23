doe********************************************************************************
*                           Ethiopia Synthesis Report 
*                     DO: 5_psnp (Productive Safety Net Program)
* Country: Ethiopia 
* Data: ESS 3 and ESS 4 
* Author: Paola Mallia | p.mallia@cgiar.org | paola_mallia@ymail.com 
* STATA Version: SE 16.1
********************************************************************************

* Household level for PSNP


* ESS3

use "${raw3}${slash}sect_cover_hh_w3.dta", clear
merge 1:m household_id2 using  "${raw3}${slash}sect1_hh_w3"
drop _m	
merge 1:1 household_id2 individual_id2 using  "${raw3}${slash}sect2_hh_w3"
drop _m
merge 1:1 household_id2 individual_id2 using  "${raw3}${slash}sect3_hh_w3"
drop _m
merge 1:1 household_id2 individual_id2 using  "${raw3}${slash}sect4_hh_w3"
drop _m


* Individual dummy
g psnp=.
replace psnp=0 if hh_s4q31==2
replace psnp=1 if hh_s4q31==1
* Household dummy
egen hhd_psnp=max(psnp), by(household_id2)
*Nb. of members per hh
egen hhm_psnp=count(psnp) if psnp==1, by(household_id2)
*Nb of days per hh
egen hh_dpsnp=sum(hh_s4q32) if psnp==1, by(household_id2)
*Nb. of days per member per hh
g hh_dpsnppc=hh_dpsnp/hhm_psnp
*Income per hh
egen hh_ipsnp=sum(hh_s4q33) if psnp==1, by(household_id2)

* Daily wage per individual
g dwpsnppc=hh_s4q33/hh_s4q32 if psnp==1
* Avg. daily wage per member per hh.
egen hh_dwpsnp=mean(dwpsnppc), by(household_id2)
* Conversion birr to dollar 15/9/2015
replace hh_dwpsnp=hh_dwpsnp/20.9653 if hhd_psnp==1
replace hh_ipsnp=hh_ipsnp/20.9653 if hhd_psnp==1

egen hh_ea=count(household_id2), by(ea_id2)
egen hhea_psnp=sum(hhd_psnp), by(ea_id2)


collapse (max) hhd_psnp  hhm_psnp  hh_dpsnp hh_dpsnppc hh_ipsnp hh_dwpsnp hh_ea hhea_psnp (firstnm) rural ea_id pw_w3  saq01 ea_id2 household_id, by(household_id2)


lab var hhd_psnp     "Percentage of hh with at least 1 member benefitting from PSNP" 
lab var hhm_psnp     "No. of members per hh benefitting from PSNP"
lab var hh_dpsnp     "No. of days per year hh benefitting from PSNP"
lab var hh_dpsnppc   "No. of days per year hh benefitting from PSNP - per member"
lab var hh_ipsnp     "Total income per hh per year from PSNP - USD"
lab var hh_dwpsnp    "Avg. daily income per hh-member from PSNP"
lab var rural        "Rural"
lab var ea_id        "ea id"
lab var ea_id2       "ea id 2"
lab var household_id "household id"
lab var pw_w3        "Sampling weight wage 3"

clonevar region=saq01
replace region=0 if region==2 | region==6 | region==15 | region==12 | region==13 | region==5
g wave=3

save "${data}${slash}ess3_hh_psnp", replace


* EA - level 

egen ead_psnp=max(hhd_psnp), by(ea_id2)
g sh_ea_psnp=hhea_psnp/hh_ea

collapse (max) ead_psnp sh_ea_psnp (firstnm) wave region saq01 pw_w3 rural ea_id2, by(ea_id)

lab var ead_psnp     "Perc. of EA with at least 1 hh benefitting from PSNP"
lab var sh_ea_psnp   "Perc. of hh per EA benefitting from PSNP"
lab var wave         "wave"
lab var ea_id2       "ea id 2"
lab var pw_w3        "Sampling weight wage 3"
lab var rural        "Rural"
lab var region       "region"

*Cleaning intermediate variables
drop saq01 

save "${data}${slash}ess3_ea_psnp", replace


* ESS4

use "${raw4}${slash}HH${slash}sect_cover_hh_w4", clear
merge 1:m household_id using "${raw4}${slash}HH${slash}sect1_hh_w4"
drop _m 
merge 1:1 individual_id household_id using "${raw4}${slash}HH${slash}sect2_hh_w4"
drop _m
merge 1:1 individual_id household_id using "${raw4}${slash}HH${slash}sect3_hh_w4"
drop _m
merge 1:1 individual_id household_id using "${raw4}${slash}HH${slash}sect4_hh_w4"
drop _m

* Individual dummy
g psnp=.
replace psnp=0 if s4q45==2
replace psnp=1 if s4q45==1
* Household dummy
egen hhd_psnp=max(psnp), by(household_id)
* Nb. of members per hh
egen hhm_psnp=count(psnp) if psnp==1, by(household_id)
* Nb. of days per hh
egen hh_dpsnp=sum(s4q46) if psnp==1, by(household_id)
* Nb. of days per member per hh
g hh_dpsnppc=hh_dpsnp/hhm_psnp
* Income per hh
egen hh_ipsnp=sum(s4q47) if psnp==1, by(household_id)

* Daily wage per individual
g dwpsnppc=s4q47/s4q46 if psnp==1
* Avg. daily wage per member per hh.
egen hh_dwpsnp=mean(dwpsnppc), by(household_id)
* Conversion birr to dollar ( rate of 15/9/2015)
replace hh_dwpsnp=hh_dwpsnp/20.9653 if hhd_psnp==1
replace hh_ipsnp=hh_ipsnp/20.9653 if hhd_psnp==1

egen hh_ea=count(household_id), by(ea_id)
egen hhea_psnp=sum(hhd_psnp), by(ea_id)

collapse (max) hhd_psnp  hhm_psnp  hh_dpsnp hh_dpsnppc hh_ipsnp hh_dwpsnp hh_ea hhea_psnp (firstnm) saq14  ea_id pw_w4  saq01 , by(household_id)


lab var hhd_psnp    "Percentage of hh with at least 1 member benefitting from PSNP" 
lab var hhm_psnp    "No. of members per hh benefitting from PSNP"
lab var hh_dpsnp    "No. of days per year hh benefitting from PSNP"
lab var hh_dpsnppc  "No. of days per year hh benefitting from PSNP - per member"
lab var hh_ipsnp    "Total income per hh per year from PSNP - USD"
lab var hh_dwpsnp   "Avg. daily income per hh-member from PSNP"
lab var ea_id        "ea id"
lab var pw_w4        "Sampling weight wage 4" 

clonevar region=saq01
replace region=0 if saq01==2 | saq01==6 | saq01==15 | saq01==12 | saq01==13 | saq01==5

g othregion=0
replace othregion=saq01 if  saq01==2 | saq01==6 | saq01==15 | saq01==12 | saq01==13 | saq01==5



g wave=4


save "${data}${slash}ess4_hh_psnp", replace


* EA - level 

egen ead_psnp=max(hhd_psnp), by(ea_id)
g sh_ea_psnp=hhea_psnp/hh_ea

collapse (max) ead_psnp sh_ea_psnp (firstnm) saq14 wave region othregion saq01 pw_w4, by(ea_id)

lab var ead_psnp   "Perc. of EA with at least 1 hh benefitting from PSNP"
lab var sh_ea_psnp "Perc. of hh per EA benefitting from PSNP"
lab var wave       "wave"
lab var region     "region"
lab var othregion  "other regions"
lab var pw_w4      "Sampling weight wage 4" 

save "${data}${slash}ess4_ea_psnp", replace




