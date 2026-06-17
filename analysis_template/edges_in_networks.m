%% ------------------------------------------------------------------------
% Edge counting within/between networks
%% ------------------------------------------------------------------------
%
% This script counts selected edges within and between networks.
%
% Required inputs:
%   bin_mats_net.top{si,c}
%   bin_mats_net.bottom{si,c}
%   ten_network_defn
%
% Assumptions:
%   1. bin_mats_net contains 268 x 268 node-level binary matrices.
%   2. Matrices are symmetric.
%   3. Matrices have zero diagonal.
%   4. bin_mats_net has already been reordered into the same node order as
%      ten_network_defn.
%   5. ten_network_defn(:,3) contains network labels.

% Load network definition
ten_network_defn_path = 'path/to/network_labels';
filename = 'ten_network_defn.mat';
file = fullfile(ten_network_defn_path, filename);
load(file);  % expects ten_network_defn

% Define node and network variables
no_nodes = size(ten_network_defn, 1);
network_labels = ten_network_defn(:, 3);
no_networks = numel(unique(network_labels));

% Initialize output
net_counts = struct();
net_counts.raw_edges     = cell(2, size(bin_mats_net.top,1), size(bin_mats_net.top,2));
net_counts.edges_by_size = cell(2, size(bin_mats_net.top,1), size(bin_mats_net.top,2));

for si = 1:size(bin_mats_net.top,1)
    for c = 1:size(bin_mats_net.top,2)

        new_assignments_final_matr_cell = cell(1,2);
        new_assignments_final_matr_cell{1} = bin_mats_net.top{si,c};
        new_assignments_final_matr_cell{2} = bin_mats_net.bottom{si,c};

        for w = 1:length(new_assignments_final_matr_cell)

            new_assignments_final_matr = new_assignments_final_matr_cell{1,w};

            for mm = 1:no_networks
                for k = 1:no_networks

                    zero_matrix = zeros(no_nodes, no_nodes);

                    indices = find(network_labels == k);
                    indices_network_mm = find(network_labels == mm);

                    zero_matrix(indices, indices_network_mm) = 1;
                    network_k = zero_matrix;
                    number_of_edges = new_assignments_final_matr + network_k;

                    tmp_raw_DP_edges_within_network_mm = length(find(number_of_edges == 2));

                    % Getting raw edges per network pair.
                    % For within-network edges, divide by 2 because a full
                    % symmetric adjacency matrix counts each undirected edge
                    % twice: once as i,j and once as j,i.
                    if mm == k
                        raw_DP_edges_within_network_mm(k) = tmp_raw_DP_edges_within_network_mm / 2;
                    else
                        raw_DP_edges_within_network_mm(k) = tmp_raw_DP_edges_within_network_mm;
                    end

                    [indices_size, ~] = size(indices);
                    [indices_network_mm_size, ~] = size(indices_network_mm);

                    % Correcting for network size.
                    if mm == k
                        edges_divided_by_net_size(k) = ...
                            (tmp_raw_DP_edges_within_network_mm / 2) / ...
                            ((indices_size * indices_network_mm_size - indices_size) / 2);
                    else
                        edges_divided_by_net_size(k) = ...
                            tmp_raw_DP_edges_within_network_mm / ...
                            (indices_size * indices_network_mm_size);
                    end

                end

                mat_test_raw_edges(mm,:) = raw_DP_edges_within_network_mm; 
                mat_test_edges_by_net_size(mm,:) = edges_divided_by_net_size; 

            end

            net_counts.raw_edges{w, si, c}     = tril(mat_test_raw_edges, 0);
            net_counts.edges_by_size{w, si, c} = tril(mat_test_edges_by_net_size, 0);

            clear mat_test_raw_edges mat_test_edges_by_net_size
            clear raw_DP_edges_within_network_mm edges_divided_by_net_size

        end
    end
end

% From here, can compare observed network-pair counts to null networks using
% and asssess for signficance using FDR, Bonferroni correction, permutation testing, etc.