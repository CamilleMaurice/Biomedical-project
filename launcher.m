clear all;
clc;

%Open the image
C_image = imread('phanton_no_noise.tif');
BW = im2bw(C_image, 0.35);
%imshow(medfilt2(BW)
%BW =medfilt2(BW); (for the noisy phantom)

%Work quite good but pb on the borders...Maybe we should ignore the
%borders? 
s = regionprops(BW, 'Centroid');
exp_centroids = cat(1, s.Centroid);
%imshow(BW)
%hold on
%plot(exp_centroids(:,1),exp_centroids(:,2), 'b*')
%hold off

%Open the windowed version (find how to get it automatically)
W_image = imread('phanton_t2.tif');

%Compute FT of both
ft_C_image = fft2(BW);
ft_W_image = fft2(W_image);

%%Then correlation image to find the centroids
Correlation = ft_C_image.*ft_W_image;
R = ifft2(Correlation);

%find the max and only keep the max. It correspond to the value of the
%pixels that are true center
M = max(max(R));
R(R<M) = 255;
R(R>=M) = 0;

%imshow(R)
[row,col] = find(R<255);
theory_centroids = cat(2,row,col);

%sort the coordinates in x ascending order
[x,y] = sort(theory_centroids(:,1));
sorted = theory_centroids(y,:);

theory_centroids = sorted;
exp_centroids;


%Problem: I found the same coordinates for the theoretical ones and the
%experimental ones ! (except on the borders)
imshow(C_image)
hold on
plot(theory_centroids(:,1),theory_centroids(:,2), 'b*')
plot(exp_centroids(:,1),exp_centroids(:,2), 'ro')
hold off



%Other method, use filter2
%We should get the ideal centroids ?
%Correlation = filter2(W_image,C_image,'same');
%Correlation(Correlation>255) = 255;
%figure()
%imshow(Correlation)
