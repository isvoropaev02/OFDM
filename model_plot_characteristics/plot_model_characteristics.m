% file to obtain plots
% 08.04.2024.

M = 4; % e.g. 2, 4, 8 -> PSK; 16, 64... -> QAM
fr_len = 1024; % the length of OFDM frame
SNR_dB = linspace(0, 25, 51)'; % [dBW] the signal power is normalized to 1 W
cp_length = fr_len/2; % the size of cyclic prefix

ber_my = zeros(length(SNR_dB), 1);
ber_matlab = zeros(length(SNR_dB), 1);
evm_my = zeros(length(SNR_dB), 1);
evm_matlab = zeros(length(SNR_dB), 1);


for k=1:length(SNR_dB)
    [ber_my_value, ber_matlab_value, evm_my_value, evm_matlab_value] =...
                        run_model(M, fr_len, SNR_dB(k), cp_length);

   ber_my(k) = ber_my_value;
   ber_matlab(k) = ber_my_value;
   evm_my(k) = evm_my_value;
   evm_matlab(k) = evm_matlab_value;
end


figure()
plot(SNR_dB, ber_my)
hold on
plot(SNR_dB, ber_matlab)
set(gca, 'YScale', 'log')

figure()
plot(SNR_dB, 20*log10(evm_my))
hold on
plot(SNR_dB, 20*log10(evm_matlab))


fileID = fopen('metrics.txt','w');
fprintf(fileID,'%s, %s, %s, %s, %s\n', "SNR_dB","BER_my", "BER_matlab", "EVM_my", "EVM_matlab");
fprintf(fileID,'%f, %f, %f, %f, %f\n', [SNR_dB'; ber_my'; ber_matlab'; evm_my'; evm_matlab';]);
fclose(fileID);
