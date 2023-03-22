// Install commands
*ssc install event_plot, replace
*ssc install did_imputation, replace
*https://friosavila.github.io/playingwithstata/main_csdid.html
*ssc install did_multiplegt, replace
*github install lsun20/eventstudyinteract, replace

// Path to data
cd "C:\Users\fcanda01\Desktop\data\eca"
use "estim_lloys_did.dta",clear

	
// Estimation with cldid of Callaway and Sant'Anna (2020)

*add notyet

csdid Y_t2, ivar(ij) time(t) gvar(first_t) notyet cluster(num_zone) drimp // wboot to bootstrap 
estat event, estore(cs) // this produces and stores the estimates at the same time
event_plot cs, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-7(1)13) ///
	title("Callaway and Sant'Anna (2020)")) stub_lag(Tp#) stub_lead(Tm#) together
	

	
// did_imputation of Borusyak et al. (2021)// enlever nose  

	did_imputation Y_t1 ij t first_t, horizon(0/4) minn(0) autosample pretrends(5) 
	event_plot, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") ///
		title("Borusyak et al. (2021) imputation estimator") xlabel(-7(1)13) name(BJS,replace))
	estimates store bjs		


// did_multiplegt of de Chaisemartin and D'Haultfoeuille (2020)

	did_multiplegt Y_c i t treated,  average_effect robust_dynamic controls(timetrend c) dynamic(10) placebo(6) longdiff_placebo breps(100) cluster(num_zone)
	event_plot e(estimates)#e(variances), default_look graph_opt(xtitle("Periods since the event") ///
		ytitle("Average causal effect") title("de Chaisemartin and D'Haultfoeuille (2020)") xlabel(-5(1)5) ///
		name(dCdH,replace)) stub_lag(Effect_#) stub_lead(Placebo_#) together
	matrix dcdh_b = e(estimates)
	matrix dcdh_v = e(variances)


// eventstudyinteract of Sun and Abraham (2020)
*use "estim.dta",clear
*egen timetrend=group(treated t)
drop F5event F6event F7event F8event
drop L13event 

	*Estimation
	eventstudyinteract Y_t1 L*event F*event, vce(cluster num_zone) absorb(ij t) cohort(first_t) control_cohort(lastcohort)
	event_plot e(b_iw)#e(V_iw), default_look graph_opt(xtitle("Periods since the event") ///
		ytitle("Average causal effect") xlabel(-4(1)12) title("Sun and Abraham (2020)") name(SA,replace)) ///
		stub_lag(L#event) stub_lead(F#event) together
	matrix sa_b = e(b_iw)
	matrix sa_v = e(V_iw)


// TWFE OLS estimation with first bacon decomp
// Path to data
use "estimTWFE.dta",clear
//
*egen region_st = group(region)
*egen country = group(ISO3)
*egen timetrend=group(treated t)
sort  ij t
xtset ij t

bacondecomp Y_t1 treated, ddetail

*Saving estimates for later
*Estimation
	reghdfe Y_t1 F*event L*event, absorb(ij t) vce(cluster num_zone)
	event_plot, default_look stub_lag(L#event) stub_lead(F#event) together ///
		graph_opt(xtitle("Days since the event") ytitle("OLS coefficients") xlabel(-7(1)13) ///
		title("OLS") name(OLS,replace))
	estimates store ols

// Combine all plots using the stored estimates
event_plot  cs sa_b#sa_v ols, ///
	stub_lag(Tp# L#event L#event) stub_lead(Tm# F#event F#event) plottype(scatter) ciplottype(rcap) ///
	together perturb(-0.325(0.13)0.325) trimlead(5) noautolegend ///
	graph_opt(title("Event study estimators", size(medlarge)) ///
		xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-5(1)13) ylabel(0(1)3) ///
		legend(order(1 "Callaway-Sant'Anna" 3 "Sun-Abraham" 5 "OLS") rows(3) region(style(none))) ///
	/// the following lines replace default_look with something more elaborate
		xline(-0.5, lcolor(gs8) lpattern(dash)) yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ylabel(, angle(horizontal)) ///
	) ///
	lag_opt1(msymbol(+) color(cranberry)) lag_ci_opt1(color(cranberry)) ///
	lag_opt2(msymbol(O) color(dkorange)) lag_ci_opt2(color(dkorange)) ///
	lag_opt3(msymbol(Dh) color(navy)) lag_ci_opt3(color(navy)) 
	
	// Combine all plots using the stored estimates
event_plot  cs sa_b#sa_v, ///
	stub_lag(Tp# L#event) stub_lead(Tm# F#event) plottype(scatter) ciplottype(rcap) ///
	together perturb(-0.325(0.13)0.325) trimlead(5) noautolegend ///
	graph_opt(title("Event study estimators", size(medlarge)) ///
		xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-7(1)13) ylabel(0(1)3) ///
		legend(order(1 "Callaway-Sant'Anna" 2 "OLS") ) ///
	/// the following lines replace default_look with something more elaborate
		xline(-0.5, lcolor(gs8) lpattern(dash)) yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ylabel(, angle(horizontal)) ///
	) ///
	lag_opt1(msymbol(+) color(cranberry)) lag_ci_opt1(color(cranberry)) ///
	lag_opt2(msymbol(O) color(blue)) lag_ci_opt2(color(blue)) ///
	lag_opt3(msymbol(Dh) color(navy)) lag_ci_opt3(color(navy)) ///
	lag_opt4(msymbol(Th) color(forest_green)) lag_ci_opt4(color(forest_green)) ///
	
	
// Combine all plots using the stored estimates
event_plot btrue# bjs dcdh_b#dcdh_v cs sa_b#sa_v ols, ///
	stub_lag(tau# tau# Effect_# Tp# L#event L#event) stub_lead(pre# pre# Placebo_# Tm# F#event F#event) plottype(scatter) ciplottype(rcap) ///
	together perturb(-0.325(0.13)0.325) trimlead(5) noautolegend ///
	graph_opt(title("Event study estimators", size(medlarge)) ///
		xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-5(1)5) ylabel(0(1)3) ///
		legend(order(1 "True value" 2 "Borusyak et al." 4 "Chaisemartin-D'Haultfoeuille" ///
				6 "Callaway-Sant'Anna" 8 "Sun-Abraham" 10 "OLS") ) ///
	/// the following lines replace default_look with something more elaborate
		xline(-0.5, lcolor(gs8) lpattern(dash)) yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ylabel(, angle(horizontal)) ///
	) ///
	lag_opt1(msymbol(+) color(cranberry)) lag_ci_opt1(color(cranberry)) ///
	lag_opt2(msymbol(O) color(cranberry)) lag_ci_opt2(color(cranberry)) ///
	lag_opt3(msymbol(Dh) color(navy)) lag_ci_opt3(color(navy)) ///
	lag_opt4(msymbol(Th) color(forest_green)) lag_ci_opt4(color(forest_green)) ///
	lag_opt5(msymbol(Sh) color(dkorange)) lag_ci_opt5(color(dkorange)) ///
	lag_opt6(msymbol(Oh) color(purple)) lag_ci_opt6(color(purple)) 
