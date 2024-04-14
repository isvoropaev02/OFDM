function E = signal_energy(signal)
%calculatesthe energy of discrete finite-time signal
% Inputs:       signal  : Signal in time domain

% Output:       E : signal energy
E = (signal'*signal) / length(signal);
end