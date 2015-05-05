close all;
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
no_B=imcrop(C_image,rect);
imwrite(no_B,'phanton_recNoB.gif');
s = regionprops(BW_B, 'Centroid'); 
exp_centroids = cat(1, s.Centroid);

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

%find theoretical centroids 
R_BW = im2bw (R, 0.35);
%invert the image so regionprops works
R_WB = imcomplement(R_BW);
t = regionprops(R_WB, 'Centroid');
th_centroids = cat(1, t.Centroid);

S1 =['nombre de centroids theoriques : ',num2str(size(th_centroids,1))];
display(S1)
S2 = ['nombre de centroids exp : ',num2str(size(exp_centroids,1))];
display(S2)

imwrite(BW_B,'no_borders.tif');
figure(1)
imshow(BW_B);
hold on
plot(th_centroids(:,1),th_centroids(:,2), 'ro')
plot(exp_centroids(:,1),exp_centroids(:,2), 'b*')
hold off


%Perform difference of the coordinates to get displacement
Vectors = th_centroids - exp_centroids;
N=sqrt(size(th_centroids,1));
dist=64;
[X_c Y_c]=size(no_B);
comp_image=zeros(size(no_B));
for i=1:X_c
    for j=1:Y_c
        P=[i j];
        pts_around=zeros(4,2);%ul ur lr ll
        %spans from 0 to 15
        pts_around(1,:) = [floor(i/dist) floor(j/dist)];
        pts_around(2,:) = [floor(i/dist) ceil(j/dist)];
        pts_around(3,:) = [ceil(i/dist) ceil(j/dist)];
        pts_around(4,:) = [ceil(i/dist) floor(j/dist)];
    
        if(0==0)%sum(pts_around,2)>0)%if for each pt x+ y>0
            offset=zeros(4,2);
            if(sum(pts_around,2)>0)
            for it=1:4
               offset(it,:) = Vectors(pts_around(it,1)*N + pts_around(it,2));
            end
            end
            new_pos = [pts_around(:,1)*dist+offset(:,1) pts_around(:,2)*dist+offset(:,2)];
            new_pos(new_pos>X_c)=X_c;
            %if 2 or just 1dim =0 then 0
            dist_pts=norm([P; P; P; P]-pts_around);
            if (sum(dist_pts==0)>1)%we are on a interpolation point so just assign
                display('on a point')
                new_pst = new_pos(dist_pts==0);
            else
                %interpolation here we go!
                new_pst(1) = i + 1/sum(1./(dist_pts))*sum((offset(:,1))./dist_pts);
                new_pst(2) = j + 1/sum(1./(dist_pts))*sum((offset(:,2))./dist_pts);
                
            end  
            new_pst=floor(new_pst);
            new_pst(new_pst<0)=0;
            new_pst(new_pst>Y_c)=Y_c;
            comp_image(new_pst(1),new_pst(2)) = no_B(i,j);
        else%if 1 around point equals 0 then 0
            comp_image(i,j) = 0;
       end
    end
end
sum(unique(comp_image)~=unique(no_B))
imwrite(comp_image,'phanton_reconstructed.gif');
recBW = im2bw (comp_image, 0.35);
recWB = imcomplement(recBW);
t2 = regionprops(recBW, 'Centroid');
fin_centroids = cat(1, t2.Centroid);
figure(2)
imshow(comp_image);
hold on
plot(fin_centroids(:,1),fin_centroids(:,2), 'ro')
plot(exp_centroids(:,1),exp_centroids(:,2), 'g*')

hold off

