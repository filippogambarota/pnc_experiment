function [datastruct] = savedata(exp_table, subjectID, noise_level, final_noise, resp_emotion, resp_visibility, staircase, trial, seed)
    
    %% Creating Folders
    
    % Calibration data folder
    
    if ~exist("calibration_data", 'dir')
        mkdir("calibration_data")
    end
    
    % CSV folder
    
    if ~exist("calibration_data\csv", 'dir')
        mkdir("calibration_data\csv")
    end
    
    %% Experiment Table
    
    exp_table.trial = (1:trial)'; %add trials
    exp_table.subject = repelem(subjectID, height(exp_table),1); %subject
    exp_table.noise = noise_level(1:trial); %noise for each trial
    exp_table.pas = resp_visibility(1:trial); %pas response
    exp_table.noise_est = repelem(final_noise, height(exp_table),1); %estimated noise
    exp_table.emo_resp = resp_emotion(1:trial); %emotion response

    %% Struct with all data

    datastruct.exp_table = exp_table; %datatable
    datastruct.seed = seed; %random seed
    datastruct.staircase = staircase; %staircase object

    savefilename = sprintf('calibration_data/S%d/exp_table_S%d.mat', subjectID, subjectID);

    save(savefilename, "datastruct")

    %% TXT files

    csv_table = exp_table;
    csv_table(:, "image") = [];

    savefilename = sprintf('calibration_data/csv/S%d.txt', subjectID);
    writetable(csv_table, savefilename);

    disp("Dati salvati!")