clear all;
clc;

%Open the image
C_image = imread('phanton_no_noise.tif');

%Open the windowed version (find how to get it automatically)
W_image = imread('phanton_template.tif');

%Compute FT of both
ft_C_image = fft(C_image);
ft_W_image = fft(W_image);

%%Then correlation image to find the centroids
%Dont know how to make it work
%Correlation = ft_C_image*ft_W_image;
%R = ifft(Correlation);
%

%Other method, use filter2
%We should get the ideal centroids ?
Correlation = filter2(W_image,C_image,'same');
Correlation(Correlation>255) = 255;
figure()
imshow(Correlation)
