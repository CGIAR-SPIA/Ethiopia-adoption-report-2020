clear all
clear matrix
capture log close
set more off

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

* 0. PRELIMINARIES

* a. General Directories
*global drive     "C:\Users\Marcelo\Desktop\ETH_report\replication_files" // original drive
// global dir "/Users/sisalzer/Library/CloudStorage/Box-Box/SPIA/Country Studies/Country Studies - Ethiopia v1/replication_files" // sihs computer lab dir
// global dir "/Users/sophiasalzer/Library/CloudStorage/Box-Box/SPIA/Country Studies/Country Studies - Ethiopia v1/replication_files" // sihs laptop dir
global dir "" // GitHub dir

* b. automatic slash detection - adedd by SIHS, 7/16/2025

if c(os) == "Windows" {
    global slash "\"
}
else {
    global slash "/"
}

adopath +        "${dir}${slash}1_ado" 											
global do        "$dir${slash}1_do_files"
global rawdata   "$dir${slash}2_raw_data"
global data      "$dir${slash}3_report_data" 
global table     "$dir${slash}4_table"

* c. Raw data 
global raw1    "${rawdata}${slash}ESS1_2011-12${slash}Data${slash}STATA"
global raw2    "${rawdata}${slash}ESS2_2013-14${slash}Data${slash}STATA"
global raw3    "${rawdata}${slash}ESS3_2015-16${slash}Data${slash}STATA"
global raw3b   "${rawdata}${slash}ESS3_2015-16${slash}Data${slash}"
global raw4    "${rawdata}${slash}ESS4_2018-19${slash}Data"
global raw4b   "${rawdata}${slash}ESS4_2018-19"
global raw4new "${rawdata}${slash}ESS4_2018-19${slash}Data_new"
global temp    "${rawdata}${slash}temp" 

* d. Covariates Raw Data
global cov3plot "${rawdata}${slash}Covariates${slash}HH_ AND_PLOT_2015${slash}Plot_level_data_2015"
global cov3hh   "${rawdata}${slash}Covariates${slash}HH_ AND_PLOT_2015${slash}HH_level_data_2015"
global cov3com  "${rawdata}${slash}Covariates${slash}community_and do file${slash}Community_level_data_2015"
global cov4plot "${rawdata}${slash}Covariates${slash}plot_hh_level_2018${slash}Plot_level_data_2018"
global cov4hh   "${rawdata}${slash}Covariates${slash}plot_hh_level_2018${slash}HH_level_data_2018"
global cov4com  "${rawdata}${slash}Covariates${slash}community and do file_2018${slash}Community_level_data_2018"

* d. Installation of packages
ssc install xml_tab, replace
ssc install winsor2, replace
ssc install fre, replace

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* 1. VARIABLES AND DATABASES CONSTRUCTION
* a. Identifying CGIAR-related innovations

do "${do}${slash}02_Community_CG_innovations"    // Using new ESS4 data // SIHS NOTE: error in this line (see comment below)
	* SIHS NOTE: the line above calls on the datafile 2_Community_CG_innovations. 
	* This file references the non-existant folder "Data_new"...
	* I believe the folder referenced should be "Data"
		* folder in path in 2_raw_data > ESS4_2018-19 > Data
		* contains the folder referenced next, "COMMUNITY"...
	* I copied the folder Data in 2_raw_data > ESS4_2018-19 and renamed the copy "Data_new"

	
do "${do}${slash}03_PP_CG_innovation_ess4"       // POST-PLANTING survey - ESS4 (new data)


do "${do}${slash}04_PP_CG_innovation_ess3"       // POST-PLANTING survey - ESS3 

do "${do}${slash}05_psnp"                        // PSNP program 

do "${do}${slash}06_DNA_ess4"                    // Crop germplasm improvement using DNA- fingerprinting data   
	* SIHS NOTE: file name reference problem in 6_DNA_ess4.do: 
		* 6_DNA_ess4.do calls upon sect9a_ph_w4.dta. 
		* This file does not exist in the file path 
			* sect9a_pp_w4.dta exists in the file path
			* sect9_ph_w4.dta exists in a different folder. NOTE: "9", not "9a"
		* I believe that sect9a_pp_w4.dta is the correct file, but I could be wrong. 
		* I changed the script to call upon the correct file (i.e. changed "_ph" -> "_pp")
	* SIHS NOTE: some obsolete variable references, recoded those lines
	* SIHS NOTE: some incorrectly named variables called, recoded those lines

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
	* sihs notes
		* obsolete command `c()` 
			* `c()` i.e. `contents()` called on, but not available for stata 17+:
			* replaced with current workaround: `statistics()`
		* missing package installs
			* `fre` and `winsor2` called on, but these are not (or are no longer?) part of base stata pkg
		* added installations for `fre` and `winsor2` to master.do (this file) in installations section
		
		
do "${do}${slash}ESS4_2018_dofile_public" 

do "${do}${slash}10_Covariates_ess3"  
	* sihs notes
		* abandoned merge line left as comment by author:
			* `* merge 1:1 household_id2 using "${raw3}\\sect_cover_hh_w3"`
			* author left this line in the file as a comment
			* unclear to me if I should use the merge or not
			* another merge using "HH_LEVEL_DATA_2015_relab.dta" follows the commented line 
				* (this subsequent merge is not commented out)
		* several lines missing `${slash}` globals (probably my own doing)
			* commented out these lines, replaced with lines with `${slash}`   
                                             
do "${do}${slash}11_Covariates_ess4"													

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* 4. TABLES CHARACTERISTICS OF HOUSEHOLD, PLOT AND EA LEVEL COVARIATES 
do "${do}${slash}12_Tables_hh_plot_ea_characteristics_ess3"
do "${do}${slash}13_Tables_hh_plot_ea_characteristics_ess4"

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* 5. TABLES - CORRELATES OF ADOPTION 
do "${do}${slash}14_Who are the adopters of the innovations_ESS4" 
* sihs note: 
	* run time for this file is quite long. be prepared for stata to be occupied 25+ minutes
	
do "${do}${slash}15_Who are the adopters of the innovations_ESS3"                   

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* 6. TABLES - SYNERGIES BETWEEN INNOVATIONS
do "${do}${slash}16_Synergies"                                                        
do "${do}${slash}17_Synergies_DNA"														

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* 7. CORRELATES OF CROP VARIETAL MISCLASSIFICATION
do "${do}${slash}18_Correlates of misclassification"									

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* 8. CGIAR REACH IN ABSOLUTE NUMBERS  
do "${do}${slash}19_CG reach in absolute numbers"

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

********************************************************************************
