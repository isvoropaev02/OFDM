function [output_signal,message_full, info_frame_full] = MIMO_generate_output_info_signal(Nt, M, fr_len, n_ifft, cp_len, guard_bands)
% forms an ouput signal from all transmitt antennas
% Inputs:       Nt          : Number of transmitt antennas
%               M           : Modulation order
%               fr_len      : The length of frame
%               cp_len   : The length of cyclic prefix (expected value = frame_size/2)
%               guard_bands : Unused subcarriers

% Output:       frame_with_prefix : frame in time domain with prefix

output_signal = zeros(n_ifft+cp_len, Nt);
message_full = zeros(fr_len-length(guard_bands), Nt);
info_frame_full = zeros(fr_len, Nt);
for id_t = 1:Nt
    message = randi([0 M-1], fr_len-length(guard_bands), 1); % decimal information symbols
    info_frame = generate_information_frame(message, M, guard_bands); % creating frame
    output_signal(:,id_t) = convert_to_time_domain(info_frame, n_ifft, cp_len);
    message_full(:,id_t) = message;
    info_frame_full(:,id_t) = info_frame;
end
end


% 11.06.24.
% function created
