function frame = generate_frame(message, M, N_inf, fr_len, nulls_idx, pilots)
% Assebles the frame according to the structure
% Inputs:       message   : Array of information bytes or numbers
%               M         : The order of the modulator (2, 4, 8, 16...)
%               N_inf     : The number of information symbols in the frame
%               fr_len    : Length of the frame
%               nulls_idx : Positions of nulls in the frame
%               pilots    : Array of different pilot signals

% Output:       frame : Aray of symbols with the frmae structure

%% frame structure
[inf_idx, pilot_idx] = make_frame_structure(fr_len, N_inf, nulls_idx);

%% pilots vector
vec_pilots = pilots_vector(fr_len, N_inf, nulls_idx, pilots);

%% modulation
if M >= 16
    info_symbols = qammod(message, M, PlotConstellation=true, UnitAveragePower=true);
else
    info_symbols = pskmod(message, M, pi/M, PlotConstellation=true);
    %info_symbols = qammod(message, M, PlotConstellation=true, UnitAveragePower=true);
end

%% Frame construction
frame = zeros(fr_len,1);
frame(pilot_idx) = vec_pilots;
frame(inf_idx) = info_symbols;

end