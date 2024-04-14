function frame = generate_information_frame(message, M)
% Assebles the frame according to the structure
% Inputs:       message   : Array of information bytes or numbers
%               M         : The order of the modulator (2, 4, 8, 16...)

% Output:       frame : Aray of symbols with the frmae structure

%% modulation
if M >= 16
    frame = qammod(message, M, UnitAveragePower=true); % PlotConstellation=false works only in matlab
else
    frame = pskmod(message, M, pi/M); % PlotConstellation=false
end
end

% 29.03.24
% full remake
