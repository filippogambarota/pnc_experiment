# Packages

library(tidyverse)
library(rprime)

# Load

load("exp_table.rda")

nblock = 3

exp_table <- bind_rows(exp_table, exp_table, exp_table) # full trial list

dat <- readxl::read_xlsx("s1_test.xlsx") # read actual data

# Sanity Check

nrow(dat) == nrow(exp_table) # check the number of trials

keep_col <- which(names(dat) %in% names(exp_table))

dat %>% 
  select(keep_col) %>% 
  group_by(emotion, gender, imageName, marker, trialType) %>% 
  summarise(count = n())

