/* Econ 488
Updated Project File (extended DiD and Synthetic Control)
Cody Byers
Prof. Denning 
*/


cd "\\Client\C$\Users\codybyers\Documents\Econ 488\Files for Project Paper"

clear all
capture log close
log using log.txt, replace text

import delimited "PaperData.csv"

tsset cityid timeperiod //Sets the data into a workable panel setup

synth housingprice  housingprice(1(1)6) housingprice(7(1)12) housingprice(13(1)18) housingprice(19(1)24) housingprice(25(1)30) housingprice(31(1)36) housingprice(37(1)44) unemployment(1(1)6) unemployment(7(1)12) unemployment(13(1)18) unemployment(19(1)24) unemployment(25(1)30) unemployment(31(1)36) unemployment(37(1)44) earnings(1(1)6) earnings(7(1)12) earnings(13(1)18) earnings(19(1)24) earnings(25(1)30) earnings(31(1)36) earnings(37(1)44), trunit(1) trperiod(45)  keep (synth_results.xlsx) replace fig;
/* Synthesizes a counterfactual on lagged housing prices, lagged unemployment, and
lagged earnings, with the treated unit 1 (New York)  and the treatment period 
as time 45 (August 2011, when New York City banned Airbnb). Keeps the results in
a separate spreadsheet */

graph export "\\Client\C$\Users\codybyers\Documents\Econ 488\Files for Project Paper\SynthComp.png", as(png) name("Graph") replace

use synth_results.xlsx, clear
keep _Y_treated _Y_synthetic _time
drop if _time==.
rename _time timeperiod
rename _Y_treated  treat
rename _Y_synthetic counterfact
gen gap48=treat-counterfact
sort timeperiod
twoway (line gap48 timeperiod,lp(solid)lw(vthin)lcolor(black)), yline(0, lpattern(shortdash) lcolor(black)) xline(1993, lpattern(shortdash) lcolor(black)) xtitle("",si(medsmall)) xlabel(#10) ytitle("Gap in Housing Price", size(medsmall)) legend(off)
graph export "\\Client\C$\Users\codybyers\Documents\Econ 488\Files for Project Paper\SynthGap.png", as(png) name("Graph") replace
/* Gets our synth results into a more intuitive/standardized form and generates
a graph for the difference in housing prices between the synthetic and the actual
*/

clear all
import delimited "PaperData.csv"


local citylist 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17
tsset cityid timeperiod

//Generating the placebo synthetic for each other city (where no treatment occurred)
foreach i of local citylist {
if (`i' <= 17){
 quietly synth housingprice  housingprice(1(1)6) housingprice(7(1)12) housingprice(13(1)18) housingprice(19(1)24) housingprice(25(1)30) housingprice(31(1)36) housingprice(37(1)44) unemployment(1(1)6) unemployment(7(1)12) unemployment(13(1)18) unemployment(19(1)24) unemployment(25(1)30) unemployment(31(1)36) unemployment(37(1)44) earnings(1(1)6) earnings(7(1)12) earnings(13(1)18) earnings(19(1)24) earnings(25(1)30) earnings(31(1)36) earnings(37(1)44), trunit(`i') trperiod(45)  keep (synth_placebos_`i'.xlsx) replace fig;
 }
 }

//Generates the gap in prices between the actual and the synthetic
local citylist 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17
foreach i of local citylist {
 	use synth_placebos_`i'.xlsx , clear
 	keep _Y_treated _Y_synthetic _time
 	drop if _time==.
	rename _time timeperiod
 	rename _Y_treated  treat`i'
 	rename _Y_synthetic counterfact`i'
 	gen gap`i'=treat`i'-counterfact`i'
 	sort timeperiod 
 	save synth_placebos_`i'.xlsx, replace
}


use synth_placebos_1.xlsx, clear
sort timeperiod
save synth_placebos_all.xlsx, replace

//Merges each of our individual placebo results into one sheet
local citylist 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17
foreach i of local citylist {

	merge 1:1 timeperiod using synth_placebos_`i'.xlsx
	drop _merge
	sort timeperiod
	save synth_placebos_all.xlsx, replace

}


//Generatin the prettiest graph in the world
twoway(line gap1 timeperiod, lp(solid) lw(thick) color(black)) (line gap2 timeperiod, lp(solid) lw(vthin)) (line gap3 timeperiod, lp(solid) lw(vthin)) (line gap4 timeperiod, lp(solid) lw(vthin)) (line gap5 timeperiod, lp(solid) lw(vthin)) (line gap6 timeperiod, lp(solid) lw(vthin)) (line gap7 timeperiod, lp(solid) lw(vthin)) (line gap8 timeperiod, lp(solid) lw(vthin)) (line gap9 timeperiod, lp(solid) lw(vthin)) (line gap10 timeperiod, lp(solid) lw(vthin)) (line gap11 timeperiod, lp(solid) lw(vthin)) (line gap12 timeperiod, lp(solid) lw(vthin)) (line gap13 timeperiod, lp(solid) lw(vthin)) (line gap14 timeperiod, lp(solid) lw(vthin)) (line gap15 timeperiod, lp(solid) lw(vthin)) (line gap16 timeperiod, lp(solid) lw(vthin)) (line gap17 timeperiod, lp(solid) lw(vthin)), yline(0, lpattern(shortdash) lw(vthin)) xline(45, lpattern(shortdash) lcolor(black)) ytitle("Gap in Predicted Housing Prices", size(small)) legend(off)

graph export  "\\Client\C$\Users\codybyers\Documents\Econ 488\Files for Project Paper\SynthPlaceboInference.png", as(png) name("Graph") replace

clear all
import delimited "PaperData.csv"

//Difference in Differences estimates 
gen interact = treated*postair

reg housingprice interact, robust
estimates store m1, title(Basic Regression)

reg housingprice interact i.cityid, vce(cluster cityid)
estimates store m2, title (City Fixed Effects)

reg housingprice interact i.cityid i.year, vce(cluster cityid)
estimates store m3, title (Year Fixed Effects)

reg housingprice interact unemployment i.cityid i.year, vce(cluster cityid)
estimates store m4, title (With Unemployment)

reg housingprice interact unemployment earnings i.cityid i.year, vce(cluster cityid)
estimates store m5, title (With Unemployment and Earnings)

estout m1 m2 m3 m4 m5, cells (b(star fmt(3)) se (par fmt(2))) legend label varlabels (_cons constant) stats (r2 df_r, fmt (3 0 1) label (R-Squared Degrees_of_Freedom))

log close
