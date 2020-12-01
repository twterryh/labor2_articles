cd "C:\Users\twter\Google Drive\Graduate\코스웍\2020 최재성 노동경제학2\stata\data"
********************************************************************************
* 1. fhs
use fhs, clear

* (a) 
count if glucose1==.

* (b)
tab sex1
tab sex1, nolab
su glucose1 if sex1==2, d
disp r(p10)

* (c)
gen bmihigh1=(bmi1>25) if bmi1!=.
tab bmihigh1

* (d)
su bmi1 bmi2 bmi3
gen meanbmi = (bmi1+bmi2+bmi3)/3
su meanbmi

* (e)
egen meanbmi2 = rowmean(bmi1 bmi2 bmi3)
su meanbmi2

********************************************************************************
* 1. 대학알리미
clear
import excel "2015년_교양과목 성적평가 분포.xls", sheet("Sheet1")
drop in 1/6

drop L-AE
rename A year
rename B name
rename C semester
rename D n_case
rename E gpa_scale
rename F n_ap
rename G p_ap
rename H n_a
rename I p_a
rename J n_am
rename K p_am

destring _all, replace

save college_info_2015, replace
use college_info_2015, clear

drop if n_case==0 // drop if no students
keep if semester=="2학기" // 2학기 기준

* (1)
gen p_sum_a = p_ap + p_a + p_am
gsort -p_sum_a
list name p_* in 1 // first
list name p_* in l // last

* (2-1)
count if p_am == 0

* (2-2)
drop if p_am ==0
gen ratio = p_ap / p_a
gsort -ratio
list name ratio in 1/3

********************************************************************************
* 2. Generate Matrix
* (1)
clear
set obs 10

forv i = 1/10 {
	gen x`i' = 0
	replace x`i' = `i'
}

* (2)
clear
set obs 10

forv i = 1/10 {
	gen x`i' = 0
	replace x`i' = `i'
	forv j = 2/10 {
		replace x`i' = x`i' + 10*(`j'-1) in `j'
	}
}

* (3) 
forv i = 1/10 {
	forv j = 1/10 {
		replace x`i' = 0 in `j' if `i'!=`j'
	}
}

********************************************************************************
* 3. Opinet
* (1)
use opinet_seoul_daily_2018, clear
keep if date == 20180301

bys district: egen price_max = max(price)
bys district: egen price_min = min(price)
keep if (price==price_max | price==price_min) // 같은 가격의 주유소가 있으면 구별로 두개 이상 있을수도 있다

* (2)
use opinet_seoul_daily_2018, clear
keep if date == 20180301

gen d_above1650 = (price>=1650)
tab d_above1650

collapse (mean) d_above1650, by(district)
gsort -d_above1650
list in 1/3

* (3)
use opinet_seoul_daily_2018, clear
drop if date == 20180301
drop if price == 0 

collapse (max) price_max=price (min) price_min=price, by(date)

tostring date, gen(datevar)
gen date2 = date(datevar, "YMD")
format date2 %td

tw 	(line price_max date2) ///
	(line price_min date2) ///
	, legend(lab(1 "Highest") lab(2 "Lowest")) ///
	title("Gasoline Prices in Seoul") scheme(s1color)

********************************************************************************
* 4. 심평원
clear
import excel "병원_한의원_약국_리스트_심사평가원_2013.xlsx", sheet("result") first

drop phone postal_code homepage
save temp, replace
use temp, clear

gen temp = address
split temp, p("(")
split temp2, p(",")
replace temp21 = subinstr(temp21, ")", "", .)
rename temp21 dong
order dong, before(address)
split dong, p(.)

split address
tab address1
rename address1 region
rename address2 district
order serial category name region district dong address

replace region = "서울"  if region == "서울특별시"
replace region = "부산"  if region == "부산광역시"
replace region = "대구"  if region == "대구광역시"
replace region = "인천"  if region == "인천광역시"
replace region = "광주"  if region == "광주광역시"
replace region = "대전"  if region == "대전광역시"
replace region = "울산"  if region == "울산광역시"
replace region = "경기"  if region == "경기도"
replace region = "강원"  if region == "강원도"
replace region = "충북"  if region == "충청북도"
replace region = "충남"  if region == "충청남도"
replace region = "전북"  if region == "전라북도"
replace region = "전남"  if region == "전라남도"
replace region = "경북"  if region == "경상북도"
replace region = "경남"  if region == "경상남도"
replace region = "제주"  if region == "제주도"
replace region = "제주"  if region == "제주특별자치도"
replace region = "세종"  if region == "세종특별자치시"

unique region
tab region

keep serial-address
compress

save health_institute_list, replace

* (1)
use health_institute_list, clear
tab category
tab region if category == "약국"

* (2) 
tab district if region == "서울" & category == "한의원", sort

* (3-1)
keep if category == "의원"
gen d_focus = (strpos(name, "성형")>0)
tab d_focus

* (3-2)
tab region if d_focus==1
tab district if d_focus==1 & region=="서울"

* (3-3)
keep if region == "서울"
keep if d_focus == 1
tab dong

replace dong = "신사동" if dong == "운광빌딩 지하1층"
tab dong, sort

********************************************************************************
* 5. 기상청
clear
import delim "weather.csv"
save weather, replace

* (a) 
use weather, clear

drop if rainfall == . 
drop if rainfall == 0
tab year

* (b)
use weather, clear

sort avg_temp
list in 1
list in l

* (c)
use weather, clear

keep if month == 8 
collapse cloud, by(year)
gsort -cloud
list in 1/5

* (d)
use weather, clear

keep if year >= 1980
gsort year -avg_temp 
collapse (first) month day avg_temp, by (year)

* (e)
use weather, clear

collapse (min) coldest=lowest_temp (max) hottest=lowest_temp, by(year)

tw	(connected hottest year) ///
	(connected coldest year) ///
	, legend(lab(1 "Highest") lab(2 "Lowest")) ///
	ytitle("Temperature") xtitle("Year") scheme(s1color)
	
graph save "weather.gph", replace

********************************************************************************
* 6. 저널 서치
cd "C:\Users\twter\Google Drive\Graduate\코스웍\2020 최재성 노동경제학2\stata\data\사회보장연구_서지정보"

clear
forv i = 2011/2015 {
	clear
	import delim "list_`i'.csv", encoding(EUC-KR)
	save journal`i', replace
}

clear
use journal2011, clear
forv i = 2012/2015 {
	append using journal`i'
}

rename 논문명 title
rename 저자명 author
rename 발행년도 year
rename 페이지 page

keep title author year page 
save temp, replace

* (1)
use temp, clear
d

* (2) 
bys year: gen n_article = _N
duplicates drop year, force
tw connected n_article year

* (3)
use temp, clear

split page, p(" ~ ")
destring page?, replace

gen n_page = page2 - page1 + 1
su n_page

* (4) 
use temp, clear

egen n_author = noccur(author), string(")") // ")" 로 저자 수 판별하기; use egenmore noccur
sort n_author

hist n_author, frac width(1) start(0.5) scheme(s1color)

* (4) alternative 
use temp, clear
forv i = 1/100 {
	replace author = regexr(author, "[a-z]|[A-Z]", "")
	replace author = regexr(author, ",", "")
	replace author = regexr(author, "\(", "")
	replace author = regexr(author, "\)", "")
	replace author = regexr(author, "\.", "")
	replace author = regexr(author, "-", "")
}
split author

gen order = _n
keep order author?
reshape long author, i(order) j(seq)
drop if author==""

gen count = 1
collapse (count) n_author=count, by(order)
tab n_author

* (5)
use temp, clear
forv i = 1/100 {
	replace author = regexr(author, "[a-z]|[A-Z]", "")
	replace author = regexr(author, ",", "")
	replace author = regexr(author, "\(", "")
	replace author = regexr(author, "\)", "")
	replace author = regexr(author, "\.", "")
	replace author = regexr(author, "-", "")
}
split author

gen order = _n
keep order author?
reshape long author, i(order) j(seq)
drop if author==""

tab author, sort

* (6)
use temp, clear

gen d_pov = regexm(title, "빈곤")
tab d_pov
gen d_welf = regexm(title, "복지")
tab d_welf
gen d_both = d_pov * d_welf
tab d_both

********************************************************************************
* 7. KTUS
cd "C:\Users\twter\Google Drive\Graduate\코스웍\2020 최재성 노동경제학2\stata\data"

use ktus2014_li, clear

* (1) 
tab day_type
tab day_type, nolab
keep if day_type == 1

keep if c45 == 1

* (2)
keep if age==10 | age==17
tab age, sum(c69)

* (3)
use ktus2014_li, clear

drop if day_type == 1
drop if age == 18

collapse c49, by (age sex)
rename c49 t_sleep
reshape wide t_sleep, i(age) j(sex)

gen abs_gap = abs(t_sleep0-t_sleep1)
gsort -abs_gap

* (4) 
use ktus2014_li, clear

keep hhid pid day_type
sort hhid pid day_type

bys hhid pid: gen seq = _n
reshape wide day_type, i(hhid pid) j(seq)

egen days = concat(day_type1 day_type2)
tab days

* (4) alternative 
use ktus2014_li, clear

collapse day_type, by(hhid pid)
tab day_type

********************************************************************************
* 8. 20대 총선
cd "C:\Users\twter\Google Drive\Graduate\코스웍\2020 최재성 노동경제학2\stata\data\총선"

import excel "개표상황(투표구별)_강남구갑.xlsx", sheet("sheet1") clear
drop in 1/6
destring _all, replace

rename A 읍면동명
rename B 투표구명
rename C 선거인수
rename D 투표수
rename E cand1
rename F cand2
rename G cand3
rename H cand4
rename Z 계
rename AA 무효투표수
rename AB 기권수
drop AC
drop I-Y

drop if 읍면동명=="합계"
drop if 읍면동명=="거소·선상투표"
drop if 읍면동명=="관외사전투표"
drop if 읍면동명=="국외부재자투표"
drop if 읍면동명=="잘못 투입·구분된 투표지"

compress
save data_q12, replace 

* (1)
use data_q12, clear

keep 읍면동명 투표구명 투표수
keep if 투표구명 == "소계" | 투표구명 == "관내사전투표"
gen 관내사전투표 = 투표수[_n+1] if 투표구명 == "소계"
keep if 투표구명 == "소계"

gen p = 관내사전투표 / 투표수
gsort -p

* (2)
use data_q12, clear

drop if 투표구명 == "소계" | 투표구명 == "관내사전투표"

gen p = 투표수 / 선거인수
gsort -p
list 투표구명 p in 1/2

* further cleaning
foreach i in 강남구갑 강남구병 강남구을 서초구갑 서초구을 {
 
import excel "개표상황(투표구별)_`i'.xlsx", sheet("sheet1") clear
drop in 1/6
destring _all, replace

rename A 읍면동명
rename B 투표구명
rename C 선거인수
rename D 투표수
rename E cand1
rename F cand2
rename G cand3
rename H cand4
rename Z 계
rename AA 무효투표수
rename AB 기권수
drop AC
drop I-Y

drop if 읍면동명=="합계"
drop if 읍면동명=="거소·선상투표"
drop if 읍면동명=="관외사전투표"
drop if 읍면동명=="국외부재자투표"
drop if 읍면동명=="잘못 투입·구분된 투표지"

replace 읍면동명 = 읍면동명[_n-1] if 읍면동명==""

gen district = "`i'"
order district
save `i', replace
}

clear
foreach i in 강남구갑 강남구병 강남구을 서초구갑 서초구을 {
	append using `i'
}

drop if 투표구명 == "소계" | 투표구명 == "관내사전투표"
compress
save master, replace

* (3)
use master, replace

unique 투표구명 // 222 투표소

duplicates drop district, force
keep district cand?
reshape long cand, i(district) j(seq)
drop if cand == 0
d, s // 16 candidates

* (4)
use master, clear

collapse (sum) cand? 투표수, by(읍면동명)

forv i = 1/4 {
	gen p_cand`i' = cand`i'/투표수
}

egen p_max = rowmax(p_cand?)
gsort -p_max
list in 1

* (5)
use master, clear

keep 투표구명 cand? 

reshape long cand, i(투표구명) j(seq)
gsort 투표구명 -cand
bys 투표구명: gen order = _n
keep if order == 1 | order == 2
drop seq
reshape wide cand, i(투표구명) j(order)

gen gap = cand1 - cand2
gsort -gap
list in 1/3

/* 
* Appendix - 읍면동을 따로 추출하기

* 1)
split 투표구명, p("제")

* 2)
gen 읍면동명 = regexr(투표구명, "제[0-9]투", "")
gen 읍면동명 = regexr(읍면동명, "제[0-9][0-9]투", "")
*/
********************************************************************************
* 9. GOMS
cd "C:\Users\twter\Google Drive\Graduate\코스웍\2020 최재성 노동경제학2\stata\data"

* (1)
use 2012goms_li, clear

decode gp1211116, gen(region)

keep if sex == 2

* ssc install fre
fre gp1211102
gen d_spouse = (gp1211102==2)
collapse d_spouse, by(region)
gsort -d_spouse
list in 1

use 2012goms_li, clear

decode gp1211116, gen(region)

keep if sex == 2

gen d_spouse = (gp1211102==2)
tab d_spouse school if region == "충남"

* (2)
use 2012goms_li, clear

decode gp1211116, gen(region)

gen d_spouse = (gp1211102==2)

collapse d_spouse, by(region sex)
reshape wide d_spouse, i(region) j(sex)
gen gap = abs(d_spouse1 - d_spouse2)
gsort -gap
list in 1

* (3)
use 2012goms_li, clear

keep if sex == 1

drop if gp1211130 == -1
gen d_army = (gp1211130==2)

collapse d_army, by(school major)

gsort school -d_army

* (4)
use 2012goms_li, clear

keep area gp1211115 gp1211116
drop if gp1211115 == -1 | gp1211115 == .
drop if gp1211116 == -1 | gp1211116 == .

gen d_same = (area == gp1211115 & area == gp1211116)
tab d_same

tab area if d_same == 1

********************************************************************************
* 10. 복지패널

* (1)
use 복지패널1차_개인, clear

bys hhid: ge n_res = _N
duplicates drop hhid, force
tab n_res
count if n_res >= 4

* (2) 
use 복지패널1차_개인, clear

merge n:1 hhid using 복지패널1차_가구, nogen

keep if edu_father == 3 | edu_father == 7

replace income = . if income <0
tab edu_father, sum(income)

su income if edu_father == 7
local a = r(mean)
su income if edu_father == 3
local b = r(mean)
disp `a' - `b'

* (3)
use 복지패널1차_가구, clear

forv i=1/9 {
	local j=4+(`i'-1)*12
	rename h0101_`j' gender`i'
}

keep hhid pid? gender?
reshape long pid gender, i(hhid) j(seq)
drop if pid == .

merge 1:1 pid using 복지패널1차_개인
keep if _merge==3

tab gender

* (4)
use 복지패널1차_가구, clear

forv i=1/9 {
	local j=5+(`i'-1)*12
	rename h0101_`j' birth_y`i'
}

keep hhid pid? birth_y?
reshape long pid birth_y, i(hhid) j(seq)
drop if pid == .

gen d_50s = (birth_y>=1950 & birth_y<=1959)
gen d_80s = (birth_y>=1980 & birth_y<=1989)

bys hhid: egen fam_d_50s = max(d_50s)
bys hhid: egen fam_d_80s = max(d_80s)

gen target = (fam_d_50s*fam_d_80s==1)
duplicates drop hhid, force
tab target

********************************************************************************
* 11. 청년패널
use yp_li_w4, clear

forv i = 5/7 {
	merge 1:1 sampid using yp_li_w`i', gen(_merge`i')
}
drop _merge?

order w?, after(sampid)

save master, replace

* (1)
use master, clear

keep sampid w?
forv i = 4/7 {
	replace w`i'=0 if w`i' ==2
}
egen n_res = rowtotal(w?)
count if n_res>=3

* (2)
use master, clear

forv i=4/7 {
	gen d_work`i' = (y0`i'a501==1) if y0`i'a501!=.
}
egen n_work = rowtotal(d_work?)
tab n_work

* (3)
use master, clear

forv i=4/7 {
	gen d_work`i' = (y0`i'a501==1) if y0`i'a501!=.
	drop if d_work`i' ==.
}
egen pattern = concat(d_work?)
tab pattern, sort

* (4)
use yp_li_w4, clear

keep if y04a501==1

gen d_work1 = (y04a503!=.)
gen d_work2 = (y04a522!=.)
gen d_work3 = (y04a541!=.)
gen d_work4 = (y04a560!=.)
gen d_work5 = (y04a579!=.)

egen n_work = rowtotal(d_work?)
tab n_work

* (5)
use yp_li_w4, clear

keep if y04a501==1

gen t_work1 = y04a515
gen t_work2 = y04a534
gen t_work3 = y04a553
gen t_work4 = y04a572
gen t_work5 = y04a591

egen t_work_max = rowmax(t_work?)
su t_work_max

********************************************************************************
* 12. 한은 기준금리
clear
import delim "q3_기준금리.csv"
save bok, replace

* (1)
use bok, clear

gen rate_lag = rate[_n-1]
gen diff = rate - rate_lag
tab diff if diff>0 // 16

count if abs(diff) >= 0.5 & diff!=. // 5

* (2)
use bok, clear

gen year_prev = year[_n-1]
gen month_prev = month[_n-1]

gen duration = (year - year_prev)*12 + (month - month_prev)
gsort -duration // 200902 ~ 201007

* (3)
clear

set obs 204
gen year =.
gen month =.
forv i = 2000/2016 {
	forv j=1/12 {
		local loc = (`i'-2000)*12+`j'
		replace year = `i' in `loc'
		replace month = `j' in `loc'
	}
}

save temp, replace
use temp, replace

merge 1:1 year month using bok, nogen
replace rate = rate[_n-1] if rate ==.
su rate

save full, clear

* (4)
use full, clear

collapse (mean) avg_rate=rate (max) max_rate=rate, by(year)
gen diff = max_rate - avg_rate
gsort -diff
list
