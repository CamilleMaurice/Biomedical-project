clear all;
clc;

%Open the image
C_image = imread('phanton_no_noise.tif');
%convert it to binary so we can get the centroids using regionprops
BW = im2bw(C_image, 0.35);

%Get size of the image and of the phantom
[X,Y] = size(BW);
size_phantom = 64;

%BW_B is the image without the borders, we crop it, and we compute the
%centroids
rect = [size_phantom/2, size_phantom/2, X-size_phantom, Y-size_phantom];
BW_B = imcrop (BW,rect);

s = regionprops(BW_B, 'Centroid'); 
exp_centroids = cat(1, s.Centroid);
figure(100)
    imshow(BW_B)

%figure(1)
%imshow(BW)
%hold on
%plot(exp_centroids(:,1),exp_centroids(:,2), 'b*')
%hold off

%Attemps to compute the windowed version, still a work in progress
%CC = bwconncomp(BW_B);
%N = sqrt(CC.NumObjects);
%assert(mod(N,1)==0);
%assert(mod(N,2)==1);%check it's integer and odd number
%N

%Open the windowed version (find how to get it automatically)
%and crop it so they both have same size
W_image = imread('phanton_t2.tif');
rect = [size_phantom/2, size_phantom/2, X-size_phantom, Y-size_phantom];
W_image_B = imcrop (W_image,rect);

%Compute FT of both
ft_C_image = fft2(BW_B);
ft_W_image = fft2(W_image_B);

%%Then correlation image to find the centroids
Correlation = ft_C_image.*ft_W_image;%xcorr(ft_C_image(:,:),ft_W_image(:,:));%f
R = ifft2(Correlation);
%figure(2)
%imshow(R)

%find theoretical centroids 
R_BW = im2bw (R, 0.35);
%invert the image so regionprops works
R_WB = imcomplement(R_BW);
t = regionprops(R_WB, 'Centroid');
th_centroids = cat(1, t.Centroid);

%figure(3)
%imshow(R_BW)
%hold on
%plot(th_centroids(:,1),th_centroids(:,2), 'ro')
%hold off

S1 =['nombre de centroids theoriques : ',num2str(size(th_centroids,1))];
display(S1)
S2 = ['nombre de centroids exp : ',num2str(size(exp_centroids,1))];
display(S2)

figure(5)
imshow(BW_B);
hold on
plot(th_centroids(:,1),th_centroids(:,2), 'ro')
plot(exp_centroids(:,1),exp_centroids(:,2), 'b*')
hold off

%Perform difference of the coordinates to get displacement
Vectors = th_centroids - exp_centroids;









%Interpolation methods : http://www.mathworks.com/help/vision/ug/interpolation-methods.html
%
%Other method, use filter2
%We should get the ideal centroids ?
%Correlation = filter2(W_image,C_image,'same');
%Correlation(Correlation>255) = 255;
%figure()
%imshow(Correlation)


%find centroids -- method 1
%find the max and only keep the max. It correspond to the value of the
%pixels that are true center
%M = max(max(R));
%R(R<M) = 255;
%R(R>=M) = 0;
%imshow(R)
%[row,col] = find(R<255);
%theory_centroids2 = cat(2,row,col);
%sort the coordinates in x ascending order
% [x,y] = sort(theory_centroids2(:,1));
% sorted = theory_centroids2(y,:);
% 
% theory_centroids2 = sorted;
%M = max(max(R));
%R(R<M) = 255;
%R(R>=M) = 0;
%imshow(R)
%[row,col] = find(R<255);
%theory_centroids2 = cat(2,row,col);
%sort the coordinates in x ascending order
%[x,y] = sort(theory_centroids2(:,1));
%sorted = theory_centroids2(y,:);
 
