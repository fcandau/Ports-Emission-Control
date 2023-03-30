// Install commands
*ssc install event_plot, replace
*ssc install did_imputation, replace
*https://friosavila.github.io/playingwithstata/main_csdid.html
*ssc install did_multiplegt, replace
*github install lsun20/eventstudyinteract, replace

// Path to data
cd "C:\Users\fcanda01\Desktop\data\eca"
use "estim_lloys_did.dta",clear

reghdfe Y_logq1 treated gdp_logexp gdp_logimp  phi_log, absorb(ij t) vce(cluster num_zone)
reghdfe Y_logdur treated gdp_logexp gdp_logimp  phi_log, absorb(ij t) vce(cluster num_zone)

	
// Estimation with cldid of Callaway and Sant'Anna (2020)

*add notyet

csdid Y_logq1 gdp_logexp gdp_logimp phi_log, notyet ivar(ij) time(t) gvar(first_t) cluster(num_zone) drimp // wboot to bootstrap 
estat event, estore(cs1) // this produces and stores the estimates at the same time
event_plot cs1, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-7(1)13) ///
	title("Callaway and Sant'Anna (2020)")) stub_lag(Tp#) stub_lead(Tm#) together
	
		
// Borusyak et al. (2021)  
did_imputation Y_logq1 ij t first_t, controls(gdp_logexp gdp_logimp phi_log) fe(ij t) horizon(0/8) minn(0) cluster(num_zone) alpha(0.1) autosample pretrends(3) 
	event_plot, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") ///
		title("Borusyak et al. (2021) imputation estimator") xlabel(-7(1)13) name(BJS,replace))
	estimates store bjs		



// did_multiplegt of de Chaisemartin and D'Haultfoeuille (2020)
	did_multiplegt  Y_logq1 ij t treated,  average_effect robust_dynamic controls(gdp_logexp gdp_logimp phi_log) dynamic(5) placebo(3) longdiff_placebo breps(100) cluster(num_zone)
	event_plot e(estimates)#e(variances), default_look graph_opt(xtitle("Periods since the event") ///
		ytitle("Average causal effect") title("de Chaisemartin and D'Haultfoeuille (2020)") xlabel(-5(1)5) ///
		name(dCdH,replace)) stub_lag(Effect_#) stub_lead(Placebo_#) together
	matrix dcdh_b = e(estimates)
	matrix dcdh_v = e(variances)


// TWFE OLS estimation with first bacon decomp

	reghdfe Y_logq1 gdp_logexp gdp_logimp night_logexp1 night_logimp1 phi_log F*event L*event, absorb(ij t) vce(cluster num_zone)
	event_plot, default_look stub_lag(L#event) stub_lead(F#event) together ///
		graph_opt(xtitle("Days since the event") ytitle("OLS coefficients") xlabel(-7(1)13) ///
		title("OLS") name(OLS,replace))
	estimates store ols

// eventstudyinteract of Sun and Abraham (2020)
*use "estim.dta",clear
*egen timetrend=group(treated t)
drop F4event F5event F6event F7event 
*drop L13event 
*Estimation
	eventstudyinteract Y_logq1 L*event F*event, covariates(gdp_logexp gdp_logimp night_logexp1 night_logimp1 phi_log) vce(cluster num_zone) absorb(ij t) cohort(first_t) control_cohort(lastcohort)
	event_plot e(b_iw)#e(V_iw), default_look graph_opt(xtitle("Periods since the event") ///
		ytitle("Average causal effect") xlabel(-4(1)12) title("Sun and Abraham (2020)") name(SA,replace)) ///
		stub_lag(L#event) stub_lead(F#event) together
	matrix sa_b = e(b_iw)
	matrix sa_v = e(V_iw)



	// Combine Borusyak et al. and Sun-Abraham
    event_plot cs ols sa_b#sa_v, ///
	stub_lag(Tp# L#event L#event) stub_lead(Tm# F#event F#event) plottype(scatter) ciplottype(rcap) ///
	together perturb(-0.325(0.13)0.325) trimlead(5) noautolegend ///
	graph_opt(title("Event study estimators", size(medlarge)) ///
		xtitle("Periods since the event") ytitle("Average causal effect") ylabel(-1.2(0.5)1.3)  ///
		legend(order(1 "Callaway-Sant'Anna" 3 "TWFE" 5 "Sun-Abraham") rows(3) region(style(none))) ///
	/// the following lines replace default_look with something more elaborate
		xline(-0.5, lcolor(gs8) lpattern(dash)) yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ylabel(, angle(horizontal)) ///
	) ///
	lag_opt1(msymbol(+) color(dkorange)) lag_ci_opt1(color(dkorange)) ///
	lag_opt2(msymbol(O) color(cranberry)) lag_ci_opt2(color(cranberry)) ///
	lag_opt3(msymbol(T) color(navy)) lag_ci_opt3(color(navy)) 
	
	
event_plot  cs sa_b#sa_v dcdh_b#dcdh_v, ///
	stub_lag(Tp# L#event Effect_#) stub_lead(Tm# F#event Placebo_#) plottype(scatter) ciplottype(rcap) ///
	together perturb(-0.325(0.13)0.325) trimlead(5) noautolegend ///
	graph_opt(title("Event study estimators", size(medlarge)) ///
		xtitle("Periods since the event") ytitle("Average causal effect") ylabel(-0.6(0.2)0.6)  ///
		legend(order(1 "Callaway-Sant'Anna" 3 "Sun-Abraham" 5 "OLS") rows(3) region(style(none))) ///
	/// the following lines replace default_look with something more elaborate
		xline(-0.5, lcolor(gs8) lpattern(dash)) yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ylabel(, angle(horizontal)) ///
	) ///
	lag_opt1(msymbol(O) color(dkorange)) lag_ci_opt1(color(dkorange)) ///
	lag_opt2(msymbol(+) color(cranberry)) lag_ci_opt2(color(cranberry)) ///
	lag_opt3(msymbol(T) color(navy)) lag_ci_opt3(color(navy)) 
	
	
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
event_plot  bjs dcdh_b#dcdh_v cs sa_b#sa_v ols, ///
	stub_lag( tau# Effect_# Tp# L#event L#event) stub_lead( pre# Placebo_# Tm# F#event F#event) plottype(scatter) ciplottype(rcap) ///
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
