% Partial implementation of Traffic Sign Detection based on the article 
% 'Feature Extraction and Recognition of Road Sign Using Dynamic Image Processing', S. Miyata et al., 2008
% 3rd International Conference on Innovative Computing Information and Control

%%
clear;
clc;
close all;

%% Constants

%PATHTRAINING = 'GTSRB_Final_Training_Images/';
PATH_TRAINING = 'Train/';
PATH_TESTING = 'TestIJCNN2013Download/';
FINAL_RES = [480 820];
EROSION_DILATION_STEPS = 2;
TEMPLATE = load('template.mat');
TEMPLATE = TEMPLATE.template;

%% Load an image

pathImage = [PATH_TESTING '00012.ppm'];
%pathImage = [PATH_TRAINING 'triangle_up.png'];

% Read image (and determine its resolution)
im = imread(pathImage);
initialRes = [size(im, 1) size(im, 2)];

% Resize image (from initialRes to finalRes)
im = imresize(im, FINAL_RES);
im_original = im;

figure;
imshow(im);
title('Original image (RGB)');

%% Apply the detection algorithm

% Transform from RGB to YCbCr
im = rgb2ycbcr(im);

figure;
imshow(im);
title('Original image (YCbCr)');

% Transform Y layer into a binary image
Ybinary = im(:, :, 1);

figure;
imshow(Ybinary);
title('Y layer - original');

Ybinary = (Ybinary > (0.57 * 255)) * 255; 

figure;
imshow(Ybinary);
title('Y layer - binary image');
 
% Transform Cr layer into a binary image
Crbinary = im(:, :, 3);

figure;
imshow(Crbinary);
title('Cr layer - original');

Crbinary = (Crbinary > (0.56 * 255)) * 255; 

figure;
imshow(Crbinary);
title('Cr layer - binary image');

% Dilation and Erosion - Cr layer
SE = strel('disk', 2);
CrbinaryDilEro = Crbinary;

for i = 1 : EROSION_DILATION_STEPS
    CrbinaryDilEro = imdilate(CrbinaryDilEro, SE);
end;

for i = 1 : EROSION_DILATION_STEPS
    CrbinaryDilEro = imerode(CrbinaryDilEro, SE);
end;

figure;
imshow(CrbinaryDilEro);
title('Cr layer (binary) after Erosion and Dilation')
 
% Apply logic AND between binary Y layer and binary Cr layer (after Dilation and Erosion)
white_area = Ybinary & CrbinaryDilEro;

figure;
imshow(white_area);
title('Y AND Cr');