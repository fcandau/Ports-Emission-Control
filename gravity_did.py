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

#we first create a column individual for each flows
df['exp_imp'] = df['iso_exp'] + df['iso_imp']
# we then build a number for each flows
df['ij'], _ = pd.factorize(df['exp_imp'])

df = df.drop_duplicates(subset=['exp_imp', 'year'])
test = df[df.duplicated(subset=['exp_imp', 'year'], keep=False)]
####### export the file with the full sample
test.to_stata('C:/Users/fcanda01/Desktop/data/eca/error_duplicate.dta')

#one limit for country like fr that it is wholy integrated in north sea!!

#creation des traitements comme pour une eq de gravite
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

df.loc[(df['iso_exp'].isin(['PRI'])), 'num_zone_exp'] = 4
df.loc[(df['iso_imp'].isin(['PRI'])), 'num_zone_imp'] = 4
df.loc[(df['num_zone_exp'] == 4) & (df['num_zone_imp'] == 4), 'num_zone'] = 4
df.loc[(df['num_zone_exp'] == 4) | (df['num_zone_imp'] == 4), 'num_zone'] = 4

df['num_zone_exp'] = df['num_zone_exp'].fillna(5)
df['num_zone_imp'] = df['num_zone_imp'].fillna(5)
df['num_zone'] = df['num_zone'].fillna(5)


# Use t=1...17 instead of year=2002...2009

df['t'] = pd.Categorical(df['year'], ordered=True,
                          categories=range(2002, 2019)).codes + 1

# Transformation
# Calculate the inverse hyperbolic sine of Y
df["value"] = pd.to_numeric(df["value"], errors='coerce')
df["quantity"] = pd.to_numeric(df["quantity"], errors='coerce')
df["Y_transp"] = np.arcsinh(df["value"])
df["Y_transt"] = np.arcsinh(df["quantity"])

# Calculate log of different variable
df.loc[df["quantity"] == 0, "quantity"] = 1
df["Y_p"] = np.log(df["quantity"])
df.loc[df["value"] == 0, "value"] = 1
df["Y_logp"] = np.log(df["value"])

# treated or not

# num_zone

#		zone 				num_zone	treated                time
#    North America				1        august 2012 ->2013     12
#        Baltic_sea 			2        august 2005 ->2006      5
#            ECA_NS 			3        august 2007 ->2007      6
# Carribean                     4        august 2014 ->2014     13

df.loc[(df['num_zone_exp'] == 1) & (df['t'] >= 12), 'treated_exp'] = 1
df.loc[(df['num_zone_exp'] == 2) & (df['t'] >= 5), 'treated_exp'] = 1
df.loc[(df['num_zone_exp'] == 3) & (df['t'] >= 6), 'treated_exp'] = 1
df.loc[(df['num_zone_exp'] == 4) & (df['t'] >= 13), 'treated_exp'] = 1
df['treated_exp'] = df['treated_exp'].fillna(0)

df.loc[(df['num_zone_imp'] == 1) & (df['t'] >= 12), 'treated_imp'] = 1
df.loc[(df['num_zone_imp'] == 2) & (df['t'] >= 5), 'treated_imp'] = 1
df.loc[(df['num_zone_imp'] == 3) & (df['t'] >= 6), 'treated_imp'] = 1
df.loc[(df['num_zone_imp'] == 4) & (df['t'] >= 13), 'treated_imp'] = 1
df['treated_imp'] = df['treated_imp'].fillna(0)


#######autre possibilite sans distinction importateur/exportateur
#######
df.loc[(df['num_zone'] == 1) & (df['t'] >= 12), 'treated'] = 1
df.loc[(df['num_zone'] == 2) & (df['t'] >= 5), 'treated'] = 1
df.loc[(df['num_zone'] == 3) & (df['t'] >= 6), 'treated'] = 1
df.loc[(df['num_zone'] == 4) & (df['t'] >= 13), 'treated'] = 1
df['treated_exp'] = df['treated_exp'].fillna(0)
#######
#######

# first treatment
df.loc[df['num_zone_exp'] == 1, 'first_t_exp'] = 12
df.loc[df['num_zone_exp'] == 2, 'first_t_exp'] = 5
df.loc[df['num_zone_exp'] == 3, 'first_t_exp'] = 6
df.loc[df['num_zone_exp'] == 4, 'first_t_exp'] = 13
df['first_t_exp'] = df['first_t_exp'].fillna(0)

df.loc[df['num_zone_imp'] == 1, 'first_t_imp'] = 12
df.loc[df['num_zone_imp'] == 2, 'first_t_imp'] = 5
df.loc[df['num_zone_imp'] == 3, 'first_t_imp'] = 6
df.loc[df['num_zone_imp'] == 4, 'first_t_imp'] = 13
df['first_t_imp'] = df['first_t_imp'].fillna(0)

#######autre possibilite sans distinction importateur/exportateur
#######
df.loc[df['num_zone'] == 1, 'first_t'] = 12
df.loc[df['num_zone'] == 2, 'first_t'] = 5
df.loc[df['num_zone'] == 3, 'first_t'] = 6
df.loc[df['num_zone'] == 4, 'first_t'] = 13
df['first_t'] = df['first_t'].fillna(0)
#######
#######

# Relative time, i.e. number of periods since treated (could be missing if never treated)
df['rel_time_exp']=df['t']-df['first_t_exp']
df['rel_time_imp']=df['t']-df['first_t_imp']

#######autre possibilite sans distinction importateur/exportateur
#######
df['rel_time']=df['t']-df['first_t']
df['rel_time']=df['t']-df['first_t']
#######
#######

# Loop over the values from 0 to 13 (correspond to the number of period since the
# first treatment, here 2018-2005=13 +1, namely positive rel_time) and create the columns "L0event", "L1event", ..., "L13event"
for l in range(15):
    df[f'Lexp{l}event'] = (df['rel_time_exp'] == l).astype(int)
for l in range(15):
    df[f'Limp{l}event'] = (df['rel_time_imp'] == l).astype(int)

# Loop over the values from 1 to 13 which is the last treated

for l in range(1, 13):
    df[f'Fexp{l}event'] = (df['rel_time_exp'] == -l).astype(int)
for l in range(1, 13):
    df[f'Fimp{l}event'] = (df['rel_time_imp'] == -l).astype(int)

# Drop the column "F1event"
df = df.drop(columns=['Fexp1event'])
df = df.drop(columns=['Fimp1event'])

####### Autre possibilite sans distinction importateur/exportateur
#######
for l in range(15):
    df[f'L{l}event'] = (df['rel_time'] == l).astype(int)
for l in range(1, 13):
    df[f'F{l}event'] = (df['rel_time'] == -l).astype(int)
df = df.drop(columns=['F1event'])
#######
#######


#last cohort at t=13
df['lastcohort_exp'] = [1 if x == 13 else 0 for x in df['first_t_exp']]
df['lastcohort_imp'] = [1 if x == 13 else 0 for x in df['first_t_imp']]

####### Autre possibilite sans distinction importateur/exportateur
#######
df['lastcohort'] = [1 if x == 13 else 0 for x in df['first_t']]
#######


####### export the file with the full sample
df.to_stata('C:/Users/fcanda01/Desktop/data/eca/estim_grav_did.dta')
#######


