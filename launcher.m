clear all;
clc;

%Open the image
C_image = imread('phanton_no_noise.tif');
BW = im2bw(C_image, 0.35);
%imshow(BW)
%Work quite good but pb on the borders...Maybe we should ignore the
%borders? 
s = regionprops(BW, 'Centroid');
centroids = cat(1, s.Centroid);
imshow(BW)
hold on
plot(centroids(:,1),centroids(:,2), 'b*')
hold off


%Open the windowed version (find how to get it automatically)
W_image = imread('phanton_t2.tif');

%Compute FT of both
ft_C_image = fft2(C_image);
ft_W_image = fft2(W_image);

%%Then correlation image to find the centroids
%Dont know how to make it work
Correlation = ft_C_image.*ft_W_image;
R = ifft2(Correlation);
%find the max and only keep the max. It correspond to the value of the
%pixels that are true center
M = max(max(R))
R(R<M) = 255;
R(R>=M) = 0;



%Other method, use filter2
%We should get the ideal centroids ?
%Correlation = filter2(W_image,C_image,'same');
%Correlation(Correlation>255) = 255;
%figure()
%imshow(Correlation)
