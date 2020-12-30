cd "C:\Users\twter\Google Drive\Graduate\코스웍\2020 최재성 노동경제학2\final project\code"

forv i = 1/4 {

use "KCYPS2010 m1w`i'.dta", clear
gen year = 2009 + `i'
rename *w`i' *

save `i', replace
}

use 1, clear
forv i = 2/4 {
append using `i'
}
sort id year
order id year

drop if survey1 == 2
save full, replace
* 원 자료에 포함되어 있는 중1 코호트 2,351명 학생들의 4년간 관측치는 총 8,998개다. (일치)

* 중1 때 학교 변수 만들어주기
use full, clear

keep id year sclid
gen origin = sclid if year==2010
keep if year==2010
keep id origin

save temp, replace

use full, clear
merge m:1 id using temp

* 개인 특성 변수 + 분석 대상 변수
keep id sclid origin year edu1a ara1a ara2a gender brt1a job1a job1b income ///
phy1a phy1b fam1e* int1b01 int1b02 int1b03 ///
edu2a02	edu2a05	edu2b01	edu2b02	edu2b04	edu2b05	///
edu2c01	edu2d01	edu2d02	edu2d03	edu2d04	edu2d05	///
psy3b01	psy3b02	psy3b03	///
dlq1a01	dlq1a02	dlq1a03	dlq1a04	dlq1a05	dlq1a06	///
dlq1a07	dlq1a08	dlq1a09	dlq1a10	dlq1a11	dlq1a12	///
dlq2a01	dlq2a02	dlq2a03	dlq2a04	dlq2a05	dlq2a06

label variable brt1a "출생 연도"
label variable ara1a "학교 지역"
label variable ara2a "자택 지역"
label variable gender "남학생 더미 "
label variable job1a "부 근로 여부 "
label variable job1b "모 근로 여부 "
label variable income "연 가구소득(만 원) "
label variable phy1a "키(cm) "
label variable phy1b "몸무게(kg) "
label variable int1b01 "성적 자체평가(국어)" 
label variable int1b02 "성적 자체평가(수학)" 
label variable int1b03 "성적 자체평가(영어)" 

label variable edu2a02 "(1) 숙제 수행 "
label variable edu2a05 "(2) 수업 집중 "
label variable edu2b01 "(3) 책임감"
label variable edu2b02 "(4) 복도정숙 "
label variable edu2b04 "(5) 질서 지키기 "
label variable edu2b05 "(6) 쓰레기처리 "

label variable edu2c01 "(1) 교우관계 "
label variable edu2d01 "(2) 반갑게 인사 "
label variable edu2d02 "(3) 교사가 편함 "
label variable edu2d03 "(4) 만나면 반가움 "
label variable edu2d04 "(5) 교사 친절 "
label variable edu2d05 "(6) 내년도 담임 "

label variable psy3b01 "(1) 즐거움 "
label variable psy3b02 "(2) 걱정거리 유무 "
label variable psy3b03 "(3) 행복함 "

label variable dlq1a01 "(1) 흡연 "
label variable dlq1a02 "(2) 음주 "
label variable dlq1a03 "(3) 무단결석 "
label variable dlq1a04 "(4) 가출 "
label variable dlq1a05 "(5) 놀림/조롱 "
label variable dlq1a06 "(6) 집단 따돌림 "
label variable dlq1a07 "(7) 패싸움 "
label variable dlq1a08 "(8) 폭행 "
label variable dlq1a09 "(9) 협박 "
label variable dlq1a10 "(10) 물건 빼앗기 "
label variable dlq1a11 "(11) 물건 훔치기 "
label variable dlq1a12 "(12) 성관계 "

label variable dlq2a01 "(1) 놀림/조롱 "
label variable dlq2a02 "(2) 집단 따돌림 "
label variable dlq2a03 "(3) 폭행 "
label variable dlq2a04 "(4) 협박 "
label variable dlq2a05 "(5) 물건 빼앗김 "
label variable dlq2a06 "(6) 성희롱 "

order ara1a ara2a, after(sclid)
order phy1a phy1b, after(income)
order income, after(job1b) 

* 조례 더미
gen dKJ = 0
replace dKJ = 1 if ara1a==23 & year>=2012
label variable dKJ "조례 더미 (광주)"

gen dJB = 0
replace dJB = 1 if ara1a==34 & year>=2013
label variable dJB "조례 더미 (전북)"

gen dSE = 0
replace dSE = 1 if ara1a==10 & year>=2012
label variable dSE "조례 더미 (서울)"

gen dGY = 0
replace dGY = 1 if ara1a==30 & year>=2011
label variable dGY "조례 더미 (경기)"

gen dLAW = dKJ + dJB
gen dLAW2 = dKJ + dJB + dSE + dGY
label variable dLAW "조례 더미"
label variable dLAW2 "조례 더미 (서울경기 포함)"

order dLAW dLAW2 dKJ dJB dSE dGY, after(sclid)

* 나이
gen age = year - brt1a
order age, after(brt1a)
label variable age "만 나이 "

* 형제 수
forv i = 1/4{
replace fam1e0`i' = . if fam1e0`i'==-9
}
egen fam1e = rowtotal(fam1e*), missing
label variable fam1e "형제 수(명)"
drop fam1e0*
order fam1e, after(job1b)

* (13) 문제행동 여부
gen  dlq1a = 0
replace dlq1a = 1 if dlq1a01==1|dlq1a02==1|dlq1a03==1|dlq1a04==1|dlq1a05==1|dlq1a06==1| ///
					 dlq1a07==1|dlq1a08==1|dlq1a09==1|dlq1a10==1|dlq1a11==1|dlq1a12==1
replace dlq1a = . if dlq1a01==.
label variable dlq1a "(13) 문제행동 여부"
order dlq1a, after(dlq1a12)

* (7) 문제행동 피해 여부
gen dlq2a = 0
replace dlq2a = 1 if dlq2a01==1|dlq2a02==1|dlq2a03==1|dlq2a04==1|dlq2a05==1|dlq2a06==1
replace dlq2a = . if dlq2a01==.
label variable dlq2a "(7) 문제행동 피해 여부"
order dlq2a, after(dlq2a06)

* -9, (1, 2) 처리, 로그 소득
replace gender = 0 if gender==2
replace phy1a = . if phy1a==-9
replace phy1b = . if phy1b==-9
replace job1a = . if job1a==-9
replace job1a = 0 if job1a==2
replace job1b = . if job1b==-9
replace job1b = 0 if job1b==2
replace income = . if income==-9
gen l_income = log(income)
label variable l_income "log(연 가구소득)"
order l_income, after(income)

* 리커트 처리
/* 
1(매우 그렇다), 2(그렇다)라고 응답한 경우 1로 코딩하고, 
3(그렇지 않다), 4(매우 그렇지 않다)로 응답한 경우 0으로 코딩하였다.
*/

foreach i in edu2a02 edu2a05 edu2b01 edu2b02 edu2b04 edu2b05 edu2c01 edu2d01 ///
edu2d02 edu2d03 edu2d04 edu2d05 psy3b01 psy3b02 psy3b03 {

replace `i' = 0 if `i'==3 | `i'==4
replace `i' = 1 if `i'==1 | `i'==2
replace `i' = . if `i'!=0 & `i'!=1
}

* 1 있다 2 없다 처리
/* 
각 행동을 하거나 당한 경험이 있는 경우에는 1, 
그렇지 않은 경우에는 0의 값을 취한다. 
*/

foreach i in dlq1a01 dlq1a02 dlq1a03 dlq1a04 dlq1a05 dlq1a06 dlq1a07 dlq1a08 ///
dlq1a09 dlq1a10 dlq1a11 dlq1a12 dlq2a01 dlq2a02 dlq2a03 dlq2a04 dlq2a05 dlq2a06 {

replace `i' = 0 if `i'==2
replace `i' = 1 if `i'==1
replace `i' = . if `i'!=0 & `i'!=1
}

save temp2, replace

* 표준 점수
/* 
이때 사용한 성적 수준은 광주와 전북에 조례가 도입되기 직전인 2차년도(2011년) 시점에 학생들이 스스로 보고한 성적을 의미한다. 
구체적으로, 설문조사에서 학생들은 국어, 수학, 영어 각각에 대하여 자신의 점수를 8개의 범주
(1. 96점 이상, 2. 90점 이상 95점 이하, 3. 85점 이상 89점 이하, 4. 80점 이상 84점 이하, 5. 75점
이상 79점 이하, 6. 70점 이상 74점 이하, 7. 65점 이상 69점 이하, 8. 64점 이하)로 
나누어 보고한다. 

본 논문에서 우리는 각 구간의 중간 값을 학생 개인의 점수라고 가정
하고, 각 과목별로 원점수를 z-점수로 표준화시켜 사용한다. 그리고 국어, 영어, 수학
각 과목 표준점수의 평균값을 학생의 최종 성적으로서 사용한다. [그림 1]은 이와 같이
구축한 표준점수 평균값의 분포를 보여준다. 이 평균값이 상위 33% 이내인 학생들을
상위권, 하위 33%인 학생들을 하위권, 나머지 학생들은 중위권으로 분류한다.
*/
use temp2, clear

keep id year sclid int1b01 int1b02 int1b03
keep if year == 2011
drop if int1b01 ==.
forv i = 1/3 {
replace int1b0`i' = 98 if int1b0`i' == 1
replace int1b0`i' = 92.5 if int1b0`i' == 2
replace int1b0`i' = 87 if int1b0`i' == 3
replace int1b0`i' = 82 if int1b0`i' == 4
replace int1b0`i' = 77 if int1b0`i' == 5
replace int1b0`i' = 72 if int1b0`i' == 6
replace int1b0`i' = 67 if int1b0`i' == 7
replace int1b0`i' = 32 if int1b0`i' == 8
}

foreach var of varlist int1b01 int1b02 int1b03{
egen `var'_mean= mean(`var')
egen `var'_sd = sd(`var')
gen `var'_std = (`var'-`var'_mean)/`var'_sd
}

gen z_score = (int1b01_std + int1b02_std + int1b03_std)/3
label variable z_score "성적 자체평가(표준화점수)"
keep id year z_score

egen z_perc33 = pctile(z_score), p(33)
egen z_perc67 = pctile(z_score), p(67)
gen z_top = (z_score>=z_perc67)
gen z_mid = (z_score<z_perc67) & (z_score>z_perc33)
gen z_low = (z_score<=z_perc33)
replace z_top = . if z_score==.
replace z_mid = . if z_score==.
replace z_low = . if z_score==.
drop z_perc*

sort id year
save score, replace

use temp2, clear
merge m:1 id using score, nogen
order z_score z_*, after(income)
drop int1b*

sort id year
save clean_before304, replace

* 조사대상 기간 4년 동안 시도 지역을 이동하거나, 학교를 이동한 적이 있는 학생들의 관측치(총 304개)는 분석에서 제외한다
use clean_before304, clear

bys id : egen a1 = max(ara1a)
bys id : egen a2 = min(ara1a)
drop if a1-a2 != 0
drop if ara1a==.

save clean_full, replace

* 서울과 경기를 제외한 분석 표본에 포함된 총 6,572개
use clean_full, clear

drop if ara1a==10 | ara1a==30

save clean, replace

********************************************************************************
********************************************************************************
* IV. 실증분석
use clean, replace
xtset id year

********************************************************************************
* <표 2> 기술통계량 : 서울·경기를 제외한 표본
eststo clear
estpost su dLAW gender age job1a job1b income z_score phy1a phy1b fam1e
esttab using ss.csv, cells("count(fmt(0)) mean(fmt(3)) sd(fmt(3)) min(fmt(0)) max(fmt(0))") ///
	nomti nonum noobs replace 

********************************************************************************
* <표 3> 분석대상 변수들의 기술 통계량: 서울·경기 제외한 표본
eststo clear
estpost su edu2a02 edu2a05 edu2b01 edu2b02 edu2b04 edu2b05 edu2c01 edu2d01 ///
	edu2d02 edu2d03 edu2d04 edu2d05 psy3b01 psy3b02 psy3b03 dlq1a01 dlq1a02 dlq1a03 ///
	dlq1a04 dlq1a05 dlq1a06 dlq1a07 dlq1a08 dlq1a09 dlq1a10 dlq1a11 dlq1a12 dlq1a ///
	dlq2a01 dlq2a02 dlq2a03 dlq2a04 dlq2a05 dlq2a06 dlq2a
esttab using ss.csv, cells("count(fmt(0)) mean(fmt(3)) sd(fmt(3))") ///
	nomti nonum noobs append 

********************************************************************************
********************************************************************************
* V. 분석 결과
use clean, replace
xtset id year

global x dLAW I.year
global x1 dKJ dJB I.year
global x2 age job1b l_income

* 패널 1은 조례더미와 4개의 연도더미를 통제한 상태에서 패널 개인 고정효과 모형을 추정한 결과를 보여준다.
* 패널 2는 이들 변수 이외에 학생의 만 나이, 모친의 근로 여부, 가구소득을 추가적으로 통제한 모형의 추정결과를 보여준다.

********************************************************************************
* <표 4> 바람직한 행동의 수행도 변화: 서울, 경기 제외
global y4 edu2a02 edu2a05 edu2b01 edu2b02 edu2b04 edu2b05

foreach y in $y4{

eststo clear

eststo: quietly xtreg `y' $x, fe vce(cluster origin)
eststo: quietly xtreg `y' $x1, fe vce(cluster origin)

eststo: quietly xtreg `y' $x $x2, fe vce(cluster origin)
eststo: quietly xtreg `y' $x1 $x2, fe vce(cluster origin)

esttab using table4.csv, nobaselevels compress plain ///
	 b(4) se(4) br dep star(* 0.1 ** 0.05 ) noobs nonote nonum ///
	 nogaps k(dLAW dKJ dJB) append
}

********************************************************************************
* <표 5> 교우 및 교사와의 관계 변화 : 서울․ 경기 제외
global y5 edu2c01 edu2d01 edu2d02 edu2d03 edu2d04 edu2d05

foreach y in $y5{

eststo clear

eststo: quietly xtreg `y' $x, fe vce(cluster origin)
eststo: quietly xtreg `y' $x1, fe vce(cluster origin)

eststo: quietly xtreg `y' $x $x2, fe vce(cluster origin)
eststo: quietly xtreg `y' $x1 $x2, fe vce(cluster origin)

esttab using table5.csv, nobaselevels compress plain ///
	 b(4) se(4) br dep star(* 0.1 ** 0.05 ) noobs nonote nonum ///
	 nogaps k(dLAW dKJ dJB) append
}

********************************************************************************
* <표 6> 삶의 만족도 변화 : 서울, 경기 제외
global y6 psy3b01 psy3b02 psy3b03

foreach y in $y6{

eststo clear

eststo: quietly xtreg `y' $x, fe vce(cluster origin)
eststo: quietly xtreg `y' $x1, fe vce(cluster origin)

eststo: quietly xtreg `y' $x $x2, fe vce(cluster origin)
eststo: quietly xtreg `y' $x1 $x2, fe vce(cluster origin)

esttab using table6.csv, nobaselevels compress plain ///
	 b(4) se(4) br dep star(* 0.1 ** 0.05 ) noobs nonote nonum ///
	 nogaps k(dLAW dKJ dJB) append
}

********************************************************************************
* [그림 1] 국·영·수 표준점수 평균의 확률밀도
use clean, replace
*keep if year==2011

tw  (kdensity z_score, k(ep) bwidth(0.1285)), ///
	xtitle("T_score") ///
	ytitle("Density") ///
	ysc(ax(1) r(0 0.61)) ylab(0(0.2)0.6) ///
	xlab(-2(1)2) ///
	note("kernel=epanechnikov, bandwidth=0.1285") ///
	title("Kernel density estimate")

********************************************************************************
* <표 7> 성적별 효과 추정: 바람직한 행동, 교우/교사관계, 삶의 만족도
use clean, replace
xtset id year

global x dLAW I.year
global x1 dKJ dJB I.year

global y7 edu2a02 edu2a05 edu2b01 edu2b02 edu2b04 edu2b05 ///
edu2c01 edu2d01 edu2d02 edu2d03 edu2d04 edu2d05 ///
psy3b01 psy3b02 psy3b03

foreach y in $y7 {

eststo clear

eststo: quietly xtreg `y' $x, fe vce(cluster origin)
eststo: quietly xtreg `y' $x1, fe vce(cluster origin)

eststo: quietly xtreg `y' $x if z_top==1, fe vce(cluster origin)
eststo: quietly xtreg `y' $x1 if z_top==1, fe vce(cluster origin)

eststo: quietly xtreg `y' $x if z_mid==1, fe vce(cluster origin)
eststo: quietly xtreg `y' $x1 if z_mid==1, fe vce(cluster origin)

eststo: quietly xtreg `y' $x if z_low==1, fe vce(cluster origin)
eststo: quietly xtreg `y' $x1 if z_low==1, fe vce(cluster origin)

esttab using table7.csv, nobaselevels compress plain ///
	 b(3) se(3) br dep star(* 0.1 ** 0.05 ) noobs nonote nonum ///
	 nogaps k(dLAW dKJ dJB) append
}

********************************************************************************
* <표 8> 성적별 효과 추정: 본인의 문제 행동과 피해 경험
global y8 dlq1a01 dlq1a02 dlq1a03 dlq1a04 dlq1a05 dlq1a06 dlq1a07 dlq1a08 ///
dlq1a09 dlq1a10 dlq1a11 dlq1a12 dlq1a dlq2a01 dlq2a02 dlq2a03 dlq2a04 dlq2a05 dlq2a06 dlq2a

foreach y in $y8 {

eststo clear

eststo: quietly xtreg `y' $x, fe vce(cluster origin)
eststo: quietly xtreg `y' $x1, fe vce(cluster origin)

eststo: quietly xtreg `y' $x if z_top==1, fe vce(cluster origin)
eststo: quietly xtreg `y' $x1 if z_top==1, fe vce(cluster origin)

eststo: quietly xtreg `y' $x if z_mid==1, fe vce(cluster origin)
eststo: quietly xtreg `y' $x1 if z_mid==1, fe vce(cluster origin)

eststo: quietly xtreg `y' $x if z_low==1, fe vce(cluster origin)
eststo: quietly xtreg `y' $x1 if z_low==1, fe vce(cluster origin)

esttab using table8.csv, nobaselevels compress plain ///
	 b(3) se(3) br dep star(* 0.1 ** 0.05 ) noobs nonote nonum ///
	 nogaps k(dLAW dKJ dJB) append
}

********************************************************************************
* <표 9> 조례의 영향을 받지 않는 종속변수들에 대한 분석결과
use clean, replace
xtset id year

global x11 dKJ I.year
global x12 dJB I.year
* 설명변수로서 모친의 근로 여부와 로그 가구소득을 통제하는 경우 (나이 빠지는 게 맞는 지 확인)
global x2 job1b l_income
* 오류확인 실험을 위한 종속변수로서 우리는 학생의 신장, 체중, 형제자매 수를 사용한다.
global y9 phy1a phy1b fam1e

foreach y in $y9 {

eststo clear

eststo: quietly xtreg `y' $x11, fe vce(cluster origin)
eststo: quietly xtreg `y' $x12, fe vce(cluster origin)

eststo: quietly xtreg `y' $x11 if z_top==1, fe vce(cluster origin)
eststo: quietly xtreg `y' $x12 if z_top==1, fe vce(cluster origin)

eststo: quietly xtreg `y' $x11 if z_mid==1, fe vce(cluster origin)
eststo: quietly xtreg `y' $x12 if z_mid==1, fe vce(cluster origin)

eststo: quietly xtreg `y' $x11 if z_low==1, fe vce(cluster origin)
eststo: quietly xtreg `y' $x12 if z_low==1, fe vce(cluster origin)

eststo: quietly xtreg `y' $x11 $x2, fe vce(cluster origin)
eststo: quietly xtreg `y' $x12 $x2, fe vce(cluster origin)

eststo: quietly xtreg `y' $x11 $x2 if z_top==1, fe vce(cluster origin)
eststo: quietly xtreg `y' $x12 $x2 if z_top==1, fe vce(cluster origin)

eststo: quietly xtreg `y' $x11 $x2 if z_mid==1, fe vce(cluster origin)
eststo: quietly xtreg `y' $x12 $x2 if z_mid==1, fe vce(cluster origin)

eststo: quietly xtreg `y' $x11 $x2 if z_low==1, fe vce(cluster origin)
eststo: quietly xtreg `y' $x12 $x2 if z_low==1, fe vce(cluster origin)

esttab using table9.csv, nobaselevels compress plain ///
	 b(3) se(3) br dep star(* 0.1 ** 0.05 ) noobs nonote nonum ///
	 nogaps k(dKJ dJB) append
}

********************************************************************************
* <표 10> 인권조례 효과의 강건성 검정: 서울, 경기 표본 포함 
use clean_full, replace
xtset id year

global y10 edu2a02 edu2b02 edu2b05 edu2d01 edu2d04 ///
psy3b01 dlq2a01 dlq2a02 dlq2a03 dlq2a04 dlq2a06 dlq2a

global x1 dLAW2 I.year
global x2 dKJ dJB dSE dGY I.year
xtreg edu2a02 $x1, fe vce(cluster origin)

foreach y in $y10 {

eststo clear

eststo: quietly xtreg `y' $x1, fe vce(cluster origin)
eststo: quietly xtreg `y' $x2, fe vce(cluster origin)

eststo:  xtreg `y' $x1 if z_top==1, fe vce(cluster origin)
eststo: quietly xtreg `y' $x2 if z_top==1, fe vce(cluster origin)

eststo:  xtreg `y' $x1 if z_mid==1, fe vce(cluster origin)
eststo: quietly xtreg `y' $x2 if z_mid==1, fe vce(cluster origin)

eststo:  xtreg `y' $x1 if z_low==1, fe vce(cluster origin)
eststo: quietly xtreg `y' $x2 if z_low==1, fe vce(cluster origin)

esttab using table10.csv, nobaselevels compress plain ///
	 b(3) se(3) br dep star(* 0.1 ** 0.05 ) nonote nonum ///
	 nogaps k(dLAW2 dKJ dJB dSE dGY) append
}
