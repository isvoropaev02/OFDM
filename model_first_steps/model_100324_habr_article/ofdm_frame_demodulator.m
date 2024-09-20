%% getting frame from file
input_file = readtable("frame.txt");
frame = input_file{:, 1};

%% same parameters as for modulator
M = 4; % e.g. QPSK 
N_inf = 16; % number of subcarriers (information symbols, actually) in the frame
fr_len = 32; % the length of our OFDM frame
N_pil = fr_len - N_inf - 5; % number of pilots in the frame
pilots = [1; j; -1; -j]; % pilots (QPSK, in fact)

nulls_idx = [1, 2, fr_len/2, fr_len-1, fr_len]; % indexes of nulls
pilot_idx = [3, 7, 10, 13, 15, 17, 20, 23, 26, 28, 30];
inf_idx = [4, 5, 6, 8, 9, 11, 12, 14, 18, 19, 21, 22, 24, 25, 27, 29];

decoded_message = zeros(N_inf, 1);
%% demodulation
for k = (1:N_inf)
    if M >= 16
        decoded_message(k) = qamdemod(frame(inf_idx(k)), M, UnitAveragePower=true);
    else
        decoded_message(k) = pskdemod(frame(inf_idx(k)), M, pi/M);
        %decoded_message(k) = qamdemod(frame(inf_idx(k)), M, UnitAveragePower=true);
    end
end
