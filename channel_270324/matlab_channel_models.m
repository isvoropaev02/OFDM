Bw = 20*10^6; % Hz -- Bandwidth
time_sample_rate = Bw;
carrier_freq = 2.4*1e9;


% IEEE 802.11n multipath fading channel
tgn = wlanTGnChannel('SampleRate', Bw, 'CarrierFrequency', carrier_freq, 'DelayProfile', 'Model-B', ...
    'EnvironmentalSpeed', 0, 'FluorescentEffect', false);

% IEEE 802.11ac multipath fading channel



%% look at IR 
x = zeros([32, 1]);
x(1) = 1;

y = tgn(x);
release(tgn);
info(tgn)


figure(1)
hold on
subplot(211)
stem((0:1:31)./Bw*1e9,abs(y))
xlabel('Time [ns]')
ylabel('h(t), abs')
title('IEEE 802.11n multipath fading channel')
subplot(212)
stem(rad2deg(angle(y)))
xlabel('Time')
ylabel('h(t), phase (deg)')

