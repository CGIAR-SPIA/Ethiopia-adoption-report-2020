
* Adopters and non adopters decriptive stats.
* T-stats of means by region
*ESS3*
* Who are the adopters of the innovations? ESS3
use "${data}${slash}ess3_pp_cov", clear

replace hhd_psnp=100 if hhd_psnp==1

rename hhd_mintillage hhd_mintil
rename hhd_sweetpotato hhd_sp

rename hhd_cross_largerum hhd_crlr
rename hhd_cross_smallrum hhd_crsr
rename hhd_cross_poultry  hhd_crpo




#delimit;
global hhdemo   sex_head age_head yrseduc fowner hhd_flab flivman
parcesizeHA  asset_index pssetindex income_offfarm tcann ntcaeq consq1 consq2
depend_ratio hhsize_ae 
sh_ch4 sh_ch510 sh_m1114 sh_f1114 sh_m1519 sh_f1519 sh_m2034 sh_f2034 sh_m3559 sh_f3559 sh_m60p sh_f60p sh_0114 sh_1559 sh_60p;
#delimit cr


global adopt     hhd_rdisp hhd_treadle hhd_motorpump hhd_rotlegume hhd_cresidue1 hhd_cresidue2 hhd_mintil hhd_zerotill hhd_consag1  hhd_swc hhd_terr hhd_wcatch hhd_affor hhd_ploc hhd_ofsp hhd_awassa83 hhd_desi hhd_kabuli hhd_avocado hhd_papaya hhd_mango  hhd_fieldp hhd_sp hhd_cross  hhd_crlr hhd_crsr hhd_crpo hhd_livIA hhd_indprod hhd_grass hhd_bbm hhd_psnp



keep if rural==1



matrix drop _all
 
foreach i in   $adopt {
foreach var in $hhdemo {



qui: mean    `var' [pw=pw_w3]           if wave==3 & `i'==100
matrix  `var'mt`i'=e(b)'
scalar  `var'mt`i'= `var'mt`i'[1,1]

matrix define `var'Vt`i'= e(V)'
matrix define `var'VVt`i'=(vecdiag(`var'Vt`i'))'
matrix list `var'VVt`i'
scalar `var'vart`i'=`var'VVt`i'[1,1]
scalar `var'set`i'=sqrt(`var'VVt`i'[1,1])



qui: mean `var' [pw=pw_w3]              if  wave==3 & `i'==0
matrix  `var'mc`i'=e(b)'
scalar  `var'mc`i'= `var'mc`i'[1,1]
matrix define `var'Vc`i'= e(V)'
matrix define `var'VVc`i'=(vecdiag(`var'Vc`i'))'
matrix list `var'VVc`i'
scalar `var'varc`i'=`var'VVc`i'[1,1]
scalar `var'sec`i'=sqrt(`var'VVc`i'[1,1])


qui sum `i' if `i'==0  & wave==3
local controbs`i'=r(N)

qui sum `i' if `i'==100 & wave==3
local treatobs`i'=r(N)


matrix mstrhelp`i'=(0,0,0,0,0)


    
scalar `var'df`i'=(`var'mt`i'-`var'mc`i') //Simple difference

*scalar `var'df`i'=((`var'mt`i'-`var'mc`i') / sqrt((`var'vart`i'+ `var'varc`i')/2))

qui: reg `var' `i' if  wave==3 [pw=pw_w3]
*local t = _b[`i']/_se[`i']
*scalar `var'pval`i' = 2*ttail(e(df_r), abs(`t'))
test `i'=0
scalar `var'pval`i'=r(p)

qui: reg `var' `i'   i.region if  wave==3 [pw=pw_w3]
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



mat C= AAhhd_rdisp, AAhhd_treadle, AAhhd_motorpump, AAhhd_rotlegume, AAhhd_cresidue1, AAhhd_cresidue2, AAhhd_mintil, AAhhd_zerotill, AAhhd_consag1, AAhhd_swc, AAhhd_terr, AAhhd_wcatch, AAhhd_affor, AAhhd_ploc, AAhhd_ofsp, AAhhd_awassa83, AAhhd_desi, AAhhd_kabuli, AAhhd_avocado, AAhhd_papaya, AAhhd_mango, AAhhd_fieldp, AAhhd_sp, AAhhd_cross,  AAhhd_crlr, AAhhd_crsr, AAhhd_crpo, AAhhd_livIA, AAhhd_indprod, AAhhd_grass, AAhhd_bbm, AAhhd_psnp

mat C_STARS= Ahhd_rdisp_STARS, Ahhd_treadle_STARS,  Ahhd_motorpump_STARS,  Ahhd_rotlegume_STARS,  Ahhd_cresidue1_STARS,  Ahhd_cresidue2_STARS,  Ahhd_mintil_STARS,  Ahhd_zerotill_STARS,  Ahhd_consag1_STARS,   Ahhd_swc_STARS,  Ahhd_terr_STARS,  Ahhd_wcatch_STARS,  Ahhd_affor_STARS,  Ahhd_ploc_STARS,  Ahhd_ofsp_STARS,  Ahhd_awassa83_STARS, Ahhd_desi_STARS, Ahhd_kabuli_STARS,  Ahhd_avocado_STARS,  Ahhd_papaya_STARS,  Ahhd_mango_STARS,   Ahhd_fieldp_STARS,  Ahhd_sp_STARS,  Ahhd_cross_STARS,   Ahhd_crlr_STARS,  Ahhd_crsr_STARS,  Ahhd_crpo_STARS,  Ahhd_livIA_STARS,  Ahhd_indprod_STARS,  Ahhd_grass_STARS, Ahhd_bbm_STARS,  Ahhd_psnp_STARS


#delimit ;
xml_tab C,  save("$table${slash}Adopters characteristics_v2.xml") replace sheet("Table 4_hh_ESS3", nogridlines)  ///
rnames(`rname' "Total No. of obs.") cnames(`cnames')
ceq(
"River dispersion" "River dispersion" "River dispersion" "River dispersion" "River dispersion"
"Treadle pump used for irrigation" "Treadle pump used for irrigation" "Treadle pump used for irrigation" "Treadle pump used for irrigation" "Treadle pump used for irrigation"
"Motor pump used for irrigation"  "Motor pump used for irrigation" "Motor pump used for irrigation" "Motor pump used for irrigation" "Motor pump used for irrigation"
"Crop rotation with a legume" "Crop rotation with a legume" "Crop rotation with a legume" "Crop rotation with a legume"  "Crop rotation with a legume"
"Crop residue cover - farmers elicitation" "Crop residue cover - farmers elicitation" "Crop residue cover - farmers elicitation" "Crop residue cover - farmers elicitation" "Crop residue cover - farmers elicitation"
"Crop residue cover - visual aid" "Crop residue cover - visual aid" "Crop residue cover - visual aid" "Crop residue cover - visual aid" "Crop residue cover - visual aid"
"Minimum tillage" "Minimum tillage" "Minimum tillage" "Minimum tillage" "Minimum tillage"
"Zero tillage" "Zero tillage" "Zero tillage" "Zero tillage"  "Zero tillage"
"Conservation Agriculture - using Minimum tillage" "Conservation Agriculture - using Minimum tillage" "Conservation Agriculture - using Minimum tillage" "Conservation Agriculture - using Minimum tillage" "Conservation Agriculture - using Minimum tillage"
"Soil Water Conservation practices" "Soil Water Conservation practices" "Soil Water Conservation practices" "Soil Water Conservation practices" "Soil Water Conservation practices" 
"Terracing" "Terracing" "Terracing" "Terracing" "Terracing"
"Water catchments" "Water catchments" "Water catchments" "Water catchments" "Water catchments"
"Afforestation" "Afforestation" "Afforestation" "Afforestation" "Afforestation"
"Plough along the contour" "Plough along the contour" "Plough along the contour" "Plough along the contour"  "Plough along the contour"
"Sweet potato OFSP variety" "Sweet potato OFSP variety" "Sweet potato OFSP variety" "Sweet potato OFSP variety" "Sweet potato OFSP variety"
"Sweet potato Awassa83 variety" "Sweet potato Awassa83 variety" "Sweet potato Awassa83 variety" "Sweet potato Awassa83 variety" "Sweet potato Awassa83 variety"
"Desi chickpea" "Desi chickpea" "Desi chickpea" "Desi chickpea" "Desi chickpea"
"Kabuli chickpea" "Kabuli chickpea" "Kabuli chickpea" "Kabuli chickpea"  "Kabuli chickpea" 
"Avocado tree" "Avocado tree" "Avocado tree" "Avocado tree" "Avocado tree"
"Papaya tree" "Papaya tree" "Papaya tree" "Papaya tree" "Papaya tree"
"Mango tree" "Mango tree" "Mango tree" "Mango tree" "Mango tree" 
"Field peas" "Field peas" "Field peas" "Field peas"  "Field peas"
"Sweetpotato" "Sweetpotato" "Sweetpotato" "Sweetpotato"  "Sweetpotato"
"Any crossbred animal" "Any crossbred animal" "Any crossbred animal" "Any crossbred animal" "Any crossbred animal"
"Crossbred large ruminants" "Crossbred large ruminants" "Crossbred large ruminants" "Crossbred large ruminants" "Crossbred large ruminants"
"Crossbred small ruminants" "Crossbred small ruminants" "Crossbred small ruminants" "Crossbred small ruminants" "Crossbred small ruminants"
"Crossbred poultry" "Crossbred poultry" "Crossbred poultry" "Crossbred poultry" "Crossbred poultry"
"AI on any livestock type" "AI on any livestock type" "AI on any livestock type" "AI on any livestock type" "AI on any livestock type"
"Feed and Forage: Industry by-products" "Feed and Forage: Industry by-products" "Feed and Forage: Industry by-products" "Feed and Forage: Industry by-products" "Feed and Forage: Industry by-products"
"Elephant grass, gaya, sasbaniya, alfalfa" "Elephant grass, gaya, sasbaniya, alfalfa" "Elephant grass, gaya, sasbaniya, alfalfa" "Elephant grass, gaya, sasbaniya, alfalfa" "Elephant grass, gaya, sasbaniya, alfalfa"
"Broad bed maker" "Broad bed maker" "Broad bed maker" "Broad bed maker" "Broad bed maker"
"PSNP" "PSNP" "PSNP" "PSNP" "PSNP") showeq ///
rblanks(COL_NAMES "HH level data" S2220)	 /// Adds blank columns which are used to separate Treatment and Control graphically.
title(Table 4: ESS3 - HH demo )  font("Times New Roman" 10) ///
cw(0 110, 1 55, 2 55, 3 55, 4 55, 5 55, 6 55, 7 55, 8 55, 9 55, 10 55, 11 55, 12 55, 13 55,  14 55,  15 55, 16 55, 17 55, 18 55, 19 55, 20 55, 21 55, 22 55, 23 55, 24 55, 25 55, 26 55, 27 55, 28 55, 29 55, 30 55, 31 55, 32 55, 33 55, 34 55, 35 55, 36 55, 37 55, 38 55, 39 55, 40 55  ) /// *Adjust the column width of the table, column 0 are the variable names* 1, 5 and 9 are the blank columns. 
	format((SCLR0) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3))  /// * format the columns. Each parentheses represents one column*
	stars(* 0.1 ** 0.05 *** 0.01) /// Define your star values/signs here (which are stored in B_STARS)
	lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 2)  /// Draws lines in specific format (Numeric Value)
	notes(Point estimates are weighted sample means. Standard errors are reported below. , Stars represent level of statistical significance of t-test/chi-squared test of difference in means. ); //Add your notes here
# delimit cr

********************************************************************************
* PLOT LEVEL DATA
********************************************************************************
********************************************************************************

use "${data}${slash}ess3_pp_cov_plot", clear

rename sp_ofsp ofsp 
rename sp_awassa83 awassa83
rename sweetpotato sp
*Adoption status

 global adopt rdisp  motorpump rotlegume cresidue1 cresidue2 mintillage zerotill consag1 swc terr wcatch affor ploc bbm ofsp awassa83 desi_d kabuli_d  avocado papaya mango  fieldp sp 



* Plot level characteristics
* ESS4
#delimit ;
global plotlevel 
title fowner frsell acqparc1 acqparc2 acqparc3 acqparc6 acqparc7 acqparcoth soilq1 soilq2 soilq3 soilt1 soilt2 soilt3 soilt4 soilt5 soilt6


plotarea_sr plotarea_gps  plotarea_full
fplotm extprog
irr  urea dap nps othfert manure hiredlab lprep soiler 

improv cdam1 cdam2 cdam3 cdam4 cdam5 cdamoth hsell  
pp_s3q091 pp_s3q092 pp_s3q093  pp_s3q03c fied_prpa1 fied_prpa2 fied_prpa3 fied_prpa4 pp_s4q05 pp_s4q06 pp_s4q07;
#delimit cr




keep if rural==1

matrix drop _all
 
foreach i in   $adopt {
foreach var in $plotlevel {



qui: mean    `var' [pw=pw_w3]           if wave==3 & `i'==1
matrix  `var'mt`i'=e(b)'
scalar  `var'mt`i'= `var'mt`i'[1,1]

matrix define `var'Vt`i'= e(V)'
matrix define `var'VVt`i'=(vecdiag(`var'Vt`i'))'
matrix list `var'VVt`i'
scalar `var'vart`i'=`var'VVt`i'[1,1]
scalar `var'set`i'=sqrt(`var'VVt`i'[1,1])



qui: mean `var' [pw=pw_w3]              if  wave==3 & `i'==0
matrix  `var'mc`i'=e(b)'
scalar  `var'mc`i'= `var'mc`i'[1,1]
matrix define `var'Vc`i'= e(V)'
matrix define `var'VVc`i'=(vecdiag(`var'Vc`i'))'
matrix list `var'VVc`i'
scalar `var'varc`i'=`var'VVc`i'[1,1]
scalar `var'sec`i'=sqrt(`var'VVc`i'[1,1])


qui sum `i' if `i'==0  & wave==3
local controbs`i'=r(N)

qui sum `i' if `i'==1 & wave==3
local treatobs`i'=r(N)


matrix mstrhelp`i'=(0,0,0,0,0)


    
scalar `var'df`i'=(`var'mt`i'-`var'mc`i') //Simple difference

*scalar `var'df`i'=((`var'mt`i'-`var'mc`i') / sqrt((`var'vart`i'+ `var'varc`i')/2))

qui: reg `var' `i' if  wave==3 [pw=pw_w3]
*local t = _b[`i']/_se[`i']
*scalar `var'pval`i' = 2*ttail(e(df_r), abs(`t'))
test `i'=0
scalar `var'pval`i'=r(p)

qui: reg `var' `i'   i.region if  wave==3 [pw=pw_w3]
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




mat C= AArdisp,  AAmotorpump, AArotlegume, AAcresidue1, AAcresidue2, AAmintillage, AAzerotill, AAconsag1,  AAswc, AAterr, AAwcatch, AAaffor, AAploc, AAofsp, AAawassa83, AAdesi_d, AAkabuli_d, AAavocado, AApapaya, AAmango,  AAfieldp, AAsp 

mat C_STARS=Ardisp_STARS, Amotorpump_STARS, Arotlegume_STARS, Acresidue1_STARS, Acresidue2_STARS, Amintillage_STARS, Azerotill_STARS, Aconsag1_STARS,  Aswc_STARS, Aterr_STARS, Awcatch_STARS, Aaffor_STARS, Aploc_STARS, Aofsp_STARS, Aawassa83_STARS, Adesi_d_STARS, Akabuli_d_STARS, Aavocado_STARS, Apapaya_STARS, Amango_STARS,  Afieldp_STARS, Asp_STARS 

#delimit ;
xml_tab C,  save("$table${slash}Adopters characteristics_v2.xml") append sheet("Table 5_plot_ESS3", nogridlines)  ///
rnames(`rname' "Total No. of obs.") cnames(`cnames')
ceq(
"River dispersion" "River dispersion" "River dispersion" "River dispersion" "River dispersion"
"Motor pump used for irrigation" "Motor pump used for irrigation" "Motor pump used for irrigation" "Motor pump used for irrigation" "Motor pump used for irrigation"
"Crop rotation with a legume" "Crop rotation with a legume" "Crop rotation with a legume" "Crop rotation with a legume" "Crop rotation with a legume"
"Crop residue cover - Farmer's elicitation" "Crop residue cover - Farmer's elicitation" "Crop residue cover - Farmer's elicitation" "Crop residue cover - Farmer's elicitation" "Crop residue cover - Farmer's elicitation"
"Crop residue cover - visual aid" "Crop residue cover - visual aid" "Crop residue cover - visual aid" "Crop residue cover - visual aid" "Crop residue cover - visual aid"
"Minimum tillage" "Minimum tillage" "Minimum tillage" "Minimum tillage"  "Minimum tillage" 
"Zero tillage" "Zero tillage" "Zero tillage" "Zero tillage" "Zero tillage"
"Conservation Agriculture - using Minimum tillage" "Conservation Agriculture - using Minimum tillage" "Conservation Agriculture - using Minimum tillage" "Conservation Agriculture - using Minimum tillage" "Conservation Agriculture - using Minimum tillage"
"Soil Water Conservation practices" "Soil Water Conservation practices" "Soil Water Conservation practices" "Soil Water Conservation practices" "Soil Water Conservation practices"
"Terracing" "Terracing" "Terracing" "Terracing" "Terracing"
"Water catchments" "Water catchments" "Water catchments"  "Water catchments" "Water catchments"
"Afforestation" "Afforestation" "Afforestation" "Afforestation"  "Afforestation"
"Plough along the contour" "Plough along the contour" "Plough along the contour" "Plough along the contour" "Plough along the contour"
"Orange Fleshed sweet potato" "Orange Fleshed sweet potato" "Orange Fleshed sweet potato"  "Orange Fleshed sweet potato" "Orange Fleshed sweet potato"
"Awassa83 sweet potato" "Awassa83 sweet potato" "Awassa83 sweet potato" "Awassa83 sweet potato" "Awassa83 sweet potato"
"Desi chickpea" "Desi chickpea" "Desi chickpea" "Desi chickpea" "Desi chickpea"
"Kabuli chickpea" "Kabuli chickpea" "Kabuli chickpea" "Kabuli chickpea" "Kabuli chickpea" 
"Avocado tree" "Avocado tree" "Avocado tree" "Kabuli chickpea"  "Kabuli chickpea"
"Papaya tree" "Papaya tree" "Papaya tree" "Papaya tree"  "Papaya tree"
"Mango tree" "Mango tree" "Mango tree" "Mango tree"  "Mango tree" 
"Field peas" "Field peas" "Field peas" "Field peas"  "Field peas"
"Sweetpotato SR" "Sweetpotato SR" "Sweetpotato SR"  "Sweetpotato SR" "Sweetpotato SR") showeq ///
rblanks(COL_NAMES "Plot level data" S2220)	 /// Adds blank columns which are used to separate Treatment and Control graphically.
title(Table 5: ESS3 - Parcel and Plot characteristics )  font("Times New Roman" 10) ///
cw(0 110, 1 55, 2 55, 3 55, 4 55, 5 55, 6 55, 7 55, 8 55, 9 55, 10 55, 11 55, 12 55, 13 55,  14 55,  15 55, 16 55, 17 55, 18 55, 19 55, 20 55, 21 55, 22 55, 23 55, 24 55, 25 55, 26 55, 27 55, 28 55, 29 55, 30 55, 31 55, 32 55, 33 55, 34 55, 35 55, 36 55, 37 55, 38 55, 39 55, 40 55  ) /// *Adjust the column width of the table, column 0 are the variable names* 1, 5 and 9 are the blank columns. 
	format((SCLR0) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3))  /// * format the columns. Each parentheses represents one column*
	stars(* 0.1 ** 0.05 *** 0.01)  /// Define your star values/signs here (which are stored in B_STARS)
	lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 2)  /// Draws lines in specific format (Numeric Value)
	notes(Point estimates are weighted sample means. Standard errors are reported below. , Stars represent level of statistical significance of t-test/chi-squared test of difference in means. ); //Add your notes here
# delimit cr


********************************************************************************
* EA - LEVEL
********************************************************************************
use "${data}${slash}ess3_pp_cov_ea", clear



#delimit;
global adopt ead_ofsp ead_awassa83 ead_desi ead_kabuli ead_avocado ead_papaya ead_mango ead_fieldp ead_sweetpotato ead_motorpump ead_rdisp ead_rotlegume ead_cresidue1 ead_cresidue2 ead_mintillage ead_zerotill ead_consag1  ead_swc ead_terr ead_wcatch ead_affor ead_ploc  commirr
ead_cross ead_crlr /*ead_crsr*/ ead_crpo
ead_livIA ead_indprod ead_grass ead_bbm ead_psnp;
#delimit cr


global eacov3 cs9q01 cs9q13 cs9q13wiz cs9q14 cs9q14wiz cs6q01  cs6q12_11 cs6q12_12 cs6q12_13 cs6q12_14 cs6q13_11 cs6q13_12 cs6q13_13 cs6q13_14 cs6q14_11 cs6q14_12 cs6q14_13 cs6q14_14 cs6q15_11 cs6q15_12 cs6q15_13 cs4q02 cs4q02wiz droad cs4q011 cs4q012 cs4q013 cs4q014 cs4q03 cs4q08 cs4q09 cs4q09wiz cs4q11 cs4q12 cs4q12wiz dadm cs4q14 cs4q150 cs4q150wiz dmkt cs3q02 cs3q02wiz csdq54 csdq55




foreach i in $adopt {
    replace `i'=1 if `i'==100
}


keep if rural==1
matrix drop _all
 
foreach i in   $adopt {
foreach var in $eacov3 {



qui: mean    `var' [pw=pw_w3]           if wave==3 & `i'==1
matrix  `var'mt`i'=e(b)'
scalar  `var'mt`i'= `var'mt`i'[1,1]

matrix define `var'Vt`i'= e(V)'
matrix define `var'VVt`i'=(vecdiag(`var'Vt`i'))'
matrix list `var'VVt`i'
scalar `var'vart`i'=`var'VVt`i'[1,1]
scalar `var'set`i'=sqrt(`var'VVt`i'[1,1])



qui: mean `var' [pw=pw_w3]              if  wave==3 & `i'==0
matrix  `var'mc`i'=e(b)'
scalar  `var'mc`i'= `var'mc`i'[1,1]
matrix define `var'Vc`i'= e(V)'
matrix define `var'VVc`i'=(vecdiag(`var'Vc`i'))'
matrix list `var'VVc`i'
scalar `var'varc`i'=`var'VVc`i'[1,1]
scalar `var'sec`i'=sqrt(`var'VVc`i'[1,1])


qui sum `i' if `i'==0  & wave==3
local controbs`i'=r(N)

qui sum `i' if `i'==1 & wave==3
local treatobs`i'=r(N)


matrix mstrhelp`i'=(0,0,0,0,0)


    
scalar `var'df`i'=(`var'mt`i'-`var'mc`i') //Simple difference

*scalar `var'df`i'=((`var'mt`i'-`var'mc`i') / sqrt((`var'vart`i'+ `var'varc`i')/2))

qui: reg `var' `i' if  wave==3 [pw=pw_w3]
*local t = _b[`i']/_se[`i']
*scalar `var'pval`i' = 2*ttail(e(df_r), abs(`t'))
test `i'=0
scalar `var'pval`i'=r(p)

qui: reg `var' `i'   i.region if  wave==3 [pw=pw_w3]
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
foreach var in $eacov3 {
local lbl : variable label `var'
local rname `"  `rname'   "`lbl'" " " "'		
}		

mat A`i'_STARS=A1`i'_STARS\mstrhelp`i'
mat A2`i'=(`treatobs`i'',`controbs`i'',.,.,.)
mat AA`i'=A1`i'\A2`i'

matrix colnames AA`i' = "Adopters" "Non-Adopters" "Difference" "p-value" "p-valuefe" 

}



mat C= AAead_ofsp,AAead_awassa83, AAead_kabuli, AAead_desi,AAead_avocado, AAead_papaya, AAead_mango, AAead_fieldp, AAead_sweetpotato, AAead_motorpump, AAead_rdisp, AAead_rotlegume,AAead_cresidue1,AAead_cresidue2,AAead_mintillage,AAead_zerotill,AAead_consag1,AAead_swc, AAead_terr, AAead_wcatch, AAead_affor, AAead_ploc,  AAcommirr, AAead_cross, AAead_crlr,  AAead_crpo, AAead_livIA, AAead_indprod, AAead_grass, AAead_bbm, AAead_psnp

mat C_STARS=Aead_ofsp_STARS,Aead_awassa83_STARS,Aead_kabuli_STARS, Aead_desi_STARS, Aead_avocado_STARS, Aead_papaya_STARS, Aead_mango_STARS, Aead_fieldp_STARS, Aead_sweetpotato_STARS,Aead_motorpump_STARS, Aead_rdisp_STARS,Aead_rotlegume_STARS,Aead_cresidue1_STARS,Aead_cresidue2_STARS,Aead_mintillage_STARS,Aead_zerotill_STARS,Aead_consag1_STARS,Aead_swc_STARS,Aead_terr_STARS, Aead_wcatch_STARS, Aead_affor_STARS, Aead_ploc_STARS,  Acommirr_STARS, Aead_cross_STARS, Aead_crlr_STARS, Aead_crpo_STARS, Aead_livIA_STARS, Aead_indprod_STARS, Aead_grass_STARS, Aead_bbm_STARS, Aead_psnp_STARS

#delimit ;
xml_tab C,  save("$table${slash}Adopters characteristics_v2.xml") append sheet("Table 6_ea_ESS3", nogridlines)  ///
rnames(`rname' "Total No. of obs.") cnames(`cnames')
ceq("Sweet potato OFSP variety" "Sweet potato OFSP variety" "Sweet potato OFSP variety" "Sweet potato OFSP variety" "Sweet potato OFSP variety"

"Sweet potato Awassa83 variety" "Sweet potato Awassa83 variety" "Sweet potato Awassa83 variety"  "Sweet potato Awassa83 variety" "Sweet potato Awassa83 variety"

"Kabuli chickpea" "Kabuli chickpea" "Kabuli chickpea" "Kabuli chickpea" "Kabuli chickpea"
"Desi chickpea" "Desi chickpea" "Desi chickpea" "Desi chickpea" "Desi chickpea"
"Avocado tree" "Avocado tree" "Avocado tree" "Avocado tree" "Avocado tree"
"Papaya tree" "Papaya tree" "Papaya tree" "Papaya tree"  "Papaya tree" 
"Mango tree" "Mango tree" "Mango tree" "Mango tree" "Mango tree"
"Field peas" "Field peas" "Field peas" "Field peas"  "Field peas"
"Sweet potato" "Sweet potato" "Sweet potato" "Sweet potato" "Sweet potato"
"Motor pump used for irrigation" "Motor pump used for irrigation" "Motor pump used for irrigation" "Motor pump used for irrigation" "Motor pump used for irrigation"
"River dispersion"  "River dispersion"  "River dispersion" "River dispersion"  "River dispersion"
"Crop rotation with a legume" "Crop rotation with a legume" "Crop rotation with a legume" "Crop rotation with a legume"  "Crop rotation with a legume" 
"Crop residue cover - farmers elicitation" "Crop residue cover - farmers elicitation" "Crop residue cover - farmers elicitation" "Crop residue cover - farmers elicitation"  "Crop residue cover - farmers elicitation"
"Crop residue cover - visual aid" "Crop residue cover - visual aid" "Crop residue cover - visual aid"  "Crop residue cover - visual aid" "Crop residue cover - visual aid"
"Minimum tillage" "Minimum tillage" "Minimum tillage"  "Minimum tillage"  "Minimum tillage"
"Zero tillage" "Zero tillage" "Zero tillage" "Zero tillage"  "Zero tillage"
"Conservation Agriculture using Minimum tillage" "Conservation Agriculture using Minimum tillage" "Conservation Agriculture using Minimum tillage" "Conservation Agriculture using Minimum tillage" "Conservation Agriculture using Minimum tillage" 
"Soil Water Conservation practices" "Soil Water Conservation practices" "Soil Water Conservation practices" "Soil Water Conservation practices"   "Soil Water Conservation practices" 
"Terracing" "Terracing" "Terracing" "Terracing" "Terracing"
"Water catchments" "Water catchments" "Water catchments" "Water catchments" "Water catchments"
"Afforestation" "Afforestation" "Afforestation" "Afforestation" "Afforestation"
"Plough along the contour" "Plough along the contour" "Plough along the contour" "Plough along the contour" "Plough along the contour"
"Any Crossbred livestock" "Any Crossbred livestock" "Any Crossbred livestock" "Any Crossbred livestock"
"Crossbred livestock" "Crossbred large ruminants" "Crossbred large ruminants" "Crossbred large ruminants" "Crossbred large ruminants"  "Crossbred large ruminants"
"Crossbred poultry" "Crossbred poultry" "Crossbred poultry" "Crossbred poultry" "Crossbred poultry"
"AI on any livestock type" "AI on any livestock type" "AI on any livestock type" "AI on any livestock type" "AI on any livestock type"
"Feed and Forage: Industry by-products" "Feed and Forage: Industry by-products" "Feed and Forage: Industry by-products" "Feed and Forage: Industry by-products" "Feed and Forage: Industry by-products"
"Elephant grass, gaya, sasbaniya, alfalfa" "Elephant grass, gaya, sasbaniya, alfalfa" "Elephant grass, gaya, sasbaniya, alfalfa" "Elephant grass, gaya, sasbaniya, alfalfa" "Elephant grass, gaya, sasbaniya, alfalfa"
"Broad Bed Maker" "Broad Bed Maker" "Broad Bed Maker" "Broad Bed Maker"  "Broad Bed Maker" 
"PSNP" "PSNP" "PSNP" "PSNP" "PSNP") showeq ///) showeq ///
rblanks(COL_NAMES "EA level data" S2220)	 /// Adds blank columns which are used to separate Treatment and Control graphically.
title(Table 6: ESS3 - EA level )  font("Times New Roman" 10) ///
cw(0 110, 1 55, 2 55, 3 55, 4 55, 5 55, 6 55, 7 55, 8 55, 9 55, 10 55, 11 55, 12 55, 13 55,  14 55,  15 55, 16 55, 17 55, 18 55, 19 55, 20 55, 21 55, 22 55, 23 55, 24 55, 25 55, 26 55, 27 55, 28 55, 29 55, 30 55, 31 55, 32 55, 33 55, 34 55, 35 55, 36 55, 37 55, 38 55, 39 55, 40 55  ) /// *Adjust the column width of the table, column 0 are the variable names* 1, 5 and 9 are the blank columns. 
	format((SCLR0) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3))  /// * format the columns. Each parentheses represents one column*
	stars(* 0.1 ** 0.05 *** 0.01)  /// Define your star values/signs here (which are stored in B_STARS)
	lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 2)  /// Draws lines in specific format (Numeric Value)
	notes(Point estimates are weighted sample means. Standard errors are reported below. , Stars represent level of statistical significance of t-test/chi-squared test of difference in means. Rural sample only ); //Add your notes here
# delimit cr

