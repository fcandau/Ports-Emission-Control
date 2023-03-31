# -*- coding: utf-8 -*-
"""
Created on Mon Mar 13 21:45:58 2023

@author: fcanda01
"""

import pandas as pd
import numpy as np
# Set the path to the STATA data file
file_path = r"C:\Users\fcanda01\Desktop\data\eca\LLOYDS_data_estimations_2018.dta"
df = pd.read_stata(file_path)


# NTM bilateralized and cleaned

#ntm_o = r"C:\Users\fcanda01\Desktop\data\eca\ntm_o.dta"
#ntm = pd.read_stata(ntm_o)
#ntm['exp_imp'] = ntm['iso_partner'] + ntm['iso_imposing']
#ntm = ntm.drop_duplicates(subset=['exp_imp','year'])
#ntm = ntm.loc[:, ['exp_imp','year','total_ntm']]

# Idem for Lloyds 
df['exp_imp'] = df['iso3_i'] + df['iso3_j']
df = df.rename(columns={'years': 'year'})
# Merge the two databases
#df = pd.merge(df, ntm, on=['exp_imp', 'year'], how='inner')

# Tariffs
file_path = r"C:\Users\fcanda01\Desktop\data\eca\database.dta"
tarif = pd.read_stata(file_path)


#pri = tarif[(tarif['iso_exp'] == 'USA') | (tarif['iso_imp'] == 'USA')]
#pri.replace({'iso_exp': {'USA': 'PRI'}, 'iso_imp': {'USA': 'PRI'}}, inplace=True)

#pri['exp_imp'] = pri['iso_exp'] + pri['iso_imp']
#pri = pri.loc[:, ['exp_imp', 'year','tariff']]

tarif['exp_imp'] = tarif['iso_exp'] + tarif['iso_imp']
tarif = tarif.loc[:, ['exp_imp', 'year','tariff']]

#tarif=pd.concat([tarif, pri])

# Merge the two databases
df = pd.merge(df, tarif, on=['exp_imp', 'year'], how='inner')

# we then build a number for each flows

df["port_imp"] = df["port_j"] + df["iso3_j"]
df["port_exp"] = df["port_i"] + df["iso3_i"]
#we first create a column individual for each flows
df['port_exp_imp'] = df['port_exp'] + df['port_imp']
# we then build a number for each flows
df['ij'], _ = pd.factorize(df['port_exp_imp'])

#test1 = df.drop_duplicates(subset=['ij', 'year'])
#test2 = df[df.duplicated(subset=['ij', 'year'], keep=False)]

#Create zone for treatment
df.loc[(df['iso3_i'].isin(['USA', 'CAN'])), 'num_zone_exp'] = 1
df.loc[(df['iso3_j'].isin(['USA', 'CAN'])), 'num_zone_imp'] = 1
#if exp=1 AND imp=1 then num_code =1
df.loc[(df['num_zone_exp'] == 1) & (df['num_zone_imp'] == 1), 'num_zone'] = 1
#if exp=1 OR imp=1 then num_code =1
df.loc[(df['num_zone_exp'] == 1) | (df['num_zone_imp'] == 1), 'num_zone'] = 1

df.loc[(df['iso3_i'].isin(['LVA', 'POL','FIN','LTU','EST','RUS'])), 'num_zone_exp'] = 2
df.loc[(df['iso3_j'].isin(['LVA', 'POL','FIN','LTU','EST','RUS'])), 'num_zone_imp'] = 2
df.loc[(df['num_zone_exp'] == 2) & (df['num_zone_imp'] == 2), 'num_zone'] = 2
df.loc[(df['num_zone_exp'] == 2) | (df['num_zone_imp'] == 2), 'num_zone'] = 2
df = df[df['num_zone'] != 2]

df.loc[(df['iso3_i'].isin(['FRA', 'GBR','DEU','BEL','NLD'])), 'num_zone_exp'] = 3
df.loc[(df['iso3_j'].isin(['FRA', 'GBR','DEU','BEL','NLD'])), 'num_zone_imp'] = 3
df.loc[(df['num_zone_exp'] == 3) & (df['num_zone_imp'] == 3), 'num_zone'] = 3
df.loc[(df['num_zone_exp'] == 3) | (df['num_zone_imp'] == 3), 'num_zone'] = 3

#df.loc[(df['iso3_i'].isin(['PRI'])), 'num_zone_exp'] = 4
#df.loc[(df['iso3_j'].isin(['PRI'])), 'num_zone_imp'] = 4
#df.loc[(df['num_zone_exp'] == 4) & (df['num_zone_imp'] == 4), 'num_zone'] = 4
#df.loc[(df['num_zone_exp'] == 4) | (df['num_zone_imp'] == 4), 'num_zone'] = 4

df.loc[(df['port_i'].isin(['rosarito','sandiego','sacramento','stockton','porthueneme','longbeach','westport','alameda','sanfrancisco','richmond','antioch','redwoodcity','benicia','manchester'])), 'num_zone_exp'] = 5
df.loc[(df['port_j'].isin(['rosarito','sandiego','sacramento','stockton','porthueneme','longbeach','westport','alameda','sanfrancisco','richmond','antioch','redwoodcity','benicia','manchester'])), 'num_zone_imp'] = 5
df.loc[(df['num_zone_exp'] == 5) & (df['num_zone_imp'] == 5), 'num_zone'] = 5
df.loc[(df['num_zone_exp'] == 5) | (df['num_zone_imp'] == 5), 'num_zone'] = 5


df['num_zone_exp'] = df['num_zone_exp'].fillna(6)
df['num_zone_imp'] = df['num_zone_imp'].fillna(6)
df['num_zone'] = df['num_zone'].fillna(6)


# Use t=1...17 instead of year=2006...2019

df['t'] = pd.Categorical(df['year'], ordered=True,
                          categories=range(2006, 2019)).codes + 1

# Transformation

# Calculate the inverse hyperbolic sine of Y

# Clean/drop unecessary columns
#columns_list = df.columns.tolist()
#print(columns_list)

df=df.drop(columns=['num_zone_exp', 'num_zone_imp','port_imp', 'port_exp', 'port_exp_imp','exp_imp','draft_2008', 'draft_2014', 'implementation_date_sox_i', 'implementation_date_nox_i', 'cumulative_eca_policy_i', 'historic_national_policy_i', 'stringency_sox_i', 'implementation_date_sox_j', 'implementation_date_nox_j', 'cumulative_eca_policy_j', 'historic_national_policy_j', 'stringency_sox_j'])

df["tonnage_1"] = pd.to_numeric(df["tonnage_1"], errors='coerce')
df["tonnage_2"] = pd.to_numeric(df["tonnage_2"], errors='coerce')
df["tonnage_3"] = pd.to_numeric(df["tonnage_3"], errors='coerce')
df["durationh"] = pd.to_numeric(df["durationh"], errors='coerce')
df["durationm"] = pd.to_numeric(df["durationm"], errors='coerce')


# Calculate the inverse hyperbolic sine of Y
df["Y_transq1"] = np.arcsinh(df["tonnage_1"])
df["Y_transq2"] = np.arcsinh(df["tonnage_2"])
df["Y_transq3"] = np.arcsinh(df["tonnage_3"])
df["Y_transd"] = np.arcsinh(df["durationh"])

# Calculate log of different variable

#Tonnage 1 = the work of Heiland (2021) is repeated. If a ship arrives in port with a shallow draft (less than 55% of its maximum draft) then it transits empty. 
#Tonnage 2: same idea but a LLOYDS contact said it was more like 65%. 
#Tonnage 3: we apply the 65% rule and another rule resulting from the study of my data on the port of Bordeaux. When there is a very large draft differential between port n-1 and n, then we consider that the vessel is also in ballast: it travels empty. 
#With these two measurements, we arrive at the conclusion that about 40% of vessels travel empty, which is rather consistent with the literature.

df.loc[df["tonnage_1"] == 0, "tonnage_1"] = 1
df['tonnage_1'] = df['tonnage_1'].fillna(1)
df["Y_logq1"] = np.log(df["tonnage_1"])

df.loc[df["tonnage_2"] == 0, "tonnage_2"] = 1
df['tonnage_2'] = df['tonnage_2'].fillna(1)
df["Y_logq2"] = np.log(df["tonnage_2"])


df.loc[df["tonnage_3"] == 0, "tonnage_3"] = 1
df['tonnage_3'] = df['tonnage_3'].fillna(1)
df["Y_logq3"] = np.log(df["tonnage_3"])



#attention ne faire tourner ci-dessous que pour la durée, car valeur extreme aux deux extremite

df = df[df['durationh'] > 0]
#df = df[df['durationh'] < 500]
df["Y_logdurm"] = np.log(df["durationm"])
df["Y_logdur"] = np.log(df["durationh"])
#summary = df['durationh'].describe()
#print(summary)



# Two variables of night light:  75km and 150 km
df.loc[df["nightlight_1_i"] == 0, "nightlight_1_i"] = 1
df['nightlight_1_i'] = df['nightlight_1_i'].fillna(1)
df["night_logexp1"] = np.log(df["nightlight_1_i"])

df.loc[df["nightlight_2_i"] == 0, "nightlight_2_i"] = 1
df['nightlight_2_i'] = df['nightlight_2_i'].fillna(1)
df["night_logexp2"] = np.log(df["nightlight_2_i"])

df.loc[df["nightlight_1_j"] == 0, "nightlight_1_j"] = 1
df['nightlight_1_j'] = df['nightlight_1_j'].fillna(1)
df["night_logimp1"] = np.log(df["nightlight_1_j"])

df.loc[df["nightlight_2_j"] == 0, "nightlight_2_j"] = 1
df['nightlight_2_j'] = df['nightlight_2_j'].fillna(1)
df["night_logimp2"] = np.log(df["nightlight_2_j"])

df["phi"] = pd.to_numeric(df["tariff"], errors='coerce')
df.loc[df["phi"] == 0, "phi"] = 1
df['phi'] = df['phi'].fillna(1)
df["phi_log"] = np.log(df["phi"])

#df["ntm"] = pd.to_numeric(df["total_ntm"], errors='coerce')
#df.loc[df["ntm"] == 0, "ntm"] = 1
#df['ntm'] = df['ntm'].fillna(1)
#df["ntm_log"] = np.log(df["ntm"])

df["gdp_logexp"] = np.log(df["gdp_i"])
df["gdp_logimp"] = np.log(df["gdp_j"])


# num_zone

#		zone 				num_zone	treated                time
#    North America				1        august 2012 ->2013     8
#        Baltic_sea 			2        august 2005 ->2006     1
#            ECA_NS 			3        august 2007 ->2008     3
# Carribean                     4        august 2014 ->2014     9
# California                    5        2009                   4
#######


# Unit of treatment are flows 

df.loc[(df['num_zone'] == 1) & (df['t'] >= 8), 'treated'] = 1
#df.loc[(df['num_zone'] == 2) & (df['t'] >= 1), 'treated'] = 1
df.loc[(df['num_zone'] == 3) & (df['t'] >= 3), 'treated'] = 1
#df.loc[(df['num_zone'] == 4) & (df['t'] >= 9), 'treated'] = 1
df.loc[(df['num_zone'] == 5) & (df['t'] >= 4), 'treated'] = 1
df['treated'] = df['treated'].fillna(0)
#######

# First_t on zone
df.loc[df['num_zone'] == 1, 'first_t'] = 8
#df.loc[df['num_zone'] == 2, 'first_t'] = 1
df.loc[df['num_zone'] == 3, 'first_t'] = 3
#df.loc[df['num_zone'] == 4, 'first_t'] = 9
df.loc[df['num_zone'] == 5, 'first_t'] = 4

df['first_t'] = df['first_t'].fillna(0)
#######
# Relative time, i.e. number of periods since treated (could be missing if never treated)

df['rel_time']=df['t']-df['first_t']

#######

# Loop over the values from 0 to 15: we want the number of period since the first treatment. The upper bound is found from the first treated
# Detail: 
#    At the time of the treatment, we want a dummy taking 1 when an individual is treated and zero otherwise, we call it L0event. 
#    One year after the treatment, we want a dummy taking 1 one year after the treatment and zero otherwise, we call it L1event.
#    Same reasoning for "L2event", ..., "L13event" 
# Here first group treated in 2006, so 2018-2007=11 positive rel_time, we add +1 in the loop because we want event0, and finally +1, which gives 14 because the loop stops at 13 
# More precisely "for l in range(14)": iterates over a range of integers from 0 to 13 (inclusive)

for l in range(13):
    df[f'L{l}event'] = (df['rel_time'] == l).astype(int)

# That's almost the reverse. We want dummies for each period before the treatment
# Detail: 
#    Just before the treatment, we want a dummy taking 1, we call it F1event. 
#    Two year before, a dummy taking one for that period, F2event
#    and so on.
# Here the last treated is at 9, at max there is 9 period before the treatment for this group
# Below the code "for l in range(1, 0)" iterates over a range of integers from 1 to 13 (inclusive by (1, 13))
#
for l in range(1, 8):
    df[f'F{l}event'] = (df['rel_time'] == -l).astype(int)
df = df.drop(columns=['F1event'])

#last cohort at t=13
df['lastcohort'] = [1 if x == 8 else 0 for x in df['first_t']]

####### export the file with the full sample
df.to_stata('C:/Users/fcanda01/Desktop/data/eca/estim_lloys_did.dta')
#######


