% Use Regions with Convolutional Neural Network (R-CNN) for Traffic Signs recognition
% Based on: https://se.mathworks.com/help/vision/examples/object-detection-using-deep-learning.html

%% Load the table with ROI details (name of the image, upper left corner, width, height)

load('TrafficSignsTableV2.mat');
%load('cifar10Net.mat');

% The table has 1213 ROIs (traffic signs) - split into training and testing data sets
TrafficSignsTableTraining = TrafficSignsTable(1:901, :); % Up to image 00640.ppm
TrafficSignsTableTesting = TrafficSignsTable(902:1213, :); % From image 00641.ppm

%% Train the R-CNN Traffic Sign Detector

% Use AlexNet for Transfer Learning
doTraining = true;

if doTraining
    % Set training options
    options = trainingOptions('sgdm', ...
        'MiniBatchSize', 32, ...
        'InitialLearnRate', 1e-3, ...
        'LearnRateSchedule', 'piecewise', ...
        'LearnRateDropFactor', 0.1, ...
        'LearnRateDropPeriod', 100, ...
        'MaxEpochs', 100, ...
        'Verbose', true);

    % Train an R-CNN object detector. This will take several minutes.
    rcnnTrafficSigns = trainRCNNObjectDetector(TrafficSignsTableTraining, alexnet, options, 'NegativeOverlapRange', [0 0.3], 'PositiveOverlapRange',[0.5 1]);

    save('rcnnTrafficSigns.mat', 'rcnnTrafficSigns');
end;

%% Test the R-CNN Traffic Sign Detector

figure;
for index = 902 : 1213
    testImage = imread(TrafficSignsTableTesting.imageFilename{index - 901});
    [bboxes, score, label] = detect(rcnnTrafficSigns, testImage, 'MiniBatchSize', 128);
    
    outputImage = testImage;
    
    % Display the detection results
    for indexBBox = 1 : size(bboxes, 1)
        % Include here a test for the score(indexBBox) about a fixed threshold
        
        bbox = bboxes(indexBBox, :);
        
        annotation = sprintf('%s: (Confidence = %f)', label(indexBBox), score(indexBBox));

        outputImage = insertObjectAnnotation(testImage, 'rectangle', bbox, annotation);
    end;
    
    imshow(outputImage);
    
    pause;
end;