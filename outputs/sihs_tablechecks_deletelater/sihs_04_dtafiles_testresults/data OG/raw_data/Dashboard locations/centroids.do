import excel "C:\Users\paola\Dropbox (Personal)\SPIA\2_Country work\2_Ethiopia\ESS\Dashboard locations\Dashboard_locations_1June2020", sheet("Sheet1") firstrow clear


rename Locationregion regions
rename Locationzone zone
rename Locationworeda woreda

foreach i in regions zone woreda {
replace `i'=upper(`i')
}

g N=_n
replace regions="SOUTHERN NATIONS, NATIONALITIES AND PEOPLES" if regions=="SNNP"
drop if woreda==""
tempfile dash
save `dash'


use "C:\Users\paola\Dropbox (SPIA)\DSM_woredas\Maps\2_dta\Woreda_names_shapefile", clear
rename dsmworedas woreda
tempfile shape
save `shape'

use `dash', clear

reclink2 regions zone woreda using `shape', gen(myscore) idm(N) idu(id) wmatch(15 15 15) required(regions) 
*merge m:1 regions zone woreda using `shape'


*export excel using "C:\Users\paola\Dropbox (Personal)\SPIA\2_Country work\2_Ethiopia\ESS\Dashboard locations\checks_1June2020.xls", firstrow(variables) replace
drop _m
tempfile allproj
save `allproj'
keep CGinovation Project Timeframe DataSource regions Uregions zone Uzone woreda Uworeda id
duplicates drop id, force
tempfile match
save `match'



cd       "C:\Users\paola\Dropbox (SPIA)\DSM_woredas\Maps\3_layer\gadm36_ETH_shp\layer3"

shp2dta using "gadm36_ETH_3", database(phdbADM3_2019) coordinates(phxyADM3_2019) genid(id) gencentroids(c) replace

use phdbADM3_2019, clear
merge 1:1 id using `match'
keep if _m==3
drop _m

merge 1:m id using `allproj'
order CGinovation Project Timeframe  DataSource regions zone woreda x_c y_c
sort CGinovation Project