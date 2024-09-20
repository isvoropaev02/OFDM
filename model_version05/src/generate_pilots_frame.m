function pilots_frame = generate_pilots_frame(fr_len, null_subcarriers)
% Generates the pilot signals frame (without synchronization)
% Inputs:       fr_len           : Length of the frame
%               null_subcarriers : subcarriers with 0 symbol

% Output:       pilots_frame : Array of RANDOM {+1; -1} pilot signal for all frequencies

pilots_frame = 2*(rand([fr_len,1])>0.5)-1 + 0i; % completed pilots vector that frame consists
pilots_frame(null_subcarriers) = 0;
end

% 27.04.24
% now pilots - are random numbers from {+1, -1} and guard band
