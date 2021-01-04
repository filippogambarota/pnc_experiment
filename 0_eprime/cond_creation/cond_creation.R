# Packages

library(tidyverse)
library(writexl)

# Loading names

image_table <- read_csv("image_name.csv")

# Eprime values

Weight <- 1
Nested <- ""
Procedure <- "trialProc"
imageName <- image_table$original_name
emotion <- image_table$emotion
gender <- image_table$gender
trialType <- c("valid", "catch")
marker <- ""

# Experiment values


nstimuli <- nrow(image_table)
rep_stimuli <- 13

nvalid <- nstimuli*rep_stimuli
ncatch <- 40
tot_trial_block <- ncatch + nvalid
nblock <- 3

tot_trial <- tot_trial_block * nblock # total trials

# Valid table

valid <- tibble(Weight, Nested, Procedure, imageName, emotion, gender, marker, trialType = trialType[1])

valid <- valid %>% 
  slice(rep(1:n(), each=rep_stimuli))

# Catch table

catch <- tibble(Weight, Nested, Procedure, imageName, emotion, gender, marker, trialType = trialType[2])[1, ]

catch <- catch %>% 
  slice(rep(1:n(), each=ncatch)) %>% 
  mutate(imageName = "catch.png",
         emotion = "noemo",
         gender = "nogender")

# Final table

exp_table <- bind_rows(valid, catch)

# EEG MARKER

# catch = 999

# gender: male = 3; female = 6;
# emotion: fear = 8; neutral = 2;

m_male <- 3
m_female <- 6
m_fear <- 8
m_neutral <- 2
m_catch <- 999

exp_table %>% 
  mutate(m_gender = ifelse(gender == "male", m_male, m_female),
         m_emotion = ifelse(emotion == "fear", m_fear, m_neutral),
         marker = case_when(trialType == "catch" ~ as.character(m_catch),
                            trialType == "valid" ~ paste0(m_emotion, m_gender)),
         marker = as.numeric(marker)) %>% 
  select(-starts_with("m_")) -> exp_table

# Jittered ISI

exp_table$isi <- round(runif(nrow(exp_table), 1400, 1700))

# Writing file

save(exp_table, file = "exp_table.rda")

write_xlsx(exp_table, path = "exp_table.xlsx")
write.table(exp_table, file = "exp_table.txt", sep = "\t", quote = F, row.names = F)
write.table(exp_table, file = "../exp_table.txt", sep = "\t", quote = F, row.names = F)