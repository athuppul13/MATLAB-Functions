function [Data] = ShadowManifoldInterp(S1,S2,i_Lag,n_dim,n_NN)
%% Function fro SMI CCM analysis between two signals
% Written by Anirudh Thuppul 04/01/2020
% Last edited by Anirudh Thuppul 04/05/2020

% Inputs:
% - S1 is input signal array one for analysis
% - S2 is input signal array two for analysis
% - i_Lag is an integer time lag applied to signal, in units of signal index 
% - n_dim is an integer number of dimesions to which analysis is conducted 
% - n_NN is an integer number of nearest neighbors for analysis

% Outputs:
% - Data.M1t is training manifold of S1 analysis array
% - Data.M2t is training manifold of S2 analysis array
% - Data.M1 is analysis manifold of S1 analysis array
% - Data.M2 is analysis manifold of S2 analysis array
% - Data.M1r is reconstructed manifold of S1 analysis array
% - Data.M2r is reconstructed manifold of S2 analysis array
% - Data.M1c is reconstructed manifold of S1 analysis array
% - Data.M2c is reconstructed manifold of S2 analysis array
% - Data.R is correlation coefficient between test and reconstruction

LS1 = length(S1); % Find length of S1
LS2 = length(S2); % Find lenghh of S2
i_build = min(4000, round(LS1/2)); % Find smaller amount, 4000 or half length of S1 for training length
S1_build = S1(1:i_build); % Use part of signal 1 for building manifold
S2_build = S2(1:i_build); % Use part of signal 2 for building manifold
S1_a = S1(i_build:end); % Use rest of signal 1 for analysis
S2_a = S2(i_build:end); % Use rest of signal 2 for analysis

% Create manifolds up to M_dim dimensions by shifting signals by i_Lag for
% each dimension
for m = 1:n_dim
    Data.M1t(:,m) = S1_build((1+(m-1)*i_Lag):(length(S1_build)-(n_dim-m+1)*i_Lag)); % Create manifold for S1 trainer
    Data.M2t(:,m) = S2_build((1+(m-1)*i_Lag):(length(S2_build)-(n_dim-m+1)*i_Lag)); % Create manifold for S2 trainer
    Data.M1(:,m) = S1_a((1+(m-1)*i_Lag):(length(S1_a)-(n_dim-m+1)*i_Lag)); % Create manifold for S1
    Data.M2(:,m) = S2_a((1+(m-1)*i_Lag):(length(S2_a)-(n_dim-m+1)*i_Lag)); % Create manifold for S2    
end

% Reconstruct S2 manifold using mapping developed from knnsearch for nearest neighbors
for n = 1:length(Data.M1(:,1))
   [i_knn, d_knn] = knnsearch(Data.M1t,Data.M1(n,:),'K',n_NN,'Distance','euclidean');
    for p=1:n_NN
        d_exp(p) = exp(-d_knn(p)/min(d_knn(d_knn>0))); % Evaluate exponential distance using dist weighting function
    end
    Nd_exp = d_exp./sum(d_exp); % Normalize exponential distance to create map
    Data.M2r(n,:) = sum(Data.M2t(i_knn,:).*Nd_exp(:,ones(n_dim,1))); % Reconstruct S2 from mapping
end

% Use reconstructed S2 to reconstruct S1 and evaluate for casuality
for n = 1:length(Data.M2r(:,1))
    [i_knn, d_knn] = knnsearch(Data.M2t,Data.M2r(n,:),'K',n_NN,'Distance','euclidean');
    for p=1:n_NN
        d_exp(p) = exp(-d_knn(p)/min(d_knn(d_knn>0))); % Evaluate exponential distance using dist weighting function
    end
    Nd_exp = d_exp./sum(d_exp); % Normalize exponential distance to create map
    Data.M1r(n,:) = sum(Data.M1t(i_knn,:).*Nd_exp(:,ones(n_dim,1))); % Reconstruct S1 from mapping
end
cc = corrcoef(Data.M1,Data.M1r); % Find cross-correlation coefficients
Data.R = cc(2,1); % Write coefficient to output

end