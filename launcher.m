%right now i strongly think it doesn't work only cause i haven't figured out borders yet
% will see that after bayesian

clear all;
clc;

%Open the image
C_image = imread('phanton_no_noise.tif');
BW = im2bw(C_image, 0.35);
figure(1)
imshow(BW)


%Get border im, see if it help
[X,Y] = size(BW);

%Get the centroids of the border
% sb = regionprops(BW, 'Centroid');
% expborder_centroids = cat(1, sb.Centroid);
% figure()
% imshow(border)
% hold on
% plot(expborder_centroids(:,1),expborder_centroids(:,2), 'b*')
% hold off


%BW_B is the image without the borders
BW_B = BW;
BW_B(:,1:32) = 0;
BW_B(1:32,:) = 0;
BW_B(:,Y-32:Y) = 0;
BW_B(X-32:X,:) = 0;

%s = regionprops(BW, 'Centroid'); %old line
s = regionprops(BW_B, 'Centroid'); % i guess that's what you wanted to do? or where do you use BW_B?
exp_centroids = cat(1, s.Centroid);


%Works quite well, but problem on the borders, I dont think the center is
%well found. Uncomment the figure to check it visually
%i think it works no?
%figure(1)
%imshow(BW_B)
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
W_image = imread('phanton_t2.tif');

%Compute FT of both
ft_C_image = fft2(BW_B);%shouldn't we use BW_B?
ft_W_image = fft2(W_image);

%%Then correlation image to find the centroids
Correlation = ft_C_image.*ft_W_image;%xcorr(ft_C_image(:,:),ft_W_image(:,:));%f
R = ifft2(Correlation);
figure(2)
imshow(R)


%find theoretical centroids -- method 2
R_BW = im2bw (R, 0.35);
%invert the image so regionprops works
R_WB = imcomplement(R_BW);
t = regionprops(R_WB, 'Centroid');
th_centroids = cat(1, t.Centroid);

figure(3)
imshow(R_BW)
figure(4)
hold on
plot(th_centroids(:,1),th_centroids(:,2), 'ro')
hold off

% about the number of centroids:
% i think we should detect 15*15=225 centroids
% what you call number of centroids expected is actually the number of
% detected objects in the picture, ie it includes all the half-circles that
% we don't wan't to detect, 289=15*15+(15+2)*4-4
% i guess we only get 256
S1 =['nombre de centroids theoriques : ',num2str(size(th_centroids,1))];
display(S1)
S2 = ['nombre de centroids exp : ',num2str(size(exp_centroids,1))];
display(S2)

%Less centroids in the theoretical result (problem with the borders maybe
%?)
figure(5)
imshow(C_image);
hold on
plot(th_centroids(:,1),th_centroids(:,2), 'ro')
plot(exp_centroids(:,1),exp_centroids(:,2), 'b*')
hold off

%We should detect the same number of centroids
%Perform difference of the coordinates to get displacement



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
 
