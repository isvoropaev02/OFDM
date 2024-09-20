function frame_fd = convert_to_frequency_domain(signal, fr_len, cp_len)
% converts the frame to frequency domain with fr_len points
% Inputs:       signal  : Array of signal samples in time domain
%               fr_len  : total number of subcarriers
%               cp_len  : the length of cyclic prefix

% Output:       frame   : OFDM symbols in frequency domain

n_ifft = size(signal,1)-cp_len;
frame_fd = zeros([fr_len,1]);
full_frame = fft(remove_cyclic_prefix(signal, cp_len))./n_ifft;
frame_fd(1:fr_len/2) = full_frame(1:fr_len/2);
frame_fd(fr_len/2+1:end) = full_frame(n_ifft-fr_len/2+1:end);
end