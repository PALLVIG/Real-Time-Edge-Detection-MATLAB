clear;
clc;
close all;

%% Reset Webcam
clear cam
cam = webcam('HP True Vision FHD Camera');
cam.Resolution = '640x480';      % Reduced resolution for faster processing

%% Select Edge Detection Method
method = 'sobel';      % Change to 'sobel', 'canny' or 'roberts'

%% Frame Counter for Spectrogram
frameCount = 0;

%% Create Figure
figure('Name','Real-Time Edge Detection','NumberTitle','off');

while ishandle(gcf)

    %% Capture Webcam Frame
    img = snapshot(cam);
    frameCount = frameCount + 1;

    %% Convert to Grayscale
    if size(img,3)==3
        gray = rgb2gray(img);
    else
        gray = img;
    end

    %% Edge Detection
    switch lower(method)

        case 'sobel'

            gray_d = double(gray);

            Gx = [-1 0 1;
                -2 0 2;
                -1 0 1];

            Gy = [-1 -2 -1;
                0  0  0;
                1  2  1];

            Ix = conv2(gray_d,Gx,'same');
            Iy = conv2(gray_d,Gy,'same');

            G = abs(Ix)+abs(Iy);

            threshold = 0.2*max(G(:));

            edges = G > threshold;

        case 'canny'

            gray_filtered = imgaussfilt(gray,1);
            edges = edge(gray_filtered,'Canny');

        case 'roberts'

            gray_filtered = imgaussfilt(gray,1);
            edges = edge(gray_filtered,'Roberts');

    end

    %% Display Original Image
    subplot(2,2,1);
    imshow(img);
    title('Original Image');

    %% Display Grayscale Image
    subplot(2,2,2);
    imshow(gray);
    title('Grayscale Image');

    %% Display Edge Detection
    subplot(2,2,3);
    imshow(edges);
    title([upper(method) ' Edge Detection']);

    %% Update Spectrogram every 20 frames
    if mod(frameCount,20)==0
        subplot(2,2,4);

        signal = double(gray(:));
        spectrogram(signal,128,120,128,'yaxis');
        title('Spectrogram');
    end

    drawnow limitrate nocallbacks;

end

%% Release Webcam
clear cam;
close all;
