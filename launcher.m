clear all;
clc;

%Open the image
C_image = imread('phanton_no_noise.tif');

%Open the windowed version (find how to get it automatically)
W_image = imread('phanton_template.tif');

%Compute FT of both
ft_C_image = fft(C_image);
ft_W_image = fft(W_image);


%Then correlation image to find the centroids

%Other method, use filter2
Correlation = filter2(W_image,C_image);
imshow(Correlation)
