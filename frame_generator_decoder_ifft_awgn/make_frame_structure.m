function [inf_idx, pilot_idx] = make_frame_structure(fr_len, N_inf, nulls_idx)
% Generates the positions of pilots and information symbols in frame
% Inputs:       fr_len    : Length of the frame
%               N_inf     : The number of information symbols in the frame
%               nulls_idx : Positions of nulls in the frame

% Output:       inf_idx, pilot_idx : arrays of information symbols
% positions and pilot symbols positions

%% information symbols idxs
idx_1_start = 4;
idx_1_end = fr_len/2 - 2;

idx_2_start = fr_len/2 + 2;
idx_2_end =  fr_len - 3;

inf_idx_1 = (floor(linspace(idx_1_start, idx_1_end, N_inf/2))).'; 
inf_idx_2 = (floor(linspace(idx_2_start, idx_2_end, N_inf/2))).';

inf_idx = [inf_idx_1; inf_idx_2]; % simple concatenation

%% pilot's idxs
%numbers in range from 1 to frame length 
% that don't overlape with inf_and_nulls_idx vector

%concatenation and ascending sorting
inf_and_nulls_idx = union(inf_idx, nulls_idx); 
pilot_idx = setdiff(1:fr_len, inf_and_nulls_idx).'; 

end