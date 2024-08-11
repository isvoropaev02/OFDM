function message = decode_frame(frame, M)
% Decodes information symbols in the frame
% Inputs:       frame     : Array of modulated signal in frequency domain
%               M         : The order of the modulator (2, 4, 8, 16...)

% Output:       message   : Aray of decoded information symbols in the frame

%% demodulation
if M >= 16
    message = qamdemod(frame, M, UnitAveragePower=true);
else
    message = pskdemod(frame, M, pi/M);
    %decoded_message(k) = qamdemod(frame(inf_idx(k)), M, UnitAveragePower=true);
end

end

% 29.03.24
% reduced to simple demodulator
