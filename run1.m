clc
clear
n_frame=32;
points=cell(n_frame,1);
%hold on
ex=[15,18];
for i=1:n_frame

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
centroids=Extract_centroid2(I);
i=i
disp(size(centroids))
plot(centroids(:,1), centroids(:,2), '.')
set(gca, 'YDir','reverse')
axis([0 1024 0 1024])

points{i}=centroids;

end
%hold off

debug = false;

[ tracks, adjacency_tracks ] = Tracking(points,...
    'Debug', debug);
%plot points

figure(21)
clf

hold on
for i_frame = 1 : n_frame
    
    str = num2str(i_frame);
    for j_point = 1 : size(points{i_frame}, 1)
        pos = points{i_frame}(j_point, :);
        plot(pos(1), pos(2), 'o')
        set(gca, 'YDir','reverse')
        text('Position', pos, 'String', str)
    end


end

%plot track
n_tracks = numel(tracks);
colors = hsv(n_tracks);

all_points = vertcat(points{:});

for i_track = 1 : n_tracks
    % We use the adjacency tracks to retrieve the points coordinates. It
    % saves us a loop.

    track = adjacency_tracks{i_track};
    track_points = all_points(track, :);
    plot(track_points(:,1), track_points(:, 2), 'Color', colors(i_track, :))
    set(gca, 'YDir','reverse')
    
end
