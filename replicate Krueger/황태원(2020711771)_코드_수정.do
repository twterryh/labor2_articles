cd "C:\Users\twter\Google Drive\Graduate\코스웍\2020 최재성 노동경제학2\krueger replication"
dir

********************************************************************************
** Generating Percentile Scores for Each Subject 
**(from MHE Data Archive krueger.do)
/* reading score */
use webstar, replace
keep if cltypek > 1   /* regular classes */
keep if treadssk ~= .
sort treadssk
gen pread0 = 100*_n/_N
egen pread = mean(pread0), by(treadssk) /* percentile score in reg. classes */
bys treadssk: keep if treadssk ~= treadssk[_n-1]
keep treadssk pread
save tempr, replace
/* math score */
use webstar
keep if cltypek > 1   /* regular classes */
keep if tmathssk ~= .
sort tmathssk
gen pmath0 = 100*_n/_N
egen pmath = mean(pmath0), by(tmathssk)
bys tmathssk: keep if tmathssk ~= tmathssk[_n-1]
keep tmathssk pmath
save tempm, replace

** Merge percentile scores back on 
use webstar, replace
keep if stark == 1
merge n:1 treadssk using tempr
ipolate pread treadssk, gen(pr) epolate
replace pr = 0 if pr < 0
drop _merge
merge n:1 tmathssk using tempm
ipolate pmath tmathssk, gen(pm) epolate
replace pm = 0 if pm < 0
drop _merge
su pr pm
egen pscore = rowmean(pr pm)
save krueger_qje_0907, replace

use krueger_qje_0907, replace
label define cltypek 1 "Small" 2 "Regular" 3 "Regular/Aide", modify
label define cltype1 1 "Small" 2 "Regular" 3 "Regular/Aide", modify
save krueger_qje_0907, replace
********************************************************************************
********** Table I Panel A
use krueger_qje_0907, clear

* Free lunch
replace sesk=0 if sesk==2

* White/Asian
replace srace=1 if srace==3
replace srace=0 if srace==2|srace==4|srace==5|srace==6

* Age in 1985 September
gen age = 1985 - sbirthy

* Attrition rate
gen att = (star1==2|star2==2|star3==2)

* Class size in kindergarten
egen classid1 = group(schidkn cltypek)
egen cs1 = count(classid1), by(classid1)
egen classid2 = group(classid1 totexpk hdegk cladk) if cltypek==1 & cs >= 20
egen classid3 = group(classid1 totexpk hdegk cladk) if cltypek>1 & cs >= 30
gen temp = classid1*100
egen classid = rowtotal(temp classid2 classid3)
egen cs = count(classid), by(classid)
replace cs=. if cs>30

* Joint P-Value
anova sesk cltypek
anova srace cltypek
anova age cltypek
anova att cltypek
anova cs cltypek
anova pscore cltypek

* Export table
eststo clear
bys cltypek: eststo: estpost sum sesk srace age att cs pscore 
esttab using "황태원(2020711771)_표.csv", cells("mean(fmt(2))") nonumbers noobs ///
	coeflabels(sesk "Free lunch" srace "White/Asian" age "Age in 1985" att "Attrition rate" ///
	cs "Class size in kindergarten" pscore "Percentile score in kindergarten") ///
	mtitles("Small" "Regular" "Regular/Aide") replace

********************************************************************************
********** Table IV Panel A
use krueger_qje_0907, clear

eststo clear
eststo: estpost tab cltypek cltype1 if stark==1&star1==1
esttab using "황태원(2020711771)_표.csv", unstack nonumbers noobs cells(b)append

********************************************************************************
********** Figure I Kindergarten
use krueger_qje_0907, clear

tw  (kdensity pscore if cltypek>1, lpattern(dash) lcolor(gs0)) ///
	(kdensity pscore if cltypek==1, lcolor(gs0)), ///
	xtitle("Stanford Achievement Test Percentile") ///
	ytitle("Density") ///
	ylab(0(0.005)0.015, angle(horizontal)) ///
	xtick(0(25)100) ///
	xlab(0(50)100) ///
	legend(pos(7) ring(0) col(1) lab(1 "Regular") lab(2 "Small") region(lw(none))) ///
	plotregion(lcolor(none) ilcolor(none) style(none) lwidth(thick)) scheme(s1color) ///
	title("Kindergarten")

********************************************************************************
********** Table V Panel A
use krueger_qje_0907, clear

replace srace=1 if srace==3
replace srace=0 if srace==2|srace==4|srace==5|srace==6
replace ssex=0 if ssex==1
replace ssex=1 if ssex==2
label define ssex 0 "Male" 1 "Female", modify
replace sesk=0 if sesk==2
replace tracek=0 if tracek==2|tracek==3|tracek==4|tracek==5|tracek==6
replace hdegk=0 if hdegk==2
replace hdegk=1 if hdegk==3|hdegk==4|hdegk==5

eststo clear
eststo: quietly reg pscore ib2.cltypek
eststo: quietly reg pscore ib2.cltypek i.schidkn
eststo: quietly reg pscore ib2.cltypek srace ssex sesk i.schidkn
eststo: quietly reg pscore ib2.cltypek srace ssex sesk tracek totexpk hdegk i.schidkn
eststo: quietly reg pscore ib2.cltypek
eststo: quietly reg pscore ib2.cltypek i.schidkn
eststo: quietly reg pscore ib2.cltypek srace ssex sesk i.schidkn
eststo: quietly reg pscore ib2.cltypek srace ssex sesk tracek totexpk hdegk i.schidkn

esttab using "황태원(2020711771)_표.csv", noomitted nobaselevels compress nostar append ///
	keep(1.cltypek 3.cltypek srace ssex sesk tracek totexpk hdegk) ///
	r2(2) se(2) nodep nogaps nonotes noobs ///
	coef(1.cltypek "Small class" 3.cltypek "Regular/aide class" ///
	srace "White/Asian (1 = yes)" ssex "Girl (1 = yes)" ///
	sesk "Free lunch (1 = yea) " tracek "White teacher" ///
	totexpk "Teacher experience" hdegk "Master's degree")
