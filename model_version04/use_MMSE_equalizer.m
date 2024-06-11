function output = use_MMSE_equalizer(frame_fd, initial_pilots, recieved_pilots, null_subcarriers, snr_db, relative_snr_error)
% 1D MMSE equalizer x = 1/(h+1/(h'*SNR))*y
% Inputs:       frame_fd        : Information frame in frequency domain
%               initial_pilots  : pilot symbols which are generated in transmitter
%               recieved_pilots : pilot symbols which are recieved
%               null_subcarriers: positions of nulls in frame
%               snr_db          : snr in the reciever (real value)
%               relative_snr_error: relative error of snr estimation

% Output:       output_signal : Signal after MMSE equalization

assert(size(initial_pilots, 1) == size(recieved_pilots, 1) && size(frame_fd, 1) == size(initial_pilots, 1), ...
                'size of the pilots sequence is not the same as the size of information sequence.')

used_subcarriers = setdiff((1:1:size(frame_fd)), null_subcarriers);

% snr estimation
snr_error_sign =2*(rand([1 1]) >= 0.5) - 1;
snr = 10^(snr_db/10);
snr = snr + snr_error_sign*snr*relative_snr_error;

% using equalizer
idx = 1;
output = zeros([length(used_subcarriers), 1]);
for k=used_subcarriers
    y = reshape(frame_fd(k,:), [length(frame_fd(k,:)), 1]);
    % channel estimation
    H = reshape(recieved_pilots(k,:)./initial_pilots(k,:), [length(frame_fd(k,:)), 1]);
    output(idx) = 1/(H'*H+1/snr).*H'*y;
    idx = idx + 1;
end

% 06.06.2024.
% 1x2 mimo equalization
