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

csdid Y_logq1 gdp_logexp gdp_logimp phi_log,  notyet ivar(ij) time(t) gvar(first_t) cluster(num_zone) drimp // wboot to bootstrap 
estat event, estore(cs) // this produces and stores the estimates at the same time
event_plot cs, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-7(1)13) ///
	title("Callaway and Sant'Anna (2020)")) stub_lag(Tp#) stub_lead(Tm#) together

csdid Y_logdur gdp_logexp gdp_logimp phi_log, notyet ivar(ij) time(t) gvar(first_t) cluster(num_zone) drimp // wboot to bootstrap 
estat event, estore(cs1) // this produces and stores the estimates at the same time
event_plot cs1, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-7(1)13) ///
	title("Callaway and Sant'Anna (2020)")) stub_lag(Tp#) stub_lead(Tm#) together
	

// eventstudyinteract of Sun and Abraham (2020)
	eventstudyinteract Y_logq1 L*event F*event, covariates(gdp_logexp gdp_logimp night_logexp1 night_logimp1 phi_log) vce(cluster num_zone) absorb(ij t) cohort(first_t) control_cohort(lastcohort)
	event_plot e(b_iw)#e(V_iw), default_look graph_opt(xtitle("Periods since the event") ///
		ytitle("Average causal effect") xlabel(-4(1)12) title("Sun and Abraham (2020)") name(SA,replace)) ///
		stub_lag(L#event) stub_lead(F#event) together
	matrix sa_b = e(b_iw)
	matrix sa_v = e(V_iw)

	eventstudyinteract Y_logdur L*event F*event, covariates(gdp_logexp gdp_logimp night_logexp1 night_logimp1 phi_log) vce(cluster num_zone) absorb(ij t) cohort(first_t) control_cohort(lastcohort)
	event_plot e(b_iw)#e(V_iw), default_look graph_opt(xtitle("Periods since the event") ///
		ytitle("Average causal effect") xlabel(-4(1)12) title("Sun and Abraham (2020)") name(SA,replace)) ///
		stub_lag(L#event) stub_lead(F#event) together
	matrix sa_bd = e(b_iw)
	matrix sa_vd = e(V_iw)
	
// Combine 3 plots using the stored estimates
event_plot  cs1 sa_b#sa_v sa_bd#sa_vd, ///
	stub_lag(Tp# L#event L#event) stub_lead(Tm# F#event F#event) plottype(scatter) ciplottype(rcap) ///
	together perturb(-0.325(0.13)0.325) trimlead(5) noautolegend ///
	graph_opt(title("Event study estimators", size(medlarge)) ///
		xtitle("Periods since the event") ytitle("Average causal effect") ylabel(-0.6(0.2)0.6)  ///
		legend(order(1 "Duration (Callaway-Sant'Anna)" 3 "Volume (Sun-Abraham)" 5 "Duration (Sun-Abraham)") rows(3) region(style(none))) ///
	/// the following lines replace default_look with something more elaborate
		xline(-0.5, lcolor(gs8) lpattern(dash)) yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ylabel(, angle(horizontal)) ///
	) ///
	lag_opt1(msymbol(O) color(dkorange)) lag_ci_opt1(color(dkorange)) ///
	lag_opt2(msymbol(+) color(cranberry)) lag_ci_opt2(color(cranberry)) ///
	lag_opt3(msymbol(T) color(navy)) lag_ci_opt3(color(navy)) 
