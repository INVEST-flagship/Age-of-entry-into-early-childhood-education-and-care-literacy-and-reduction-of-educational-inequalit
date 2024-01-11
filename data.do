* Markus Laaninen
* majlaan@utu.fi

* set working directory
cd "PATH"

* 2015 data
use pisa_2015.dta, clear 
ren *, lower
drop if cnt != "DNK" & cnt != "FIN" & cnt != "NOR" & cnt != "SWE" & cnt != "ISL" 
fre cnt
gen year = 2015
save pisa_2015_nordic.dta, replace

* 2018 data
use pisa_2018.dta, clear 
ren *, lower
drop if cnt != "DNK" & cnt != "FIN" & cnt != "NOR" & cnt != "SWE" & cnt != "ISL" 
fre cnt
gen year = 2018
save pisa_2018_nordic.dta, replace

*append
append using pisa_2015_nordic.dta, force

* lowercase variable names for repest
ren *, lower

* switch school id from 2018
replace cntschid= cntschid + 1000000000 if year == 2018

* school starting age, keep only students who started at the age of 5-7
fre st126q01ta 
keep if st126q01ta == 3 |st126q01ta == 4  | st126q01ta == 5
ren st126q01ta school_start

* immigration status
recode immig (9=.)
fre immig

* standardize escs (economic social cultural status)
fre escs if escs > 2 // no 999 or 9999 values
egen std_escs = std(escs) if immig !=., by(cnt pisa)
egen escs5 = xtile(escs) if immig !=., nq(5) by(cnt pisa) // to five categories

* rename sex
ren st004d01t sex

* country to numerical variable
egen country = group(cnt)
recode country (1=1 "Denmark")(2=2 "Finland")(3=3 "Iceland")(4=4 "Norway")(5=5 "Sweden"), gen(cnt2)
drop cnt
ren cnt2 cnt

* ECEC starting age 
fre st125q01na
ren st125q01na ecec_age
tab ecec_age cnt
label define mecec_age 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "Did not attend" 8 "Do not remember" 99 "missing"
label value ecec_age mecec_age
label var ecec_age "How old started in ECEC" 

* ecec age for different countries
tab ecec_age cnt
fre ecec_age
recode ecec_age (2=2 "0-2")(3=3 "3")(4=4 "4") (5/7= 5 "5 or older or did not attend")(8=88 "do not remember") (99=99 "missing"), gen(ececdnk2)
recode ecec_age (1=1 "0-1") (2=2 "2")(3=3 "3")(4=4 "4")(5/7= 5 "5 or older or did not attend")(8=88 "do not remember") (99=99 "missing"), gen(ececfinswe2)
recode ecec_age (1=1 "0-1") (2=2 "2")(3=3 "3")(4/7=4 "4 or older or did not attend")(8=88 "do not remember") (99=99 "missing"), gen(ececicenor2)

* hisei 
fre hisei
recode hisei (999/9999=.)
fre hisei

egen std_hisei = std(hisei) if immig !=., by(cnt pisa)
egen hisei5 = xtile(hisei) if immig !=., nq(5) by(cnt pisa) // to five categories

* rename year
ren year pisa

* language
tab st022q01ta cnt
ren st022q01ta language
tab language cnt
fre language
recode language 99=. 

*Standardize PV
* account for the pisa wave, country and  some missing values
* literacy
forvalues t = 1/10 {
egen std_pv`t'read = std(pv`t'read) if immig !=. & escs !=. , by(cnt pisa)
}

save data, replace 