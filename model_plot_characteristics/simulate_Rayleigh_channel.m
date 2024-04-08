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
output_signal_same = conv(input_signal, h, 'same');

%% plot output
figure()
plot(real(output_signal), 'DisplayName','real')
hold on
plot(imag(output_signal), 'DisplayName','imag')
title('Signal after channel conv(full)')
xlabel('Time')
ylabel('Singal')
legend()

figure()
plot(real(output_signal_same), 'DisplayName','real')
hold on
plot(imag(output_signal_same), 'DisplayName','imag')
title('Signal after channel conv(same)')
xlabel('Time')
ylabel('Singal')
legend()

end


% 02.04.2024.
% output signal plots


%% tests
%simulate_Rayleigh_channel([1; 0; 0; 0; 0; 0], [1 4 10], [0 -15 -30])
%simulate_Rayleigh_channel([1; 0; 0; 0; 0; 0], [1 2], [-1 -1])
%simulate_Rayleigh_channel([1; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0], [1 4 10], [0 -15 -30])
%simulate_Rayleigh_channel([1; 0; 0; 0; 0; 0], [1 4 10], [0 -90 -90])

