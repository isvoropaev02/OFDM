function frame_fd = convert_to_frequency_domain(signal, fr_len, cp_len)
% converts the frame to frequency domain with fr_len points
n_ifft = size(signal,1)-cp_len;
frame_fd = zeros([fr_len,1]);
full_frame = fft(remove_cyclic_prefix(signal, cp_len))./n_ifft;
frame_fd(1:fr_len/2) = full_frame(1:fr_len/2);
frame_fd(fr_len/2+1:end) = full_frame(n_ifft-fr_len/2+1:end);
end