%%%% Preparing Workspace %%%%

clear
close all

% Seed for reproducibility

%%% Storing all filenames %%%

[all_images, n_image, all_images_name] = readImages("stimuli/raw/selection", 'jpg'); % this function read all images and convert to greyscale / from SHINE toolbox
all_images_name = strrep(all_images_name,"JPG","png"); %convert to png for writing with the same name

%%% Oval Cropping Parameters %%%

x = 130;
y = 226;
width = 300;
height = 407;

%%% MASK Preparation %%%

im_mask = all_images{1};
imshow(im_mask);
ellipse = imellipse(gca,[x y width height]);
MASK = double(ellipse.createMask());
close;

% imcrop(im, [xmin, ymin, width, heigth]
% Il crop è x = 130 y = 226 height = 406 width = 299

MASK = imcrop(MASK,[130 226 299 406]); % creating the cropped mask

for i = 1:length(all_images)
    all_images{i} = imcrop(all_images{i}, [130 226 299 406]);
end

%% Mask Creation

mask_exp = all_images{1}; %random image to create mask

% Exp Mask in RGB value

for i=1:10
    mask_exp_rgb = uint8(randi(255,762/2,562/2,3));
end

mask_exp_rgb = imresize(mask_exp_rgb, 2);
mask_exp_rgb = imcrop(mask_exp_rgb,[130 226 299 406]);
mask_exp_rgb = mask_exp_rgb + 50;

% Adjusting the image luminance

mask_exp = mask_exp + 0; % Adjusting the mask luminance 0 means that the mask is the same

mask_exp = scramble(mask_exp, 100);

imwrite(mask_exp, fullfile(cd, 'stimuli', "final", "mask.png"), "png", "Alpha", MASK);
%imwrite(mask_exp_rgb, fullfile(cd, 'stimuli', "final", "mask_rgb.png"), "png", "Alpha", MASK);

%% Stimuli For Experiment

%% Using the histmatch function

all_images = histMatch(all_images, 1); %match with Avanaki (2009) algorithm

% Creating the png images

for i = 1:length(all_images)
    im = all_images{i};
    imwrite(im, fullfile(cd, 'stimuli','final', all_images_name{i}), "png", "Alpha",MASK);
end

% reload and separating layers

images_exp = cell(n_image, 1);

for i = 1:length(all_images)
    [im, ~, ~] =  imread(fullfile(cd, 'stimuli','final', all_images_name{i}));
    images_exp{i} = im;
end

[~, ~, alpha] = imread(fullfile(cd, 'stimuli','final', all_images_name{1})); % alpha layer in common


%% Table with names

for i = 1:length(all_images_name)
    if contains(all_images_name{i},"afs",'IgnoreCase',true) 
        emotion(i) = "fear";
    elseif contains(all_images_name{i},"nes",'IgnoreCase',true)
        emotion(i) = "neutral";
    end
    if all_images_name{i}(2) == "F"
        gender(i) = "female";
    elseif all_images_name{i}(2) == "M"
        gender(i) = "male";
    end
        id_image{i} =all_images_name{i}([3,4]);
end

stimuli_table = table(images_exp, emotion', gender', char(id_image), all_images_name);
stimuli_table.Properties.VariableNames = ["image", "emotion", "gender", "id", "original_name"];
neutral_stimuli = stimuli_table(stimuli_table.emotion == "neutral", :);
fear_stimuli = stimuli_table(stimuli_table.emotion == "fear", :);

%% Saving

save("stimuli/final/images_exp.mat", "images_exp");
save("stimuli/final/alpha.mat", "alpha");
save("stimuli/final/stimuli_table.mat", "stimuli_table");
save("stimuli/final/fear_stimuli.mat", "fear_stimuli")
save("stimuli/final/neutral_stimuli.mat", "neutral_stimuli")

%% Catch Image

% creating and saving catch image for eprime

im_catch = stimuli_table.image{1};

im_catch = imnoise(im_catch, 'gaussian', 0, 5);

imwrite(im_catch, fullfile(cd, 'stimuli', "final", "catch.png"), "png", "Alpha", MASK);
% imwrite(im_catch, fullfile(cd, '0_eprime', "catch.png"), "png", "Alpha", MASK); % writing catch image
% imwrite(mask_exp, fullfile(cd, '0_eprime', "mask.png"), "png", "Alpha", MASK); %writing mask image

% creating and saving image table

writetable(stimuli_table(:, 2:size(stimuli_table, 2)), fullfile("0_eprime", "cond_creation", "image_name.csv")) % save image name for eprime

sound(sin(2:6000));
disp("Stimuli created! good job man!!")