Bw = 20*10^6; % Hz -- Bandwidth
time_sample_rate = Bw;
carrier_freq = 2.4*1e9;


% IEEE 802.11n multipath fading channel
tgn = wlanTGnChannel('SampleRate', Bw, 'CarrierFrequency', carrier_freq, 'DelayProfile', 'Model-B', ...
    'EnvironmentalSpeed', 0, 'FluorescentEffect', false);

% IEEE 802.11ac multipath fading channel



%% look at IR 
x = zeros([64, 1]);
x(1) = 1;

y = tgn(x);

figure(1)
hold on
stem(abs(y))
stem(angle(y))
info(tgn)
title('IEEE 802.11n multipath fading channel')
