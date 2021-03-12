/* Project: Investigate SSA office closures and consolidate zip codes of offices
that have closed.
Cody Byers
Professor: Emily Leslie
Appropriate Accompanying Playlist: Power Metal
*/


clear all
global input_data I:ssa/office_closures/input_data
global intermediate_data I:ssa/office_closures/intermediate_data
global output I:/ssa/office_closures/output


//Making variable names the same, and transferring to .dta files

local states AK AL AR CA CO CT FL GA IA IL KS KY LA MA ME MI MO MS NC ND NE NJ NY OH OK OR PA SC SD TN TX VA WA
quietly foreach state of local states{
	import delimited $input_data/`state'/`state'_tract_evictions.csv, asdouble stringcols(1) clear 
	rename geoid tract
	save $input_data/`state'/`state'_tract_evictions.dta, replace 
}
//creating the master evictions sheet
use $input_data/AK/AK_tract_evictions, clear
local states AL AR CA CO CT FL GA IA IL KS KY LA MA ME MI MO MS NC ND NE NJ NY OH OK OR PA SC SD TN TX VA WA
quietly foreach state of local states{
	append using $input_data/`state'/`state'_tract_evictions.dta
}
save $input_data/allstates_tract_evictions.dta, replace 

import delimited $input_data/field-office-listing-2016.csv, clear

//Figuring out which offices closed, where, and when
gen closuredate = date(closedateifapplicable, "MD20Y")
keep zipcode closuredate
format closuredate %td
drop if closuredate == .
gen closure_year = year(closuredate)

//Figuring out which adjacent zips were affected
merge 1:m zipcode using $input_data/zip_adjacency.dta
drop _merge
drop if closuredate == . 
sort zipcode

//save $intermediate_data/closed_zips.dta, replace 

//Preserving zeroes in front of codes
replace zipcode = zipcode/100000

//Figuring out which tracts are in which zip
merge m:m zipcode using $input_data/zip-tract-info.dta

gen tract = TRACT
drop if _m != 3
drop _m 
sort tract RES_RATIO
bys tract: keep if _n==1
sort tract 

/*keep tract
duplicates drop
sort tract

save $intermediate_data/closed_tracts*/

keep zipcode closuredate tract


//Merging with evictions data
merge m:m tract using $input_data/allstates_tract_evictions.dta
drop if _m != 3
drop _m
sort tract year
replace zipcode = zipcode*100000
save $output/closure_tract_evictions.dta, replace
