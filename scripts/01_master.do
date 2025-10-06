********************************************************************************
*                           Ethiopia Synthesis Report 
*                                MASTER DO-FILE
* Country: Ethiopia 
* Data: ESS 3 and ESS 4 
* Author: Paola Mallia | p.mallia@cgiar.org | paola_mallia@ymail.com 
* STATA Version: SE 16.1

/*================================ PROGRAM =====================================
This do file contains the necessary codes to replicate the SPIA Synthesis Report 
Shining a Brighter Light: 
Comprehensive Evidence on Adoption and Diffusion of CGIAR-Related Innovations in 
Ethiopia

Input files:  -  ESS1_2011-12
			  -  ESS2_2013-14
			  -  ESS3_2015-16
			  -  ESS4_2018-19

Output files: -  Adopters characteristics.xml
              -  Adopters characteristics_v2.xml
			  -  ESS_innovation overlap_DNANEW.xml
			  -  ESS_innovation overlapNEW.xml
			  -  ESS3_ABSNUMBERBEN.xml
			  -  ESS3_Characteristics.xml
			  -  ESS4_ABSNUMBERBEN.xml
			  -  ESS4_Characteristics.xml
			  -  ESS4_corr_misclasificationNEW.xml
			  -  ESS4_Individual_livestock
			  -  Sec6_ESS3.xml 
			  -  Sec6_ESS4.xml
			  -  Table13.xml
			  -  Table14.xml
			  
=========================== STRUCTURE OF THE CODE =============================
0. PRELIMINARIES
	a. General Directories	
	b. Raw data
	c. Covariates Raw Data
	d. Installation of packages
1. VARIABLES AND DATABASES CONSTRUCTION 
	a. Identifying CGIAR-related innovations
2. TABLES - NATIONAL AND REGIONAL ADOPTION RATES
3. COVARIATES CONSTRUCTION AND MERGING
	a. Covariates construction
	b. Covariates construction and merging - Household, plot and community level 
	   characteristics 
4. TABLES CHARACTERISTICS OF HOUSEHOLD, PLOT AND EA LEVEL COVARIATES
5. TABLES - CORRELATES OF ADOPTION 
6. TABLES - SYNERGIES BETWEEN INNOVATIONS
7. CORRELATES OF CROP VARIETAL MISCLASSIFICATION
8. CGIAR REACH IN ABSOLUTE NUMBERS
=============================================================================*/

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

clear all
clear matrix
capture log close
set more off

* 0. PRELIMINARIES

* a. General Directories

cd "/Users/sophiasalzer/Documents/Ethiopia-adoption-report-2020" // parent directory
// for GitHub use if in "scripts", see below:
	* cd ".."` // cd up one level (i.e. Ethiopia-adoption-report-2020 <- scripts)

global dir "`c(pwd)'" // set directory global, "dir"

* b. automatic slash detection
if c(os) == "Windows" {
    global slash "\"
}
else {
    global slash "/"
}

* c. define globals to sub folders

* stata: ado and do files
adopath + "${dir}${slash}ado"				// contains ado files
global do "${dir}${slash}scripts"			// conains scripts (.do and .R)
* data: main and sub directories
global bigdata "${dir}${slash}data"			// contains data subfolders
global rawdata "${bigdata}${slash}raw_data"	// contains raw data subfolder
global data "${bigdata}${slash}report_data"	// contains report data subfolder

* subfolders in raw data subfolder 
global raw3    "${rawdata}${slash}ESS3_2015-16${slash}Data${slash}STATA" 
global raw4    "${rawdata}${slash}ESS4_2018-19${slash}Data" 
global raw4new "${rawdata}${slash}ESS4_2018-19${slash}Data_new" 
global temp    "${rawdata}${slash}temp" 

* obsolete subfolders in raw data subfolder: 
// global raw1    "${rawdata}${slash}ESS1_2011-12${slash}Data${slash}STATA" 
// global raw2    "${rawdata}${slash}ESS2_2013-14${slash}Data${slash}STATA" 
// global raw3b   "${rawdata}${slash}ESS3_2015-16${slash}Data${slash}" 
// global raw4b   "${rawdata}${slash}ESS4_2018-19" 

* results folder
global output "${dir}${slash}outputs" // outputs folder (contains tabs & figs)
global table "${output}${slash}tables"	// tables subfolder // use for final master.do and for 04 OG check
global figure "${output}${slash}figures" // figures subfolder

* d. covariates (in raw data subfolder)
global cov3plot "${rawdata}${slash}Covariates${slash}HH_AND_PLOT_2015${slash}Plot_level_data_2015"
global cov3hh   "${rawdata}${slash}Covariates${slash}HH_AND_PLOT_2015${slash}HH_level_data_2015"
global cov3com  "${rawdata}${slash}Covariates${slash}community_and_do_file${slash}Community_level_data_2015"
global cov4plot "${rawdata}${slash}Covariates${slash}plot_hh_level_2018${slash}Plot_level_data_2018"
global cov4hh   "${rawdata}${slash}Covariates${slash}plot_hh_level_2018${slash}HH_level_data_2018"
global cov4com  "${rawdata}${slash}Covariates${slash}community_and_do_file_2018${slash}Community_level_data_2018"

* e. installation of packages
ssc install xml_tab, replace
ssc install winsor2, replace
ssc install fre, replace

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* 1. VARIABLES AND DATABASES CONSTRUCTION
* a. Identifying CGIAR-related innovations

do "${do}${slash}02_Community_CG_innovations"    // Using new ESS4 data
	
do "${do}${slash}03_PP_CG_innovation_ess4"       // POST-PLANTING survey - ESS4 (new data)

do "${do}${slash}04_PP_CG_innovation_ess3"       // POST-PLANTING survey - ESS3 

do "${do}${slash}05_psnp"                        // PSNP program 

do "${do}${slash}06_DNA_ess4"                    // Crop germplasm improvement using DNA- fingerprinting data   

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*2. TABLES - NATIONAL AND REGIONAL ADOPTION RATES
do "${do}${slash}07_National and regional adoption rates_ess3" 

do "${do}${slash}08_National and regional adoption rates_ess4"   
 
do "${do}${slash}08a_National and regional urban livestock adoption rates_ess4" 

do "${do}${slash}09_Misclassification_new"										

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* 3. COVARIATES CONSTRUCTION AND MERGING
* a. Covariates construction
do "${do}${slash}ESS_2015_dofile_public"
		
do "${do}${slash}ESS4_2018_dofile_public" 

do "${do}${slash}10_Covariates_ess3"    
                                             
do "${do}${slash}11_Covariates_ess4"													

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* 4. TABLES CHARACTERISTICS OF HOUSEHOLD, PLOT AND EA LEVEL COVARIATES 

do "${do}${slash}12_Tables_hh_plot_ea_characteristics_ess3"

do "${do}${slash}13_Tables_hh_plot_ea_characteristics_ess4"

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* 5. TABLES - CORRELATES OF ADOPTION 
do "${do}${slash}14_Who are the adopters of the innovations_ESS4" // note: expect long run time
	
do "${do}${slash}15_Who are the adopters of the innovations_ESS3" // note: expect long run time

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* 6. TABLES - SYNERGIES BETWEEN INNOVATIONS
do "${do}${slash}16_Synergies" // note: expect long run time

do "${do}${slash}17_Synergies_DNA"

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* 7. CORRELATES OF CROP VARIETAL MISCLASSIFICATION
do "${do}${slash}18_Correlates of misclassification"									

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* 8. CGIAR REACH IN ABSOLUTE NUMBERS  
do "${do}${slash}19_CG reach in absolute numbers"

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

********************************************************************************
