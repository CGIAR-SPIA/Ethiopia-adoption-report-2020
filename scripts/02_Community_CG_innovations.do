* Community survey 
*Community Irrigation Scheme * Only for rural EAs
*ESS4

use "${raw4new}${slash}COMMUNITY${slash}sect06_com_w4", clear

merge 1:1 ea_id using "${raw4new}${slash}COMMUNITY${slash}sect03_com_w4"
drop _m

g commirr=.
replace commirr=0 if cs6q10==2
replace commirr=1 if cs6q10==1
lab var commirr "Community Irrigation Scheme"

g shhh_commirr=.
replace shhh_commirr=cs6q11/cs3q04b if cs6q11!=. & cs6q11<cs3q04b 
replace shhh_commirr=1 if cs6q11!=. & cs6q11>cs3q04b
replace shhh_commirr=0 if cs6q11==. & commirr==0
lab var shhh_commirr "Share of farmers that farm in the irrigation scheme (out of tot. no. of hh in community)"

keep commirr shhh_commirr ea_id 
save "${data}${slash}ess4_community_new", replace 
