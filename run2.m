clc
clear
n=32;

%hold on
for i=1:n
    if i<100
        if i<10
            a=['00' num2str(i)];
        else
            a=['0' num2str(i)];
        end
    else
        a=num2str(i);
    end
filename=['images2\t' a '.tif'];
I=imread(filename);
centroids=Extract_centroid3(I,i);
i=i
disp(size(centroids))
%plot(centroids(:,1), centroids(:,2), '.')
set(gca, 'YDir','reverse')
axis([0 1024 0 1024])



end
%hold off


    