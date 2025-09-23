* Adopters and non adopters decriptive stats.
* T-stats of means by region
*ESS4*

use "${data}${slash}ess4_pp_cov_new", clear // HH-level 

replace hhd_psnp=100 if hhd_psnp==1

foreach i in maize_cg barley_cg sorghum_cg qpm dtmz {
	replace `i'=100 if `i'==1

}

rename nom_totcons_aeq nmtotcons
rename hhd_mintillage hhd_mintil
rename hhd_sweetpotato hhd_sp
rename  total_cons_ann_win totconswin
replace hhd_impcr2=. if maize_cg==.

*HH level 
#delimit;
global hhdemo      hhd_flab flivman
parcesizeHA  asset_index pssetindex income_offfarm total_cons_ann totconswin nmtotcons consq1 consq2 adulteq 
;
#delimit cr

*ex /// sihs note: not a valid stata command

global adopt     hhd_rdisp hhd_motorpump hhd_rotlegume hhd_cresidue1 hhd_cresidue2 hhd_mintil hhd_zerotill hhd_consag1 hhd_consag2 hhd_swc hhd_terr hhd_wcatch hhd_affor hhd_ploc hhd_ofsp hhd_awassa83 hhd_avocado hhd_papaya hhd_mango  hhd_fieldp hhd_sp hhd_cross  hhd_crlr  hhd_crpo  hhd_indprod hhd_grass hhd_psnp maize_cg sorghum_cg barley_cg dtmz hhd_impcr2 hhd_impcr1


*qpm dtmz

matrix drop _all
 
foreach i in   $adopt {
foreach var in $hhdemo {



qui: mean    `var' [pw=pw_w4]           if wave==4 & `i'==100
matrix  `var'mt`i'=e(b)'
scalar  `var'mt`i'= `var'mt`i'[1,1]

matrix define `var'Vt`i'= e(V)'
matrix define `var'VVt`i'=(vecdiag(`var'Vt`i'))'
matrix list `var'VVt`i'
scalar `var'vart`i'=`var'VVt`i'[1,1]
scalar `var'set`i'=sqrt(`var'VVt`i'[1,1])



qui: mean `var' [pw=pw_w4]              if  wave==4 & `i'==0
matrix  `var'mc`i'=e(b)'
scalar  `var'mc`i'= `var'mc`i'[1,1]
matrix define `var'Vc`i'= e(V)'
matrix define `var'VVc`i'=(vecdiag(`var'Vc`i'))'
matrix list `var'VVc`i'
scalar `var'varc`i'=`var'VVc`i'[1,1]
scalar `var'sec`i'=sqrt(`var'VVc`i'[1,1])


qui sum `i' if `i'==0  & wave==4
local controbs`i'=r(N)

qui sum `i' if `i'==100 & wave==4
local treatobs`i'=r(N)


matrix mstrhelp`i'=(0,0,0,0,0)


    
scalar `var'df`i'=(`var'mt`i'-`var'mc`i') //Simple difference

*scalar `var'df`i'=((`var'mt`i'-`var'mc`i') / sqrt((`var'vart`i'+ `var'varc`i')/2))

qui: reg `var' `i' if  wave==4 [pw=pw_w4]
*local t = _b[`i']/_se[`i']
*scalar `var'pval`i' = 2*ttail(e(df_r), abs(`t'))
test `i'=0
scalar `var'pval`i'=r(p)

qui: reg `var' `i'   i.region if  wave==4 [pw=pw_w4]
*local t = _b[`i']/_se[`i']
*scalar `var'pval`i' = 2*ttail(e(df_r), abs(`t'))
test `i'=0
scalar `var'pvalf`i'=r(p)



matrix mat`var'`i'  = (`var'mt`i',  `var'mc`i', `var'df`i', `var'pval`i', `var'pvalf`i') 
matrix mat1`var'`i' = (`var'set`i', `var'sec`i',         .,            .,             .) 


    if (`var'pval`i'<=0.1 & `var'pval`i'>0.05)   & (`var'pvalf`i'<=0.1  & `var'pvalf`i'>0.05)  {
	matrix mstr`var'`i' = (0, 0, 0, 3, 3) 
     }
	if (`var'pval`i'  <=0.1 & `var'pval`i'>0.05) & (`var'pvalf`i' <=0.05 & `var'pvalf`i' >0.01) {
	matrix mstr`var'`i' = (0, 0, 0, 3, 2) 
     }
	 if (`var'pval`i'  <=0.1 & `var'pval`i'>0.05) & `var'pvalf`i'<=0.01 {
	matrix mstr`var'`i' = (0, 0, 0, 3, 1) 
     }
	 if (`var'pval`i'  <=0.1 & `var'pval`i'>0.05) & `var'pvalf`i'>0.1   {
	matrix mstr`var'`i' = (0, 0, 0, 3, 0) 
     }
	 
	 
    if (`var'pval`i'  <=0.05 & `var'pval`i'>0.01)  & (`var'pvalf`i'<=0.1  & `var'pvalf`i'>0.05)  {
	matrix mstr`var'`i' = (0, 0, 0, 2, 3) 
     }
	if (`var'pval`i'  <=0.05 & `var'pval`i'>0.01)  & (`var'pvalf`i' <=0.05 & `var'pvalf`i' >0.01) {
	matrix mstr`var'`i' = (0, 0, 0, 2, 2) 
     }
    if (`var'pval`i'  <=0.05 & `var'pval`i'>0.01)   & `var'pvalf`i'<=0.01 {
	matrix mstr`var'`i' = (0, 0, 0, 2, 1) 
     }
	 if (`var'pval`i'  <=0.05 & `var'pval`i'>0.01)   & `var'pvalf`i'>0.1  {
	matrix mstr`var'`i' = (0, 0, 0, 2, 0) 
     }	 
	 
	 
	 if `var'pval`i'  <=0.01 & (`var'pvalf`i'<=0.1  & `var'pvalf`i'>0.05) {
	matrix mstr`var'`i' = (0, 0, 0, 1, 3) 
     }
	if `var'pval`i'  <=0.01 & (`var'pvalf`i' <=0.05 & `var'pvalf`i' >0.01) {
	matrix mstr`var'`i' = (0, 0, 0, 1, 2) 
     }
	 if `var'pval`i'  <=0.01 &  `var'pvalf`i'<=0.01 {
	matrix mstr`var'`i' = (0, 0, 0, 1, 1) 
     }
	 if `var'pval`i'  <=0.01  & `var'pvalf`i'>0.1 {
	matrix mstr`var'`i' = (0, 0, 0, 1, 0) 
     }
	 
	 
	if `var'pval`i'   >0.1 & (`var'pvalf`i'<=0.1  & `var'pvalf`i'>0.05)  {
	matrix mstr`var'`i' = (0, 0, 0, 0, 3) 
     }
	if `var'pval`i'   >0.1 & (`var'pvalf`i' <=0.05 & `var'pvalf`i' >0.01) {
	matrix mstr`var'`i' = (0, 0, 0, 0, 2) 
     }
	 if `var'pval`i'  >0.1 & `var'pvalf`i'<=0.01 {
	matrix mstr`var'`i' = (0, 0, 0, 0, 1) 
     }
	 if `var'pval`i'  >0.1 & `var'pvalf`i'>0.1  {
	matrix mstr`var'`i' = (0, 0, 0, 0, 0) 
     }
	 
	 
	 

matrix list mat`var'`i'


matrix A1`i' = nullmat(A1`i')\ mat`var'`i'\mat1`var'`i'


matrix A1`i'_STARS =  nullmat(A1`i'_STARS)\mstr`var'`i'\mstrhelp`i'
}


local rname ""
foreach var in $hhdemo {
local lbl : variable label `var'
local rname `"  `rname'   "`lbl'" " " "'		
}		

mat A`i'_STARS=A1`i'_STARS\mstrhelp`i'
mat A2`i'=(`treatobs`i'',`controbs`i'',.,.,.)
mat AA`i'=A1`i'\A2`i'

matrix colnames AA`i' = "Adopters" "Non-Adopters" "Difference" "p-value" "p-valuefe" 

}


 
 
mat C= AAhhd_rdisp,  AAhhd_motorpump, AAhhd_rotlegume, AAhhd_cresidue1, AAhhd_cresidue2, AAhhd_mintil, AAhhd_zerotill, AAhhd_consag1, AAhhd_consag2, AAhhd_swc, AAhhd_terr, AAhhd_wcatch, AAhhd_affor, AAhhd_ploc, AAhhd_ofsp, AAhhd_awassa83, AAhhd_avocado, AAhhd_papaya, AAhhd_mango,  AAhhd_fieldp, AAhhd_sp, AAhhd_cross,  AAhhd_crlr, AAhhd_crpo, AAhhd_indprod, AAhhd_grass, AAhhd_psnp, AAmaize_cg, AAsorghum_cg, AAbarley_cg, AAdtmz, AAhhd_impcr2, AAhhd_impcr1


mat C_STARS=Ahhd_rdisp_STARS,   Ahhd_motorpump_STARS,  Ahhd_rotlegume_STARS,  Ahhd_cresidue1_STARS,  Ahhd_cresidue2_STARS,  Ahhd_mintil_STARS,  Ahhd_zerotill_STARS,  Ahhd_consag1_STARS,  Ahhd_consag2_STARS,  Ahhd_swc_STARS,  Ahhd_terr_STARS,  Ahhd_wcatch_STARS,  Ahhd_affor_STARS,  Ahhd_ploc_STARS,  Ahhd_ofsp_STARS,  Ahhd_awassa83_STARS,  Ahhd_avocado_STARS,  Ahhd_papaya_STARS,  Ahhd_mango_STARS,   Ahhd_fieldp_STARS,  Ahhd_sp_STARS,  Ahhd_cross_STARS,   Ahhd_crlr_STARS,    Ahhd_crpo_STARS,    Ahhd_indprod_STARS,  Ahhd_grass_STARS,  Ahhd_psnp_STARS,  Amaize_cg_STARS, Asorghum_cg_STARS, Abarley_cg_STARS, Adtmz_STARS, Ahhd_impcr2_STARS, Ahhd_impcr1_STARS

#delimit ;
xml_tab C,  save("$table${slash}Table14.xml") replace sheet("Table 1_hh_ESS4", nogridlines)  ///
rnames(`rname' "Total No. of obs.") cnames(`cnames')
ceq( "River dispersion" "River dispersion" "River dispersion" "River dispersion"  "River dispersion" 
"Motor pump used for irrigation"  "Motor pump used for irrigation" "Motor pump used for irrigation" "Motor pump used for irrigation" "Motor pump used for irrigation"
"Crop rotation with a legume" "Crop rotation with a legume" "Crop rotation with a legume" "Crop rotation with a legume"  "Crop rotation with a legume"
"Crop residue cover- farmers elicitation" "Crop residue cover- farmers elicitation" "Crop residue cover- farmers elicitation" "Crop residue cover- farmers elicitation" "Crop residue cover- farmers elicitation"
"Crop residue cover - visual aid" "Crop residue cover - visual aid" "Crop residue cover - visual aid" "Crop residue cover - visual aid"  "Crop residue cover - visual aid"
"Minimum tillage" "Minimum tillage" "Minimum tillage" "Minimum tillage"  "Minimum tillage"
"Zero tillage" "Zero tillage" "Zero tillage" "Zero tillage"  "Zero tillage"
"Conservation Agriculture - using Minimum tillage" "Conservation Agriculture - using Minimum tillage" "Conservation Agriculture - using Minimum tillage" "Conservation Agriculture - using Minimum tillage" "Conservation Agriculture - using Minimum tillage"
"Conservation Agriculture - using Zero tillage" "Conservation Agriculture - using Zero tillage" "Conservation Agriculture - using Zero tillage" "Conservation Agriculture - using Zero tillage" "Conservation Agriculture - using Zero tillage"
"Soil Water Conservation practices" "Soil Water Conservation practices" "Soil Water Conservation practices" "Soil Water Conservation practices" "Soil Water Conservation practices"
"Terracing" "Terracing" "Terracing" "Terracing" "Terracing"
"Water catchments" "Water catchments" "Water catchments" "Water catchments"  "Water catchments"
"Afforestation" "Afforestation" "Afforestation" "Afforestation" "Afforestation"
"Plough along the contour" "Plough along the contour" "Plough along the contour" "Plough along the contour" "Plough along the contour"
"Sweet potato OFSP variety" "Sweet potato OFSP variety" "Sweet potato OFSP variety" "Sweet potato OFSP variety" "Sweet potato OFSP variety"
"Sweet potato Awassa83 variety" "Sweet potato Awassa83 variety" "Sweet potato Awassa83 variety" "Sweet potato Awassa83 variety" "Sweet potato Awassa83 variety"
"Avocado tree" "Avocado tree" "Avocado tree" "Avocado tree"  "Avocado tree"
"Papaya tree" "Papaya tree" "Papaya tree" "Papaya tree" "Papaya tree"
"Mango tree" "Mango tree" "Mango tree" "Mango tree"  "Mango tree" 
"Field peas" "Field peas" "Field peas" "Field peas" "Field peas"
"Sweetpotato" "Sweetpotato" "Sweetpotato" "Sweetpotato" "Sweetpotato"
"Crossbred animals" "Crossbred animals" "Crossbred animals" "Crossbred animals"  "Crossbred animals"
"Crossbred large ruminants" "Crossbred large ruminants" "Crossbred large ruminants" "Crossbred large ruminants" "Crossbred large ruminants"
"Crossbred poultry" "Crossbred poultry" "Crossbred poultry" "Crossbred poultry" "Crossbred poultry"
"Feed and Forage: Industry by-products" "Feed and Forage: Industry by-products" "Feed and Forage: Industry by-products" "Feed and Forage: Industry by-products" "Feed and Forage: Industry by-products"
"Elephant grass, gaya, sasbaniya, alfalfa" "Elephant grass, gaya, sasbaniya, alfalfa" "Elephant grass, gaya, sasbaniya, alfalfa" "Elephant grass, gaya, sasbaniya, alfalfa" "Elephant grass, gaya, sasbaniya, alfalfa"
"PSNP" "PSNP" "PSNP" "PSNP"  "PSNP" 
"Maize CG germplasm" "Maize CG germplasm" "Maize CG germplasm" "Maize CG germplasm"  "Maize CG germplasm" 
"Sorghum CG germplasm" "Sorghum CG germplasm" "Sorghum CG germplasm" "Sorghum CG germplasm"  "Sorghum CG germplasm" 
"Barley CG germplasm"  "Barley CG germplasm"  "Barley CG germplasm"  "Barley CG germplasm"   "Barley CG germplasm" 
"DTMZ" "DTMZ" "DTMZ" "DTMZ" "DTMZ"
"Improved maize - SR" "Improved maize - SR" "Improved maize - SR" "Improved maize - SR" "Improved maize - SR"
"Improved barley - SR" "Improved barley - SR" "Improved barley - SR" "Improved barley - SR" "Improved barley - SR") showeq ///
rblanks(COL_NAMES "HH level data" S2220)	 /// Adds blank columns which are used to separate Treatment and Control graphically.
title(Table 1: ESS4 - HH demo )  font("Times New Roman" 10) ///
cw(0 110, 1 55, 2 55, 3 55, 4 55, 5 55, 6 55, 7 55, 8 55, 9 55, 10 55, 11 55, 12 55, 13 55,  14 55,  15 55, 16 55, 17 55, 18 55, 19 55, 20 55, 21 55, 22 55, 23 55, 24 55, 25 55, 26 55, 27 55, 28 55, 29 55, 30 55, 31 55, 32 55, 33 55, 34 55, 35 55, 36 55, 37 55, 38 55, 39 55, 40 55  ) /// *Adjust the column width of the table, column 0 are the variable names* 1, 5 and 9 are the blank columns. 
	format((SCLR0) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3))  /// * format the columns. Each parentheses represents one column*
	stars(* 0.1 ** 0.05 *** 0.01)  /// Define your star values/signs here (which are stored in B_STARS)
	lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 2)  /// Draws lines in specific format (Numeric Value)
	notes(Point estimates are weighted sample means. Standard errors are reported below. , Stars represent level of statistical significance of t-test/chi-squared test of difference in means. ); //Add your notes here
# delimit cr


*ex
********************************************************************************
* PLOT LEVEL DATA
********************************************************************************
********************************************************************************

use "${data}${slash}ess4_pp_cov_plot_new", clear

rename sp_ofsp ofsp 
rename sp_awassa83 awassa83
rename sweetpotato sp
*Adoption status
*ESS4
 global adopt   rdisp  motorpump rotlegume cresidue1 cresidue2 mintillage zerotill consag1 consag2 swc terr wcatch affor ploc ofsp awassa83 avocado papaya mango  fieldp sp impcr2 impcr1


* Plot level characteristics
* ESS4
#delimit ;
global plotlevel 
title fowner frsell acqparc1 acqparc2 acqparc3 acqparc6 acqparc7 acqparcoth soilq1 soilq2 soilq3 soilt1 soilt2 soilt3 soilt4 soilt5 soilt6
plotarea_sr plotarea_gps  plotarea_full
cropt1 cropt2 cropt3 cropm1  
fplotm extprog
irr urea dap nps othfert manure hiredlab lprep soiler 

improv cdam1 cdam2 cdam3 cdam4 cdam5 cdamoth hsell  
s3q121 s3q122 s3q123  s3q05 fild_prpa1 fild_prpa2 fild_prpa3 fild_prpa4 s4q05 s4q06 s4q07;
#delimit cr



matrix drop _all
 
foreach i in   $adopt {
foreach var in $plotlevel {



qui: mean    `var' [pw=pw_w4]           if wave==4 & `i'==1
matrix  `var'mt`i'=e(b)'
scalar  `var'mt`i'= `var'mt`i'[1,1]

matrix define `var'Vt`i'= e(V)'
matrix define `var'VVt`i'=(vecdiag(`var'Vt`i'))'
matrix list `var'VVt`i'
scalar `var'vart`i'=`var'VVt`i'[1,1]
scalar `var'set`i'=sqrt(`var'VVt`i'[1,1])



qui: mean `var' [pw=pw_w4]              if  wave==4 & `i'==0
matrix  `var'mc`i'=e(b)'
scalar  `var'mc`i'= `var'mc`i'[1,1]
matrix define `var'Vc`i'= e(V)'
matrix define `var'VVc`i'=(vecdiag(`var'Vc`i'))'
matrix list `var'VVc`i'
scalar `var'varc`i'=`var'VVc`i'[1,1]
scalar `var'sec`i'=sqrt(`var'VVc`i'[1,1])


qui sum `i' if `i'==0  & wave==4
local controbs`i'=r(N)

qui sum `i' if `i'==1 & wave==4
local treatobs`i'=r(N)


matrix mstrhelp`i'=(0,0,0,0,0)


    
scalar `var'df`i'=(`var'mt`i'-`var'mc`i') //Simple difference

*scalar `var'df`i'=((`var'mt`i'-`var'mc`i') / sqrt((`var'vart`i'+ `var'varc`i')/2))

qui: reg `var' `i' if  wave==4 [pw=pw_w4]
*local t = _b[`i']/_se[`i']
*scalar `var'pval`i' = 2*ttail(e(df_r), abs(`t'))
test `i'=0
scalar `var'pval`i'=r(p)

qui: reg `var' `i'   i.region if  wave==4 [pw=pw_w4]
*local t = _b[`i']/_se[`i']
*scalar `var'pval`i' = 2*ttail(e(df_r), abs(`t'))
test `i'=0
scalar `var'pvalf`i'=r(p)



matrix mat`var'`i'  = (`var'mt`i',  `var'mc`i', `var'df`i', `var'pval`i', `var'pvalf`i') 
matrix mat1`var'`i' = (`var'set`i', `var'sec`i',         .,            .,             .) 


       if (`var'pval`i'<=0.1 & `var'pval`i'>0.05)   & (`var'pvalf`i'<=0.1  & `var'pvalf`i'>0.05)  {
	matrix mstr`var'`i' = (0, 0, 0, 3, 3) 
     }
	if (`var'pval`i'  <=0.1 & `var'pval`i'>0.05) & (`var'pvalf`i' <=0.05 & `var'pvalf`i' >0.01) {
	matrix mstr`var'`i' = (0, 0, 0, 3, 2) 
     }
	 if (`var'pval`i'  <=0.1 & `var'pval`i'>0.05) & `var'pvalf`i'<=0.01 {
	matrix mstr`var'`i' = (0, 0, 0, 3, 1) 
     }
	 if (`var'pval`i'  <=0.1 & `var'pval`i'>0.05) & `var'pvalf`i'>0.1   {
	matrix mstr`var'`i' = (0, 0, 0, 3, 0) 
     }
	 
	 
    if (`var'pval`i'  <=0.05 & `var'pval`i'>0.01)  & (`var'pvalf`i'<=0.1  & `var'pvalf`i'>0.05)  {
	matrix mstr`var'`i' = (0, 0, 0, 2, 3) 
     }
	if (`var'pval`i'  <=0.05 & `var'pval`i'>0.01)  & (`var'pvalf`i' <=0.05 & `var'pvalf`i' >0.01) {
	matrix mstr`var'`i' = (0, 0, 0, 2, 2) 
     }
    if (`var'pval`i'  <=0.05 & `var'pval`i'>0.01)   & `var'pvalf`i'<=0.01 {
	matrix mstr`var'`i' = (0, 0, 0, 2, 1) 
     }
	 if (`var'pval`i'  <=0.05 & `var'pval`i'>0.01)   & `var'pvalf`i'>0.1  {
	matrix mstr`var'`i' = (0, 0, 0, 2, 0) 
     }	 
	 
	 
	 if `var'pval`i'  <=0.01 & (`var'pvalf`i'<=0.1  & `var'pvalf`i'>0.05) {
	matrix mstr`var'`i' = (0, 0, 0, 1, 3) 
     }
	if `var'pval`i'  <=0.01 & (`var'pvalf`i' <=0.05 & `var'pvalf`i' >0.01) {
	matrix mstr`var'`i' = (0, 0, 0, 1, 2) 
     }
	 if `var'pval`i'  <=0.01 &  `var'pvalf`i'<=0.01 {
	matrix mstr`var'`i' = (0, 0, 0, 1, 1) 
     }
	 if `var'pval`i'  <=0.01  & `var'pvalf`i'>0.1 {
	matrix mstr`var'`i' = (0, 0, 0, 1, 0) 
     }
	 
	 
	if `var'pval`i'   >0.1 & (`var'pvalf`i'<=0.1  & `var'pvalf`i'>0.05)  {
	matrix mstr`var'`i' = (0, 0, 0, 0, 3) 
     }
	if `var'pval`i'   >0.1 & (`var'pvalf`i' <=0.05 & `var'pvalf`i' >0.01) {
	matrix mstr`var'`i' = (0, 0, 0, 0, 2) 
     }
	 if `var'pval`i'  >0.1 & `var'pvalf`i'<=0.01 {
	matrix mstr`var'`i' = (0, 0, 0, 0, 1) 
     }
	 if `var'pval`i'  >0.1 & `var'pvalf`i'>0.1  {
	matrix mstr`var'`i' = (0, 0, 0, 0, 0) 
     }
	 
	 

matrix list mat`var'`i'


matrix A1`i' = nullmat(A1`i')\ mat`var'`i'\mat1`var'`i'


matrix A1`i'_STARS =  nullmat(A1`i'_STARS)\mstr`var'`i'\mstrhelp`i'
}


local rname ""
foreach var in $plotlevel {
local lbl : variable label `var'
local rname `"  `rname'   "`lbl'" " " "'		
}		

mat A`i'_STARS=A1`i'_STARS\mstrhelp`i'
mat A2`i'=(`treatobs`i'',`controbs`i'',.,.,.)
mat AA`i'=A1`i'\A2`i'

matrix colnames AA`i' = "Adopters" "Non-Adopters" "Difference" "p-value" "p-valuefe" 

}

mat C= AArdisp,  AAmotorpump, AArotlegume, AAcresidue1, AAcresidue2, AAmintillage, AAzerotill, AAconsag1, AAconsag2, AAswc, AAterr, AAwcatch, AAaffor, AAploc, AAofsp, AAawassa83, AAavocado, AApapaya, AAmango,  AAfieldp, AAsp, AAimpcr2, AAimpcr1

mat C_STARS=Ardisp_STARS, Amotorpump_STARS, Arotlegume_STARS, Acresidue1_STARS, Acresidue2_STARS, Amintillage_STARS, Azerotill_STARS, Aconsag1_STARS, Aconsag2_STARS, Aswc_STARS, Aterr_STARS, Awcatch_STARS, Aaffor_STARS, Aploc_STARS, Aofsp_STARS, Aawassa83_STARS, Aavocado_STARS, Apapaya_STARS, Amango_STARS,  Afieldp_STARS, Asp_STARS, Aimpcr2_STARS, Aimpcr1_STARS


#delimit ;
xml_tab C,  save("$table${slash}Table14.xml") append sheet("Table 2_plot_ESS4", nogridlines)  ///
rnames(`rname' "Total No. of obs.") cnames(`cnames')
ceq(
"River dispersion" "River dispersion" "River dispersion" "River dispersion" "River dispersion"
"Motor pump used for irrigation" "Motor pump used for irrigation" "Motor pump used for irrigation" "Motor pump used for irrigation" "Motor pump used for irrigation"
"Crop rotation with a legume" "Crop rotation with a legume" "Crop rotation with a legume" "Crop rotation with a legume" "Crop rotation with a legume"
"Crop residue cover - Farmer's elicitation" "Crop residue cover - Farmer's elicitation" "Crop residue cover - Farmer's elicitation" "Crop residue cover - Farmer's elicitation" "Crop residue cover - Farmer's elicitation"
"Crop residue cover - visual aid" "Crop residue cover - visual aid" "Crop residue cover - visual aid" "Crop residue cover - visual aid" "Crop residue cover - visual aid"
"Minimum tillage" "Minimum tillage" "Minimum tillage" "Minimum tillage" "Minimum tillage"
"Zero tillage" "Zero tillage" "Zero tillage" "Zero tillage" "Zero tillage"
"Conservation Agriculture - using Minimum tillage" "Conservation Agriculture - using Minimum tillage" "Conservation Agriculture - using Minimum tillage" "Conservation Agriculture - using Minimum tillage" "Conservation Agriculture - using Minimum tillage"
"Conservation Agriculture - using Zero tillage" "Conservation Agriculture - using Zero tillage" "Conservation Agriculture - using Zero tillage" "Conservation Agriculture - using Zero tillage" "Conservation Agriculture - using Zero tillage"
"Soil Water Conservation practices" "Soil Water Conservation practices" "Soil Water Conservation practices" "Soil Water Conservation practices"
"Terracing" "Terracing" "Terracing" "Terracing" "Terracing"
"Water catchments" "Water catchments" "Water catchments" "Water catchments" "Water catchments"
"Afforestation" "Afforestation" "Afforestation" "Afforestation" "Afforestation"
"Plough along the contour" "Plough along the contour" "Plough along the contour" "Plough along the contour" "Plough along the contour"
"Orange Fleshed sweet potato" "Orange Fleshed sweet potato" "Orange Fleshed sweet potato" "Orange Fleshed sweet potato" "Orange Fleshed sweet potato"
"Awassa83 sweet potato" "Awassa83 sweet potato" "Awassa83 sweet potato" "Awassa83 sweet potato" "Awassa83 sweet potato"
"Avocado tree" "Avocado tree" "Avocado tree" "Avocado tree" "Avocado tree"
"Papaya tree" "Papaya tree" "Papaya tree" "Papaya tree" "Papaya tree"
"Mango tree" "Mango tree" "Mango tree" "Mango tree"   "Mango tree"
"Field peas" "Field peas" "Field peas" "Field peas"  "Field peas"
"Sweetpotato SR" "Sweetpotato SR" "Sweetpotato SR" "Sweetpotato SR" "Sweetpotato SR"
"Improved maize -SR" "Improved maize -SR" "Improved maize -SR" "Improved maize -SR" "Improved maize -SR"  "Improved maize -SR"
"Improved barley - SR" "Improved barley - SR" "Improved barley - SR" "Improved barley - SR" "Improved barley - SR" "Improved barley - SR") showeq ///
rblanks(COL_NAMES "Plot level data" S2220)	 /// Adds blank columns which are used to separate Treatment and Control graphically.
title(Table 2: ESS4 - Parcel and Plot characteristics )  font("Times New Roman" 10) ///
cw(0 110, 1 55, 2 55, 3 55, 4 55, 5 55, 6 55, 7 55, 8 55, 9 55, 10 55, 11 55, 12 55, 13 55,  14 55,  15 55, 16 55, 17 55, 18 55, 19 55, 20 55, 21 55, 22 55, 23 55, 24 55, 25 55, 26 55, 27 55, 28 55, 29 55, 30 55, 31 55, 32 55, 33 55, 34 55, 35 55, 36 55, 37 55, 38 55, 39 55, 40 55  ) /// *Adjust the column width of the table, column 0 are the variable names* 1, 5 and 9 are the blank columns. 
	format((SCLR0) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3))  /// * format the columns. Each parentheses represents one column*
	stars(* 0.1 ** 0.05 *** 0.01)  /// Define your star values/signs here (which are stored in B_STARS)
	lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 2)  /// Draws lines in specific format (Numeric Value)
	notes(Point estimates are weighted sample means. Standard errors are reported below. , Stars represent level of statistical significance of t-test/chi-squared test of difference in means. ); //Add your notes here
# delimit cr


* MERGE WITH DNA DATA 
drop if field_id==.
merge 1:1 household_id parcel_id field_id using "${rawdata}${slash}Auxiliary_data${slash}ess4_dna_plot_new"
keep if _m==3
drop _m

g dnacrop=0
replace dnacrop=1 if cg_m==1 | cg_b==1 | cg_s==1 


* USING ONLY DNA SAMPLE *

*ESS4
 global adopt2    swc terr wcatch affor ploc 


* Plot level characteristics
* ESS4
#delimit ;
global plotlevel2
title fowner frsell acqparc1 acqparc2 acqparc3 acqparc6 acqparc7 acqparcoth soilq1 soilq2 soilq3 soilt1 soilt2 soilt3 soilt4 soilt5 soilt6
plotarea_sr plotarea_gps  plotarea_full
cropt1 cropt2 cropt3 cropm1  
fplotm extprog
irr urea dap nps othfert manure hiredlab lprep soiler 

improv cdam1 cdam2 cdam3 cdam4 cdam5 cdamoth hsell  
s3q121 s3q122 s3q123  s3q05 fild_prpa1 fild_prpa2 fild_prpa3 fild_prpa4 s4q05 s4q06 s4q07 dnacrop;
#delimit cr



matrix drop _all
 
foreach i in   $adopt2 {
foreach var in $plotlevel2 {



qui: mean    `var' [pw=pw_w4]           if wave==4 & `i'==1
matrix  `var'mt`i'=e(b)'
scalar  `var'mt`i'= `var'mt`i'[1,1]

matrix define `var'Vt`i'= e(V)'
matrix define `var'VVt`i'=(vecdiag(`var'Vt`i'))'
matrix list `var'VVt`i'
scalar `var'vart`i'=`var'VVt`i'[1,1]
scalar `var'set`i'=sqrt(`var'VVt`i'[1,1])



qui: mean `var' [pw=pw_w4]              if  wave==4 & `i'==0
matrix  `var'mc`i'=e(b)'
scalar  `var'mc`i'= `var'mc`i'[1,1]
matrix define `var'Vc`i'= e(V)'
matrix define `var'VVc`i'=(vecdiag(`var'Vc`i'))'
matrix list `var'VVc`i'
scalar `var'varc`i'=`var'VVc`i'[1,1]
scalar `var'sec`i'=sqrt(`var'VVc`i'[1,1])


qui sum `i' if `i'==0  & wave==4
local controbs`i'=r(N)

qui sum `i' if `i'==1 & wave==4
local treatobs`i'=r(N)


matrix mstrhelp`i'=(0,0,0,0,0)


    
scalar `var'df`i'=(`var'mt`i'-`var'mc`i') //Simple difference

*scalar `var'df`i'=((`var'mt`i'-`var'mc`i') / sqrt((`var'vart`i'+ `var'varc`i')/2))

qui: reg `var' `i' if  wave==4 [pw=pw_w4]
*local t = _b[`i']/_se[`i']
*scalar `var'pval`i' = 2*ttail(e(df_r), abs(`t'))
test `i'=0
scalar `var'pval`i'=r(p)

qui: reg `var' `i'   i.region if  wave==4 [pw=pw_w4]
*local t = _b[`i']/_se[`i']
*scalar `var'pval`i' = 2*ttail(e(df_r), abs(`t'))
test `i'=0
scalar `var'pvalf`i'=r(p)



matrix mat`var'`i'  = (`var'mt`i',  `var'mc`i', `var'df`i', `var'pval`i', `var'pvalf`i') 
matrix mat1`var'`i' = (`var'set`i', `var'sec`i',         .,            .,             .) 


       if (`var'pval`i'<=0.1 & `var'pval`i'>0.05)   & (`var'pvalf`i'<=0.1  & `var'pvalf`i'>0.05)  {
	matrix mstr`var'`i' = (0, 0, 0, 3, 3) 
     }
	if (`var'pval`i'  <=0.1 & `var'pval`i'>0.05) & (`var'pvalf`i' <=0.05 & `var'pvalf`i' >0.01) {
	matrix mstr`var'`i' = (0, 0, 0, 3, 2) 
     }
	 if (`var'pval`i'  <=0.1 & `var'pval`i'>0.05) & `var'pvalf`i'<=0.01 {
	matrix mstr`var'`i' = (0, 0, 0, 3, 1) 
     }
	 if (`var'pval`i'  <=0.1 & `var'pval`i'>0.05) & `var'pvalf`i'>0.1   {
	matrix mstr`var'`i' = (0, 0, 0, 3, 0) 
     }
	 
	 
    if (`var'pval`i'  <=0.05 & `var'pval`i'>0.01)  & (`var'pvalf`i'<=0.1  & `var'pvalf`i'>0.05)  {
	matrix mstr`var'`i' = (0, 0, 0, 2, 3) 
     }
	if (`var'pval`i'  <=0.05 & `var'pval`i'>0.01)  & (`var'pvalf`i' <=0.05 & `var'pvalf`i' >0.01) {
	matrix mstr`var'`i' = (0, 0, 0, 2, 2) 
     }
    if (`var'pval`i'  <=0.05 & `var'pval`i'>0.01)   & `var'pvalf`i'<=0.01 {
	matrix mstr`var'`i' = (0, 0, 0, 2, 1) 
     }
	 if (`var'pval`i'  <=0.05 & `var'pval`i'>0.01)   & `var'pvalf`i'>0.1  {
	matrix mstr`var'`i' = (0, 0, 0, 2, 0) 
     }	 
	 
	 
	 if `var'pval`i'  <=0.01 & (`var'pvalf`i'<=0.1  & `var'pvalf`i'>0.05) {
	matrix mstr`var'`i' = (0, 0, 0, 1, 3) 
     }
	if `var'pval`i'  <=0.01 & (`var'pvalf`i' <=0.05 & `var'pvalf`i' >0.01) {
	matrix mstr`var'`i' = (0, 0, 0, 1, 2) 
     }
	 if `var'pval`i'  <=0.01 &  `var'pvalf`i'<=0.01 {
	matrix mstr`var'`i' = (0, 0, 0, 1, 1) 
     }
	 if `var'pval`i'  <=0.01  & `var'pvalf`i'>0.1 {
	matrix mstr`var'`i' = (0, 0, 0, 1, 0) 
     }
	 
	 
	if `var'pval`i'   >0.1 & (`var'pvalf`i'<=0.1  & `var'pvalf`i'>0.05)  {
	matrix mstr`var'`i' = (0, 0, 0, 0, 3) 
     }
	if `var'pval`i'   >0.1 & (`var'pvalf`i' <=0.05 & `var'pvalf`i' >0.01) {
	matrix mstr`var'`i' = (0, 0, 0, 0, 2) 
     }
	 if `var'pval`i'  >0.1 & `var'pvalf`i'<=0.01 {
	matrix mstr`var'`i' = (0, 0, 0, 0, 1) 
     }
	 if `var'pval`i'  >0.1 & `var'pvalf`i'>0.1  {
	matrix mstr`var'`i' = (0, 0, 0, 0, 0) 
     }
	 
	 

matrix list mat`var'`i'


matrix A1`i' = nullmat(A1`i')\ mat`var'`i'\mat1`var'`i'


matrix A1`i'_STARS =  nullmat(A1`i'_STARS)\mstr`var'`i'\mstrhelp`i'
}


local rname ""
foreach var in $plotlevel2 {
local lbl : variable label `var'
local rname `"  `rname'   "`lbl'" " " "'		
}		

mat A`i'_STARS=A1`i'_STARS\mstrhelp`i'
mat A2`i'=(`treatobs`i'',`controbs`i'',.,.,.)
mat AA`i'=A1`i'\A2`i'

matrix colnames AA`i' = "Adopters" "Non-Adopters" "Difference" "p-value" "p-valuefe" 

}

mat C=  AAswc, AAterr, AAwcatch, AAaffor, AAploc

mat C_STARS= Aswc_STARS, Aterr_STARS, Awcatch_STARS, Aaffor_STARS, Aploc_STARS


#delimit ;
xml_tab C,  save("$table${slash}Adopters characteristics.xml") replace sheet("Table 2B_plot_ESS4", nogridlines)  ///
rnames(`rname' "Total No. of obs.") cnames(`cnames')
ceq(

"Soil Water Conservation practices" "Soil Water Conservation practices" "Soil Water Conservation practices" "Soil Water Conservation practices"
"Terracing" "Terracing" "Terracing" "Terracing"
"Water catchments" "Water catchments" "Water catchments" "Water catchments"
"Afforestation" "Afforestation" "Afforestation" "Afforestation"
"Plough along the contour" "Plough along the contour" "Plough along the contour" "Plough along the contour") showeq ///
rblanks(COL_NAMES "Plot level data" S2220)	 /// Adds blank columns which are used to separate Treatment and Control graphically.
title(Table 2: ESS4 - Parcel and Plot characteristics )  font("Times New Roman" 10) ///
cw(0 110, 1 55, 2 55, 3 55, 4 55, 5 55, 6 55, 7 55, 8 55, 9 55, 10 55, 11 55, 12 55, 13 55,  14 55,  15 55, 16 55, 17 55, 18 55, 19 55, 20 55, 21 55, 22 55, 23 55, 24 55, 25 55, 26 55, 27 55, 28 55, 29 55, 30 55, 31 55, 32 55, 33 55, 34 55, 35 55, 36 55, 37 55, 38 55, 39 55, 40 55  ) /// *Adjust the column width of the table, column 0 are the variable names* 1, 5 and 9 are the blank columns. 
	format((SCLR0) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3))  /// * format the columns. Each parentheses represents one column*
	stars(* 0.1 ** 0.05 *** 0.01)  /// Define your star values/signs here (which are stored in B_STARS)
	lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 2)  /// Draws lines in specific format (Numeric Value)
	notes(Point estimates are weighted sample means. Standard errors are reported below. , Stars represent level of statistical significance of t-test/chi-squared test of difference in means. ); //Add your notes here
# delimit cr


*Distribution of DNA fingerprinted samples in ESS4, by region
foreach x in 0 1 3 4 7 {
foreach var in cg_b cg_m cg_s  {
tab `var' if region == `x'
scalar `var'n`x' = r(N)
quietly sum `var'
scalar `var'N = r(N) 
}
matrix a`x' = (cg_bn`x', cg_mn`x', cg_sn`x')
}
matrix a = (cg_bN, cg_mN, cg_sN)
matrix N_obs = (a3 \ a4 \ a7 \ a1 \ a0 \ a)

matrix colnames N_obs = "Barley" "Maize" "Sorghum"
matrix rownames N_obs = "Amhara" "Oromia" "SNNPR" "Tigray" "Other regions" "Total"

xml_tab N_obs,  save("$table${slash}Adopters characteristics.xml") append sheet("Table 2B_plot_ESS4_regions", nogridlines) ///
title(Table 2: ESS4 - Distribution of DNA samples, by region )  font("Times New Roman" 10) ///
format ((SCLR0) (NBCR0) (NBCR0) (NBCR0)) lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 2)  


********************************************************************************
* EA LEVEL
********************************************************************************




use "${data}${slash}ess4_pp_cov_ea_new", clear
replace commirr=100 if commirr==1
rename ead_sweetpotato ead_sp
rename ead_mintillage ead_mtill

rename Dist_CG_LargeR  d1
rename Dist_CG_SmallR d2
rename Dist_CG_chicken d3
rename Dist_CG_Avocado d4
rename Dist_CG_DTMZ d5
rename Dist_CG_CA d6
rename Dist_CG_OFSP d7
rename Dist_CG_NUME d8
rename Dist_CG_SLM d9
rename Dist_CG_Barley d10
rename Dist_CG_Sorghum d11

foreach i in ead_psnp maize_cg sorghum_cg barley_cg  dtmz qpm ead_impcr2 ead_impcr1 {
    replace `i'=100 if `i'==1
}
replace ead_impcr2=. if maize_cg==.
replace ead_impcr1=. if barley_cg==.

*Adoption status
*ESS4
#delimit;
global adopt4 ead_ofsp ead_awassa83 ead_avocado ead_papaya ead_mango ead_fieldp ead_sp ead_motorpump ead_rdisp ead_rotlegume ead_cresidue1 ead_cresidue2 ead_mtill ead_zerotill ead_consag1 ead_consag2 ead_swc ead_terr ead_wcatch ead_affor ead_ploc  commirr
ead_cross ead_crlr /*ead_crsr*/ ead_crpo
ead_livIA ead_indprod ead_grass ead_psnp
maize_cg sorghum_cg barley_cg  dtmz ead_impcr2 ead_impcr1
;
#delimit cr


*ESS4
global eacov4 cs9q01 cs6q12_11 cs6q12_12 cs6q12_13 cs6q12_14 cs6q13_11 cs6q13_12 cs6q13_13 cs6q13_14 cs6q14_11 cs6q14_12 cs6q14_13 cs6q14_14 cs6q15_11 cs6q15_12 cs6q15_13 cs4q011 cs4q012 cs4q013 cs4q014 cs4q03 cs4q08 cs4q11 cs4q14 cs4q52 cs9q13 cs9q13wiz cs9q14 cs6q01 cs6q10   cs4q02 cs4q02wiz cs4q01    cs4q09 cs4q09wiz cs4q11 cs4q12b cs4q12bwiz  cs4q15 cs4q15wiz cs3q02 cs3q02wiz cs4q52 cs4q53 csdq53wiz 


matrix drop _all
 
foreach i in   $adopt4 {
foreach var in $eacov4 {



qui: mean    `var' [pw=pw_w4]           if wave==4 & `i'==100
matrix  `var'mt`i'=e(b)'
scalar  `var'mt`i'= `var'mt`i'[1,1]

matrix define `var'Vt`i'= e(V)'
matrix define `var'VVt`i'=(vecdiag(`var'Vt`i'))'
matrix list `var'VVt`i'
scalar `var'vart`i'=`var'VVt`i'[1,1]
scalar `var'set`i'=sqrt(`var'VVt`i'[1,1])



qui: mean `var' [pw=pw_w4]              if  wave==4 & `i'==0
matrix  `var'mc`i'=e(b)'
scalar  `var'mc`i'= `var'mc`i'[1,1]
matrix define `var'Vc`i'= e(V)'
matrix define `var'VVc`i'=(vecdiag(`var'Vc`i'))'
matrix list `var'VVc`i'
scalar `var'varc`i'=`var'VVc`i'[1,1]
scalar `var'sec`i'=sqrt(`var'VVc`i'[1,1])


qui sum `i' if `i'==0  & wave==4
local controbs`i'=r(N)

qui sum `i' if `i'==100 & wave==4
local treatobs`i'=r(N)


matrix mstrhelp`i'=(0,0,0,0,0)


    
scalar `var'df`i'=(`var'mt`i'-`var'mc`i') //Simple difference

*scalar `var'df`i'=((`var'mt`i'-`var'mc`i') / sqrt((`var'vart`i'+ `var'varc`i')/2))

qui: reg `var' `i' if  wave==4 [pw=pw_w4]
*local t = _b[`i']/_se[`i']
*scalar `var'pval`i' = 2*ttail(e(df_r), abs(`t'))
test `i'=0
scalar `var'pval`i'=r(p)

qui: reg `var' `i'   i.region if  wave==4 [pw=pw_w4]
*local t = _b[`i']/_se[`i']
*scalar `var'pval`i' = 2*ttail(e(df_r), abs(`t'))
test `i'=0
scalar `var'pvalf`i'=r(p)



matrix mat`var'`i'  = (`var'mt`i',  `var'mc`i', `var'df`i', `var'pval`i', `var'pvalf`i') 
matrix mat1`var'`i' = (`var'set`i', `var'sec`i',         .,            .,             .) 


    if (`var'pval`i'<=0.1 & `var'pval`i'>0.05)   & (`var'pvalf`i'<=0.1  & `var'pvalf`i'>0.05)  {
	matrix mstr`var'`i' = (0, 0, 0, 3, 3) 
     }
	if (`var'pval`i'  <=0.1 & `var'pval`i'>0.05) & (`var'pvalf`i' <=0.05 & `var'pvalf`i' >0.01) {
	matrix mstr`var'`i' = (0, 0, 0, 3, 2) 
     }
	 if (`var'pval`i'  <=0.1 & `var'pval`i'>0.05) & `var'pvalf`i'<=0.01 {
	matrix mstr`var'`i' = (0, 0, 0, 3, 1) 
     }
	 if (`var'pval`i'  <=0.1 & `var'pval`i'>0.05) & `var'pvalf`i'>0.1   {
	matrix mstr`var'`i' = (0, 0, 0, 3, 0) 
     }
	 
	 
    if (`var'pval`i'  <=0.05 & `var'pval`i'>0.01)  & (`var'pvalf`i'<=0.1  & `var'pvalf`i'>0.05)  {
	matrix mstr`var'`i' = (0, 0, 0, 2, 3) 
     }
	if (`var'pval`i'  <=0.05 & `var'pval`i'>0.01)  & (`var'pvalf`i' <=0.05 & `var'pvalf`i' >0.01) {
	matrix mstr`var'`i' = (0, 0, 0, 2, 2) 
     }
    if (`var'pval`i'  <=0.05 & `var'pval`i'>0.01)   & `var'pvalf`i'<=0.01 {
	matrix mstr`var'`i' = (0, 0, 0, 2, 1) 
     }
	 if (`var'pval`i'  <=0.05 & `var'pval`i'>0.01)   & `var'pvalf`i'>0.1  {
	matrix mstr`var'`i' = (0, 0, 0, 2, 0) 
     }	 
	 
	 
	 if `var'pval`i'  <=0.01 & (`var'pvalf`i'<=0.1  & `var'pvalf`i'>0.05) {
	matrix mstr`var'`i' = (0, 0, 0, 1, 3) 
     }
	if `var'pval`i'  <=0.01 & (`var'pvalf`i' <=0.05 & `var'pvalf`i' >0.01) {
	matrix mstr`var'`i' = (0, 0, 0, 1, 2) 
     }
	 if `var'pval`i'  <=0.01 &  `var'pvalf`i'<=0.01 {
	matrix mstr`var'`i' = (0, 0, 0, 1, 1) 
     }
	 if `var'pval`i'  <=0.01  & `var'pvalf`i'>0.1 {
	matrix mstr`var'`i' = (0, 0, 0, 1, 0) 
     }
	 
	 
	if `var'pval`i'   >0.1 & (`var'pvalf`i'<=0.1  & `var'pvalf`i'>0.05)  {
	matrix mstr`var'`i' = (0, 0, 0, 0, 3) 
     }
	if `var'pval`i'   >0.1 & (`var'pvalf`i' <=0.05 & `var'pvalf`i' >0.01) {
	matrix mstr`var'`i' = (0, 0, 0, 0, 2) 
     }
	 if `var'pval`i'  >0.1 & `var'pvalf`i'<=0.01 {
	matrix mstr`var'`i' = (0, 0, 0, 0, 1) 
     }
	 if `var'pval`i'  >0.1 & `var'pvalf`i'>0.1  {
	matrix mstr`var'`i' = (0, 0, 0, 0, 0) 
     }
	 
	 

matrix list mat`var'`i'


matrix A1`i' = nullmat(A1`i')\ mat`var'`i'\mat1`var'`i'


matrix A1`i'_STARS =  nullmat(A1`i'_STARS)\mstr`var'`i'\mstrhelp`i'
}


local rname ""
foreach var in $eacov4 {
local lbl : variable label `var'
local rname `"  `rname'   "`lbl'" " " "'		
}		

mat A`i'_STARS=A1`i'_STARS\mstrhelp`i'
mat A2`i'=(`treatobs`i'',`controbs`i'',.,.,.)
mat AA`i'=A1`i'\A2`i'

matrix colnames AA`i' = "Adopters" "Non-Adopters" "Difference" "p-value" "p-valuefe" 

}


mat C=AAead_ofsp, AAead_awassa83, AAead_avocado, AAead_papaya, AAead_mango, AAead_fieldp, AAead_sp, AAead_motorpump, AAead_rdisp, AAead_rotlegume, AAead_cresidue1, AAead_cresidue2, AAead_mtill, AAead_zerotill, AAead_consag1, AAead_consag2, AAead_swc, AAead_terr, AAead_wcatch, AAead_affor, AAead_ploc, AAcommirr, AAead_cross, AAead_crlr, AAead_crpo, AAead_livIA, AAead_indprod, AAead_grass, AAead_psnp, AAmaize_cg, AAsorghum_cg, AAbarley_cg, AAdtmz, AAead_impcr2, AAead_impcr1

mat C_STARS= Aead_ofsp_STARS, Aead_awassa83_STARS, Aead_avocado_STARS, Aead_papaya_STARS, Aead_mango_STARS, Aead_fieldp_STARS, Aead_sp_STARS, Aead_motorpump_STARS, Aead_rdisp_STARS, Aead_rotlegume_STARS, Aead_cresidue1_STARS, Aead_cresidue2_STARS, Aead_mtill_STARS, Aead_zerotill_STARS, Aead_consag1_STARS,  Aead_consag2_STARS, Aead_swc_STARS,  Aead_terr_STARS, Aead_wcatch_STARS, Aead_affor_STARS, Aead_ploc_STARS,  Acommirr_STARS,   Aead_cross_STARS, Aead_crlr_STARS, Aead_crpo_STARS, Aead_livIA_STARS,  Aead_indprod_STARS, Aead_grass_STARS, Aead_psnp_STARS, Amaize_cg_STARS, Asorghum_cg_STARS, Abarley_cg_STARS, Adtmz_STARS, Aead_impcr2_STARS, Aead_impcr1_STARS


#delimit ;
xml_tab C,  save("$table${slash}Adopters characteristics.xml") append sheet("Table 3_ea_ESS4", nogridlines)  ///
rnames(`rname' "Total No. of obs.") cnames(`cnames')
ceq("Sweet potato OFSP variety" "Sweet potato OFSP variety" "Sweet potato OFSP variety" "Sweet potato OFSP variety" "Sweet potato OFSP variety"
"Sweet potato Awassa83 variety" "Sweet potato Awassa83 variety" "Sweet potato Awassa83 variety" "Sweet potato Awassa83 variety" "Sweet potato Awassa83 variety"
"Avocado tree" "Avocado tree" "Avocado tree" "Avocado tree" "Avocado tree"
"Papaya tree" "Papaya tree" "Papaya tree" "Papaya tree"  "Papaya tree"
"Mango tree" "Mango tree" "Mango tree" "Mango tree"  "Mango tree"
"Field peas" "Field peas" "Field peas" "Field peas" "Field peas"
"Sweetpotato" "Sweetpotato" "Sweetpotato" "Sweetpotato" "Sweetpotato"
"Motor pump used for irrigation" "Motor pump used for irrigation" "Motor pump used for irrigation" "Motor pump used for irrigation"  "Motor pump used for irrigation"
"River dispersion"  "River dispersion"  "River dispersion" "River dispersion" "River dispersion"
"Crop rotation with a legume" "Crop rotation with a legume" "Crop rotation with a legume" "Crop rotation with a legume"   "Crop rotation with a legume" 
"Crop residue cover - farmers elicitation" "Crop residue cover - farmers elicitation" "Crop residue cover - farmers elicitation" "Crop residue cover - farmers elicitation" "Crop residue cover - farmers elicitation"
"Crop residue cover - visual aid" "Crop residue cover - visual aid" "Crop residue cover - visual aid" "Crop residue cover - visual aid" "Crop residue cover - visual aid"
"Minimum tillage" "Minimum tillage" "Minimum tillage"  "Minimum tillage" "Minimum tillage"
"Zero tillage" "Zero tillage" "Zero tillage" "Zero tillage" "Zero tillage"
"Conservation Agriculture using Minimum tillage" "Conservation Agriculture using Minimum tillage" "Conservation Agriculture using Minimum tillage" "Conservation Agriculture using Minimum tillage"  "Conservation Agriculture using Minimum tillage"
"Conservation Agriculture using Zero tillage" "Conservation Agriculture using Zero tillage" "Conservation Agriculture using Zero tillage" "Conservation Agriculture using Zero tillage" "Conservation Agriculture using Zero tillage"
"Soil Water Conservation practices" "Soil Water Conservation practices" "Soil Water Conservation practices" "Soil Water Conservation practices"  "Soil Water Conservation practices"
"Terracing" "Terracing" "Terracing" "Terracing" "Terracing"
"Water catchments" "Water catchments" "Water catchments" "Water catchments" "Water catchments"
"Afforestation" "Afforestation" "Afforestation" "Afforestation"  "Afforestation" 
"Plough along the contour" "Plough along the contour" "Plough along the contour" "Plough along the contour" "Plough along the contour"
"Community Irrigation Scheme" "Community Irrigation Scheme" "Community Irrigation Scheme" "Community Irrigation Scheme" "Community Irrigation Scheme"
"Any crossbred animals" "Any crossbred animals" "Any crossbred animals" "Any crossbred animals"  "Any crossbred animals"
"Crossbred large ruminants" "Crossbred large ruminants" "Crossbred large ruminants" "Crossbred large ruminants" "Crossbred large ruminants"
"Crossbred poultry" "Crossbred poultry" "Crossbred poultry" "Crossbred poultry"  "Crossbred poultry"
"AI on any livestock type" "AI on any livestock type" "AI on any livestock type" "AI on any livestock type" "AI on any livestock type"
"Feed and Forage: Industry by-products" "Feed and Forage: Industry by-products" "Feed and Forage: Industry by-products" "Feed and Forage: Industry by-products" "Feed and Forage: Industry by-products"
"Elephant grass, gaya, sasbaniya, alfalfa" "Elephant grass, gaya, sasbaniya, alfalfa" "Elephant grass, gaya, sasbaniya, alfalfa" "Elephant grass, gaya, sasbaniya, alfalfa" "Elephant grass, gaya, sasbaniya, alfalfa"
"PSNP" "PSNP" "PSNP" "PSNP" "PSNP"
"Maize CG germplasm" "Maize CG germplasm" "Maize CG germplasm" "Maize CG germplasm"  "Maize CG germplasm" 
"Sorghum CG germplasm" "Sorghum CG germplasm" "Sorghum CG germplasm" "Sorghum CG germplasm"   "Sorghum CG germplasm"
"Barley CG germplasm"  "Barley CG germplasm"  "Barley CG germplasm"  "Barley CG germplasm"  "Barley CG germplasm"
"DTMZ" "DTMZ" "DTMZ" "DTMZ" "DTMZ"
"Improved maize -SR" "Improved maize -SR" "Improved maize -SR" "Improved maize -SR" "Improved maize -SR"
"Improved barley - SR" "Improved barley - SR" "Improved barley - SR" "Improved barley - SR" "Improved barley - SR") showeq ///
rblanks(COL_NAMES "EA level data" S2220)	 /// Adds blank columns which are used to separate Treatment and Control graphically.
title(Table 3: ESS4 - EA level )  font("Times New Roman" 10) ///
cw(0 110, 1 55, 2 55, 3 55, 4 55, 5 55, 6 55, 7 55, 8 55, 9 55, 10 55, 11 55, 12 55, 13 55,  14 55,  15 55, 16 55, 17 55, 18 55, 19 55, 20 55, 21 55, 22 55, 23 55, 24 55, 25 55, 26 55, 27 55, 28 55, 29 55, 30 55, 31 55, 32 55, 33 55, 34 55, 35 55, 36 55, 37 55, 38 55, 39 55, 40 55  ) /// *Adjust the column width of the table, column 0 are the variable names* 1, 5 and 9 are the blank columns. 
	format((SCLR0) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3))  /// * format the columns. Each parentheses represents one column*
	stars(* 0.1 ** 0.05 *** 0.01)  /// Define your star values/signs here (which are stored in B_STARS)
	lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 2)  /// Draws lines in specific format (Numeric Value)
	notes(Point estimates are weighted sample means. Standard errors are reported below. , Stars represent level of statistical significance of t-test/chi-squared test of difference in means. Rural sample only ); //Add your notes here
# delimit cr

*ex
********************************************************************************
* Distances to CG activities only
*ESS4

use "${data}${slash}ess4_pp_ea_new", clear

merge 1:1 ea_id using  "${data}${slash}dashboard_locations"


drop if _m==2
drop _m
merge 1:1 ea_id using "${data}${slash}ess4_dna_ea_new"
drop _m

rename ead_sweetpotato ead_sp
rename ead_mintillage ead_mtillv

rename ead_cross_largerum ead_crlr
rename ead_cross_smallrum ead_crsr
rename ead_cross_poultry  ead_crpo

foreach i in  sorghum_cg barley_cg dtmz qpm {
    replace `i'=100 if `i'==1
}

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
lab var d75_LargeR     "Distance  < 75 Km to CG activity - Large ruminants crossbred"
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


lab var d25_Avocado    "Distance  < 25 Km to CG activity - Avocado trees" 
lab var d50_Avocado    "Distance  < 50 Km to CG activity - Avocado trees" 
lab var d75_Avocado    "Distance  < 75 Km to CG activity - Avocado trees" 
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

#delimit;
global adoptcg ead_ofsp ead_avocado ead_rotlegume ead_cresidue1 ead_cresidue2 ead_mtill ead_zerotill ead_consag1 ead_consag2 ead_swc ead_terr ead_wcatch ead_affor ead_ploc
 ead_crlr ead_crsr ead_crpo
 sorghum_cg barley_cg  dtmz qpm
;
#delimit cr

*ESS4
global eacov4 d25_LargeR d50_LargeR d75_LargeR d100_LargeR d125_LargeR d150_LargeR d25_SmallR d50_SmallR d75_SmallR d100_SmallR d125_SmallR d150_SmallR d25_chicken d50_chicken d75_chicken d100_chicken d125_chicken d150_chicken d25_Avocado d50_Avocado d75_Avocado d100_Avocado d125_Avocado d150_Avocado d25_DTMZ d50_DTMZ d75_DTMZ d100_DTMZ d125_DTMZ d150_DTMZ d25_CA d50_CA d75_CA d100_CA d125_CA d150_CA d25_OFSP d50_OFSP d75_OFSP d100_OFSP d125_OFSP d150_OFSP d25_NUME d50_NUME d75_NUME d100_NUME d125_NUME d150_NUME d25_SLM d50_SLM d75_SLM d100_SLM d125_SLM d150_SLM d25_Barley d50_Barley d75_Barley d100_Barley d125_Barley d150_Barley d25_Sorghum d50_Sorghum d75_Sorghum d100_Sorghum d125_Sorghum d150_Sorghum


matrix drop _all
 
foreach i in   $adoptcg {
foreach var in $eacov4 {



qui: mean    `var' [pw=pw_w4]           if wave==4 & `i'==100
matrix  `var'mt`i'=e(b)'
scalar  `var'mt`i'= `var'mt`i'[1,1]

matrix define `var'Vt`i'= e(V)'
matrix define `var'VVt`i'=(vecdiag(`var'Vt`i'))'
matrix list `var'VVt`i'
scalar `var'vart`i'=`var'VVt`i'[1,1]
scalar `var'set`i'=sqrt(`var'VVt`i'[1,1])



qui: mean `var' [pw=pw_w4]              if  wave==4 & `i'==0
matrix  `var'mc`i'=e(b)'
scalar  `var'mc`i'= `var'mc`i'[1,1]
matrix define `var'Vc`i'= e(V)'
matrix define `var'VVc`i'=(vecdiag(`var'Vc`i'))'
matrix list `var'VVc`i'
scalar `var'varc`i'=`var'VVc`i'[1,1]
scalar `var'sec`i'=sqrt(`var'VVc`i'[1,1])


qui sum `i' if `i'==0  & wave==4
local controbs`i'=r(N)

qui sum `i' if `i'==100 & wave==4
local treatobs`i'=r(N)


matrix mstrhelp`i'=(0,0,0,0,0)


    
scalar `var'df`i'=(`var'mt`i'-`var'mc`i') //Simple difference

*scalar `var'df`i'=((`var'mt`i'-`var'mc`i') / sqrt((`var'vart`i'+ `var'varc`i')/2))

qui: reg `var' `i' if  wave==4 [pw=pw_w4]
*local t = _b[`i']/_se[`i']
*scalar `var'pval`i' = 2*ttail(e(df_r), abs(`t'))
test `i'=0
scalar `var'pval`i'=r(p)

qui: reg `var' `i'   i.region if  wave==4 [pw=pw_w4]
*local t = _b[`i']/_se[`i']
*scalar `var'pval`i' = 2*ttail(e(df_r), abs(`t'))
test `i'=0
scalar `var'pvalf`i'=r(p)



matrix mat`var'`i'  = (`var'mt`i',  `var'mc`i', `var'df`i', `var'pval`i', `var'pvalf`i') 
matrix mat1`var'`i' = (`var'set`i', `var'sec`i',         .,            .,             .) 


    if (`var'pval`i'<=0.1 & `var'pval`i'>0.05)   & (`var'pvalf`i'<=0.1  & `var'pvalf`i'>0.05)  {
	matrix mstr`var'`i' = (0, 0, 0, 3, 3) 
     }
	if (`var'pval`i'  <=0.1 & `var'pval`i'>0.05) & (`var'pvalf`i' <=0.05 & `var'pvalf`i' >0.01) {
	matrix mstr`var'`i' = (0, 0, 0, 3, 2) 
     }
	 if (`var'pval`i'  <=0.1 & `var'pval`i'>0.05) & `var'pvalf`i'<=0.01 {
	matrix mstr`var'`i' = (0, 0, 0, 3, 1) 
     }
	 if (`var'pval`i'  <=0.1 & `var'pval`i'>0.05) & `var'pvalf`i'>0.1   {
	matrix mstr`var'`i' = (0, 0, 0, 3, 0) 
     }
	 
	 
    if (`var'pval`i'  <=0.05 & `var'pval`i'>0.01)  & (`var'pvalf`i'<=0.1  & `var'pvalf`i'>0.05)  {
	matrix mstr`var'`i' = (0, 0, 0, 2, 3) 
     }
	if (`var'pval`i'  <=0.05 & `var'pval`i'>0.01)  & (`var'pvalf`i' <=0.05 & `var'pvalf`i' >0.01) {
	matrix mstr`var'`i' = (0, 0, 0, 2, 2) 
     }
    if (`var'pval`i'  <=0.05 & `var'pval`i'>0.01)   & `var'pvalf`i'<=0.01 {
	matrix mstr`var'`i' = (0, 0, 0, 2, 1) 
     }
	 if (`var'pval`i'  <=0.05 & `var'pval`i'>0.01)   & `var'pvalf`i'>0.1  {
	matrix mstr`var'`i' = (0, 0, 0, 2, 0) 
     }	 
	 
	 
	 if `var'pval`i'  <=0.01 & (`var'pvalf`i'<=0.1  & `var'pvalf`i'>0.05) {
	matrix mstr`var'`i' = (0, 0, 0, 1, 3) 
     }
	if `var'pval`i'  <=0.01 & (`var'pvalf`i' <=0.05 & `var'pvalf`i' >0.01) {
	matrix mstr`var'`i' = (0, 0, 0, 1, 2) 
     }
	 if `var'pval`i'  <=0.01 &  `var'pvalf`i'<=0.01 {
	matrix mstr`var'`i' = (0, 0, 0, 1, 1) 
     }
	 if `var'pval`i'  <=0.01  & `var'pvalf`i'>0.1 {
	matrix mstr`var'`i' = (0, 0, 0, 1, 0) 
     }
	 
	 
	if `var'pval`i'   >0.1 & (`var'pvalf`i'<=0.1  & `var'pvalf`i'>0.05)  {
	matrix mstr`var'`i' = (0, 0, 0, 0, 3) 
     }
	if `var'pval`i'   >0.1 & (`var'pvalf`i' <=0.05 & `var'pvalf`i' >0.01) {
	matrix mstr`var'`i' = (0, 0, 0, 0, 2) 
     }
	 if `var'pval`i'  >0.1 & `var'pvalf`i'<=0.01 {
	matrix mstr`var'`i' = (0, 0, 0, 0, 1) 
     }
	 if `var'pval`i'  >0.1 & `var'pvalf`i'>0.1  {
	matrix mstr`var'`i' = (0, 0, 0, 0, 0) 
     }
	 
	 

matrix list mat`var'`i'


matrix A1`i' = nullmat(A1`i')\ mat`var'`i'\mat1`var'`i'


matrix A1`i'_STARS =  nullmat(A1`i'_STARS)\mstr`var'`i'\mstrhelp`i'
}


local rname ""
foreach var in $eacov4{
local lbl : variable label `var'
local rname `"  `rname'   "`lbl'" " " "'		
}		

mat A`i'_STARS=A1`i'_STARS\mstrhelp`i'
mat A2`i'=(`treatobs`i'',`controbs`i'',.,.,.)
mat AA`i'=A1`i'\A2`i'

matrix colnames AA`i' = "Adopters" "Non-Adopters" "Difference" "p-value" "p-valuefe" 

}


mat C=AAead_ofsp, AAead_avocado, AAead_rotlegume, AAead_cresidue1, AAead_cresidue2, AAead_mtill, AAead_zerotill, AAead_consag1, AAead_consag2, AAead_swc, AAead_terr, AAead_wcatch, AAead_affor, AAead_ploc, AAead_crlr, AAead_crsr, AAead_crpo, AAsorghum_cg, AAbarley_cg, AAdtmz, AAqpm

mat C_STARS= Aead_ofsp_STARS, Aead_avocado_STARS, Aead_rotlegume_STARS, Aead_cresidue1_STARS, Aead_cresidue2_STARS, Aead_mtill_STARS, Aead_zerotill_STARS, Aead_consag1_STARS, Aead_consag2_STARS, Aead_swc_STARS, Aead_terr_STARS, Aead_wcatch_STARS, Aead_affor_STARS, Aead_ploc_STARS, Aead_crlr_STARS, Aead_crsr_STARS, Aead_crpo_STARS, Asorghum_cg_STARS, Abarley_cg_STARS, Adtmz_STARS, Aqpm_STARS



#delimit ;
xml_tab C,  save("$table${slash}Adopters characteristics.xml") append sheet("Table 4_distances", nogridlines)  ///
rnames(`rname' "Total No. of obs.") cnames(`cnames')
ceq("Sweet potato OFSP variety" "Sweet potato OFSP variety" "Sweet potato OFSP variety" "Sweet potato OFSP variety" "Sweet potato OFSP variety"
"Avocado tree" "Avocado tree" "Avocado tree" "Avocado tree" "Avocado tree"

"Crop rotation with a legume" "Crop rotation with a legume" "Crop rotation with a legume" "Crop rotation with a legume"   "Crop rotation with a legume" 
"Crop residue cover - farmers elicitation" "Crop residue cover - farmers elicitation" "Crop residue cover - farmers elicitation" "Crop residue cover - farmers elicitation" "Crop residue cover - farmers elicitation"
"Crop residue cover - visual aid" "Crop residue cover - visual aid" "Crop residue cover - visual aid" "Crop residue cover - visual aid" "Crop residue cover - visual aid"
"Minimum tillage" "Minimum tillage" "Minimum tillage"  "Minimum tillage" "Minimum tillage"
"Zero tillage" "Zero tillage" "Zero tillage" "Zero tillage" "Zero tillage"
"Conservation Agriculture using Minimum tillage" "Conservation Agriculture using Minimum tillage" "Conservation Agriculture using Minimum tillage" "Conservation Agriculture using Minimum tillage"  "Conservation Agriculture using Minimum tillage"
"Conservation Agriculture using Zero tillage" "Conservation Agriculture using Zero tillage" "Conservation Agriculture using Zero tillage" "Conservation Agriculture using Zero tillage" "Conservation Agriculture using Zero tillage"
"Soil Water Conservation practices" "Soil Water Conservation practices" "Soil Water Conservation practices" "Soil Water Conservation practices"  "Soil Water Conservation practices"
"Terracing" "Terracing" "Terracing" "Terracing" "Terracing"
"Water catchments" "Water catchments" "Water catchments" "Water catchments" "Water catchments"
"Afforestation" "Afforestation" "Afforestation" "Afforestation"  "Afforestation" 
"Plough along the contour" "Plough along the contour" "Plough along the contour" "Plough along the contour" "Plough along the contour"

"Crossbred large ruminants" "Crossbred large ruminants" "Crossbred large ruminants" "Crossbred large ruminants" "Crossbred large ruminants"
"Crossbred small ruminants" "Crossbred small ruminants" "Crossbred small ruminants" "Crossbred small ruminants" "Crossbred small ruminants"
"Crossbred poultry" "Crossbred poultry" "Crossbred poultry" "Crossbred poultry"  "Crossbred poultry"

"Sorghum CG germplasm" "Sorghum CG germplasm" "Sorghum CG germplasm" "Sorghum CG germplasm"   "Sorghum CG germplasm"
"Barley CG germplasm"  "Barley CG germplasm"  "Barley CG germplasm"  "Barley CG germplasm"  "Barley CG germplasm"
"DTMZ" "DTMZ" "DTMZ" "DTMZ" "DTMZ"
"QPM" "QPM" "QPM" "QPM" "QPM") showeq ///
rblanks(COL_NAMES "EA level data" S2220)	 /// Adds blank columns which are used to separate Treatment and Control graphically.
title(Table 4: ESS4 - EA level )  font("Times New Roman" 10) ///
cw(0 110, 1 55, 2 55, 3 55, 4 55, 5 55, 6 55, 7 55, 8 55, 9 55, 10 55, 11 55, 12 55, 13 55,  14 55,  15 55, 16 55, 17 55, 18 55, 19 55, 20 55, 21 55, 22 55, 23 55, 24 55, 25 55, 26 55, 27 55, 28 55, 29 55, 30 55, 31 55, 32 55, 33 55, 34 55, 35 55, 36 55, 37 55, 38 55, 39 55, 40 55  ) /// *Adjust the column width of the table, column 0 are the variable names* 1, 5 and 9 are the blank columns. 
	format((SCLR0) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3))  /// * format the columns. Each parentheses represents one column*
	stars(* 0.1 ** 0.05 *** 0.01)  /// Define your star values/signs here (which are stored in B_STARS)
	lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 2)  /// Draws lines in specific format (Numeric Value)
	notes(Point estimates are weighted sample means. Standard errors are reported below. , Stars represent level of statistical significance of t-test/chi-squared test of difference in means. Rural sample only ); //Add your notes here
# delimit cr
