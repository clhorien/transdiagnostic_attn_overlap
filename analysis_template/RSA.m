% RSA
clear
clc

%load in data; feat importance vectors and participant characteristics,
%including run type, behavioral measure, mean age, and percent of sample
%with autism diagnosis
load('example_dataset.mat', 'edge_importance_vis_final')
load('example_participant_characteristics.mat')

%examples below, can change this to whatever is desired. use group average
%for each sample

n_dataset = 5;
run_type      = []; %binary: 1 = rest, 2 = task
behav_measure = []; %binary: 1 = attention, 2 = autism
mean_age      = []; %mean age of each sample
percent_autism = []; %percent of particpants with autism diagnosis in a sample               

% Get feature importance similarity matrix
[edge_imp_sim,tmp_p] = corrcoef(edge_importance_vis_final);

% Create model (i.e., hypothesis) matrices
for i = 1:n_dataset
    for j = 1:n_dataset
        age_sim(i,j) = abs(mean_age(i)-mean_age(j));
        aut_sim(i,j) = abs(percent_autism(i)-percent_autism(j));
       
        if run_type(i)==run_type(j)
            run_type_sim(i,j)=1;
        else run_type_sim(i,j)=0;
        end
       
        if behav_measure(i)==behav_measure(j)
            behav_measure_sim(i,j)=1;
        else behav_measure_sim(i,j)=0;
        end
         
    end
end

% Vectorize matrices 
tmp    = ones(n_dataset,n_dataset);
upp_id = find(triu(tmp,1));  

edge_imp_vect          = edge_imp_sim(upp_id);
age_sim_vect           = age_sim(upp_id);
run_type_sim_vect      = run_type_sim(upp_id);
behav_measure_sim_vect = behav_measure_sim(upp_id);
aut_sim_vect           = aut_sim(upp_id);

% z-score predictor vectors to get standardized betas
age_sim_z           = zscore(age_sim_vect);
run_type_sim_z      = zscore(run_type_sim_vect);
behav_measure_sim_z = zscore(behav_measure_sim_vect);
aut_sim_z           = zscore(aut_sim_vect);

% Note: in the regression below, pairwise matrix entries are not fully independent. With a small
% number of input datasets here, regression coefficients may be useful descriptively,
% but p-values and confidence intervals should be interpreted cautiously.

    %-->Measure unique variance explained by each predictor
[b,bint,r,rint,stats] = regress(edge_imp_vect,[ones(length(edge_imp_vect),1) age_sim_z run_type_sim_z behav_measure_sim_z aut_sim_z]);
