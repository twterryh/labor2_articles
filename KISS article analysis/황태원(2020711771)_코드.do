cd "C:\Users\twter\Google Drive\Graduate\코스웍\2020 최재성 노동경제학2\kiss analysis"
dir
forv i=2011/2015 {
import delim list_`i'.csv, encoding(CP949) clear
save list_`i', replace
}
use list_2011, clear
forv i=2012/2015{
append using list_`i'
}
rename 발행년도 year
order year no
save total, replace

********************************************************************************
********** 1. Total # of articles
use total, clear

count 
* ans) 203

********** 2. # of articles per year, plot w connected line
use total, clear

collapse (max) no, by(year)
* ans) 48, 33, 26, 42, 34
tw connected no year

********** 3. generate variable w total # of pages for each article, find mean and s.d.
use total, clear

gen start = regexs(1) if regexm(페이지, "(^[0-9]+ )~( [0-9]+$)")
gen end = regexs(2) if regexm(페이지, "(^[0-9]+ )~( [0-9]+$)")
destring start end, replace

gen pages = end-start+1
su pages
disp r(mean) 	// 27.384236
disp r(sd)		// 4.9910958

********** 4. generate variable w # of authors for each article, plot histogram
use total, clear

rename 저자명 authors
keep authors
replace authors = "박은주 ( Eun Joo Park )" in 152
replace authors = "한정림 ( Jeong Lim Han ) , 우해봉 ( Hae Bong Woo )" in 160

gen auth_no = length(authors) - length(subinstr(authors, ",", "", .)) +1
hist auth_no

********** 5. find who wrote the most articles
use total, clear

rename 저자명 authors
keep authors
replace authors = "박은주 ( Eun Joo Park )" in 152
replace authors = "한정림 ( Jeong Lim Han ) , 우해봉 ( Hae Bong Woo )" in 160

split authors, p(" , ")
keep authors authors1-authors7
order authors1-authors7
save temp_total, replace

forv i=1/7{
use temp_total, clear
keep authors`i'
drop if authors`i'==""
rename authors`i' auth
save temp`i', replace
}

use temp1, clear
forv i=2/7{
append using temp`i'
}

bysort auth: gen count=_n
collapse (max) count, by(auth) 
gsort -count
* ans) 김진수, 10회 (영문명 띄어쓰기가 다른 경우, 다른 사람으로 판단함.)

********** 6-1. find how many articles include '빈곤' in its title
use total, clear
keep 논문명
rename 논문명 title

gen name1 = regexm(title, "빈곤")
tab name1 // 9 articles

********** 6-2. find how many articles include '복지' in its title
gen name2 = regexm(title, "복지")
tab name2 // 31 articles

********** 6-3. find how many articles include both in its title
gen count = name1 + name2
tab count // 0 articles

