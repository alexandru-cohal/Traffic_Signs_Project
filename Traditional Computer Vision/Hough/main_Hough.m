% Traffic Sign Detection based on Hough Transform

% Classes: 1 - DETOUR RIGHT, 2 - GO STRAIGHT, 3 - TURN RIGHT, 
% 4 - TURN AROUND, 5 - FORBIDDEN, 6 - END OF RESTRICTIONS, 
% 7 - FORBIDDEN TRUCK OVERCOME, 8 - FORBIDDEN (red with white line), 9 - SPEED LIMITATION

%%
clear;
clc;
close all;

%% Constants

PATH_TESTING = '../Benchmark/TestIJCNN2013Download/';
FINAL_RES = [480 820];

%% Load an image and improve it

for index = 17 : 299
    imageName = num2str(index, '%05d');
    
    fprintf('Processing Image %s.ppm \n', imageName);

    pathImage = [PATH_TESTING imageName '.ppm'];

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
    title('Contrast improved image and ROIs');

    %% Detect ROIs
    
    % Apply Hough Transform
    [centers, radii, metric] = imfindcircles(im, [5 35]);
    viscircles(centers, radii, 'EdgeColor', 'b');
    
    % Select the square around each ROI (which contains a detected circle)
    if (size(centers, 1) > 0)
        leftColumn = round( centers(:, 1) - radii - 1 );
        leftColumn(leftColumn < 1) = 1;
        rightColumn = round( centers(:, 1) + radii + 1 );
        rightColumn(rightColumn > FINAL_RES(2)) = FINAL_RES(2);
        upRow = round( centers(:, 2) - radii - 1 );
        upRow(upRow < 1) = 1;
        downRow = round( centers(:, 2) + radii + 1 );
        downRow(downRow > FINAL_RES(1)) = FINAL_RES(1);

        % Classify each ROI
        for indexCircle = 1 : size(centers, 1)
            fprintf('Region %g: ', indexCircle);

            ROI = im_original(upRow(indexCircle) : downRow(indexCircle), leftColumn(indexCircle) : rightColumn(indexCircle), :);

            class = traffic_sign_recognition(ROI);

            if class > -1
                figure;
                imshow(ROI);
                title(sprintf('ROI - class %g', class));
            else
                fprintf('\n');
            end;

        end;
    end;
        
    pause;
  
end;