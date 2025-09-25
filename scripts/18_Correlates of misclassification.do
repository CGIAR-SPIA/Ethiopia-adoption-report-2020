*Correlates of crop varietal misclassifications *



use "${data}${slash}misclassification_plot_new", clear
drop saq13

merge m:1 household_id parcel_id field_id using "${data}${slash}w4_plotlevel_pp_new"
drop if _m==2
drop _m
merge m:1 ea_id using "${data}${slash}ess4_pp_cov_ea_new"
drop if _m==2
drop _merge
drop saq21
merge m:1 household_id using "${data}${slash}ess4_pp_cov_new"
drop if _m==2
drop _m


rename nom_totcons_aeq nmtotcons


replace cs4q12bwiz=0 if cs4q11==1  
replace cs4q15wiz=0  if cs4q14==1  
replace csdq53wiz=0  if cs4q52==1 

rename  total_cons_ann_win totconswin
*drop maize_tp2 maize_tn2 maize_fp2 maize_fn2 maize_tp3 maize_tn3 maize_fp3 maize_fn3
foreach i in  maize_tp2 maize_tn2 maize_fp2 maize_fn2 {
rename `i'c `i'
}
foreach i in  maize_tp3 maize_tn3 maize_fp3 maize_fn3 {
rename `i'c `i'
}


#delimit;
global dna
maize_tp1 maize_tn1 maize_fp1 maize_fn1 //Cg germplasm
maize_tp2 maize_tn2 maize_fp2 maize_fn2 // CG and above 95%
maize_tp3 maize_tn3 maize_fp3 maize_fn3 // CG and years 2010-2020
;
#delimit cr


#delimit;
global cov 

sex_head age_head  yrseduc  fowner hhd_flab flivman
parcesizeHA  asset_index pssetindex income_offfarm total_cons_ann totconswin nmtotcons consq1 consq2
adulteq 




fild_prpa1 fild_prpa2 fild_prpa3 
hsell
plotarea_full
falloq
fplotm
extprog
irr 
urea
dap
nps
othfert
manure
hiredlab

soiler
title
fowner
frsell acqparc1 acqparc2 acqparc3 acqparc6 acqparc7 soilq1 soilq2 soilq3 soilt1 soilt2 soilt3 soilt4 soilt5

cs6q14_11 cs6q14_12 cs6q14_13 cs6q14_14  //Major source of hybrid seed


cs4q011 cs4q11 cs4q12bwiz cs4q14 cs4q15wiz cs4q52 csdq53wiz

;
#delimit cr

* General stats of covariates


matrix drop _all
foreach x in 1 3 4 7 0 {
foreach var in $cov {

 
mean `var' [pw=pw_w4] if region==`x' & wave==4
if _rc==2000 {
matrix  `var'meanr`x'=0
matrix define `var'V`x'= 0

scalar `var'se`x'=0


}
else if _rc!=0 {
error _rc
}
else {
matrix  `var'meanr`x'=e(b)'
matrix define `var'V`x'= e(V)'
matrix define `var'VV`x'=(vecdiag(`var'V`x'))'
matrix list `var'VV`x'
scalar `var'se`x'=sqrt(`var'VV`x'[1,1])
}

sum    `var'  if region==`x' & wave==4
scalar `var'minr`x'=r(min)
scalar `var'maxr`x'=r(max)
scalar `var'n`x'=r(N)

qui sum region if region==`x' & wave==4
local obsr`x'=r(N)



matrix mat`var'`x'  = ( `var'meanr`x', `var'se`x', `var'minr`x', `var'maxr`x', `var'n`x')


matrix list mat`var'`x'

matrix A1`x' = nullmat(A1`x')\ mat`var'`x'


mat A2`x'=(`obsr`x'', . , ., .,.)
mat B`x'=A1`x'\A2`x'

matrix colnames B`x' = "Mean" "SE" "Min" "Max" "N"

}
local rname ""
foreach var in $cov {
local lbl : variable label `var'
local rname `"  `rname'   "`lbl'" " " "'		
}	



}	
* National
foreach var in $cov {

 
cap:mean `var' [pw=pw_w4] if wave==4
if _rc==2000 {
	matrix  `var'meanrN=0
	matrix define `var'VN= 0
	scalar `var'seN=0
				}
else if _rc!=0 {
	error _rc
				}

else {	
matrix  `var'meanrN=e(b)'
matrix define `var'VN= e(V)'
matrix define `var'VVN=(vecdiag(`var'VN))'
matrix list `var'VVN
scalar `var'seN=sqrt(`var'VVN[1,1])
}

sum    `var'  if  wave==4
scalar `var'minrN=r(min)
scalar `var'maxrN=r(max)
scalar `var'nN=r(N)

qui sum region if  wave==4
local obsrN=r(N)



matrix mat`var'N  = ( `var'meanrN,`var'seN, `var'minrN, `var'maxrN, `var'nN)


matrix list mat`var'N

matrix A1N = nullmat(A1N)\ mat`var'N


mat A2N=(`obsrN', . , ., .,.)
mat BN=A1N\A2N

matrix colnames BN = "Mean" "SE" "Min" "Max" "N"

}
local rname ""
foreach var in $cov {
local lbl : variable label `var'
local rname `"  `rname'   "`lbl'" "'		
}	
mat C= B1, B3, B4, B7, B0, BN


#delimit;
xml_tab C,  save("$table${slash}ESS4_corr_misclassificationNEW.xml") replace sheet("Table 1", nogridlines)  ///
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') ceq("Tigray" "Tigray" "Tigray" "Tigray" "Tigray" "Amhara"  "Amhara"  "Amhara"  "Amhara" "Amhara" "Oromia" "Oromia" "Oromia" "Oromia" "Oromia" "SNNP"  "SNNP"  "SNNP"  "SNNP" "SNNP" "Other regions" "Other regions" "Other regions" "Other regions" "Other regions" "National" "National" "National" "National" "National" ) showeq ///
title(Table 1: ESS4 - General stats )  font("Times New Roman" 10) ///
cw(0 110, 1 55, 2 55, 3 30, 4 30, 5 40, 
6 55, 7 55, 8 30, 9 30, 10 40,
11 55, 12 55, 13 30, 14 30, 15 40,
16 55, 17 55, 18 30, 19 30, 20 40,
21 55, 22 55, 23 30, 24 30, 25 40,
26 55, 27 55, 28 30, 29 30, 30 40,
) /// *Adjust the column width of the table, column 0 are the variable names* 1, 5 and 9 are the blank columns. 
	format((SCLR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0))  /// * format the columns. Each parentheses represents one column*
	star(.1 .05 .01)  /// Define your star values/signs here (which are stored in B_STARS)
	lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 13)  /// Draws lines in specific format (Numeric Value)
	notes(Point estimates are weighted sample means. Rural sample ) //Add your notes here
;
#delimit cr		

********************************************************************************
* Correlates of misclassification
********************************************************************************

* Def1: true positive + true negative vs. False positive + False negative

    foreach i in maize  { 
	    forvalues x=1/3 {
    g       `i'cat1_`x'=.
	replace `i'cat1_`x'=0 if `i'_tp`x'==0 & `i'_tn`x'==0
	replace `i'cat1_`x'=1 if `i'_tp`x'==1 | `i'_tn`x'==1

	
	
	g       `i'cat2_`x'=.
	replace `i'cat2_`x'=0 if `i'_tp`x'==1
	replace `i'cat2_`x'=1 if `i'_fp`x'==1 
	
	g       `i'cat3_`x'=.
	replace `i'cat3_`x'=0 if `i'_tn`x'==1
	replace `i'cat3_`x'=1 if `i'_fn`x'==1 
	
	
	}
	}









matrix drop _all
 
forvalues i=1/3 {
foreach var in $cov {


*True positive
qui: mean    `var' [pw=pw_w4]           if wave==4 & maize_tp`i'==1
matrix  `var'mtp`i'=e(b)'
scalar  `var'mtp`i'= `var'mtp`i'[1,1]

matrix define `var'Vtp`i'= e(V)'
matrix define `var'VVtp`i'=(vecdiag(`var'Vtp`i'))'
matrix list `var'VVtp`i'
scalar `var'vartp`i'=`var'VVtp`i'[1,1]
scalar `var'setp`i'=sqrt(`var'VVtp`i'[1,1])

*True negative
qui: mean    `var' [pw=pw_w4]           if wave==4 & maize_tn`i'==1
matrix  `var'mtn`i'=e(b)'
scalar  `var'mtn`i'= `var'mtn`i'[1,1]
matrix define `var'Vtn`i'= e(V)'
matrix define `var'VVtn`i'=(vecdiag(`var'Vtn`i'))'
matrix list `var'VVtn`i'
scalar `var'vartn`i'=`var'VVtn`i'[1,1]
scalar `var'setn`i'=sqrt(`var'VVtn`i'[1,1])

*False positive 
qui: mean    `var' [pw=pw_w4]           if wave==4 & maize_fp`i'==1
matrix  `var'mfp`i'=e(b)'
scalar  `var'mfp`i'= `var'mfp`i'[1,1]
matrix define `var'Vfp`i'= e(V)'
matrix define `var'VVfp`i'=(vecdiag(`var'Vfp`i'))'
matrix list `var'VVfp`i'
scalar `var'varfp`i'=`var'VVfp`i'[1,1]
scalar `var'sefp`i'=sqrt(`var'VVfp`i'[1,1])

*False positive 
qui: mean    `var' [pw=pw_w4]           if wave==4 & maize_fn`i'==1
matrix  `var'mfn`i'=e(b)'
scalar  `var'mfn`i'= `var'mfn`i'[1,1]
matrix define `var'Vfn`i'= e(V)'
matrix define `var'VVfn`i'=(vecdiag(`var'Vfn`i'))'
matrix list `var'VVfn`i'
scalar `var'varfn`i'=`var'VVfn`i'[1,1]
scalar `var'sefn`i'=sqrt(`var'VVfn`i'[1,1])

reg `var' maizecat1_`i'  [pw=pw_w4]
test maizecat1_`i' =0
scalar `var'c1pval`i'=r(p)

reg `var' maizecat2_`i'  [pw=pw_w4]
test maizecat2_`i' =0
scalar `var'c2pval`i'=r(p)




qui sum  maize_tp`i' if  maize_tp`i'==1
local tp`i'=r(N)

qui sum   maize_tn`i' if   maize_tn`i'==1
local tn`i'=r(N)

qui sum  maize_fp`i' if  maize_fp`i'==1
local fp`i'=r(N)

qui sum  maize_fn`i' if  maize_fn`i'==1
local fn`i'=r(N)




matrix mstrhelp`i'=(0,0,0,0,0,0)


    




matrix mat`var'`i'  = (`var'mtp`i', `var'mtn`i', `var'mfp`i', `var'mfn`i', `var'c1pval`i', `var'c2pval`i') 
matrix mat1`var'`i' = (`var'setp`i', `var'setn`i', `var'sefp`i', `var'sefn`i',         .,            .) 

     if ( `var'c1pval`i'<=0.1 &  `var'c1pval`i'>0.05)   & (`var'c2pval`i'<=0.1  & `var'c2pval`i'>0.05)  {
	matrix mstr`var'`i' = (0, 0, 0, 0, 3, 3) 
     }
	if ( `var'c1pval`i'  <=0.1 &  `var'c1pval`i'>0.05) & (`var'c2pval`i' <=0.05 & `var'c2pval`i' >0.01) {
	matrix mstr`var'`i' = (0, 0, 0, 0, 3, 2) 
     }
	 if ( `var'c1pval`i'  <=0.1 &  `var'c1pval`i'>0.05) & `var'c2pval`i'<=0.01 {
	matrix mstr`var'`i' = (0, 0, 0, 0, 3, 1) 
     }
	 if ( `var'c1pval`i' <=0.1 &  `var'c1pval`i'>0.05) & `var'c2pval`i'>0.1   {
	matrix mstr`var'`i' = (0, 0, 0, 0, 3, 0) 
     }
	 
	 
    if ( `var'c1pval`i'  <=0.05 &  `var'c1pval`i'>0.01)  & (`var'c2pval`i'<=0.1  & `var'c2pval`i'>0.05)  {
	matrix mstr`var'`i' = (0, 0, 0, 0, 2, 3) 
     }
	if ( `var'c1pval`i'  <=0.05 &  `var'c1pval`i'>0.01)  & (`var'c2pval`i' <=0.05 & `var'c2pval`i' >0.01) {
	matrix mstr`var'`i' = (0, 0, 0, 0, 2, 2) 
     }
    if ( `var'c1pval`i'  <=0.05 &  `var'c1pval`i'>0.01)   & `var'c2pval`i'<=0.01 {
	matrix mstr`var'`i' = (0, 0, 0, 0, 2, 1) 
     }
	 if ( `var'c1pval`i'  <=0.05 &  `var'c1pval`i'>0.01)   & `var'c2pval`i'>0.1  {
	matrix mstr`var'`i' = (0, 0, 0, 0, 2, 0) 
     }	 
	 
	 
	 if  `var'c1pval`i'  <=0.01 & (`var'c2pval`i'<=0.1  & `var'c2pval`i'>0.05) {
	matrix mstr`var'`i' = (0, 0, 0, 0, 1, 3) 
     }
	if `var'c1pval`i'  <=0.01 & (`var'c2pval`i' <=0.05 & `var'c2pval`i' >0.01) {
	matrix mstr`var'`i' = (0, 0, 0, 0, 1, 2) 
     }
	 if  `var'c1pval`i'  <=0.01 &  `var'c2pval`i'<=0.01 {
	matrix mstr`var'`i' = (0, 0, 0, 0, 1, 1) 
     }
	 if  `var'c1pval`i'  <=0.01  & `var'c2pval`i'>0.1 {
	matrix mstr`var'`i' = (0, 0, 0, 0, 1, 0) 
     }
	 
	 
	if  `var'c1pval`i'   >0.1 & (`var'c2pval`i'<=0.1  & `var'c2pval`i'>0.05)  {
	matrix mstr`var'`i' = (0, 0, 0, 0, 0, 3) 
     }
	if  `var'c1pval`i'   >0.1 & (`var'c2pval`i' <=0.05 & `var'c2pval`i' >0.01) {
	matrix mstr`var'`i' = (0, 0, 0, 0, 0, 2) 
     }
	 if  `var'c1pval`i'  >0.1 & `var'c2pval`i'<=0.01 {
	matrix mstr`var'`i' = (0, 0, 0, 0, 0, 1) 
     }
	 if `var'c1pval`i'  >0.1 & `var'c2pval`i'>0.1  {
	matrix mstr`var'`i' = (0, 0, 0, 0, 0, 0) 
     }  

matrix list mat`var'`i'


matrix A1`i' = nullmat(A1`i')\ mat`var'`i'\mat1`var'`i'
matrix A1`i'_STARS =  nullmat(A1`i'_STARS)\mstr`var'`i'\mstrhelp`i'

}


local rname ""
foreach var in $cov {
local lbl : variable label `var'
local rname `"  `rname'   "`lbl'" " " "'		
}		





mat A`i'_STARS=A1`i'_STARS\mstrhelp`i'
mat A2`i'=(`tp`i'',`tn`i'',`fp`i'', `fn`i'',.,.)
mat AA`i'=A1`i'\A2`i'




matrix colnames AA`i' = "True positive" "True negative" "False positive" "False negative" "p-value_1" "p-value_2"  

}


forvalues i=1/3 {
foreach var in $cov {
    
reg `var' maizecat3_`i'  [pw=pw_w4]
test maizecat3_`i' =0
scalar `var'c3pval`i'=r(p)


matrix matb`var'`i'  = (`var'c3pval`i') 
matrix mat1b`var'`i' = (.) 



matrix mstrhelp`i'=(0)

if (`var'c3pval`i'<=0.1 & `var'c3pval`i'>0.05)    {
	matrix mstr`var'`i' = ( 3) 
     }

if (`var'c3pval`i'  <=0.05 & `var'c3pval`i'>0.01)    {
	matrix mstr`var'`i' = ( 2) 
}


 if `var'c3pval`i'  <=0.01 {
	matrix mstr`var'`i' = ( 1) 
 }

if `var'c3pval`i'  >0.1  {
	matrix mstr`var'`i' = ( 0) 
     }


matrix list matb`var'`i'


matrix A1b`i' = nullmat(A1b`i')\ matb`var'`i'\mat1b`var'`i'
matrix A1b`i'_STARS =  nullmat(A1b`i'_STARS)\mstr`var'`i'\mstrhelp`i'

}


local rname ""
foreach var in $cov {
local lbl : variable label `var'
local rname `"  `rname'   "`lbl'" " " "'		
}		





mat Ab`i'_STARS=A1b`i'_STARS\mstrhelp`i'
mat A2b`i'=(.)
mat AAb`i'=A1b`i'\A2b`i'




matrix colnames AAb`i' = "p-value_3"  
}


mat C= AA1,AAb1,AA2,AAb2, AA3,AAb3
mat C_STARS= A1_STARS,Ab1_STARS,A2_STARS,Ab2_STARS, A3_STARS,Ab3_STARS




#delimit ;
xml_tab C,  save("$table${slash}ESS4_corr_misclassificationNEW.xml") append sheet("Table 2_Correlates", nogridlines)  ///
rnames(`rname' "Total No. of obs.") cnames(`cnames')
ceq( 
"CG Germplasm" "CG Germplasm" "CG Germplasm" "CG Germplasm" "CG Germplasm" "CG Germplasm" "CG Germplasm"
"CG Germplasm & PP>95%"  "CG Germplasm & PP>95%" "CG Germplasm & PP>95%" "CG Germplasm & PP>95%" "CG Germplasm & PP>95%" "CG Germplasm & PP>95%" "CG Germplasm & PP>95%"
"CG Germplasm & 2010-2020" "CG Germplasm & 2010-2020"  "CG Germplasm & 2010-2020"  "CG Germplasm & 2010-2020"  "CG Germplasm & 2010-2020"  "CG Germplasm & 2010-2020" 
) showeq ///
rblanks(COL_NAMES "Plot level data" S2220)	 /// Adds blank columns which are used to separate Treatment and Control graphically.
title(Table 2: Correlates of misclassification )  font("Times New Roman" 10) ///
cw(0 110, 1 55, 2 55, 3 55, 4 55, 5 55, 6 55, 7 55, 8 55, 9 55, 10 55, 11 55, 12 55, 13 55,  14 55,  15 55, 16 55, 17 55, 18 55, 19 55, 20 55, 21 55, 22 55, 23 55, 24 55, 25 55, 26 55, 27 55, 28 55, 29 55, 30 55, 31 55, 32 55, 33 55, 34 55, 35 55, 36 55, 37 55, 38 55, 39 55, 40 55  ) /// *Adjust the column width of the table, column 0 are the variable names* 1, 5 and 9 are the blank columns. 
	format((SCLR0) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3))  /// * format the columns. Each parentheses represents one column*
	stars(* 0.1 ** 0.05 *** 0.01)  /// Define your star values/signs here (which are stored in B_STARS)
	lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 2)  /// Draws lines in specific format (Numeric Value)
	notes(Point estimates are weighted sample means. Standard errors are reported below. , Stars represent level of statistical significance of t-test/chi-squared test of difference in means.,
	P-value_1= difference btw true(positive&negative) vs. false(positive&negative),
	P-value_2= difference btw True positive vs. False positive,
	P-value_3= difference btw True negative vs. False negative); //Add your notes here
# delimit cr


