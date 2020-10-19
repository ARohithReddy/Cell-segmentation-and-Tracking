function [ tracks,adjacency_tracks] = Tracking(points, varargin)

     p = inputParser;

     defaultDebug                = false;

     defaultMaxGapClosing        = 3;

     defaultMaxLinkingDistance   = Inf;

     defaultMethod               = 'NearestNeighbor';


     p.addParameter('Debug', defaultDebug, @islogical);

     p.addParameter('MaxGapClosing', defaultMaxGapClosing, @isnumeric);

     p.addParameter('MaxLinkingDistance', defaultMaxLinkingDistance, @isnumeric);

     p.addParameter('Method', defaultMethod);


     p.parse( varargin{:} );


     debug                   = p.Results.Debug;

     max_gap_closing         = p.Results.MaxGapClosing;

     max_linking_distance    = p.Results.MaxLinkingDistance;

     method                  = p.Results.Method;


     %% Frame to frame linking


     if debug

        fprintf('Frame to frame linking using %s method.\n', method);

     end


     n_slices = numel(points);


     current_slice_index = 0;

     row_indices = cell(n_slices, 1);

     column_indices = cell(n_slices, 1);

     unmatched_targets = cell(n_slices, 1);

     unmatched_sources = cell(n_slices, 1);

     n_cells = cellfun(@(x) size(x, 1), points);


     if debug

        fprintf('%03d/%03d', 0, n_slices-1);

     end


     for i = 1 : n_slices-1


         if debug

             fprintf(repmat('\b', 1, 7)); 

             fprintf('%03d/%03d', i, n_slices-1);

         end
 
        source = points{i};

         target = points{i+1};


         % Frame to frame linking


         [target_indices , ~, unmatched_targets{i+1} ] = nearestneighborlinker(source, target, max_linking_distance);



         unmatched_sources{i} = find( target_indices == -1 );


         % Prepare holders for links in the sparse matrix

         n_links = sum( target_indices ~= -1 );

         row_indices{i} = NaN(n_links, 1);

         column_indices{i} = NaN(n_links, 1);


         % Put it in the adjacency matrix

         index = 1;

         for j = 1 : numel(target_indices)


             % If we did not find a proper target to link, we skip

             if target_indices(j) == -1

                 continue

             end


             % The source line number in the adjacency matrix

             row_indices{i}(index) = current_slice_index + j;


             % The target column number in the adjacency matrix

             column_indices{i}(index) = current_slice_index + n_cells(i) + target_indices(j);


             index = index + 1;


         end


         current_slice_index = current_slice_index + n_cells(i);


     end
 
    


     row_index = vertcat(row_indices{:});

     column_index = vertcat(column_indices{:});

     link_flag = ones( numel(row_index), 1);

     n_total_cells = sum(n_cells);


     if debug

         fprintf('\nCreating %d links over a total of %d points.\n', numel(link_flag), n_total_cells)

     end
 
    A = sparse(row_index, column_index, link_flag, n_total_cells, n_total_cells);


     if debug

         fprintf('Done.\n')

     end



     %% Parse adjacency matrix to build tracks


     if debug

         fprintf('Building tracks:\n')

     end


     % Find columns full of 0s -> means this cell has no source

     cells_without_source = [];

     for i = 1 : size(A, 2)

         if length(find(A(:,i))) == 0 %#ok<ISMT>

             cells_without_source = [ cells_without_source ; i ]; %#ok<AGROW>

         end

     end


     n_tracks = numel(cells_without_source);

     adjacency_tracks = cell(n_tracks, 1);


     AT = A';


     for i = 1 : n_tracks


         tmp_holder = NaN(n_total_cells, 1);


         target = cells_without_source(i);

         index = 1;

         while ~isempty(target)

             tmp_holder(index) = target;

             target = find( AT(:, target), 1, 'first' );

             index = index + 1;

         end


         adjacency_tracks{i} = tmp_holder ( ~isnan(tmp_holder) );

     end



     tracks = cell(n_tracks, 1);


     for i = 1 : n_tracks


         adjacency_track = adjacency_tracks{i};

         track = NaN(n_slices, 1);


         for j = 1 : numel(adjacency_track)


             cell_index = adjacency_track(j);


             % We must determine the frame this index belong to

             tmp = cell_index;

             frame_index = 1;

             while tmp > 0

                 tmp = tmp - n_cells(frame_index);

                 frame_index = frame_index + 1;

             end

             frame_index = frame_index - 1;

             in_frame_cell_index = tmp + n_cells(frame_index);


             track(frame_index) = in_frame_cell_index;


         end


         tracks{i} = track;


     end


 end