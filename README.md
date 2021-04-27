# Stata Data and Code for _Methods_ Special Issue on COVID-19 - Harrison, Hofmeyr, Kincaid, Monroe, Ross, Schneider and Swarthout

Open Main.do and run it to reproduce all of the figures and analyses reported in the manuscript. 

Main.do is simple to follow, so if you would like to perform some alternative analyses just set the globals related to specific frames ($doIHME, $doNON_IHME, $doFRAMES23, and $doALLframes) equal to "y" to perform the Bayesian statistical analyses on these frames. Note that you cannot set all of these globals to "y" simultaneously, and if you set $doALLframes == "y" then this will automatically set all other globals to "n".

This repository requires Stata 15 (or above) to incorporate transparency in the figures. The repository also requires the Candara font to render the figures correctly. This is automatically installed in Windows, but may need to be downloaded for MacOS and Linux.
