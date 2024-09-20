function message = decode_frame(frame, M, N_inf, fr_len, nulls_idx, pilots)
% Decodes information symbols in the frame
% Inputs:       frame     : Array of modulated signal
%               M         : The order of the modulator (2, 4, 8, 16...)
%               N_inf     : The number of information symbols in the frame
%               fr_len    : Length of the frame
%               nulls_idx : Positions of nulls in the frame
%               pilots    : Array of different pilot signals

% Output:       message : Aray of decoded information symbols in the frame

%% frame structure
[inf_idx, pilot_idx] = make_frame_structure(fr_len, N_inf, nulls_idx);

%% pilots vector
vec_pilots = pilots_vector(fr_len, N_inf, nulls_idx, pilots);

%% demodulation
message = zeros(N_inf, 1);
for k = (1:N_inf)
    if M >= 16
        message(k) = qamdemod(frame(inf_idx(k)), M, UnitAveragePower=true);
    else
        message(k) = pskdemod(frame(inf_idx(k)), M, pi/M);
        %decoded_message(k) = qamdemod(frame(inf_idx(k)), M, UnitAveragePower=true);
    end
end

end