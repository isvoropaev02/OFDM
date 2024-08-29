function [output_signal, pilots_frame] = MIMO_generate_output_pilot_signal(Nt, fr_len, n_ifft, cp_len, guard_bands)
% forms an ouput signal from all transmitt antennas
% Inputs:       Nt          : Number of transmitt antennas
%               M           : Modulation order
%               fr_len      : The length of frame
%               cp_len   : The length of cyclic prefix (expected value = frame_size/2)
%               guard_bands : Unused subcarriers

% Output:       frame_with_prefix : frame in time domain with prefix

output_signal = zeros(n_ifft+cp_len, Nt, Nt);
pilots_frame = zeros(fr_len, Nt, Nt);
pilots_frame_single = generate_pilots_frame(fr_len, guard_bands);
for id_t = 1:Nt
    output_signal(:,id_t, id_t) = convert_to_time_domain(pilots_frame_single, n_ifft, cp_len)./sqrt(Nt);
    pilots_frame(:,id_t, id_t) = pilots_frame_single;
end

end


% 12.06.24.
% function created
