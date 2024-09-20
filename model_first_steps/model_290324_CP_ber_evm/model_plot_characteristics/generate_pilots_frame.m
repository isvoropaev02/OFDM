function pilots_frame = generate_pilots_frame(fr_len, pilots)
% Generates the pilot signals frame (without synchronization)
% Inputs:       fr_len    : Length of the frame
%               pilots    : Array of sequential pilot signals shape=(n, 1)

% Output:       pilots_frame : Array of THE SAME pilot signal for all frequencies

pilots_len_psudo = floor(fr_len/length(pilots));
mat_1 = pilots*ones(1, pilots_len_psudo); % matrix
resh = reshape(mat_1, pilots_len_psudo*length(pilots),1); % vectorization

tail_len = fr_len - length(resh);
tail = pilots(1:tail_len); % "tail" of pilots vector


pilots_frame = [resh; tail]; % completed pilots vector that frame consists
end

% 29.03.24
% full remake
