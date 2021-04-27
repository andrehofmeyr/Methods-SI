/**********************************************************************/
/*  SECTION 1: Figures  			
    This DO file produces all of the figures for the Methods journal
    submission */
/**********************************************************************/

* Load up the data and change into /Figures/
cd Figures

* Graphics scheme
global scheme "s1color"
set scheme $scheme

*Get the number of waves
summ wave
local Nwaves = r(max)

*Setup for processing of waves -- default is the latest wave
local wave_first = `Nwaves'
local wave_last = `Nwaves'
di "There have been `wave_last' waves"

global doWAVE "0"

if "$doWAVE" == "0" {
	local wave_first = 1
	local wave_last = `Nwaves'
}
forvalues w=1/6 {
	if "$doWAVE" == "`w'" {
		local wave_first = `w'
		local wave_last = `w'
	}
}

*Close putpdf in case it is "open"
capture putpdf clear	

*Set up locals to capture the report dates, horizons, correct answers, correct answers by frame, etc.
local reports "May 29, June 30, July 31, August 31, September 29 and October 29, 2020"
local short_horizon = "June 30, July 31, August 30, September 30, October 30 and December 1 2020"
local short_horizon_ = "June 30, July 30, August 30, September 30, October 30 and December 1"

local reports1 = "May 29, 2020"
local short_horizon1 = "June 30, 2020"
local short_horizon1_ = "June 30"

local reports2 = "June 30, 2020"
local short_horizon2 = "July 30, 2020"
local short_horizon2_ = "July 30"

local reports3 = "July 31, 2020"
local short_horizon3 = "August 30, 2020"
local short_horizon3_ = "August 30"

local reports4 = "August 31, 2020"
local short_horizon4 = "September 30, 2020"
local short_horizon4_ = "September 30"

local reports5 = "September 29, 2020"
local short_horizon5 = "October 30, 2020"
local short_horizon5_ = "October 30"

local reports6 = "October 29, 2020"
local short_horizon6 = "December 1, 2020"
local short_horizon6_ = "December 1"


*Correct answers by wave
local answerq1w1 "2,624,873 cases"
local answerq3w1 "127,299 deaths"
local answerq1w2 "4,473,974 cases"
local answerq3w2 "151,499 deaths"
local answerq1w3 "5,972,356 cases"
local answerq3w3 "182,622 deaths"
local answerq1w4 "7,213,419 cases"
local answerq3w4 "206,402 deaths"

*These need updating
local answerq1w5 "9,024,298 cases"
local answerq3w5 "229,109 deaths"
local answerq5w6 "13,626,022 cases"
local answerq7w6 "269,763 deaths"


*Correct answers x coordinates by question, frame, and wave - Only one-month horizon Qs
*Infections
*Wave 1, Q1
local answercoordf0q1w1 "10.1"
local answercoordf1q1w1 "10.1"
local answercoordf2q1w1 "5.9"
local answercoordf3q1w1 "3.8"

*Wave 2, Q1
local answercoordf0q1w2 "10.35"
local answercoordf1q1w2 "10.4"
local answercoordf2q1w2 "10.2"
local answercoordf3q1w2 "10.1"

*Wave 3, Q1
local answercoordf0q1w3 "1.45"
local answercoordf1q1w3 "2.95"
local answercoordf2q1w3 "1.35"
local answercoordf3q1w3 "1.25"

*Wave 4, Q1
local answercoordf0q1w4 "10.1"
local answercoordf1q1w4 "10.2"
local answercoordf2q1w4 "3.9"
local answercoordf3q1w4 "2.1"

*Wave 5, Q1
local answercoordf0q1w5 "7.2"
local answercoordf1q1w5 "10.05"
local answercoordf2q1w5 "4.9"
local answercoordf3q1w5 "2.2"

*Wave 6, Q5
local answercoordf0q5w6 "10.4"
local answercoordf1q5w6 "10.4"
local answercoordf2q5w6 "10.3"
local answercoordf3q5w6 "10.25"


*Deaths
*Wave 1, Q3
local answercoordf0q3w1 "3.7"
local answercoordf1q3w1 "4.05"
local answercoordf2q3w1 "3.1"
local answercoordf3q3w1 "2.95"

*Wave 2, Q3
local answercoordf0q3w2 "3.05"
local answercoordf1q3w2 "5.95"
local answercoordf2q3w2 "2.1"
local answercoordf3q3w2 "1.9"

*Wave 3, Q3
local answercoordf0q3w3 "3.95"
local answercoordf1q3w3 "4.05"
local answercoordf2q3w3 "3.01"
local answercoordf3q3w3 "2.9"

*Wave 4, Q3
local answercoordf0q3w4 "2.05"
local answercoordf1q3w4 "3.95"
local answercoordf2q3w4 "1.9"
local answercoordf3q3w4 "1.7"

*Wave 5, Q3
local answercoordf0q3w5 "2.9"
local answercoordf1q3w5 "3.99"
local answercoordf2q3w5 "1.47"
local answercoordf3q3w5 "2.53"

*Wave 6, Q7
local answercoordf0q7w6 "8.03"
local answercoordf1q7w6 "10.2"
local answercoordf2q7w6 "3.95"
local answercoordf3q7w6 "2.95"


*Set up some graph properties
* bar color and box color
local barcolor "gs8"
local barcolor "blue"
local boxcolor "none"

* loop over questions and get histograms
forvalues wave = `wave_first'/`wave_last' {
	local questions "1 3" 
	local country = "USA"
	local country_full = "the United States"
	if ("`wave'" == "6") local questions "5 7"

	* start PDF
	putpdf begin

	foreach q of local questions {
		if "`q'" == "1" {
			local topic = "Infections by `short_horizon`wave''"
			local units "Millions of "
		}
		if "`q'" == "3" {
			local topic = "Deaths by `short_horizon`wave''"
			local units "Hundreds of Thousands of "
		}
		if "`q'" == "5" {
			local topic = "Infections by `short_horizon`wave''"
			local units "Millions of "
		}
		if "`q'" == "7" {
			local topic = "Deaths by `short_horizon`wave''"
			local units "Hundreds of Thousands of "
		}

		forvalues f=0/3 {
			* generate value labels on the fly-by..
			forvalues b=1/10 {
				if "`b'" == "10" {
					qui: summ v_lo if question==`q' & frame==`f' & bbin==`b' & wave==`wave'
				}
				else {
					qui: summ v_mid if question==`q' & frame==`f' & bbin==`b' & wave==`wave'
				}
				local v = r(mean)
				if `v' < 1 {
					local v`b'_ = string(`v', "%3.2f")
				}
				if `v' >= 1 & `v' < 100 {
					local v`b'_ = string(`v', "%3.2f")
				}
				if `v' > 100 {
					local v`b'_ = string(`v', "%4.0f")
				}
				if "`b'" == "10" {
					local v`b' = "`v`b'_'+"
					*local v`b' = "`v`b'_'"
				}
				else {
					local v`b' = "`v`b'_'"
				}
				qui: summ v_lo if question==`q' & frame==`f' & bbin==`b' & wave==`wave'
				local v_lo = r(mean)
				qui: summ v_hi if question==`q' & frame==`f' & bbin==`b' & wave==`wave'
				local v_hi = r(mean)
				*di "Country `country' wave `wave' question `q' frame `f' bin `b': lower value is `v_lo', upper value is `v_hi' and mid-point is `v' (or string `v`b'')"
			}
			label define Lframe 1 "`v1'" 2 "`v2'" 3 "`v3'" 4 "`v4'" 5 "`v5'" 6 "`v6'" 7 "`v7'" 8 "`v8'" 9 "`v9'" 10 "`v10'", replace
			label values bbin Lframe
			local extra_text = "Token Allocations from "
			histogram bbin if question==`q' & frame==`f' & wave==`wave' [fweight = choiceI], discrete percent fcolor(`barcolor'%90) fintensity(60) lcolor(`barcolor') ytitle("") ylabel(, labsize(medsmall) angle(horizontal)) xtitle("") xlabel(1(1)10, valuelabel labsize(small)) xline(`answercoordf`f'q`q'w`wave'' ,lpattern(shortdash) lcolor(red)) title("Frame #`f'", box size(medsmall) ring(0) pos(1)) saving(`country'_`q'_`f', replace)
			label values bbin .
		}
		gr combine `country'_`q'_0.gph `country'_`q'_1.gph `country'_`q'_2.gph `country'_`q'_3.gph, ycommon imargin(small) title("Subjective Beliefs about COVID-19 in `country_full':" "`units'`topic'", size(large) span) subtitle("`extra_text'`reports`wave'' (Wave `wave')", size(medsmall) span margin(small)) t2title("CDC Report = `answerq`q'w`wave''", size(small) margin(small) color(red)) l1title("Percentage") saving(`country'_wave`wave'_`q', replace)

		* save to PDF
		graph export pic.png, replace
		putpdf paragraph, halign(center)
		putpdf image pic.png, linebreak width(6)
		if ("`q'" == "1" | "`q'" == "5") putpdf paragraph, halign(center)


		* clean up
		forvalues f=0/3 {
			erase `country'_`q'_`f'.gph
		}
	}

	* save the PDF, also closing it
	putpdf save `country'_wave`wave'_histograms.pdf, replace
	capture erase pic.png

}


cd ..
pwd


/*------------------------------------ End of SECTION 1 ------------------------------------*/




