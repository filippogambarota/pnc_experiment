%% Workspace

clear
close all

% Seed the random number generator
[seed,whichGen] = ClockRandSeed;

%% Preparing Subject Folder

[subjectID, stop] = collectinfo(); % call collect info script

if stop
    return
end

%% PTB Setup

PsychDefaultSetup(2);

%% Screen Setup

screenid = max(Screen('Screens'));
black=BlackIndex(screenid);
white = WhiteIndex(screenid);

[w1, rect] = PsychImaging('OpenWindow', screenid, black);

Screen('Flip', w1);

flip = Screen('GetFlipInterval', w1); % get the flip time 1/refresh_rate
slack = flip/2; % force to resfresh rate start

Screen('BlendFunction', w1, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); % this is for displaying png image transparency

topPriorityLevel = MaxPriority(w1); % max priority

[center(1), center(2)] = RectCenter(rect); % center coordinates

%% Keyboard Setup

KbName('UnifyKeyNames');

% Keys

escapeKey = KbName('escape'); % exit the experiment

pas0 = KbName('1!');
pas1 = KbName('2"');
pas2 = KbName('3£');
pas3 = KbName('4$');
pas4 = KbName('5%');
fear = KbName('m');
neutral = KbName('z');
start = KbName('space');

RestrictKeysForKbCheck([pas0, pas1, pas2, pas3, pas4, fear, neutral, escapeKey, start]);

%% Stimuli Duration

% In seconds

fix_dur = 1;  % Fixation cross
mask_dur = 0.5;   % Mask
target_dur = flip*3; % Target
intertrial = 1.5; % ISI

%% Stimuli Loading

load stimuli/final/alpha.mat
mask = imread("stimuli/final/mask.png");
load stimuli/final/fear_stimuli.mat
load stimuli/final/neutral_stimuli.mat

exp_table_temp = [fear_stimuli; neutral_stimuli];

[imageHeight, imageWidth] = size(exp_table_temp.image{1}); %get the image size

%     exp_stim_fear = table2cell(fear_stimuli(:, 1)); % select only images and convert to cell for better use
%     exp_stim_neutral = table2cell(neutral_stimuli(:, 1)); % select only images and convert to cell for better use
%     exp_stim = [exp_stim_fear; exp_stim_neutral];

%% Experiment Trials Setup

nstim = height(exp_table_temp); %number of single stimuli
stim_rep = 5; %how many repetition of a single stimulus
catch_per = 20; % percentage of catch trials
ntest_trials = 15; %random initial trials

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

noise_test = datasample(0:0.01:0.1, ntest_trials); %sample some random noise values;
test_table = datasample(exp_table, ntest_trials); % sample some images as initial trials
test_table.trial_type = repmat(99, [ntest_trials 1]);

%% Bind test table and exp table

exp_table = [test_table; exp_table];

%% Staircase Settings

max_noise = 0.2;
min_noise = 0;
step_noise = 0.04;

step_ratio = 0.871; % Adding step-size rule by Garcia-Perez (2001)

staircase = PAL_AMUD_setupUD('up', 1, 'down', 1, 'stepsizeup', step_noise*step_ratio, 'stepsizedown', step_noise, ...
    'xMax', max_noise, 'xMin', min_noise, 'stopCriterion', 'trials', 'stopRule', nvalid_trials, 'startvalue', min_noise);

% Parameter explanation
% the staircase is set in order to increase the stimulus level after
% a yes (0) response.
% here the p|yes decrease as x increase so before updating the staircase
% (#line 233) the response is reverted.
% Following the Garcia-Perez email, after a NO response the x is
% decreased by the step-up delta and after a yes response the x is
% increased by a step-down delta. the step-down delta comes from the
% equation step-up delta * ratio (0.871)

%% Preallocation vector

resp_emotion = zeros(1000, 1);
resp_visibility = zeros(1000, 1);
id_subj = zeros(1000, 1);
noise_level = zeros(1000, 1);

%%% ------------------------------------------------------------------------------------------------------------------------ %%%
%%% ------------------------------------------------------------------------------------------------------------------------ %%%

%% Experiment

HideCursor;

% Welcome Screen

line1 = 'Benvenuto/a, e grazie per la tua partecipazione!';
line2 = '\n \nLo scopo di questo esperimento è indagare come il cervello elabora consapevolmente le espressioni facciali di un volto';
line3 = '\n \nL’esperimento si divide in due fasi, una prima solo comportamentale ed una seconda in cui l’attività cerebrale verrà registrata con l’elettroencefalogramma (EEG)';

DrawFormattedText(w1, [line1 line2 line3], 'centerblock', 'center', white);
Screen('Flip', w1);
KbStrokeWait; % wait for keypress

% Instructions

line1 = 'In questa prima fase, ti verranno presentate per un breve intervallo, una alla volta al centro dello schermo, una serie di immagini di volti che possono essere neutri o spaventati';
line2 = '\n\nQuesti volti ti verranno presentati velocemente e potrebbero essere visivamente degradati (come le immagini di un televisore che non funziona)';
line3 = '\n\nIl tuo compito consisterà nel riferire quale è stata la tua esperienza consapevole dell’immagine appena presentata.';
line4 = '\n\n\n\nPer farlo ti chiediamo di rispondere dopo ogni immagine alla seguente domanda:';
line5 = '\n\n\n\n"Per favore, scegli l’opzione che meglio descrive la tua esperienza dell’immagine"';
line6 = '\n\n\nPremi 1 se non hai visto nessun volto';
line7 = '\n\nPremi 2 se hai visto un volto, ma non hai visto la sua espressione facciale';
line8 = '\n\nPremi 3 se hai visto un volto, ma hai avuto solo l’impressione di averne visto l’espressione';
line9 = '\n\nPremi 4 se hai visto un volto e sei abbastanza sicuro/a di averne visto l’espressione';
line10 = '\n\nPremi 5 se hai visto un volto e sei sicuro/a di averne visto l’espressione';

DrawFormattedText(w1, [line1 line2 line3 line4 line5 line6 line7 line8 line9 line10], 'centerblock', 'center', white);%line6 line7 line8 line9 line10 line11 line12
Screen('Flip', w1);
KbStrokeWait; % wait for keypress

% Instructions Emotions

line1 = 'Ogniqualvolta risponderai di aver visto sia un volto che la sua espressione, ti verrà chiesto anche di indicare il tipo di espressione emotiva che hai riconosciuto.';
line2 = '\n\nPer rispondere utilizza i tasti:';
line3 = '\n\nPremi il tasto "z" se hai visto un volto neutro';
line4 = '\n\n\n\nPremi il tasto "m" se hai visto un volto spaventato';
line5 = '\n\n\n\n\n È molto importante che tu sappia che non c’è una risposta giusta o sbagliata.';
line6 = '\n\nLo scopo del compito non è indovinare la risposta esatta, ma solo riferire in maniera sincera cosa hai visto.';
line7 = '\n\nPer questo, l’unica cosa che conta è che tu scelga l’opzione che meglio descrive l’esperienza che hai avuto.';

DrawFormattedText(w1, [line1 line2 line3 line4 line5 line6 line7], 'centerblock', 'center', white);%line6 line7 line8 line9 line10 line11 line12
Screen('Flip', w1);
KbStrokeWait; % wait for keypress

% Stimulus Presentation

image_test_index_fear = datasample(exp_table_temp(exp_table_temp.emotion == "fear", "image"), 1);
image_test_index_neutral = datasample(exp_table_temp(exp_table_temp.emotion == "neutral", "image"), 1);

image_test_fear = image_test_index_fear.image{1}; % select a random image to display
image_test_neutral = image_test_index_neutral.image{1}; % select a random image to display
image_test_fear(:,:,2) = alpha;
image_test_neutral(:,:,2) = alpha;

gap=100; % distance from the center
leftRect=[center(1)-gap-imageWidth,center(2)-imageHeight/2,center(1)-gap,center(2)+imageHeight/2]; %left image
rightRect=[center(1)+gap, center(2)-imageHeight/2, center(1)+gap+imageWidth, center(2)+imageHeight/2]; %right image

target_test_neutral = Screen('MakeTexture', w1, image_test_neutral); % Draw the image
target_test_fear = Screen('MakeTexture', w1, image_test_fear); % Draw the image
Screen('DrawTexture', w1, target_test_neutral, [], leftRect,  0);
Screen('DrawTexture', w1, target_test_fear, [], rightRect, 0);
DrawFormattedText(w1, 'Questo è un esempio di un volti che ti potranno essere presentati', 'center', center(2) - 300, 255);
DrawFormattedText(w1, 'Se è tutto chiaro premi la barra spaziatrice per cominciare.', 'center', center(2) + 300, 255);
Screen('Flip', w1);

Screen('Close', [target_test_neutral, target_test_fear]) % close textures

KbStrokeWait;

% Starting Trials

trial = 0;

while ~staircase.stop
    
    trial = trial + 1; % count trials
    
    if trial > ntrials
        trial_table = datasample(exp_table(exp_table.trial_type == 1, :), 1); % random sample row
        exp_table = [exp_table; trial_table];
    elseif trial <= ntrials
        trial_table = exp_table(trial, :); % select only one row
    end
    
    % Pause
    
    if trial == round(ntrials/2)
        
        % Pause Screen
        line1 = 'Puoi prenderti una pausa';
        line2 = '\n \n \nPremi la barra spaziatrice per continuare.';
        DrawFormattedText(w1, [line1, line2],'centerblock', 'center', 255); % 'center', 'center', 255);
        Screen('Flip', w1);
        KbStrokeWait;
        
    end
    
    if trial_table.trial_type == 1 % valid
        noise = staircase.xCurrent; % get staircase noise
    elseif trial_table.trial_type == 0  % catch
        noise = 5; %catch trial with max noise
    elseif trial_table.trial_type == 99 % test
        noise = noise_test(trial);
    end
    
    % Fixation %
    Screen('FillOval', w1, 255, CenterRect([0, 0, 10, 10], rect));
    
    fix_onset = Screen('Flip', w1);
    
    % Target %
    image_trial = trial_table.image{1};
    image_trial = imnoise(image_trial, 'gaussian', 0, noise);
    image_trial(:,:,2) = alpha;
    target = Screen('MakeTexture', w1, image_trial);
    Screen('DrawTexture', w1, target, [], [], 0);
    
    target_onset = Screen('Flip', w1, fix_onset + fix_dur - slack);
    
    % Backward Mask %
    imageTexture = Screen('MakeTexture', w1, mask);
    Screen('DrawTexture', w1, imageTexture, [], [], 0);
    
    mask_onset = Screen('Flip', w1, target_onset + target_dur - slack);
    
    % Awareness Question
    line1 = 'Per favore, scegli l’opzione che meglio descrive la tua esperienza dell’immagine';
    line2 = '\n\n\n\nPremi 1 se non hai visto nessun volto';
    line3 = '\n\nPremi 2 se hai visto un volto, ma non hai visto la sua espressione';
    line4 = '\n\nPremi 3 se hai visto un volto, ma hai avuto solo l’impressione di averne visto l’espressione';
    line5 = '\n\nPremi 4 se hai visto un volto e sei abbastanza sicuro/a di averne visto l’espressione';
    line6 = '\n\nPremi 5 se hai visto un volto e sei sicuro/a di averne visto l’espressione';
    
    DrawFormattedText(w1, [line1, line2, line3, line4, line5 line6],'centerblock', 'center', 255); % 'center', 'center', 255);
    
    Screen('Flip', w1, mask_onset + mask_dur - slack);
    
    % Collecting Keyboard Response
    
    % wait for a response (Esc = exit)
    
    respToBeMade = true;
    while respToBeMade
        [keyIsDown,secs, keyCode] = KbCheck;
        if keyCode(escapeKey)
            ShowCursor;
            sca;
            return
        elseif keyCode(pas0) % pas 0
            visibility = 0;
            resp_trial = 0;
            respToBeMade = false;
            update_staircase = false;
        elseif keyCode(pas1)  % pas 1
            visibility = 1;
            resp_trial = 0;
            respToBeMade = false;
            update_staircase = true;
        elseif keyCode(pas2) % pas 2
            visibility = 2;
            resp_trial = 1;
            respToBeMade = false;
            update_staircase = true;
        elseif keyCode(pas3) % pas 3
            visibility = 3;
            resp_trial = 1;
            respToBeMade = false;
            update_staircase = true;
        elseif keyCode(pas4) % pas 4
            visibility = 4;
            resp_trial = 1;
            respToBeMade = false;
            update_staircase = true;
        end
    end
    
    % Check if emotion has to be specified
    
    if visibility == 2 || visibility == 3 || visibility == 4
        
        % Awareness Question
        line1 = 'Quale espressione facciale hai visto?';
        line2 = '\n\nPremi il tasto "z" se hai visto un volto neutro';
        line3 = '\n\n\n\nPremi il tasto "m" se hai visto un volto spaventato';
        
        DrawFormattedText(w1, [line1, line2, line3],'centerblock', 'center', 255); % 'center', 'center', 255);
        
        Screen('Flip', w1);
        
        % Collecting Keyboard Response
        
        % wait for a response (Esc = exit)
        
        respToBeMade = true;
        while respToBeMade
            [keyIsDown,secs, keyCode] = KbCheck;
            if keyCode(escapeKey)
                ShowCursor;
                sca;
                return
            elseif keyCode(neutral) 
                emotion_trial = 0;
                respToBeMade = false;
            elseif keyCode(fear) 
                emotion_trial = 1;
                respToBeMade = false;
            end
        end
    else
        emotion_trial = NaN;
    end
    
    Screen('Flip', w1);
    
    if trial_table.trial_type == 1 && update_staircase
        % Update Staircase
        % revert resp for staircase
        if resp_trial == 1
            resp_trial_rev = 0;
        else
            resp_trial_rev = 1;
        end
        staircase = PAL_AMUD_updateUD(staircase, resp_trial_rev);
    end
    
    % Save Data Trial-by-Trial
    resp_visibility(trial) = visibility;
    %resp_stair(trial, 1) = resp_trial;
    id_subj(trial) = subjectID;
    noise_level(trial) = noise;
    resp_emotion(trial) = emotion_trial;
    
    % Intertrial Interval %
    WaitSecs(intertrial);
    
    Screen('Close', [target, imageTexture]) % close textures for target and mask
    
end
Screen('Close', w1);
Priority(0);
ShowCursor();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%              END EXPERIMENT              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Analysing Staircase

final_noise = PAL_AMUD_analyzeUD(staircase); % compute the final estimation

%% Saving Data

datastruct = savedata(exp_table, subjectID, noise_level, final_noise, resp_emotion, resp_visibility, staircase, trial, seed);

%% Saving Eprime File

eprimeData(subjectID, fear_stimuli, neutral_stimuli, alpha, final_noise)

%% Backup Session

save(sprintf("calibration_data/S%d/backup_session_S%d", subjectID, subjectID)) %backup the entire session

mess = ("Sessione terminata e dati salvati, è possibile chiudere MATLAB!");
msgbox(mess)
player = audioplayer(cos(1:0.1:3000), 44100); play(player)