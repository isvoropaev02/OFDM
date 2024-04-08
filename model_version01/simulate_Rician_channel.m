function output_signal = simulate_Rician_channel(input_signal, path_delay, path_gain_db, K_dB)
% simulates the signal propagation in Rician channel (convolution with impulse response of the channel)
% the non-delayed beam is deterministic
% Inputs:    input_signal : Signal in time domain
%            path_delay   : Array of time delays of the signal arrival to reciever (cannot be = 1)
%            path_gain_db : Array of level of delayed singals
%            K_dB         : Rician factor (a ratio of the specular component power and scattering component power

% Output:    output_signal : Signal after propagating through channel

%% channel generation
h = zeros(path_delay(end), 1);
h(path_delay(end)) = 1i*0;

%% LOS component
K = 10^(K_dB/10);
h(1) = sqrt(K/(K+1));
%% NLOS component
L=length(path_delay);
path_gain_lin=10.^(path_gain_db/10); % power gain in linear scale
temp=(randn(1,L)+1i*randn(1,L)) ./ sqrt(2*(K+1)); % 1 W gain coefficients

for k=1:L
    h(path_delay(k))=sqrt(path_gain_lin(k)).*temp(k);
end


%% plot IR
figure
subplot(211)
stem(abs(h))
subplot(212)
stem(rad2deg(angle(h)))
title('Impulse response of the channel')
xlabel('Time')
ylabel('Singal phase')

%% output
output_signal = conv(input_signal, h, 'full');
output_signal_same = conv(input_signal, h, 'same');

%% plot output
figure()
stem(real(output_signal), 'DisplayName','real')
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
%simulate_Rician_channel([1; 0; 0; 0; 0; 0], [3 4 10], [0 -15 -30], 10)
%simulate_Rician_channel([1; 0; 0; 0; 0; 0], [3 7], [-1 -1], 10)
%simulate_Rician_channel([1; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0], [6 7 8], [0 -15 -30], 10)
%simulate_Rician_channel([1; 0; 0; 0; 0; 0], [4 7 10], [0 -90 -90], 10)

