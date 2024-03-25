function vec_pilots = pilots_vector(fr_len, N_inf, nulls_idx, pilots)
% Generates the pilot signals
% Inputs:       fr_len    : Length of the frame
%               N_inf     : The number of information symbols in the frame
%               nulls_idx : Positions of nulls in the frame
%               pilots    : Array of different pilot symbols

% Output:       vec_pilots : Array of different pilot symbols in a cyclical sequence 

N_pil = fr_len - N_inf - length(nulls_idx); % number of pilots in the frame

%% pilots vector
pilots_len_psudo = floor(N_pil/length(pilots)); % how many full pilon templates fit in the frame

% linear algebra tricks:
mat_1 = pilots*ones(1, pilots_len_psudo); % rank-one matrix
resh = reshape(mat_1, pilots_len_psudo*length(pilots),1); % vectorization


tail_len = fr_len  - N_inf - length(nulls_idx) ...
                - length(pilots)*pilots_len_psudo; 
tail = pilots(1:tail_len); % "tail" of pilots vector


vec_pilots = [resh; tail]; % completed pilots vector that frame consists
end