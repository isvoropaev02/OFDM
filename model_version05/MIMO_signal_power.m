function E = MIMO_signal_power(signal)
% calculates the power of discrete signal
% Inputs:       signal  : Signal in time/frequency domain

% Output:       E : signal power
E = 0;
for k=1:size(signal,2)
    E = E + (signal(:,k)'*signal(:,k)) / length(signal(:,k));
end
E=E/size(signal,2);
end

% 27.04.2024.
% function comments updated