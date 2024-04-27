function E = signal_energy(signal)
% calculates the energy of discrete signal
% Inputs:       signal  : Signal in time/frequency domain

% Output:       E : signal energy
E = (signal'*signal) / length(signal);
end

% 27.04.2024.
% function comments updated