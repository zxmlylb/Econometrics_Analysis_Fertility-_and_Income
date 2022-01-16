*Research Project 
*Lily Chen, Bo Liu, Michelle Wang
*drop missing data and negative values
drop if inctot <0
drop if ftotinc ==9999999
drop if ftotinc ==9999998
drop if ftotinc <0
*education categories
gen Less_HS = educ < 6
gen HS = educ ==6
gen Some_col = 0
replace Some_col=1 if educ > 6 & educ <10
gen BA = educ==10
gen Grad = educ >10
*female 
gen female=sex==2
*employed
gen employed = 0
replace employed  = 1 if empstat == 1
*home ownershp
gen ownhome=ownershp==1
*age^2 
gen age2=age^2
*marry 
gen marry = marst==1

*adjust for inflation for female income and family income 
gen real_inc =inctot
replace real_inc=inctot * 1.19 if year==2009 
replace real_inc=inctot * 1.16 if year==2010 
replace real_inc=inctot * 1.14 if year==2011 
replace real_inc=inctot * 1.11 if year==2012 
replace real_inc=inctot * 1.09 if year==2013 
replace real_inc=inctot * 1.07 if year==2014 
replace real_inc=inctot * 1.07 if year==2015 
replace real_inc=inctot * 1.06 if year==2016 
replace real_inc=inctot * 1.03 if year==2017 
replace real_inc=inctot * 1.01 if year==2018 

gen real_finc =ftotinc
replace real_finc=ftotinc * 1.19 if year==2009 
replace real_finc=ftotinc * 1.16 if year==2010 
replace real_finc=ftotinc * 1.14 if year==2011 
replace real_finc=ftotinc * 1.11 if year==2012 
replace real_finc=ftotinc * 1.09 if year==2013 
replace real_finc=ftotinc * 1.07 if year==2014 
replace real_finc=ftotinc * 1.07 if year==2015 
replace real_finc=ftotinc * 1.06 if year==2016 
replace real_finc=ftotinc * 1.03 if year==2017 
replace real_finc=ftotinc * 1.01 if year==2018

*gen real income for spouse 
gen real_sinc = real_finc - real_inc

*real income in 10 thousand 
gen real_inc10000=real_inc/10000
gen real_sinc10000=real_sinc/10000
gen real_finc10000=real_finc/10000

*speaks english 
gen speak_english = 1
replace speak_english=0 if speakeng == 1 
replace speak_english=0 if speakeng == 6  
*race and ethnicity 
gen white_nh=0
replace white_nh=1 if race==1 & hispan==0

gen black_nh=0
replace black_nh=1 if race==2 & hispan==0

gen other_nh=0
replace other_nh=1 if race>2 & hispan==0

gen hispanic=0
replace hispanic=1 if hispan>0
*insurance 
gen insur = 0
replace insur = 1 if hcovany == 2
*naive reg 
reg nchild real_inc, r
reg nchild real_inc10000, r
reg nchild real_finc10000, r
reg nchild real_sinc10000, r
*controlling for other variables 
reg nchild real_inc10000 real_sinc1000 age age2 marry ownhome speak_english black_nh other_nh hispanic insur Less_HS HS Some_col Grad [w=perwt], r 
*time fixed effects 
reg nchild real_inc10000 real_sinc1000 age age2 marry ownhome speak_english black_nh other_nh hispanic insur Less_HS HS Some_col Grad i.year [w=perwt], r 
*interaction term 
gen white_nhXreal_inc= white_nh * real_inc10000
gen black_nhXreal_inc = black_nh *real_inc10000 
gen other_nhXreal_inc = other_nh *real_inc10000 
gen hispanicXreal_inc = hispanic *real_inc10000 

*figure data 
tab year, sum (nchild)
tab year, sum (real_inc)
sum nchild, d

*outreg table 
cd "\\apporto.com\dfs\MIDDLEBURY\Users\lingxic_middlebury\Desktop\New folder"
ssc install outreg2
reg nchild real_inc10000 [w=perwt],r
outreg2 using nchild_inc, excel replace ctitle(naive reg)

reg nchild real_inc10000 real_sinc10000 [w=perwt],r
outreg2 using nchild_inc, excel append ctitle(reg with sinc)

reg nchild real_inc10000 real_sinc10000 black_nh other_nh hispanic black_nhXreal_inc other_nhXreal_inc hispanicXreal_inc[w=perwt], r
outreg2 using nchild_inc, excel append ctitle(reg with sinc, race)

reg nchild real_inc10000 real_sinc1000 age age2 Less_HS HS Some_col Grad [w=perwt], r 
outreg2 using nchild_inc, excel append ctitle(reg with sinc, age, educ)

reg nchild real_inc10000 real_sinc1000 age age2 black_nh other_nh hispanic black_nhXreal_inc other_nhXreal_inc hispanicXreal_inc Less_HS HS Some_col Grad i.year [w=perwt], r 
outreg2 using nchild_inc, excel append ctitle(reg with sinc, age, race, educ)

reg nchild real_inc10000 real_sinc1000 age age2 black_nh other_nh hispanic black_nhXreal_inc other_nhXreal_inc hispanicXreal_inc Less_HS HS Some_col Grad marry ownhome speak_english insur employed i.year [w=perwt], r 
outreg2 using nchild_inc, excel append ctitle(reg with sinc, age, race, educ+other)

*hypothesis test if incrental effect of income on fertilty is different across race 
reg nchild real_inc10000 real_sinc1000 age age2 black_nh other_nh hispanic black_nhXreal_inc other_nhXreal_inc hispanicXreal_inc Less_HS HS Some_col Grad marry ownhome speak_english insur employed i.year [w=perwt], r 
test black_nhXreal_inc=other_nhXreal_inc=hispanicXreal_inc
*figure 3 
gen racecat=.
replace racecat=1 if white_nh==1
replace racecat=2 if black_nh==1
replace racecat=3 if other_nh==1
replace racecat=4 if hispanic==1

label define racecat 1 "white_nh" 2 "black_nh" 3 "other_nh" 4 "hispanic", replace
label values racecat racecat

gen high_inc = 1 
replace high_inc =0 if real_inc<28955

reg nchild i.high_inc##i.racecat
** the following command gives us the marginal effect of college for each race group - it adds beta_1 to beta_interaction for each race
margins, dydx(high_inc) over(racecat)
marginsplot, recast(scatter)  horizontal title("Marginal effects (income level) by Race") subtitle(US ACS 2009-2018) xtitle(income level) ytitle("") name(marginal_effects, replace)
