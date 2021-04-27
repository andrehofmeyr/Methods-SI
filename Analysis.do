/**********************************************************************/
/*  SECTION 1: Analysis  			
    This DO file performs the Bayesian statistical analyses for the
    Methods journal submission */
/**********************************************************************/

/*----------------------------------------------------*/
   /* [>   1.  Set the globals and start the log   <] */ 
/*----------------------------------------------------*/

* Drop typo in frame 3 of wave 5?
global dropTYPO "y"

* Set up frames for log files
if "$doIHME" == "y" {
	local frames " -- only the IHME frame"
}
if "$doNON_IHME" == "y" {
	local frames " -- only the non-IHME frames"
}
if "$doFRAMES23" == "y" {
	local frames " -- only frames 2 and 3"
}
if "$doALLframes" == "y" {
	local frames " -- all frames"
	global doIHME "n"
	global doNON_IHME "n"
	global doFRAMES23 "n"
}


* Log
log using "Logs/COVID-19 Estimation for Methods paper`frames'.log", replace text name(Analysis)

 
/*----------------------------------------------------*/
   /* [>   2.  Prepare the data   <] */ 
/*----------------------------------------------------*/

	* drop frame 3 for deaths in wave 5 if requested
	if "$dropTYPO" == "y" {
		foreach x in 3 4 7 8 {
			drop if qid == "g`x'q3" & wave==5 & usa==1
		}
	}

	if "$doIHME" == "y" {
		drop if frame > 0
	}
	if "$doNON_IHME" == "y" {
		drop if frame == 0
	}
	if "$doFRAMES23" == "y" {
		drop if frame == 0 | frame == 1
	}

	* binary indicators for later wave
	summ wave
	local Nwaves = r(max)

	* flags for the short-horizon belief questions
	generate int infections = 0
	generate int deaths = 0
	compress qid
	forvalues f=0/3 {
		* for waves 1 through 5
		replace infections = 1 if qid=="g1q`f'" | qid=="g1_usa" | qid=="g1_rsa"
		replace deaths = 1 if qid=="g3q`f'" | qid=="g3_usa" | qid=="g3_rsa"

		* just for wave 6
		replace infections = 1 if wave==6 & qid=="g5q`f'" | qid=="g5_usa" | qid=="g5_rsa"
		replace deaths = 1 if wave==6 & qid=="g7q`f'" | qid=="g7_usa" | qid=="g7_rsa"
	}
	generate int both = 0
	replace both = 1 if infections == 1 | deaths == 1
	tab infections death
	tab both infections
	tab both death
	tab wave infections
	tab wave deaths


 
/*----------------------------------------------------*/
   /* [>   3.  Conduct Bayesian Analyses to test
   				uniformity using OLOGIT				<] */
/*----------------------------------------------------*/

* Ordered logit DGP

* construct ROPE

	* deterministic null
	generate int choiceNULL = 10
	summ choiceNULL
	ologit bbin [fw=choiceNULL] if both==1, cluster(subjectid)
	matrix list e(b)
	matrix list r(table)
	matrix r = r(table)
	forvalues c=1/9 {
		local cut`c'_pe = r[1,`c']
	}
	margins, dydx(*) coeflegend post

	* simulated data
	local low = 0
	local hi = 20
	local rope = 0

	* evaluate ROPE over 100 simulations of random allocation
	qui {
	forvalues sim=1/100 {

		replace choiceNULL = runiformint(`low',`hi')
		summ choiceNULL
		ologit bbin [fw=choiceNULL] if both==1, cluster(subjectid)
		matrix r = r(table)
		forvalues c=1/9 {
			local cut`c'_lo = r[5,`c']
			local cut`c'_hi = r[6,`c']
			local diff = abs(`cut`c'_hi' - `cut`c'_lo')
			if `diff' > `rope' {
				local rope = `diff'
				di "ROPE is now `rope'
			}
			else {
				di "CI difference is now `diff'
			}
		}
		local rope20 = `rope'
		noi: di "After simulation `sim', ROPE is `rope' if random tokens between 0 and 20"
	}
	}
	margins, dydx(*) coeflegend post

	local low = 0
	local hi = 50
	replace choiceNULL = runiformint(`low',`hi')
	summ choiceNULL
	ologit bbin [fw=choiceNULL] if both==1, cluster(subjectid)
	matrix r = r(table)
	local rope = 0
	forvalues c=1/9 {
		local cut`c'_lo = r[5,`c']
		local cut`c'_hi = r[6,`c']
		local diff = abs(`cut`c'_hi' - `cut`c'_lo')
		if `diff' > `rope' {
			local rope = `diff'
			di "ROPE is now `rope'
		}
		else {
			di "CI difference is now `diff'
		}
	}
	local rope50 = `rope'
	di "ROPE is `rope' if random tokens between 0 and 50"
	margins, dydx(*) coeflegend post

	local low = 0
	local hi = 100
	replace choiceNULL = runiformint(`low',`hi')
	summ choiceNULL
	ologit bbin [fw=choiceNULL] if both==1, cluster(subjectid)
	matrix r = r(table)
	local rope = 0
	forvalues c=1/9 {
		local cut`c'_lo = r[5,`c']
		local cut`c'_hi = r[6,`c']
		local diff = abs(`cut`c'_hi' - `cut`c'_lo')
		if `diff' > `rope' {
			local rope = `diff'
			di "ROPE is now `rope'
		}
		else {
			di "CI difference is now `diff'
		}
	}
	local rope100 = `rope'
	di "ROPE is `rope' if random tokens between 0 and 100"
	margins, dydx(*) coeflegend post

	* actual data
	ologit bbin [fw=reportsI] if both==1, cluster(subjectid)
	margins, dydx(*) coeflegend post
	test  (_b[1bn._predict] = 0.1) (_b[2._predict] = 0.1) (_b[3._predict] = 0.1) (_b[4._predict] = 0.1) (_b[5._predict] = 0.1) (_b[6._predict] = 0.1) (_b[7._predict] = 0.1) (_b[8._predict] = 0.1) (_b[9._predict] = 0.1) (_b[10._predict] = 0.1)

	bayes, clevel(95) hpd: ologit bbin [fw=reportsI] if both==1, cluster(subjectid)
	local rope = `rope20'
	forvalues c=1/9 {
		local c`c'_lo = `cut`c'_pe'-`rope'
		local c`c'_hi = `cut`c'_pe'+`rope'
		di "Cut `c' intervals: `c`c'_lo'       `c`c'_hi'"
	}
	bayestest interval ({cut1}, lower(`c1_lo') upper(`c1_hi')) ({cut2}, lower(`c2_lo') upper(`c2_hi')) ({cut3}, lower(`c3_lo') upper(`c3_hi')) ({cut4}, lower(`c4_lo') upper(`c4_hi')) ({cut5}, lower(`c5_lo') upper(`c5_hi')) ({cut6}, lower(`c6_lo') upper(`c6_hi')) ({cut7}, lower(`c7_lo') upper(`c7_hi')) ({cut8}, lower(`c8_lo') upper(`c8_hi')) ({cut9}, lower(`c9_lo') upper(`c9_hi'))
	bayestest interval (({cut1}, lower(`c1_lo') upper(`c1_hi')) ({cut2}, lower(`c2_lo') upper(`c2_hi')) ({cut3}, lower(`c3_lo') upper(`c3_hi')) ({cut4}, lower(`c4_lo') upper(`c4_hi')) ({cut5}, lower(`c5_lo') upper(`c5_hi')) ({cut6}, lower(`c6_lo') upper(`c6_hi')) ({cut7}, lower(`c7_lo') upper(`c7_hi')) ({cut8}, lower(`c8_lo') upper(`c8_hi')) ({cut9}, lower(`c9_lo') upper(`c9_hi')), joint)


* Bayesian version, diffuse priors
	bayes, clevel(95) hpd: ologit bbin [fw=reportsI] if both==1, cluster(subjectid)
	bayestest interval ({cut1}, lower(`c1_lo') upper(`c1_hi')) ({cut2}, lower(`c2_lo') upper(`c2_hi')) ({cut3}, lower(`c3_lo') upper(`c3_hi')) ({cut4}, lower(`c4_lo') upper(`c4_hi')) ({cut5}, lower(`c5_lo') upper(`c5_hi')) ({cut6}, lower(`c6_lo') upper(`c6_hi')) ({cut7}, lower(`c7_lo') upper(`c7_hi')) ({cut8}, lower(`c8_lo') upper(`c8_hi')) ({cut9}, lower(`c9_lo') upper(`c9_hi'))
	bayestest interval (({cut1}, lower(`c1_lo') upper(`c1_hi')) ({cut2}, lower(`c2_lo') upper(`c2_hi')) ({cut3}, lower(`c3_lo') upper(`c3_hi')) ({cut4}, lower(`c4_lo') upper(`c4_hi')) ({cut5}, lower(`c5_lo') upper(`c5_hi')) ({cut6}, lower(`c6_lo') upper(`c6_hi')) ({cut7}, lower(`c7_lo') upper(`c7_hi')) ({cut8}, lower(`c8_lo') upper(`c8_hi')) ({cut9}, lower(`c9_lo') upper(`c9_hi')), joint)
	matrix list r(summary)
	matrix x = r(summary)
	local p_val_both = x[1,1]

	* just infections
	bayes, clevel(95) hpd: ologit bbin [fw=reportsI] if infections==1, cluster(subjectid)
	bayestest interval ({cut1}, lower(`c1_lo') upper(`c1_hi')) ({cut2}, lower(`c2_lo') upper(`c2_hi')) ({cut3}, lower(`c3_lo') upper(`c3_hi')) ({cut4}, lower(`c4_lo') upper(`c4_hi')) ({cut5}, lower(`c5_lo') upper(`c5_hi')) ({cut6}, lower(`c6_lo') upper(`c6_hi')) ({cut7}, lower(`c7_lo') upper(`c7_hi')) ({cut8}, lower(`c8_lo') upper(`c8_hi')) ({cut9}, lower(`c9_lo') upper(`c9_hi'))
	bayestest interval (({cut1}, lower(`c1_lo') upper(`c1_hi')) ({cut2}, lower(`c2_lo') upper(`c2_hi')) ({cut3}, lower(`c3_lo') upper(`c3_hi')) ({cut4}, lower(`c4_lo') upper(`c4_hi')) ({cut5}, lower(`c5_lo') upper(`c5_hi')) ({cut6}, lower(`c6_lo') upper(`c6_hi')) ({cut7}, lower(`c7_lo') upper(`c7_hi')) ({cut8}, lower(`c8_lo') upper(`c8_hi')) ({cut9}, lower(`c9_lo') upper(`c9_hi')), joint)
	matrix x = r(summary)
	local p_val_i = x[1,1]

	* just deaths
	bayes, clevel(95) hpd: ologit bbin [fw=reportsI] if deaths==1, cluster(subjectid)
	bayestest interval ({cut1}, lower(`c1_lo') upper(`c1_hi')) ({cut2}, lower(`c2_lo') upper(`c2_hi')) ({cut3}, lower(`c3_lo') upper(`c3_hi')) ({cut4}, lower(`c4_lo') upper(`c4_hi')) ({cut5}, lower(`c5_lo') upper(`c5_hi')) ({cut6}, lower(`c6_lo') upper(`c6_hi')) ({cut7}, lower(`c7_lo') upper(`c7_hi')) ({cut8}, lower(`c8_lo') upper(`c8_hi')) ({cut9}, lower(`c9_lo') upper(`c9_hi'))
	bayestest interval (({cut1}, lower(`c1_lo') upper(`c1_hi')) ({cut2}, lower(`c2_lo') upper(`c2_hi')) ({cut3}, lower(`c3_lo') upper(`c3_hi')) ({cut4}, lower(`c4_lo') upper(`c4_hi')) ({cut5}, lower(`c5_lo') upper(`c5_hi')) ({cut6}, lower(`c6_lo') upper(`c6_hi')) ({cut7}, lower(`c7_lo') upper(`c7_hi')) ({cut8}, lower(`c8_lo') upper(`c8_hi')) ({cut9}, lower(`c9_lo') upper(`c9_hi')), joint)
	matrix x = r(summary)
	local p_val_d = x[1,1]

* now over waves
forvalues w=1/6 {

	di "Testing just with responses from wave `w':"

	bayes, clevel(95) hpd: ologit bbin [fw=reportsI] if wave==`w' & both==1, cluster(subjectid)
	bayestest interval ({cut1}, lower(`c1_lo') upper(`c1_hi')) ({cut2}, lower(`c2_lo') upper(`c2_hi')) ({cut3}, lower(`c3_lo') upper(`c3_hi')) ({cut4}, lower(`c4_lo') upper(`c4_hi')) ({cut5}, lower(`c5_lo') upper(`c5_hi')) ({cut6}, lower(`c6_lo') upper(`c6_hi')) ({cut7}, lower(`c7_lo') upper(`c7_hi')) ({cut8}, lower(`c8_lo') upper(`c8_hi')) ({cut9}, lower(`c9_lo') upper(`c9_hi'))
	bayestest interval (({cut1}, lower(`c1_lo') upper(`c1_hi')) ({cut2}, lower(`c2_lo') upper(`c2_hi')) ({cut3}, lower(`c3_lo') upper(`c3_hi')) ({cut4}, lower(`c4_lo') upper(`c4_hi')) ({cut5}, lower(`c5_lo') upper(`c5_hi')) ({cut6}, lower(`c6_lo') upper(`c6_hi')) ({cut7}, lower(`c7_lo') upper(`c7_hi')) ({cut8}, lower(`c8_lo') upper(`c8_hi')) ({cut9}, lower(`c9_lo') upper(`c9_hi')), joint)
	matrix x = r(summary)
	local p_val_`w'_both = x[1,1]

	* just infections
	bayes, clevel(95) hpd: ologit bbin [fw=reportsI] if wave==`w' & infections==1, cluster(subjectid)
	bayestest interval ({cut1}, lower(`c1_lo') upper(`c1_hi')) ({cut2}, lower(`c2_lo') upper(`c2_hi')) ({cut3}, lower(`c3_lo') upper(`c3_hi')) ({cut4}, lower(`c4_lo') upper(`c4_hi')) ({cut5}, lower(`c5_lo') upper(`c5_hi')) ({cut6}, lower(`c6_lo') upper(`c6_hi')) ({cut7}, lower(`c7_lo') upper(`c7_hi')) ({cut8}, lower(`c8_lo') upper(`c8_hi')) ({cut9}, lower(`c9_lo') upper(`c9_hi'))
	bayestest interval (({cut1}, lower(`c1_lo') upper(`c1_hi')) ({cut2}, lower(`c2_lo') upper(`c2_hi')) ({cut3}, lower(`c3_lo') upper(`c3_hi')) ({cut4}, lower(`c4_lo') upper(`c4_hi')) ({cut5}, lower(`c5_lo') upper(`c5_hi')) ({cut6}, lower(`c6_lo') upper(`c6_hi')) ({cut7}, lower(`c7_lo') upper(`c7_hi')) ({cut8}, lower(`c8_lo') upper(`c8_hi')) ({cut9}, lower(`c9_lo') upper(`c9_hi')), joint)
	matrix x = r(summary)
	local p_val_`w'_i = x[1,1]

	* just deaths
	bayes, clevel(95) hpd: ologit bbin [fw=reportsI] if wave==`w'  & deaths==1, cluster(subjectid)
	bayestest interval ({cut1}, lower(`c1_lo') upper(`c1_hi')) ({cut2}, lower(`c2_lo') upper(`c2_hi')) ({cut3}, lower(`c3_lo') upper(`c3_hi')) ({cut4}, lower(`c4_lo') upper(`c4_hi')) ({cut5}, lower(`c5_lo') upper(`c5_hi')) ({cut6}, lower(`c6_lo') upper(`c6_hi')) ({cut7}, lower(`c7_lo') upper(`c7_hi')) ({cut8}, lower(`c8_lo') upper(`c8_hi')) ({cut9}, lower(`c9_lo') upper(`c9_hi'))
	bayestest interval (({cut1}, lower(`c1_lo') upper(`c1_hi')) ({cut2}, lower(`c2_lo') upper(`c2_hi')) ({cut3}, lower(`c3_lo') upper(`c3_hi')) ({cut4}, lower(`c4_lo') upper(`c4_hi')) ({cut5}, lower(`c5_lo') upper(`c5_hi')) ({cut6}, lower(`c6_lo') upper(`c6_hi')) ({cut7}, lower(`c7_lo') upper(`c7_hi')) ({cut8}, lower(`c8_lo') upper(`c8_hi')) ({cut9}, lower(`c9_lo') upper(`c9_hi')), joint)
	matrix x = r(summary)
	local p_val_`w'_d = x[1,1]

	* display estimates -- full display only after wave 6 is run
	di "Posterior probability for ROPE assuming ordered logit DGP:"
	di "Infections"
	di "       Over all waves: `p_val_i'"
	di "       Wave 1:	   `p_val_1_i'"
	di "       Wave 2:	   `p_val_2_i'"
	di "       Wave 3:	   `p_val_3_i'"
	di "       Wave 4:	   `p_val_4_i'"
	di "       Wave 5:	   `p_val_5_i'"
	di "       Wave 6:	   `p_val_6_i'"
	di "Deaths"
	di "       Over all waves: `p_val_d'"
	di "       Wave 1:	   `p_val_1_d'"
	di "       Wave 2:	   `p_val_2_d'"
	di "       Wave 3:	   `p_val_3_d'"
	di "       Wave 4:	   `p_val_4_d'"
	di "       Wave 5:	   `p_val_5_d'"
	di "       Wave 6:	   `p_val_6_d'"
	di "Both Infections and Deaths"
	di "       Over all waves: `p_val_both'"
	di "       Wave 1:	   `p_val_1_both'"
	di "       Wave 2:	   `p_val_2_both'"
	di "       Wave 3:	   `p_val_3_both'"
	di "       Wave 4:	   `p_val_4_both'"
	di "       Wave 5:	   `p_val_5_both'"
	di "       Wave 6:	   `p_val_6_both'"

}

* display estimates
di "Posterior probability for ROPE assuming ordered logit DGP:"
di "Infections"
di "       Over all waves: `p_val_i'"
di "       Wave 1:	   `p_val_1_i'"
di "       Wave 2:	   `p_val_2_i'"
di "       Wave 3:	   `p_val_3_i'"
di "       Wave 4:	   `p_val_4_i'"
di "       Wave 5:	   `p_val_5_i'"
di "       Wave 6:	   `p_val_6_i'"
di "Deaths"
di "       Over all waves: `p_val_d'"
di "       Wave 1:	   `p_val_1_d'"
di "       Wave 2:	   `p_val_2_d'"
di "       Wave 3:	   `p_val_3_d'"
di "       Wave 4:	   `p_val_4_d'"
di "       Wave 5:	   `p_val_5_d'"
di "       Wave 6:	   `p_val_6_d'"
di "Both Infections and Deaths"
di "       Over all waves: `p_val_both'"
di "       Wave 1:	   `p_val_1_both'"
di "       Wave 2:	   `p_val_2_both'"
di "       Wave 3:	   `p_val_3_both'"
di "       Wave 4:	   `p_val_4_both'"
di "       Wave 5:	   `p_val_5_both'"
di "       Wave 6:	   `p_val_6_both'"


 
/*----------------------------------------------------*/
   /* [>   4.  Finish up   <] */ 
/*----------------------------------------------------*/

log close Analysis


/*------------------------------------ End of SECTION 1 ------------------------------------*/
