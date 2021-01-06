function [] = eprimeData(subjectID, fear_stimuli, neutral_stimuli, alpha, final_noise)

    %% Saving Eprime File

    eprime_folder = fullfile("0_eprime", sprintf("S%d", subjectID)); % eprime folder

    if ~ exist(eprime_folder, 'dir')
        mkdir(eprime_folder) % create eprime folder
        fprintf("Cartella EPRIME soggetto %d creata!", subjectID)
    end

    for i = 1:height(fear_stimuli)
        im = imnoise(fear_stimuli.image{i}, 'gaussian', 0, final_noise);
        imwrite(im, fullfile(eprime_folder, fear_stimuli.original_name{i}), 'png', 'alpha', alpha)
    end

    for i = 1:height(neutral_stimuli)
        im = imnoise(neutral_stimuli.image{i}, 'gaussian', 0, final_noise);
        imwrite(im, fullfile(eprime_folder, neutral_stimuli.original_name{i}), 'png', 'alpha', alpha)
    end

    % mask and catch

    eprime_mask =  imread("stimuli\final\mask.png");
    eprime_catch =  imread("stimuli\final\catch.png");

    copyfile("stimuli\final\mask.png", eprime_folder) % copy mask file
    copyfile("stimuli\final\catch.png", eprime_folder) % copy catch file

    fprintf("Stimoli EPRIME soggetto %d creati!", subjectID)