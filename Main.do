/**********************************************************************/
/*  SECTION 1: Main  			
    This DO file plots the figures and performs the Bayesian statisical 
    analyses for the Methods article by Harrison, Hofmeyr, Kincaid, 
    Monroe, Ross, Schneider and Swarthout */
/**********************************************************************/

capture: clear all

* Log
capture: log close _all
log using "Evaluation of uniform token allocation for US COVID study 1-month timeframe.log", ///
replace text name(main)

* Specify version
version 15
capture: version 16.1
set more off

* Start timer
capture: timer clear
timer on 1

* Allow big machines to process (needs capture so SE can run; comment out if you want to avoid too many processors)
capture: set processors 2
capture: set processors 4
capture: set processors 32

* Need to ensure replications across computers with multiple processors
set seed 1234

* Graphics font
graph set window fontface "Candara"

* Graphics scheme
global scheme "s1color"
set scheme $scheme

* Document what ran
about

 
/*----------------------------------------------------*/
   /* [>   1.  Prepare the data   <] */ 
/*----------------------------------------------------*/
unzipfile "ExpData.zip", replace
use ExpData.dta, clear
 
/*----------------------------------------------------*/
   /* [>   2.  Set globals for figures and analyses   <] */ 
/*----------------------------------------------------*/

* global for figures
global doFIGURES	"y"

* global for analyses
global doANALYSES	"y"

/* [> Decide which frames to analyse -- If you set 
	$doALLframes to "y" then it ignores other globals<] */ 

* global to only do IHME analyses
global doIHME "n"

* global to only do non-IHME analyses
global doNON_IHME "n"

* global to only do frames 2 and 3 analyses
global doFRAMES23 "n"

* global to do analyses for all frames
global doALLframes "y"

 
/*----------------------------------------------------*/
   /* [>   3.  Figures and Analyses   <] */ 
/*----------------------------------------------------*/

* Plot the figures
if "$doFIGURES" == "y" {
	do Figures.do
}

* Conduct analyses
if "$doANALYSES" == "y" {
	do Analysis.do
}

 
/*----------------------------------------------------*/
   /* [>   4.  Check runtime and close log   <] */ 
/*----------------------------------------------------*/

* Time taken
timer off 1
timer list
local secs = r(t1)
local mins = `secs'/60
local hrs = `mins'/60
local secs_ = string(`secs', "%10.0f")
local mins_ = string(`mins', "%4.1f")
local hrs_ = string(`hrs', "%4.2f")
di "Calculations took `secs_' seconds, `mins_' minutes, or `hrs_' hours."

log close main

/*------------------------------------ End of SECTION 1 ------------------------------------*/
