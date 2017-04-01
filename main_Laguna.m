% Implementation of Traffic Sign Detection based on the article 
% 'Traffic sign recognition application based on image processing techniques', R. Laguna et al., 2014
% 19th World Congress: The International Federation of Automatic Control Cape Town, South Africa

%%
clear;
clc;
close all;

%% Constants

%PATHTRAINING = 'GTSRB_Final_Training_Images/';
PATH_TRAINING = 'Train/';
PATH_TESTING = 'TestIJCNN2013Download/';
TEMPLATE = load('template.mat');
TEMPLATE = TEMPLATE.template;

FINAL_RES = [480 820];
TH_OPEN = 50;
TH_CIRCLE = 3;
TH_OCTAGON = 2;
TH_TRIANGLE_UP = 2;
TH_TRIANGLE_DOWN = 2;
TH_RHOMBUS = 1.9;

%% Load an image and improve it

pathImage = [PATH_TESTING '00019.ppm'];
%pathImage = [PATH_TRAINING 'triangle_up.png'];

% Read image (and determine its resolution)
im = imread(pathImage);
initialRes = [size(im, 1) size(im, 2)];

% Resize image (from initialRes to finalRes)
im = imresize(im, FINAL_RES);
im_original = im;

figure;
imshow(im);
title('Resized image');

% Transform the RGB image to gray scale
im = rgb2gray(im);

figure;
imshow(im);
title('Grayscale image');

% Apply Contrast-limited adaptive histogram equalization (CLAHE)
im = adapthisteq(im);

figure;
imshow(im);
title('Contrast improved image');

%% Detect ROIs

% Detect edges by using the Laplacian of Gaussian (LoG) method
im = edge(im, 'canny');

figure;
imshow(im);
title('Edges');

% Remove smaller components than TH_OPEN pixels (area opening)
im = bwareaopen(im, TH_OPEN);

figure;
imshow(im);
title('Large edges');

% For each region determine: image, centroid, extrema points (2nd is top-right) and pixel list
properties = regionprops(im, 'Image', 'Centroid', 'Extrema', 'PixelList');

%% Analyse the obtained ROIs

for region = 1 : size(properties, 1)
    
    % Determine the centroid
    upperLeftROI = [ceil(min(properties(region).Extrema(:, 1))), ceil(min(properties(region).Extrema(:, 2)))];
    downRightROI = [ceil(max(properties(region).Extrema(:, 1))), ceil(max(properties(region).Extrema(:, 2)))];
    centroid = properties(region).Centroid - upperLeftROI;
      
    % Compute the signature
    properties(region).Extrema = ceil(properties(region).Extrema);
    topLeft = properties(region).Extrema(1, :);  
    startIndex = find(properties(region).PixelList(:, 1) == topLeft(1) & properties(region).PixelList(:, 2) == topLeft(2));
       
    signature = [];
    for pixel = startIndex : size(properties(region).PixelList, 1)
        signature = [signature pdist([properties(region).Centroid; properties(region).PixelList(pixel, :)])];
    end;
    for pixel = 1 : startIndex - 1
        signature = [signature pdist([properties(region).Centroid; properties(region).PixelList(pixel, :)])];
    end;
    
%     % Show the region and its centroid and Top-Left pixel
%     topLeftImageROI = topLeft - upperLeftROI;
%     topLeftImageROI(topLeftImageROI == 0) = 1;
%     
%     figure;
%     imshow(properties(region).Image);
%     
%     hold on;
%     plot(centroid(1), centroid(2), 'xb');
%     
%     hold on;
%     plot(topLeftImageROI(1), topLeftImageROI(2), 'or');    
%     
%     title(sprintf('Region %g, Centroid (X), Top-Left pixel (O)', region))
% 
%     pause;
   
    % Resample
    signature = resample(signature, 100, size(signature, 2));
    
    % Normalize
    range = max(signature) - min(signature);
    signature = (signature - min(signature)) / range;
    
    % Compare the signatures with the known patterns
    match = 0;
    if norm(TEMPLATE(1).signature - signature) <= TH_CIRCLE
        fprintf('Circle - region %g \n', region);
        match = 1;
    end;
    
    if norm(TEMPLATE(2).signature - signature) <= TH_OCTAGON
        fprintf('Octagon - region %g \n', region);
        match = 1;
    end;
    
    if norm(TEMPLATE(5).signature - signature) <= TH_TRIANGLE_UP
        fprintf('Triangle up - region %g \n', region);
        match = 1;
    end;
    
    if norm(TEMPLATE(6).signature - signature) <= TH_TRIANGLE_DOWN
        fprintf('Triangle down - region %g \n', region);
        match = 1;
    end;
    
    if norm(TEMPLATE(3).signature - signature) <= TH_RHOMBUS
        fprintf('Rhombus - region %g \n', region);
        match = 1;
    end;
    
    if match == 1  
        figure;
        
        suptitle(sprintf('Region %g', region));
        
        subplot(1, 2, 1);
        imshow(properties(region).Image);  
              
        subplot(1, 2, 2);
        imshow(im_original(upperLeftROI(2) : downRightROI(2), upperLeftROI(1) : downRightROI(1)));
    end;

end;