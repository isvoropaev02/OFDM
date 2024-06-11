function output_signal = MIMO_generate_output_info_signal(Nt, M, fr_len, cp_length, guard_bands)
% forms an ouput signal from all transmitt antennas
% Inputs:       Nt          : Number of transmitt antennas
%               M           : Modulation order
%               fr_len      : The length of frame
%               cp_length   : The length of cyclic prefix (expected value = frame_size/2)
%               guard_bands : Unused subcarriers

% Output:       frame_with_prefix : frame in time domain with prefix

output_signal = zeros(fr_len+cp_length, Nt);
for id_t = 1:Nt
    message = randi([0 M-1], fr_len-length(guard_bands), 1); % decimal information symbols
    info_frame = generate_information_frame(message, M, guard_bands); % creating frame
    output_signal(:,id_t) = add_cyclic_prefix(ifft(info_frame).*fr_len, cp_length);
end
end


% 11.06.24.
% function created
