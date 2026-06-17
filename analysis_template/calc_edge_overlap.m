%% calc edge overlap across any models 
clear
clc
close all

% --- Load feature importance matrix ---(referred to as
% "edge_importance_vis_final" below)

[N, C] = size(edge_importance_vis_final);

% <-- Can edit this to try other sizes, try a variety of sizes, etc. -->
set_sizes = [1000];   

sort_idx_desc = cell(1, C);
sort_idx_asc  = cell(1, C);

for c = 1:C
    [~, sort_idx_desc{c}] = sort(edge_importance_vis_final(:, c), 'descend');
    [~, sort_idx_asc{c}]  = sort(edge_importance_vis_final(:, c), 'ascend');
end

% --------- EXPLICIT COLUMN-SPECIFIC SORTING RULE ----------
% IMPORTANT:
% For columns 1 and 4, we intentionally REVERSE the usual meaning of
% TOP/BOTTOM (to account for autism diagnoses as mentioned in the paper)

% This variable marks the columns that should be flipped in sort direction:
flip_sort_cols = [1 4];

obs_top_freq    = nan(numel(set_sizes), C);
obs_bottom_freq = nan(numel(set_sizes), C);

for s = 1:numel(set_sizes)
    K = set_sizes(s);
    if K > N || K <= 0
        warning('Set size %d is invalid for N=%d. Skipping.', K, N);
        continue
    end

    top_all = [];
    bottom_all = [];

    for c = 1:C

        if ismember(c, flip_sort_cols)
            top_idx_this_col    = sort_idx_asc{c}(1:K);   
            bottom_idx_this_col = sort_idx_desc{c}(1:K);  
        else
            top_idx_this_col    = sort_idx_desc{c}(1:K);  
            bottom_idx_this_col = sort_idx_asc{c}(1:K);   
        end

        top_all    = [top_all; top_idx_this_col];
        bottom_all = [bottom_all; bottom_idx_this_col];
    end

    top_counts = accumarray(top_all, 1, [N 1]);
    bot_counts = accumarray(bottom_all, 1, [N 1]);

    for k = 1:C
        obs_top_freq(s,k)    = sum(top_counts == k);
        obs_bottom_freq(s,k) = sum(bot_counts == k);
    end
end


