*******************************************************************************
*******************************************************************************
* Part 4

** Local Variable
local a=3
local b=5
disp `a'+`b'

local name1 "apple"
local name2 "samsung"
disp `"name1"' 
disp `"name2"'

** Loop
forv i=1/10{
disp "haha `i'"
}

foreach i in a b d e {
disp "haha `i'"
}

clear
set obs 10
foreach i of numlist 1 2 4 5{
gen x`i'=`i'
gen y`i'="`i'"
}
foreach j of varlist x1-y4{
replace `j'=`j'*10
} // 얘는 왼쪽에서부터 순서대로 varlist에 넣는듯

*******************************************************************************
cd "C:\Users\twter\Google Drive\Graduate\코스웍\2020 최재성 노동경제학2\stata\data"
dir
use es_list_seoul_2012, clear

* append 하기 편하게 연도별로 만들어버림
foreach i of varlist edu_admin-n_classroom {
rename `i' `i'_2012
}

use es_list_seoul_2012, replace
forv i=1/6{
gen n_boy`i'=n_stu`i'-n_girl`i'
order n_boy`i', after(n_girl`i')
}

local list n_tea n_clerk
foreach i of local list {
gen `i'_m = `i'-`i'_f
order `i'_m, after(`i'_f)
}

*******************************************************************************
*******************************************************************************
********** Part 5 labeling, delimit
cd "C:\Users\twter\Google Drive\Graduate\코스웍\2020 최재성 노동경제학2\stata\data"
dir

use coed_ex, clear
label define gender_def 1 "Boy" 2 "Girl"
label values gender gender_def // define 한걸 적용하는 것, 파란글씨는 str 처럼보이는데 숫자가 들어가 있음
label list
tab gender
tab gender, nolabel
tab schtype if gender==1
// tab schtype if gender=="Boy" //ERROR

use coed_ex
replace schtype = "1" if schtype=="남학교"
replace schtype = "2" if schtype=="여학교"
replace schtype = "3" if schtype=="남여공학"
destring schtype, replace

label define schtype 1 "B" 2 "G" 3 "Co"
label values schtype schtype

recode schtype(1 2 = 1)(3 = 0), gen(d_sss)  //더미들 끼리 묶고 풀고, 재정의해서 새로운 변수 만들기


cd "C:\Users\twter\Google Drive\Graduate\코스웍\2020 최재성 노동경제학2\stata\data"
dir

use pt_survey_2015_ex, clear
d,s

rename c1 region_size
label define region_size 1 "seoul" 2 "metro" 3 "urban" 4 "rural"
label list
label values region_size region_size
tab region_size
tab region_size c2

*******************************************************************************
// 엄청 outcome 많은 dummy 있을때 편한 방법
// delimit 은 '///' 랑 비슷하게 쓸 수 있음
rename c2 region
#delimit ;
label define region
11 "seoul"
21 "busan"
22 "daegu"

39 "jeju"
;
#delimit clear // cr = clear, delimit 끝내줘야함!
label values region region
label list

*******************************************************************************
cd "C:\Users\twter\Google Drive\Graduate\코스웍\2020 최재성 노동경제학2\stata\data"
dir

use es_list_seoul_2012, replace

sort school_name
keep school_name n_class? n_stu?

reshape long n_class n_stu, i(school_name) j(grade) // 경기초 obs를 6개씩 만들어서 행별로 학년이 들어가게
reshape wide n_class n_stu, i(school_name) j(grade) // 경기초 1 obs, 학년별로 6 column 만들기 (원본으로)


*******************************************************************************
*******************************************************************************
********** Part 6 append merge
cd "C:\Users\twter\Google Drive\Graduate\코스웍\2020 최재성 노동경제학2\stata\data"
dir

****** Append
local list 2011 2012
foreach i of local list {
use es_list_seoul_`i', replace
gen year=`i'
save es_list_seoul_`i'_append, replace
}
// or forv i = 2008/2012 { }

use es_list_seoul_2011_append, replace
append using es_list_seoul_2012_append
tab year
tab district year
save es_list_seoul_appended, replace

***** Merge
// 1:1 if unique key
// n:1 master 에 여러개 있을 때 (house 밑에 여러 individual)
// 1:n master 에 key 하나씩만 있을 때

use individual, clear
merge n:1 hhid using house

use house, clear
merge 1:n hhid using individual, gen(result1) // _merge 대신에 result1 이 생김, 
// 여러개 merge 할때 result`i' 로 하면 될듯

set more off // 페에지 다 차도 계속 진행하라

forv i=2008/2012{
	use es_list_seoul_`i', replace
	foreach j of varlist n_class1-n_classroom {
		rename `j' `j'_`i'
		}
	save es_list_seoul_`i'_merge, replace
}

use es_list_seoul_2008_merge, replace
forv i=2009/2012{
	merge 1:1 district school_name using es_list_seoul_`i'_merge, gen(_merge_`i')
	tab _merge_`i'
}

list school_name if _merge_2010~=3 // 왜 merge가 안됐는지 확인해야 됨

********************************************************************************
********** rowmean, rowtotal helpful in cases with missing values
clear
set obs 5 
gen x=1
gen y=2
gen z=3
replace x=. in 3

gen total=x+y+z
egen rowtot=rowtotal(x y z)
egen rowtot2=rowtotal(x y z), missing // 같은 결과가 나오네

gen mean = (x+y+z)/3
egen rowmean = rowmean(x y z)

* concat
clear
set obs 2
gen x=1
gen y=2
egen xy=concat(x y) // string으로 띄어쓰기 없이 묶어 줌
egen xy2=concat(x y), p(_) // _를 사이에 두고 붙여줌
egen xy3=concat(x y), p(" ")

* cumulative sum
clear
set obs 4
gen x=1
replace x=2 in 2
replace x=. in 3
replace x=4 in 4

gen y = sum(x)  // running sum of x for each row : cumulative sum 
egen z = total(x) // total sum of x in each row

* cut
clear
set obs 100
gen x=_n
egen group=cut(x), group(4)
tab group

egen group2 = cut(x), at (0,20,50,80,101)
tab group2

***************
* std : standardization
clear
set obs 100
gen x = runiform()  //uniform distn 에서 random sample
gen x100 = x*100
egen x_std = std(x) // std 1
su x_std, de
gen y = 10*x_std + 50 // mean 50 , std 10
hist y
su
********************************************************************************
********************************************************************************
********** Part 7 egen
* return list
cd "C:\Users\twter\Google Drive\Graduate\코스웍\2020 최재성 노동경제학2\stata\data"
dir

use bsgkorm5, replace

egen math=rowmean(bsmmat0?)

su math
return list

disp r(mean)

* normalize sd = 1
gen math_std1 = (math-r(mean))/r(sd)
egen math_std2 = std(math)

su math_std1 math_std2, de

* drop top 1% low 1% : outliers
use bsgkorm5, replace
su bsmmat01, d

drop if bsmmat01<r(p1) | bsmmat01>r(p99)
su bsmmat01, d

***** ereturn list : estimate result return
clear
sysuse auto

reg price mpg weight length

ereturn list
disp e(r2)

* coef
mat list e(b)
disp _b[_cons]

* var-cov matrix
mat list e(V)
mat cov=e(V)

mat e1 = cov[2,2]
mat list e1

mat e2 = cov[1..4,1]
mat list e2
********************************************************************************
********************************************************************************
**** Part 8 String Variable Manipulation

help string_functions

disp length("ab") // number of letters : 2
disp length("스태타") // number of letters : 9
disp wordcount("hello world") // number of words : 2

disp trim(" hello world ") 
set obs 1
gen x=" trim "
gen y=trim(" trim ")

// upper("") lower("") uppercase lowercase

set obs 1
gen s = "성 균 관 대"
split s

gen addr="서울,마포,마포구"
split addr, p(,)

********************* string position
* strpos(s1, s2)
disp strpos("this", "is") // is 가 등장하는 위치 3
disp strpos("this", "it") // it 는 없으니 0

* substr
disp substr("abceds",3,2) // ce : 세번째부터 두개, 음수도 가능

* subinstr 
disp subinstr("this is this", "is", "X",.) // thX X thX : . : 모두 찾아서 바꿔
disp subinstr("this is this", "is", "X",2) // thX X this : 두개만

********************************************************************************
********************************************************************************
**** Part 9 Regular Expression
disp regexm("this", "is")  // match:1 : "is" is in "this"

sysuse auto
list make if regexm(make, "^B")==1 // lists if obs start with "B"
list make if regexm(make, "[0-9][0-9][0-9]$")==1 // lists is obs end with 3 numbers

disp regexr("중앙대학교부속고등학교", "대학교", "대") //중앙대부속고등학교 : 원문에서 대학교를 대로 바꿈

gen make2 = make
replace make2 = regexr(make2, "^B.*[0-9][0-9][0-9][a-z]$", "found") // change obs name to found
list make make2 if make != make2 // find

clear
set obs 3 
gen number=""
replace number = "(123) 456-2342" in 1
replace number = "(234) 413-2534" in 2
replace number = "(800) ARRJSK" in 3
gen str newnum = regexs(1) + "-" + regexs(2) if regexm(number, "^\(([0-9]+)\) (.*)") 
// "\(" serves as physical parentheses
// + 한번 이상 등장
gen str newnum2 = regexs(1) + regexs(2) + regexs(3) if regexm(newnum, "(^[0-9]+)-([0-9]+)-([0-9]+)")

********************************************************************************
********************************************************************************
**** Part 10 regression result 내보내기 
* ssc install estout
* ssc install outreg2
* ssc install xml_tab

clear
sysuse auto
eststo clear

reg price mpg
eststo m1
reg price mpg weight
eststo m2
reg price mpg weight length
eststo m3
reg price mpg weight length foreign
eststo m4

est table *
est table *, b(%9.2f) star(.1 .05 .01) stats(N r2)

xml_tab *, ///
stats(N r2) ///
save(table.xml) sh(t1) /// 
replace below nolabel 
* 마지막에 replace 대신 append 로 하면 추가됨 sh(sheet) 바꿔서 하면 좋을 듯
* below 말고 다른거 하면 standard error 딴데다 넣을 수 있음

reg price mpg
outreg using table2.xls, replace
rep price mpg weight
outreg using table2.xls, append

* can use either eststo + xml_tab or outreg

********** Summary Statistics
eststo clear

// fmt : 소숫점자리
estpost sum price mpg weight length // summarize
esttab using summary.csv, cells("count(fmt(0)) mean(fmt(1)) sd(fmt(2)) min(fmt(3))") ///
nomtitle nonumber replace

eststo 
bys foreign : estpost sum price mpg weight length
esttab using summary.csv, cells("count(fmt(0)) mean(fmt(1)) sd(fmt(2)) min(fmt(3))") ///
nomtitle nonumber append

********** Tabulation
eststo clear
forv i=0/1 {
eststo: estpost tab rep78 if foreign==`i'
}
esttab using summary.csv, cells(b(fmt(0)) pct(fmt(1))) append

********************************************************************************
********************************************************************************
**** Part 11 Graphs
webuse nlswork, clear

hist age, frac bin(20)
hist age, frac width(2)

graph pie, over(race) plabel(_all percent, format(%9.1f))

collapse msp, by (year)
tw scatter msp year
tw connected msp year

clear
cd "C:\Users\twter\Google Drive\Graduate\코스웍\2020 최재성 노동경제학2\stata\data"
use census_2010_edu_dist_analysis, clear

egen n_above_uv_grad = rowtotal(uv_grad ma phd)
gen p_above_uv_grad = n_above_uv_grad/n_pop

tw (sc n_above_uv_grad age if gender==0) (sc n_above_uv_grad age if gender==1)
tw (connected n_above_uv_grad age if gender==0, msymbol(O)) ///
	(connected n_above_uv_grad age if gender==1, msymbol(Oh)) ///
	, legend(label(1 Female) label(2 Male))

tw (function y=x^3, range(-4 2)) ///
	(function y=0, range(-4 2)) 
	

********** Extra
* preserve restore
clear
cd "C:\Users\twter\Google Drive\Graduate\코스웍\2020 최재성 노동경제학2\stata\data"
use census_2010_edu_dist_analysis, clear
preserve
drop if gender==1
restore // 다시 원래 dataset으로 복구

renvars  _all, lowcase
destring _all, ignore(",") replace
