# -*- coding: utf-8 -*-
"""
Created on Mon Mar 13 21:45:58 2023

@author: fcanda01
"""

import pandas as pd
import numpy as np
# Set the path to the STATA data file
file_path = r"C:\Users\fcanda01\Desktop\data\eca\database.dta"
df = pd.read_stata(file_path)

# NTM bilateralized and cleaned

#ntm_o = r"C:\Users\fcanda01\Desktop\data\eca\ntm_o.dta"
#ntm = pd.read_stata(ntm_o)
#ntm['exp_imp'] = ntm['iso_partner'] + ntm['iso_imposing']
#ntm = ntm.drop_duplicates(subset=['exp_imp','year'])
#ntm = ntm.loc[:, ['exp_imp','year','total_ntm']]

# Idem for BACI 
df['exp_imp'] = df['iso_exp'] + df['iso_imp']

# Merge the two databases
#df = pd.merge(df, ntm, on=['exp_imp', 'year'], how='inner')


# we then build a number for each flows
df['ij'], _ = pd.factorize(df['exp_imp'])
#df['ij'] += 1
#test1 = df.drop_duplicates(subset=['ij', 'year'])
#test2 = df[df.duplicated(subset=['exp_imp', 'year'], keep=False)]

#never treated: we reduced slightly the sample to drop all the trade between landlocked countries
df.loc[(df['landlocked_imp'] == 1) & (df['landlocked_exp'] == 1), 'landlocked'] = 1
df = df.drop(df[df['landlocked'] == 1].index)


#Create zone for treatment
df.loc[(df['iso_exp'].isin(['USA', 'CAN'])), 'num_zone_exp'] = 1
df.loc[(df['iso_imp'].isin(['USA', 'CAN'])), 'num_zone_imp'] = 1
#if exp=1 AND imp=1 then num_code =1
df.loc[(df['num_zone_exp'] == 1) & (df['num_zone_imp'] == 1), 'num_zone'] = 1
#if exp=1 OR imp=1 then num_code =1
df.loc[(df['num_zone_exp'] == 1) | (df['num_zone_imp'] == 1), 'num_zone'] = 1


df.loc[(df['iso_exp'].isin(['LVA', 'POL','FIN','LTU','EST','RUS'])), 'num_zone_exp'] = 2
df.loc[(df['iso_imp'].isin(['LVA', 'POL','FIN','LTU','EST','RUS'])), 'num_zone_imp'] = 2
df.loc[(df['num_zone_exp'] == 2) & (df['num_zone_imp'] == 2), 'num_zone'] = 2
df.loc[(df['num_zone_exp'] == 2) | (df['num_zone_imp'] == 2), 'num_zone'] = 2


df.loc[(df['iso_exp'].isin(['FRA', 'GBR','DEU','BEL','NLD'])), 'num_zone_exp'] = 3
df.loc[(df['iso_imp'].isin(['FRA', 'GBR','DEU','BEL','NLD'])), 'num_zone_imp'] = 3
df.loc[(df['num_zone_exp'] == 3) & (df['num_zone_imp'] == 3), 'num_zone'] = 3
df.loc[(df['num_zone_exp'] == 3) | (df['num_zone_imp'] == 3), 'num_zone'] = 3

df['num_zone_exp'] = df['num_zone_exp'].fillna(4)
df['num_zone_imp'] = df['num_zone_imp'].fillna(4)
df['num_zone'] = df['num_zone'].fillna(4)


# Use t=1...17 instead of year=2002...2018

df = df.drop(df[df['year'] < 2004].index)
df['t'] = pd.Categorical(df['year'], ordered=True,
                          categories=range(2004, 2019)).codes + 1

# some test
#df[df['ij'].isnull()]
#
#test = df.loc[df['value'] == 59154.664]
### balance panel
# create a multi-index for individual and time period
# set the column names for individual IDs and time periods

# create a multi-index for individual and time period
# create a multi-index for individual and time period
# set the column names for individual IDs and time periods
# create a multi-index for individual and time period


# create a multi-index for individual and time period
# set the column names for individual IDs and time periods

# Transformation

# Calculate the inverse hyperbolic sine of Y
df["value"] = pd.to_numeric(df["value"], errors='coerce')
df["quantity"] = pd.to_numeric(df["quantity"], errors='coerce')
df["Y_transp"] = np.arcsinh(df["value"])
df["Y_transt"] = np.arcsinh(df["quantity"])

# Calculate log of different variable
df.loc[df["quantity"] == 0, "quantity"] = 1
df['quantity'] = df['quantity'].fillna(1)
df["Y_logt"] = np.log(df["quantity"])

df.loc[df["value"] == 0, "value"] = 1
df['value'] = df['value'].fillna(1)
df["Y_logp"] = np.log(df["value"])
df["gdp_logexp"] = np.log(df["gdp_exp"])
df["gdp_logimp"] = np.log(df["gdp_imp"])

#
df["phi"] = pd.to_numeric(df["tariff"], errors='coerce')
df.loc[df["phi"] == 0, "phi"] = 1
df['phi'] = df['phi'].fillna(1)
df["phi_log"] = np.log(df["phi"])

#df["ntm"] = pd.to_numeric(df["total_ntm"], errors='coerce')
#df["ntm_log"] = np.log(df["ntm"])

# Clean/drop unecessary columns
columns_list = df.columns.tolist()
print(columns_list)
df=df.drop(columns=['exporter', 'importer','iso_imp', 'landlocked_imp', 'landlocked','iso_exp', 'landlocked_exp','num_zone_exp', 'num_zone_imp','implementation_date_sox_exp', 'implementation_date_nox_exp', 'cumulative_eca_policy_exp', 'historic_national_policy_exp', 'international_stringency_exp', 'stringency_sox_exp', 'implementation_date_sox_imp', 'implementation_date_nox_imp', 'cumulative_eca_policy_imp', 'historic_national_policy_imp', 'international_stringency_imp', 'stringency_sox_imp'])

# here I save a new dataset without always treated
#df_w = df[~df['num_zone'].isin([2])]

# treated or not

# num_zone

#		zone 				num_zone	treated                time
#    North America				1        august 2012 ->2013     8
#        Baltic_sea 			2        august 2005 ->2006     1
#            ECA_NS 			3        august 2007 ->2007     2
# Carribean                     4        august 2014 ->2014     9

# Unit of treatment are flows 

df.loc[(df['num_zone'] == 1) & (df['t'] >= 10), 'treated'] = 1
df.loc[(df['num_zone'] == 2) & (df['t'] >= 3), 'treated'] = 1
df.loc[(df['num_zone'] == 3) & (df['t'] >= 5), 'treated'] = 1
df['treated'] = df['treated'].fillna(0)
#######
#######

# First_t on zone
df.loc[df['num_zone'] == 1, 'first_t'] = 10
df.loc[df['num_zone'] == 2, 'first_t'] = 3
df.loc[df['num_zone'] == 3, 'first_t'] = 5
df['first_t'] = df['first_t'].fillna(0)
#######
#######

# Relative time, i.e. number of periods since treated (could be missing if never treated)

# On exporter and importer, finally not used
#df['rel_time_exp']=df['t']-df['first_t_exp']
#df['rel_time_imp']=df['t']-df['first_t_imp']

df['rel_time']=df['t']-df['first_t']

#######
#######

# Loop over the values from 0 to 15: we want the number of period since the first treatment. The upper bound is found from the first treated
# Detail: 
#    At the time of the treatment, we want a dummy taking 1 when an individual is treated and zero otherwise, we call it L0event. 
#    One year after the treatment, we want a dummy taking 1 one year after the treatment and zero otherwise, we call it L1event.
#    Same reasoning for "L2event", ..., "L13event" 
# Here first group treated in 2006, so 2018-2006=12 positive rel_time, we add +1 in the loop because we want event0, and finally +1, which gives 14 because the loop stops at 13 
# More precisely "for l in range(14)": iterates over a range of integers from 0 to 13 (inclusive)

for l in range(14):
    df[f'L{l}event'] = (df['rel_time'] == l).astype(int)

# That's almost the reverse. We want dummies for each period before the treatment
# Detail: 
#    Just before the treatment, we want a dummy taking 1, we call it F1event. 
#    Two year before, a dummy taking one for that period, F2event
#    and so on.
# Here the last treated is at 10, at max there is 10 period before the treatment for this group
# Below the code "for l in range(1, 0)" iterates over a range of integers from 1 to 10 (inclusive by (1, 8))
#
for l in range(1, 10):
    df[f'F{l}event'] = (df['rel_time'] == -l).astype(int)
df = df.drop(columns=['F1event'])

#last cohort at t=10
df['lastcohort'] = [1 if x == 10 else 0 for x in df['first_t']]


####### export the file with the full sample
df.to_stata('C:/Users/fcanda01/Desktop/data/eca/estim_grav_did.dta')
#######
