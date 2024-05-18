function E = signal_power(signal)
% calculates the power of discrete signal
% Inputs:       signal  : Signal in time/frequency domain

% Output:       E : signal power
E = (signal'*signal) / length(signal);
end

% 27.04.2024.
% function comments updated