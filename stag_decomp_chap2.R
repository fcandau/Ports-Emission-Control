
# Load packages
#-----------------------------------------------------------------------------
# Libraries
library(readstata13)
library(statar)
library(ggpubr)

#Download latest version of did package and load it
#remotes::install_github("bcallaway11/did")
library(did)
# Use here package to facilitate relative paths
library(here)
# Use these for data manipulation, and plots
library(tidyverse)
library(ggplot2)
library(scales)
library(ggrepel)
library(dplyr)
library(bacondecomp) 
library(TwoWayFEWeights)
library(fixest)
library(glue) 
#---------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------
# Load data
library(haven)
df <- data.frame(read.dta13(here("C:/Users/fcanda01/Desktop/data/eca",'estim_grav_did.dta')))

# Get TWFE coefficient
twfe <- fixest::feols(Y_logp ~ treated + gdp_logexp + gdp_logimp + phi_log | ij + t, 
                      data = df,
                      cluster = ~num_zone)

summary(twfe)

# Get Bacon decomposition 

df_bacon <- bacon(Y_logp ~ treated,
                  data = df,
                  id_var = "ij",
                  time_var = "t")
bacon_summary(df_bacon)

#---------------------------------------------------------------------------------------
# Get de Chaisemartin and D'Haultfoeuille Decomposition
dCDH_decomp <- twowayfeweights(
  df = df, 
  Y = "Y_logp", 
  G = "ij",
  T = "t", 
  D ="treated",
  cmd_type =  "feTR"
)

# Weakly Positive weights
dCDH_positive <- sum(dCDH_decomp$weight[dCDH_decomp$weight>=0])

# Negative weights
dCDH_negative <- sum(dCDH_decomp$weight[dCDH_decomp$weight<0])
summary(dCDH_negative)
#---------------------------------------------------------------------------------------
library(haven)
df <- data.frame(read.dta13(here("C:/Users/fcanda01/Desktop/data/eca",'estim_grav_did_w.dta')))

# Get TWFE coefficient

twfe <- fixest::feols(Y_logp ~ treated| ij + t, 
                      data = df,
                      cluster = ~num_zone)

summary(twfe)

# Get Bacon decomposition 

df_bacon <- bacon(Y_logp ~ treated,
                  data = df,
                  id_var = "num_zone",
                  time_var = "t")
bacon_summary(df_bacon)

#---------------------------------------------------------------------------------------
# Get de Chaisemartin and D'Haultfoeuille Decomposition
dCDH_decomp <- twowayfeweights(
  df = df, 
  Y = "Y_logp", 
  G = "ij",
  T = "t", 
  D ="treated",
  cmd_type =  "feTR"
)

# Weakly Positive weights
dCDH_positive <- sum(dCDH_decomp$weight[dCDH_decomp$weight>=0])

# Negative weights
dCDH_negative <- sum(dCDH_decomp$weight[dCDH_decomp$weight<0])
summary(dCDH_negative)
#---------------------------------------------------------------------------------------
