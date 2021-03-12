
global clean_data C:\Users\byersc\Box\Evictions/ssdi/clean_data

 use $clean_data/closure_tract_evictions.dta, clear

gen treatmentyear = year(closuredate)

gen treated = .


replace treated = 1 if year >= treatmentyear

replace treated = 0 if treated == .

gen dif = year - treatmentyear

gen negchecker = "."

//Since a negative sign can't be in a variable name, we have to change them to words
local negs -1 -2 -3 -4 -5 -6 -7 -8 -9 -10 -11 -12 -13 -14
local i = 1
foreach neg of local negs{
	replace negchecker = "neg`i'" if dif == `neg'
	local ++i
}

//Generating negative period variables
local differences neg14 neg13 neg12 neg11 neg10 neg9 neg8 neg7 neg6 neg5 neg4 neg3 neg2 neg1
foreach diff of local differences{
	gen treat`diff' = .
	replace treat`diff' = 1 if negchecker == "`diff'"
	replace treat`diff' = 0 if treat`diff' == .
	
}

//generating positive period varables
local differences 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16
foreach diff of local differences{
	gen treat`diff' = .
	replace treat`diff' = 1 if dif == `diff'
	replace treat`diff' = 0 if treat`diff' == .
}

//generating the treatment time variable (for the visual)
gen treat0 = 0

reg evictionrate treatneg14 treatneg13 treatneg12 treatneg11 treatneg10 treatneg9 treatneg8 treatneg7 treatneg6 treatneg5 treatneg4 treatneg3 treatneg2 treatneg1 treat0 treat1 treat2 treat3 treat4 treat5 treat6 treat7 treat8 treat9 treat10 treat11 treat12 treat13 treat14 treat15 treat16

coefplot, yline(0) omit vertical rename(treatneg14 = "-14" treatneg13 = "-13" treatneg12 = "-12" treatneg11 = "-11" treatneg10 = "-10" treatneg9 = "-9" treatneg8 = "-8" treatneg7 = "-7" treatneg6 = "-6" treatneg5 = "-5" treatneg4 = "-4" treatneg3 = "-3" treatneg2 = "-2" treatneg1 = "-1" treat0 = "0" treat1 = "1" treat2 = "2" treat3 = "3" treat4 ="4" treat5 = "5" treat6 = "6" treat7 = "7" treat8 = "8" treat9 = "9" treat10 = "10" treat11 = "11" treat12 = "12" treat13 = "13" treat14 = "14" treat15 = "15" treat16 = "16")

reg evictions treatneg14 treatneg13 treatneg12 treatneg11 treatneg10 treatneg9 treatneg8 treatneg7 treatneg6 treatneg5 treatneg4 treatneg3 treatneg2 treatneg1 treat0 treat1 treat2 treat3 treat4 treat5 treat6 treat7 treat8 treat9 treat10 treat11 treat12 treat13 treat14 treat15 treat16

coefplot, yline(0) omit vertical rename(treatneg14 = "-14" treatneg13 = "-13" treatneg12 = "-12" treatneg11 = "-11" treatneg10 = "-10" treatneg9 = "-9" treatneg8 = "-8" treatneg7 = "-7" treatneg6 = "-6" treatneg5 = "-5" treatneg4 = "-4" treatneg3 = "-3" treatneg2 = "-2" treatneg1 = "-1" treat0 = "0" treat1 = "1" treat2 = "2" treat3 = "3" treat4 ="4" treat5 = "5" treat6 = "6" treat7 = "7" treat8 = "8" treat9 = "9" treat10 = "10" treat11 = "11" treat12 = "12" treat13 = "13" treat14 = "14" treat15 = "15" treat16 = "16")
