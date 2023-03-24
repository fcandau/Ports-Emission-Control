// Install commands
*ssc install event_plot, replace
*ssc install did_imputation, replace
*https://friosavila.github.io/playingwithstata/main_csdid.html
*ssc install did_multiplegt, replace
*github install lsun20/eventstudyinteract, replace
*ssc install hdfe, replace
* you may need to install eventstudyweights (click help eventstudyweights, follow the link and install)
// Path to data
cd "C:\Users\fcanda01\Desktop\data\eca"
use "estim_grav_did.dta",clear

	
// Estimation Callaway and Sant'Anna (2020)


csdid Y_logp gdp_logexp gdp_logimp phi_log, ivar(ij) time(t) gvar(first_t) notyet cluster(num_zone) drimp // wboot to bootstrap 
estat event, estore(cs) // this produces and stores the estimates at the same time
event_plot cs, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-7(1)13) ///
	title("Callaway and Sant'Anna (2020)")) stub_lag(Tp#) stub_lead(Tm#) together
	

	
// did_imputation of Borusyak et al. (2021)  

	did_imputation Y_logp ij t first_t, controls(gdp_logexp gdp_logimp phi_log) fe(ij t) horizon(0/8) nose cluster(num_zone) alpha(0.1) autosample pretrends(3) 
	event_plot, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") ///
		title("Borusyak et al. (2021) imputation estimator") xlabel(-7(1)13) name(BJS,replace))
	estimates store bjs		


// did_multiplegt of de Chaisemartin and D'Haultfoeuille (2020)

	did_multiplegt Y_logp ij t treated,  average_effect robust_dynamic controls(gdp_logexp gdp_logimp phi_log) dynamic(10) placebo(6) longdiff_placebo breps(100) cluster(num_zone)
	event_plot e(estimates)#e(variances), default_look graph_opt(xtitle("Periods since the event") ///
		ytitle("Average causal effect") title("de Chaisemartin and D'Haultfoeuille (2020)") xlabel(-5(1)5) ///
		name(dCdH,replace)) stub_lag(Effect_#) stub_lead(Placebo_#) together
	matrix dcdh_b = e(estimates)
	matrix dcdh_v = e(variances)


// eventstudyinteract of Sun and Abraham (2020)
*use "estim.dta",clear
*egen timetrend=group(treated t)
*drop F5event F6event F7event F8event
*drop L13event 

	*Estimation	
	
eventstudyinteract Y_logp L*event F*event, covariates(gdp_logexp gdp_logimp phi_log) vce(cluster num_zone) absorb(ij t) cohort(first_t) control_cohort(lastcohort)
	event_plot e(b_iw)#e(V_iw), default_look graph_opt(xtitle("Periods since the event") ///
		ytitle("Average causal effect") xlabel(-4(1)12) title("Sun and Abraham (2020)") name(SA,replace)) ///
		stub_lag(L#event) stub_lead(F#event) together
	matrix sa_b = e(b_iw)
	matrix sa_v = e(V_iw)


// TWFE OLS estimation with first bacon decomp
		
	reghdfe Y_logp gdp_logexp gdp_logimp phi_log F*event L*event, absorb(ij t) vce(cluster num_zone)
	event_plot, default_look stub_lag(L#event) stub_lead(F#event) together ///
		graph_opt(xtitle("Days since the event") ytitle("OLS coefficients") xlabel(-7(1)13) ///
		title("OLS") name(OLS,replace))
	estimates store ols

	
	// Combine Callaway Sant'anna and Chaisemartin-D'Haultfoeuille
event_plot  cs dcdh_b#dcdh_v, ///
	stub_lag(Tp# Effect_#) stub_lead(Tm# Placebo_#) plottype(scatter) ciplottype(rcap) ///
	together perturb(-0.325(0.13)0.325) trimlead(5) noautolegend ///
	graph_opt(title("Event study estimators", size(medlarge)) ///
		xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-7(1)13) ylabel(-0.6(0.2)0.7) ///
		legend(order(1 "Callaway-Sant'Anna" 3 "Chaisemartin-D'Haultfoeuille") ) ///
	/// the following lines replace default_look with something more elaborate
		xline(-0.5, lcolor(gs8) lpattern(dash)) yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ylabel(, angle(horizontal)) ///
	) ///
	lag_opt1(msymbol(O) color(cranberry)) lag_ci_opt1(color(cranberry)) ///
	lag_opt2(msymbol(+) color(blue)) lag_ci_opt2(color(blue)) ///
	lag_opt3(msymbol(Dh) color(navy)) lag_ci_opt3(color(navy)) ///
	lag_opt4(msymbol(Th) color(forest_green)) lag_ci_opt4(color(forest_green)) 

	// Combine Borusyak et al. and Sun-Abraham
event_plot  bjs sa_b#sa_v, ///
	stub_lag(tau# L#event) stub_lead(pre# F#event) plottype(scatter) ciplottype(rcap) ///
	together perturb(-0.325(0.13)0.325) trimlead(5) noautolegend ///
	graph_opt(title("Event study estimators", size(medlarge)) ///
		xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-7(1)13) ylabel(-0.6(0.2)0.7) ///
		legend(order(1 "Borusyak et al." 3 "Sun-Abraham") ) ///
	/// the following lines replace default_look with something more elaborate
		xline(-0.5, lcolor(gs8) lpattern(dash)) yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ylabel(, angle(horizontal)) ///
	) ///
	lag_opt1(msymbol(O) color(cranberry)) lag_ci_opt1(color(cranberry)) ///
	lag_opt2(msymbol(+) color(blue)) lag_ci_opt2(color(blue)) ///
	lag_opt3(msymbol(Dh) color(navy)) lag_ci_opt3(color(navy)) ///
	lag_opt4(msymbol(Th) color(forest_green)) lag_ci_opt4(color(forest_green)) 
