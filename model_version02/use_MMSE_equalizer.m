function output = use_MMSE_equalizer(frame_fd, initial_pilots, recieved_pilots, null_subcarriers, snr_db, relative_snr_error)
% 1D MMSE equalizer x = 1/(h+1/(h'*SNR))*y
% Inputs:       frame_fd        : Information frame in frequency domain
%               initial_pilots  : pilot symbols which are generated in transmitter
%               recieved_pilots : pilot symbols which are recieved
%               null_subcarriers: positions of nulls in frame
%               snr_db          : snr in the reciever (real value)
%               relative_snr_error: relative error of snr estimation

% Output:       output_signal : Signal after MMSE equalization

assert(length(initial_pilots) == length(recieved_pilots) && length(frame_fd) == length(initial_pilots), ...
                'Length of the pilots sequence is not the same as the length of information sequence.')

used_subcarriers = setdiff((1:1:length(frame_fd)), null_subcarriers);

%channel estimation
h = recieved_pilots(used_subcarriers) ./ initial_pilots(used_subcarriers);

% snr estimation
snr_error_sign =2*(rand([1 1]) >= 0.5) - 1;
snr = 10^(snr_db/10);
snr = snr + snr_error_sign*snr*relative_snr_error;

% using equalizer
output = frame_fd(used_subcarriers) ./ (h + 1./(conj(h).*snr));
end

% 18.05.2024.
% null subcarriers are removed
