// Install commands
*ssc install event_plot, replace
*ssc install did_imputation, replace
*ssc install did_multiplegt, replace
*github install lsun20/eventstudyinteract, replace
*ssc install hdfe, replace

// Path to data
cd "C:\Users\fcanda01\Desktop\data\eca"
use "estim_grav_did.dta",clear

// TWFE OLS estimation 		
reghdfe Y_logp treated gdp_logexp gdp_logimp phi_log, absorb(ij t) vce(cluster num_zone)
reghdfe Y_logt treated gdp_logexp gdp_logimp phi_log, absorb(ij t) vce(cluster num_zone)


// Callaway and Sant'Anna (2020)

csdid Y_logp gdp_logexp gdp_logimp phi_log, ivar(ij) time(t) gvar(first_t) notyet cluster(num_zone) drimp // 
estat event, estore(cs) // this produces and stores the estimates at the same time
event_plot cs, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-7(1)13) ///
	title("Callaway and Sant'Anna (2020)")) stub_lag(Tp#) stub_lead(Tm#) together
	
			  
csdid_plot, group(3) title(Baltic Sea) name(m3,replace) legend( row(1))
csdid_plot, group(5) title(North Sea) name(m5,replace) legend( row(1))
csdid_plot, group(10) title(North America) name(m10,replace) legend( row(1))
*csdid_plot, group(9) title(North America) name(m9,replace) legend( row(1))
	
** Here we put all these graph on one page
net install  grc1leg, from(http://www.stata.com/users/vwiggins)
grc1leg m3 m5 m10, nocopies ycommon
grc1leg m3 m5 m10 , nocopies ycommon xcommon note(note: ATT(g,t) within cohorts)
	

// de Chaisemartin and D'Haultfoeuille (2020)
	did_multiplegt Y_logp ij t treated,  average_effect robust_dynamic controls(gdp_logexp gdp_logimp phi_log) dynamic(10) placebo(6) longdiff_placebo breps(100) cluster(num_zone)
	event_plot e(estimates)#e(variances), default_look graph_opt(xtitle("Periods since the event") ///
		ytitle("Average causal effect") title("de Chaisemartin and D'Haultfoeuille (2020)") xlabel(-5(1)5) ///
		name(dCdH,replace)) stub_lag(Effect_#) stub_lead(Placebo_#) together
	matrix dcdh_b = e(estimates)
	matrix dcdh_v = e(variances)

// Sun and Abraham (2021)
    eventstudyinteract Y_logp L*event F*event, covariates(gdp_logexp gdp_logimp phi_log) vce(cluster num_zone) absorb(ij t) cohort(first_t) control_cohort(lastcohort)
	event_plot e(b_iw)#e(V_iw), default_look graph_opt(xtitle("Periods since the event") ///
		ytitle("Average causal effect") xlabel(-4(1)12) title("Sun and Abraham (2020)") name(SA,replace)) ///
		stub_lag(L#event) stub_lead(F#event) together
	matrix sa_b = e(b_iw)
	matrix sa_v = e(V_iw)

// TWFE OLS estimation 			

	reghdfe Y_logp gdp_logexp gdp_logimp phi_log F*event L*event, absorb(ij t) vce(cluster num_zone)
	event_plot, default_look stub_lag(L#event) stub_lead(F#event) together ///
		graph_opt(xtitle("Days since the event") ytitle("OLS coefficients") xlabel(-7(1)13) ///
		title("OLS") name(OLS,replace))
	estimates store ols
	
	
// Combine 3 plots using the stored estimates
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
