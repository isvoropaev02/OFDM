function signal = convert_to_time_domain(frame, n_ifft, cp_len)
% converts the frame to time domain with n_ifft points

fr_len = size(frame,1);
assert(mod(fr_len,2)==0, "fr_len should be even integer number")

tapped_frame = zeros([n_ifft,1]);
tapped_frame(1:fr_len/2) = frame(1:fr_len/2);
tapped_frame(n_ifft-fr_len/2+1:end) = frame(fr_len/2+1:end);

signal = add_cyclic_prefix(ifft(tapped_frame).*n_ifft, cp_len);

end