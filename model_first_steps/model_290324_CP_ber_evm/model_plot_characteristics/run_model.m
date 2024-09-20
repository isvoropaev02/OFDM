function [ber_my, ber_matlab, evm_my, evm_matlab] = run_model(M, fr_len, SNR_dB, cp_length)
% runs model with given parameters
% Inputs:       M           : Modulator order
%               fr_len      : Length of the frame
%               SNR_db      : SNR in dB on the reciever
%               cp_length   : Length of the cyclic prefix

% Output:       output_signal : Array of THE SAME pilot signal for all frequencies

%% message to transmit and recieve (block "Bits stream")
message = randi([0 M-1], fr_len, 1); % decimal information symbols

%% Frame in frequency domain (blocks "Modulator" and "Pilot signals")
%pilots_frame = generate_pilots_frame(fr_len, 1+0i); % just one pilot symbol in all positions
info_frame = generate_information_frame(message, M); % creating frame

%% Converting to Time domain and adding cyclic prefix (blocks "IFFT" and "Cyclic prefix")
info_frame_td = add_cyclic_prefix(ifft(info_frame).*fr_len, cp_length);
%pilots_frame_td = add_cyclic_prefix(ifft(pilots_frame), cp_length);

%% Add the AWGN (block "AWGN")
info_frame_td_noise = awgn(complex(info_frame_td), SNR_dB, 'measured');
%pilots_frame_td_noise = awgn(complex(pilots_frame_td), SNR_dB, 'measured');

%% Removing cyclic prefix and Converting to Frequency domain (blocks "FFT" and "Remove Cyclic prefix")
info_frame_fd = fft(remove_cyclic_prefix(info_frame_td_noise, cp_length))./fr_len;
%pilots_frame_fd = fft(remove_cyclic_prefix(pilots_frame_td_noise, cp_length));

%% Decoded message from frame in frequency domain (block "Demodulator")
decoded_message = decode_frame(info_frame_fd, M); % decoding frame

%% Metrics calculation (blocks "BER" and "EVM")
ber_matlab = biterr(message, decoded_message) / (fr_len*log2(M));
ber_my = evaluate_ber(message, decoded_message, M);
evm_matlab = lteEVM(info_frame_fd, info_frame).RMS;
evm_my = evaluate_evm(info_frame_fd, info_frame);

end

% 08.04.2024.
% function created