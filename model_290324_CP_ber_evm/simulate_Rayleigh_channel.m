function output_signal = simulate_Rayleigh_channel(input_signal, path_delay, path_gain_db)
% simulates the signal propagation in Rayleigh channel (convolution with impulse response of the channel)
% Inputs:       input_signal  : Signal in time domain
%               path_delay    : Array of time delays of the signal arrival to reciever
%               path_gain_db  : Array of level of delayed singals

% Output:       output_signal : Array of THE SAME pilot signal for all frequencies

%% channel generation
h = zeros(path_delay(end), 1);
h(path_delay(end)) = 1i*0;
L=length(path_delay);
path_gain_lin=10.^(path_gain_db/10); % power gain in linear scale
temp=(randn(1,L)+1i*randn(1,L)) ./ sqrt(2); % 1 W gain coefficients

for k=1:L
  h(path_delay(k))=sqrt(path_gain_lin(k)).*temp(k);
end


%% plot IR
figure()
plot(real(h), 'DisplayName','real')
hold on
plot(imag(h), 'DisplayName','imag')
title('Impulse response of the channel')
xlabel('Time')
ylabel('Singal')
legend()

%% output
output_signal = conv(input_signal, h, 'full');

end


% 30.03.2024.
% function created