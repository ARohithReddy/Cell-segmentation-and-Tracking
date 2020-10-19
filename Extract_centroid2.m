function [centroids] = Extract_centroid2(I,i)

% Read the image and convert to gray-scale
%I = imread('images\t035.tif');
%imshow(I);


I_eq = adapthisteq(I);
%imshow(I_eq);

bw = im2bw(I_eq, .095);
%imshow(bw)
bw2=imfill(bw,'holes');
%imshow(bw2)

se90 = strel('line',3,90);
se0 = strel('line',3,0);

BWsdil = imdilate(bw2,[se90 se0]);
%imshow(BWsdil)
%title('Dilated Gradient Mask')

BWsdil=imfill(BWsdil,'holes');

bw3 = bwareaopen(BWsdil, 2050);
%imshow(bw3);

bw4=imfill(bw3,'holes');
% figure(i)
% imshow(bw4)

s = regionprops(bw4,'centroid');
%imshow(s);
centroids = cat(1,s.Centroid);
%imshow(centroids)
%imshow(bw4)
%hold on
%plot(centroids(:,1), centroids(:,2), 'b.')
%hold off

%plot(centroids(:,1), centroids(:,2), '.')
%set(gca, 'YDir','reverse')
%axis([0 1024 0 1024])

end

