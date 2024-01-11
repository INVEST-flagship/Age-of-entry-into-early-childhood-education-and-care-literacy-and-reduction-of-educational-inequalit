* Markus Laaninen 
* majlaan@uu.fi 

* set working directory
cd "Path"
use data.dta, clear 

* margins for repest comand, see info from "help repest"
cap program drop myregmargins
        program define myregmargins, eclass
        syntax [if] [in] [pweight], reg(string) [margins(string) loptions(string) moptions(string)]
        tempname b m
        // compute reg regressions, store results in vectors
                reg `reg' [`weight' `exp'] `if' `in', `loptions'
                matrix `b'= e(b)
        // compute reg postestimation, store results in vectors
                if "`margins'" != "" | "`moptions'" != ""{
                        margins `margins', post `moptions'
                        matrix `m' = e(b)
                        matrix colnames `m' =  margins:
                        matrix `b'= [`b', `m']
                        }
        // post results
                ereturn post `b' 
        end
	
***********
* Table A1
***********

* exporting not supported with repest

forvalues i =1/5 {
eststo m_`i'_1: repest PISA2015 if cnt == `i' & immig !=. & escs !=. & language !=.,estimate(means std_pv@read) 
eststo m_`i'_2:repest PISA2015 if cnt == `i' & immig !=. & escs !=. & language !=.,estimate(means std_pv@read) by(escs5) 
eststo m_`i'_3:repest PISA2015 if cnt == `i' & immig !=. & escs !=. & language !=.,estimate(means std_pv@read) by(ecec_age) 
eststo m_`i'_4:repest PISA2015 if cnt == `i' & immig !=. & escs !=. & language !=.,estimate(means std_pv@read) by(sex) 
eststo m_`i'_5:repest PISA2015 if cnt == `i' & immig !=. & escs !=. & language !=.,estimate(means std_pv@read) by(immig) 
eststo m_`i'_6:repest PISA2015 if cnt == `i' & immig !=. & escs !=. & language !=.,estimate(means std_pv@read) by(language) 

* these are the same as with tabulate/fre
eststo m_`i'_7:repest PISA2015, estimate(freq ecec_age if cnt == `i' & immig !=. & escs !=.& language !=., count levels(1 2 3 4 5 6 7 8 99))
eststo m_`i'_8:repest PISA2015, estimate(freq escs5 if cnt == `i' & immig !=. & escs !=.& language !=., count levels(1 2 3 4 5))
eststo m_`i'_9:repest PISA2015, estimate(freq sex if cnt == `i' & immig !=. & escs !=.& language !=., count levels(1 2))
eststo m_`i'_10:repest PISA2015, estimate(freq immig if cnt == `i' & immig !=. & escs !=.& language !=., count levels(1 2 3))
eststo m_`i'_11:repest PISA2015, estimate(freq language if cnt == `i' & immig !=. & escs !=.& language !=., count levels(1 2))

}

esttab m_1_1
esttab m_1_2
esttab m_1_3
esttab m_1_4
esttab m_1_5
esttab m_1_6
esttab m_1_7
esttab m_1_8
esttab m_1_9
esttab m_1_10
esttab m_1_11
	
****************
* Table A6
****************

bysort cnt: tab sex ecec_age if immig !=. & escs !=. & language !=., missing 
bysort cnt: tab immig ecec_age if immig !=. & escs !=. & language !=., missing 
bysort cnt: tab pisa ecec_age if immig !=. & escs !=. & language !=., missing 
bysort cnt: tab escs5 ecec_age if immig !=. & escs !=. & language !=., missing
bysort cnt: tab language ecec_age if immig !=. & escs !=. & language !=., missing 

***********************
* Table A7
***********************

eststo cnt_1_1: repest PISA2015, estimate(stata: myregmargins, reg(std_pv@read i.sex i.immig i.pisa c.age i.language i.ececdnk2 if cnt ==1 & immig !=. & escs !=.& language !=.) margins() moptions(at (ececdnk2 = (2 3 4 5 88 99))))

eststo cnt_1_2: repest PISA2015, estimate(stata: myregmargins, reg(std_pv@read i.sex i.immig i.pisa c.age i.language i.ececdnk2 i.escs5 if cnt ==1 & immig !=. & escs !=.& language !=.) margins() moptions(at (ececdnk2 = (2 3 4 5 88 99))))


foreach i of numlist 2 5 {
eststo cnt_`i'_1: repest PISA2015, estimate(stata: myregmargins, reg(std_pv@read i.sex i.immig i.pisa c.age i.language i.ececfinswe2 if cnt ==`i' & immig !=. & escs !=.& language !=.) margins() moptions(at (ececfinswe2 = (1 2 3 4 5 88 99))))

eststo cnt_`i'_2: repest PISA2015, estimate(stata: myregmargins, reg(std_pv@read i.sex i.immig i.pisa c.age i.language i.ececfinswe2 i.escs5 if cnt ==`i' & immig !=. & escs !=.& language !=.) margins() moptions(at (ececfinswe2 = (1 2 3 4 5 88 99))))

}

foreach i of numlist 3 4 {
eststo cnt_`i'_1: repest PISA2015, estimate(stata: myregmargins, reg(std_pv@read i.sex i.immig i.pisa c.age i.language i.ececicenor2 if cnt ==`i' & immig !=. & escs !=.& language !=.) margins() moptions(at (ececicenor2 = (1 2 3 4 88 99))))

eststo cnt_`i'_2: repest PISA2015, estimate(stata: myregmargins, reg(std_pv@read i.sex i.immig i.pisa c.age i.language i.ececicenor2 i.escs5 if cnt ==`i' & immig !=. & escs !=.& language !=.) margins() moptions(at (ececicenor2 = (1 2 3 4 88 99))))

}

esttab cnt_1_1 cnt_1_2 using dnk_h1.rtf, replace se nostar
esttab cnt_2_1 cnt_2_2 using fin_h1.rtf, replace se nostar
esttab cnt_3_1 cnt_3_2 using ice_h1.rtf, replace se nostar
esttab cnt_4_1 cnt_4_2 using nor_h1.rtf, replace se nostar
esttab cnt_5_1 cnt_5_2 using swe_h1.rtf, replace se nostar

*****************
* Table A8
*****************

eststo cnt_1_3: repest PISA2015, estimate(stata: myregmargins, reg(std_pv@read i.sex i.immig i.pisa c.age i.language i.ececdnk2##i.escs5 if cnt ==1 & immig !=. & escs !=.& language !=.) margins() moptions(at (escs5 = (1 5) ececdnk2 = (2 3 4 5 88 99))))

foreach i of numlist 2 5 {

eststo cnt_`i'_3: repest PISA2015, estimate(stata: myregmargins, reg(std_pv@read i.sex i.immig i.pisa c.age i.language i.ececfinswe2##i.escs5 if cnt ==`i' & immig !=. & escs !=.& language !=.) margins() moptions(at (escs5 = (1 5) ececfinswe2 = (1 2 3 4 5 88 99))))

}

foreach i of numlist 3 4 {

eststo cnt_`i'_3: repest PISA2015, estimate(stata: myregmargins, reg(std_pv@read i.sex i.immig i.pisa c.age i.language i.ececicenor2##i.escs5 if cnt ==`i' & immig !=. & escs !=.& language !=.) margins() moptions(at (escs5 = (1 5) ececicenor2 = (1 2 3 4 88 99) escs5 = (1 5))))

}

esttab cnt_1_3 using dnk_h2.rtf, replace se nostar
esttab cnt_2_3 using fin_h2.rtf, replace se nostar
esttab cnt_3_3 using ice_h2.rtf, replace se nostar
esttab cnt_4_3 using nor_h2.rtf, replace se nostar
esttab cnt_5_3 using swe_h2.rtf, replace se nostar 

**************************
* Table A5
**************************

* Sweden as ref.
* 2-way 
repest PISA2015, estimate(stata: reg(std_pv@read i.sex i.immig i.pisa c.age i.language c.escs5 c.ecec_age2##ib5.cnt) if immig !=. & escs !=.& language !=.)

* 3 way margins
repest PISA2015, estimate(stata: reg(std_pv@read i.sex i.immig i.pisa c.age i.language c.escs5##c.ecec_age2##ib5.cnt) if immig !=. & escs !=.& language !=.)

/*
* Denmark as ref. 

* 2-way 
repest PISA2015, estimate(stata: reg(std_pv@read i.sex i.immig i.pisa c.age i.language c.escs5 c.ecec_age2##ib1.cnt) if immig !=. & escs !=.& language !=.)

* 3 way 
repest PISA2015, estimate(stata: reg(std_pv@read i.sex i.immig i.pisa c.age i.language c.escs5##c.ecec_age2##ib1.cnt) if immig !=. & escs !=.& language !=.)
*/

****************************************************
* Figure 1, Figure 2, Table A2, Table A3, Table A4, Figure A1
****************************************************

* Do country by country to not mix the imputed datasets. 
* School is fixed by adding school as a factor variable -> school fixed effects.  
* Figures to be made in excel based on the calculation after "mimrgns"

* Sweden 

cd "Path"
use data.dta, clear 

keep if cnt == 5

fre ececfinswe2
recode ececfinswe2 (8/99=.), gen(ececfinswe2_2)
fre ececfinswe2_2

mdesc ececfinswe2_2

mi set flong 

mi svyset [pweight= w_fstuwt]  

mi misstable summarize ececfinswe2_2

gen ececfinswe2_2_flag =1
replace ececfinswe2_2_flag=0 if ececfinswe2_2==. 

ttest escs, by(ececfinswe2_2_flag)

set seed 1234543

mi set flong

mi register imputed ececfinswe2_2

mi impute ologit ececfinswe2_2 = escs sex i.immig i.language, add(10) force

mi estimate, saving(swe0) esample(swesample0): svy: reg std_pv1read i.cntschid i.sex i.immig i.pisa c.age i.language i.ececfinswe2_2 if cnt ==5 & immig !=. & escs !=.& language !=. 

* Figure 1 /Table A2
mimrgns using swe0, esample(swesample0) at(ececfinswe2_2 = (1 2 3 4 5))

drop swesample0 
erase swe0.ster

mi estimate, saving(swe1) esample(swesample1): svy: reg std_pv1read i.cntschid i.sex i.immig i.pisa c.age i.language i.ececfinswe2_2 i.escs5 if cnt ==5 & immig !=. & escs !=.& language !=. 

* Figure 1 /Table A2
mimrgns using swe1, esample(swesample1) at(ececfinswe2_2 = (1 2 3 4 5))

drop swesample1 
erase swe1.ster

mi estimate, saving(swe2) esample(swesample2): svy: reg std_pv1read i.cntschid i.sex i.immig i.pisa c.age i.language i.ececfinswe2_2##i.escs5 if cnt ==5 & immig !=. & escs !=.& language !=. 

* Figure 2 /Table A3
mimrgns using swe2, esample(swesample2) at(escs5= (1 5) ececfinswe2_2 = (1 2 3 4 5) )

* Table A4
mimrgns (r(1 5)escs5) using swe2, esample(swesample2) at(ececfinswe2_2 = (1 2 3 4 5) )

drop swesample2 
erase swe2.ster

* hisei instead of escs
mi estimate, saving(swe3) esample(swesample3): svy: reg std_pv1read i.cntschid i.sex i.immig i.pisa c.age i.language i.ececfinswe2_2##i.hisei5 if cnt ==5 & immig !=. & escs !=.& language !=. 

* Figure A1, figure made in excel
mimrgns using swe3, esample(swesample3) at(hisei5= (1 5) ececfinswe2_2 = (1 2 3 4 5) )

drop swesample3
erase swe3.ster

**********
* Denmark 
**********

cd "Path"
use data.dta, clear 

keep if cnt == 1

fre ececdnk2
recode ececdnk2 (8/99=.), gen(ececdnk2_2)
fre ececdnk2_2

mdesc ececdnk2_2

mi set flong 

mi svyset [pweight= w_fstuwt]  

mi misstable summarize ececdnk2_2

gen ececdnk2_2_flag =1
replace ececdnk2_2_flag=0 if ececdnk2_2==. 

ttest escs, by(ececdnk2_2_flag)

set seed 1234543

mi set flong

mi register imputed ececdnk2_2

mi impute ologit ececdnk2_2 = escs sex i.immig i.language, add(10) force

mi estimate, saving(dnk0) esample(dnksample0): svy: reg std_pv1read i.cntschid i.sex i.immig i.pisa c.age i.language i.ececdnk2_2 if cnt ==1 & immig !=. & escs !=.& language !=. 

mimrgns using dnk0, esample(dnksample0) at(ececdnk2_2 = (2 3 4 5))

drop dnksample0 
erase dnk0.ster

mi estimate, saving(dnk1) esample(dnksample1): svy: reg std_pv1read i.cntschid i.sex i.immig i.pisa c.age i.language i.ececdnk2_2 i.escs5 if cnt ==1 & immig !=. & escs !=.& language !=. 

mimrgns using dnk1, esample(dnksample1) at(ececdnk2_2 = (2 3 4 5))

drop dnksample1 
erase dnk1.ster

mi estimate, saving(dnk2) esample(dnksample2): svy: reg std_pv1read i.cntschid i.sex i.immig i.pisa c.age i.language i.ececdnk2_2##i.escs5 if cnt ==1 & immig !=. & escs !=.& language !=. 

mimrgns using dnk2, esample(dnksample2) at(escs5= (1 5) ececdnk2_2 = (2 3 4 5) )

mimrgns (r(1 5)escs5) using dnk2, esample(dnksample2) at(ececdnk2_2 = (2 3 4 5) )

drop dnksample2 
erase dnk2.ster

* hisei 
mi estimate, saving(dnk3) esample(dnksample3): svy: reg std_pv1read i.cntschid i.sex i.immig i.pisa c.age i.language i.ececdnk2_2##i.escs5 if cnt ==1 & immig !=. & escs !=.& language !=. 

mimrgns using dnk3, esample(dnksample3) at(escs5= (1 5) ececdnk2_2 = (2 3 4 5) )

drop dnksample3 
erase dnk3.ster


***************
* Finland
*************

cd "Path"
use data.dta, clear 

keep if cnt == 2

fre ececfinswe2
recode ececfinswe2 (8/99=.), gen(ececfinswe2_2)
fre ececfinswe2_2

mdesc ececfinswe2_2

mi set flong 

mi svyset [pweight= w_fstuwt]  

mi misstable summarize ececfinswe2_2

gen ececfinswe2_2_flag =1
replace ececfinswe2_2_flag=0 if ececfinswe2_2==. 

ttest escs, by(ececfinswe2_2_flag)

set seed 1234543

mi set flong

mi register imputed ececfinswe2_2

mi impute ologit ececfinswe2_2 = escs sex i.immig i.language, add(10) force

mi estimate, saving(fin0) esample(finsample0): svy: reg std_pv1read i.cntschid i.sex i.immig i.pisa c.age i.language i.ececfinswe2_2 if cnt ==2 & immig !=. & escs !=.& language !=. 

mimrgns using fin0, esample(finsample0) at(ececfinswe2_2 = (1 2 3 4 5))

drop finsample0 
erase fin0.ster

mi estimate, saving(fin1) esample(finsample1): svy: reg std_pv1read i.cntschid i.sex i.immig i.pisa c.age i.language i.ececfinswe2_2 i.escs5 if cnt ==2 & immig !=. & escs !=.& language !=. 

mimrgns using fin1, esample(finsample1) at(ececfinswe2_2 = (1 2 3 4 5))

drop finsample1 
erase fin1.ster

mi estimate, saving(fin2) esample(finsample2): svy: reg std_pv1read i.cntschid i.sex i.immig i.pisa c.age i.language i.ececfinswe2_2##i.escs5 if cnt ==2 & immig !=. & escs !=.& language !=. 

mimrgns using fin2, esample(finsample2) at(escs5= (1 5) ececfinswe2_2 = (1 2 3 4 5) )

mimrgns (r(1 5)escs5) using fin2, esample(finsample2) at(ececfinswe2_2 = (1 2 3 4 5) )

drop finsample2 
erase fin2.ster

* hisei 
mi estimate, saving(fin3) esample(finsample3): svy: reg std_pv1read i.cntschid i.sex i.immig i.pisa c.age i.language i.ececfinswe2_2##i.hisei5 if cnt ==2 & immig !=. & escs !=.& language !=. 

mimrgns using fin3, esample(finsample3) at(hisei5= (1 5) ececfinswe2_2 = (1 2 3 4 5) )

drop finsample3 
erase fin3.ster

***************
* Iceland
*************

cd "Path"
use data.dta, clear 

keep if cnt == 3

fre ececicenor2
recode ececicenor2 (8/99=.), gen(ececicenor2_2)
fre ececicenor2_2

mdesc ececicenor2_2

mi set flong 

mi svyset [pweight= w_fstuwt]  

mi misstable summarize ececicenor2_2

gen ececicenor2_2_flag =1
replace ececicenor2_2_flag=0 if ececicenor2_2==. 

ttest escs, by(ececicenor2_2_flag)

set seed 1234543

mi set flong

mi register imputed ececicenor2_2

mi impute ologit ececicenor2_2 = escs sex i.immig i.language, add(10) force

mi estimate, saving(ice0) esample(icesample0): svy: reg std_pv1read i.cntschid i.sex i.immig i.pisa c.age i.language i.ececicenor2_2 if cnt ==3 & immig !=. & escs !=.& language !=. 

mimrgns using ice0, esample(icesample0) at(ececicenor2_2 = (1 2 3 4))

drop icesample0 
erase ice0.ster

mi estimate, saving(ice1) esample(icesample1): svy: reg std_pv1read i.cntschid i.sex i.immig i.pisa c.age i.language i.ececicenor2_2 i.escs5 if cnt ==3 & immig !=. & escs !=.& language !=. 

mimrgns using ice1, esample(icesample1) at(ececicenor2_2 = (1 2 3 4))

drop icesample1 
erase ice1.ster

mi estimate, saving(ice2) esample(icesample2): svy: reg std_pv1read i.cntschid i.sex i.immig i.pisa c.age i.language i.ececicenor2_2##i.escs5 if cnt ==3 & immig !=. & escs !=.& language !=. 

mimrgns using ice2, esample(icesample2) at(escs5= (1 5) ececicenor2_2 = (1 2 3 4) )

mimrgns (r(1 5)escs5) using ice2, esample(icesample2) at(ececicenor2_2 = (1 2 3 4) )

drop icesample2 
erase ice2.ster 

* hisei 
mi estimate, saving(ice3) esample(icesample3): svy: reg std_pv1read i.cntschid i.sex i.immig i.pisa c.age i.language i.ececicenor2_2##i.hisei5 if cnt ==3 & immig !=. & escs !=.& language !=. 

mimrgns using ice3, esample(icesample3) at(hisei5= (1 5) ececicenor2_2 = (1 2 3 4) )

drop icesample3 
erase ice3.ster 


***************
* Norway
*************

cd "Path"
use data.dta, clear 

keep if cnt == 4

fre ececicenor2
recode ececicenor2 (8/99=.), gen(ececicenor2_2)
fre ececicenor2_2

mdesc ececicenor2_2

mi set flong 

mi svyset [pweight= w_fstuwt]  

mi misstable summarize ececicenor2_2

gen ececicenor2_2_flag =1
replace ececicenor2_2_flag=0 if ececicenor2_2==. 

ttest escs, by(ececicenor2_2_flag)

set seed 1234543

mi set flong

mi register imputed ececicenor2_2

mi impute ologit ececicenor2_2 = escs sex i.immig i.language, add(10) force

mi estimate, saving(nor0) esample(norsample0): svy: reg std_pv1read i.cntschid i.sex i.immig i.pisa c.age i.language i.ececicenor2_2 if cnt ==4 & immig !=. & escs !=.& language !=. 

mimrgns using nor0, esample(norsample0) at(ececicenor2_2 = (1 2 3 4))

drop norsample0 
erase nor0.ster

mi estimate, saving(nor1) esample(norsample1): svy: reg std_pv1read i.cntschid i.sex i.immig i.pisa c.age i.language i.ececicenor2_2 i.escs5 if cnt ==4 & immig !=. & escs !=.& language !=. 

mimrgns using nor1, esample(norsample1) at(ececicenor2_2 = (1 2 3 4))

drop norsample1 
erase nor1.ster

mi estimate, saving(nor2) esample(norsample2): svy: reg std_pv1read i.cntschid i.sex i.immig i.pisa c.age i.language i.ececicenor2_2##i.escs5 if cnt ==4 & immig !=. & escs !=.& language !=. 

mimrgns using nor2, esample(norsample2) at(escs5= (1 5) ececicenor2_2 = (1 2 3 4) )

mimrgns (r(1 5)escs5) using nor2, esample(norsample2) at(ececicenor2_2 = (1 2 3 4) )

drop norsample2 
erase nor2.ster


* hisei 
mi estimate, saving(nor3) esample(norsample3): svy: reg std_pv1read i.cntschid i.sex i.immig i.pisa c.age i.language i.ececicenor2_2##i.hisei5 if cnt ==4 & immig !=. & escs !=.& language !=. 

mimrgns using nor3, esample(norsample3) at(hisei5= (1 5) ececicenor2_2 = (1 2 3 4) )

drop norsample3 
erase nor3.ster