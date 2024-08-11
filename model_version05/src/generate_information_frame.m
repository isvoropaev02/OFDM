function frame = generate_information_frame(message, M, null_subcarriers)
% Assebles the frame according to the structure
% Inputs:       message   : Array of information bytes or numbers
%               M         : The order of the modulator (2, 4, 8, 16...)

% Output:       frame : Aray of symbols with the frmae structure


frame = zeros(length(message)+length(null_subcarriers),1);
used_subcarriers = setdiff((1:1:length(message)+length(null_subcarriers)), null_subcarriers);
%% modulation
if M >= 16
    frame(used_subcarriers) = qammod(message, M, UnitAveragePower=true); % PlotConstellation=false works only in matlab
else
    frame(used_subcarriers) = pskmod(message, M, pi/M); % PlotConstellation=false
end

end

% 18.05.24
% guard bands added
