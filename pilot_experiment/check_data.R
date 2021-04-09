# Environment -------------------------------------------------------------

library(tidyverse)
library(rstanarm)
library(tidybayes)

# Loading Data ------------------------------------------------------------

# Loading Data - Calibration

calibration <- read_csv("calibration_data/csv/S1.txt") %>% 
  tibble()

# Loading Data - Calibration

eeg <- readxl::read_xlsx("eprime_data/filippo_eprime.xlsx")

# General Check -----------------------------------------------------------

nrow(calibration) # number of trials

# type and number of trials

calibration %>% 
  group_by(trial_type) %>% 
  summarise(n = n()) 

# Response to catch trials

calibration %>% 
  filter(trial_type == 0) %>% 
  group_by(pas) %>% 
  summarise(n = n())

# PAS distribution for gender and emotion

calibration %>% 
  ggplot(aes(x = pas, fill = gender)) +
  geom_bar() +
  facet_wrap(~emotion) +
  cowplot::theme_minimal_grid()

# 0 resp for valid trials

calibration %>% 
  filter(pas == 0 & trial_type == 1)

# Emotion response

calibration %>% 
  filter(pas > 1) %>% 
  mutate(acc = ifelse((emotion == "fear" & emo_resp == 1) |
                        (emotion == "neutral" & emo_resp == 0),
                      yes = 1, no = 0)) %>% 
  summarise(tot = n(),
            correct_emo = sum(acc),
            wrong_emo = tot - correct_emo,
            acc = mean(acc))

# Staircase Analysis ------------------------------------------------------

calibration %>% 
  filter(trial_type == 1) %>% 
  ggplot(aes(x = trial, y = noise, color = as.factor(pas))) +
  geom_hline(yintercept = calibration$noise_est[1], linetype = "dashed", size = 1) +
  geom_line(aes(group = 0), col = "black", size = 0.8) +
  geom_point(size = 5) +
  cowplot::theme_minimal_grid()

# Psychometric Function

calibration %>% 
  filter(trial_type == 1) %>% 
  mutate(y = ifelse(pas <= 1, 0, 1)) -> cal_dat # 0-1 response

# GLM Approach
#http://rstudio-pubs-static.s3.amazonaws.com/446272_5aa2c51c9e2d4e71b2cf8229e205ce64.html

fit <- glm(y ~ noise, data = cal_dat, family = binomial(link = "logit"))

new_dat <- tibble(noise = seq(0, 0.3, 0.001))

new_dat$pred <- predict(fit, newdata = new_dat, type = "response")

new_dat %>% 
  ggplot(aes(x = noise, y = pred)) +
  geom_line(size = 1)

# Bayesian

fit.stan <- stan_glm(y ~ noise, data = cal_dat, family = binomial(link = "logit"))  

# a/b (intercept/slope) = treshold

fit.stan %>% 
  spread_draws(., `(Intercept)`, noise) %>% 
  rename("intercept" = `(Intercept)`) %>% 
  mutate(threshold = -(intercept/noise)) %>% 
  ggplot(aes(x = threshold)) +
  stat_halfeye()

# 95% BCI

fit.stan %>% 
  spread_draws(., `(Intercept)`, noise) %>% 
  rename("intercept" = `(Intercept)`) %>% 
  mutate(threshold = -(intercept/noise)) %>% 
  median_qi(threshold)

# Prediction

new_dat$bayes_pred <- predict(fit.stan, newdata = new_dat, type = "response")

new_dat %>% 
  ggplot(aes(x = noise, y = bayes_pred)) +
  geom_line(size = 1)






