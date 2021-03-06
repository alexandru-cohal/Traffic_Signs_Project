% Train a Convolutional Neural Network for Traffic Signs recognition
% Based on: https://se.mathworks.com/help/vision/examples/object-detection-using-deep-learning.html

%%
clear;
clc;
close all;

%%
load trainingDataAndLabels.mat;
numImageCategories = 43;

%% Create the training data set

% Reshape to N x Cols x Rows x Channels
trainingImages = reshape(trainingData, [39209 32 32 3]);
% Permute to Rows x Cols x Channels x N
trainingImages = permute(trainingImages, [2 3 4 1]);
% Size of the training data
size(trainingImages)
% Show first 100 images
montage(trainingImages(:, :, :, round(rand(1, 100)*39209)))

%% Define the CNN's Input Layer

% Create the image input layer for 32x32x3 CIFAR-10 images
[height, width, numChannels, ~] = size(trainingImages);

imageSize = [height width numChannels];
inputLayer = imageInputLayer(imageSize)

%% Define the CNN's Convolutional Layer

% Convolutional layer parameters
filterSize = [5 5];
numFilters = 32;

middleLayers = [

% The first convolutional layer has a bank of 32 5x5x3 filters. A
% symmetric padding of 2 pixels is added to ensure that image borders
% are included in the processing. This is important to avoid
% information at the borders being washed away too early in the
% network.
convolution2dLayer(filterSize, numFilters, 'Padding', 2)

% Note that the third dimension of the filter can be omitted because it
% is automatically deduced based on the connectivity of the network. In
% this case because this layer follows the image layer, the third
% dimension must be 3 to match the number of channels in the input
% image.

% Next add the ReLU layer:
reluLayer()

% Follow it with a max pooling layer that has a 3x3 spatial pooling area
% and a stride of 2 pixels. This down-samples the data dimensions from
% 32x32 to 15x15.
maxPooling2dLayer(3, 'Stride', 2)

% Repeat the 3 core layers to complete the middle of the network.
convolution2dLayer(filterSize, numFilters, 'Padding', 2)
reluLayer()
maxPooling2dLayer(3, 'Stride',2)

convolution2dLayer(filterSize, 2 * numFilters, 'Padding', 2)
reluLayer()
maxPooling2dLayer(3, 'Stride',2)

]

%% Define the CNN's Final Layer

finalLayers = [

% Add a fully connected layer with 64 output neurons. The output size of
% this layer will be an array with a length of 64.
fullyConnectedLayer(64)

% Add an ReLU non-linearity.
reluLayer

% Add the last fully connected layer. At this point, the network must
% produce 10 signals that can be used to measure whether the input image
% belongs to one category or another. This measurement is made using the
% subsequent loss layers.
fullyConnectedLayer(numImageCategories)

% Add the softmax loss layer and classification layer. The final layers use
% the output of the fully connected layer to compute the categorical
% probability distribution over the image classes. During the training
% process, all the network weights are tuned to minimize the loss over this
% categorical distribution.
softmaxLayer
classificationLayer
]

%% Combine all the CNN's layers together

layers = [
    inputLayer
    middleLayers
    finalLayers
    ]

%% Initialize the parameters of the CNN's first convolutional layer

layers(2).Weights = gpuArray( 0.0001 * randn([filterSize numChannels numFilters]) );

%% Define the CNN's training parameters

% Set the network training options
opts = trainingOptions('sgdm', ...
    'Momentum', 0.9, ...
    'InitialLearnRate', 0.001, ...
    'LearnRateSchedule', 'piecewise', ...
    'LearnRateDropFactor', 0.1, ...
    'LearnRateDropPeriod', 8, ...
    'L2Regularization', 0.004, ...
    'MaxEpochs', 40, ...
    'MiniBatchSize', 128, ...
    'Verbose', true);

%% Train the CNN

% A trained network is loaded from disk to save time when testing. 
% Set this flag to true to train the network.
doTraining = true;

if doTraining
    % Train a network.
    TrafficSignsNet = trainNetwork(trainingImages, trainingLabels, layers, opts);
else
    % Load pre-trained detector for the example.
    load('TrafficSignsNet.mat', 'TrafficSignsNet');
end

%% Compute the accuracy over the training data set

% Validation with Training Data Set
YTrain = classify(TrafficSignsNet, trainingImages);
accuracy = sum(YTrain == trainingLabels) / numel(trainingLabels)

%% Show a montage of the classification results

N = 36;

index_images = round(rand(1, N) * 39209);

images = trainingImages(:,:,:,index_images);

images = imresize(images, [200, 200]);

for i = 1 : N
    if YTrain(index_images(i)) == trainingLabels(index_images(i))
        color = 'Green';
    else
        color = 'Red';
    end
    
    images(:,:,:,i) = insertObjectAnnotation(images(:,:,:,i), 'Rectangle', [0 0 10 10], char(YTrain(index_images(i))), 'LineWidth', 1, 'FontSize', 26, 'TextBoxOpacity', 0.9, 'Color', color);
end

figure;
montage(images);