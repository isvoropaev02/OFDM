function output_signal = MIMO_AWGN(input_signal, SNR_dB)
% adds white gaussian noise to Rx signal
% Inputs:       input_signal  : Signal in time domain (N_ifft x Nr)
%               SNR_dB        : signal-noise ratio in dB

% Output:       output_signal : Signal with noise (N_ifft x Nr)

output_signal = zeros(size(input_signal));
for id_r = 1:size(input_signal,2)
    output_signal(:,id_r) = awgn(complex(input_signal(:,id_r)), SNR_dB, 'measured');
end
end

% 11.06.2024.
% function created