function output_signal = MIMO_convolution(input_signal, h)
% calculates full convolution and resizes the output signal
% Inputs:       input_signal  : Signal in time domain (N_ifft x Nt)
%               h             : IR of the channel (N_IR x Nr x Nt)

% Output:       output_signal : Signal after propagating through channel (N_ifft+N_IR+1 x Nr)

output_signal = zeros(size(input_signal,1),size(h,2));
for id_r = 1:size(h,2)
    for id_t = 1:size(input_signal,2)
        output_signal_full = conv(input_signal(:,id_t), h(:,id_r, id_t), 'full');
        output_signal(:,id_r) = output_signal(:,id_r) + output_signal_full(1:length(input_signal));
    end
end
end

% 11.06.2024.
% function created