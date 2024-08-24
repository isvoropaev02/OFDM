function frame_fd = MIMO_Rx_signal_to_fd(signal_td, fr_len, cp_len, null_subcarriers)
% deletes cyclic prefix, performs fft of recieved signal and removes NULL subcarriers
% Inputs:       signal_td   : recieved signal in time-domain
%               fr_len      : the length of frame
%               cp_len   : The length of cyclic prefix (expected value = frame_size/2)
%               null_subcarriers : not used subcarriers

% Output:       frame_fd    : frame in frequency domain

used_subcarriers = setdiff((1:1:fr_len), null_subcarriers);

frame_fd_full = zeros(fr_len, size(signal_td,2));
for id_r = 1:size(signal_td,2)
    frame_fd_full(:,id_r) = convert_to_frequency_domain(signal_td(:,id_r), fr_len, cp_len);
end

frame_fd = frame_fd_full(used_subcarriers,:);
end


% 11.06.24.
% function created
