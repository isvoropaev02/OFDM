function output_signal = my_convolution(input_signal,h)
% calculates full convolution and resizes the output signal
% Inputs:       input_signal  : Signal in time domain
%               h             : IR of the channel

% Output:       output_signal : Signal after propagating through channel

output_signal_full = conv(input_signal, h, 'full');

output_signal = output_signal_full(1:length(input_signal));
end

% 08.04.2024.
% function created