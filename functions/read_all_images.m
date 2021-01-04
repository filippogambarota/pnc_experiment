% [ims,nim,imname] = readImages(pathname,imformat)
%
% This is the modified version of the original function by Willenbockel et
% al. (2010). I have added a `grayscale` argument to check if the function
% need to convert or not. Use 1 to convert and 0 to not convert
% ------------------------------------------------------------------------

function [ims,nim,imname] = readImages(pathname,imformat, grayscale)

all_images = dir(fullfile(pathname, lower(strcat('*.',imformat)))); % adding lower for more general approach
nim = length(all_images);
ims = cell(nim,1); % create a cell array with 10x1 (column)

if nargout == 3
    imname = cell(nim,1); % if arguments are specifed, preallocate a cell array for images
end

for im = 1:nim
    % read file and info
    im1 = imread(fullfile(pathname,all_images(im).name));
    info = imfinfo(fullfile(pathname,all_images(im).name));
    if grayscale == 1
        if strcmp(info.ColorType(1:4),'gray') ~= 1
           im1 = rgb2gray(im1);
        end
    end
    ims{im} = im1; % assign to cell
    if nargout == 3
        imname{im} = all_images(im).name;
    end
end