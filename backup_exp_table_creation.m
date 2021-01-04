%% Experiment Trials Setup

nstim = height(exp_table_temp); %number of single stimuli
stim_rep = 1; %how many repetition of a single stimulus
catch_per = 20; % percentage of catch trials
ntest_trials = 20; %random initial trials

%% Exp Table Creation

exp_table = repmat(exp_table_temp, [stim_rep 1]); % repeat the table n times
nvalid_trials = nstim * stim_rep; % total valid trials
ncatch_trials = round((nvalid_trials/100) * catch_per);
ntrials = nvalid_trials + ncatch_trials + ntest_trials;

table_catch = datasample(exp_table, ncatch_trials); % sample ncatch_trials stimuli
exp_table = [exp_table; table_catch]; % combine the table

trial_type = [ones(nvalid_trials, 1); zeros(ncatch_trials, 1)]; % create vector of 1 (valid trials) and 0 (catch trials)

exp_table.trial_type = trial_type; % add the column to table

%% Exp Table randomization

id_rand = randperm(height(exp_table));

exp_table = exp_table(id_rand, :);

%% Random Initial trials

noise_test = datasample(0:0.01:0.05, ntest_trials); %sample some random noise values;
test_table = datasample(exp_table, ntest_trials);
test_table.trial_type = repmat(99, [ntest_trials 1]);

%% Bind test table and exp table

exp_table = [test_table; exp_table];