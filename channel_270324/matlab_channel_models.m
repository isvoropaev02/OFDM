clear all
Bw = 20*1e6; % Hz -- Bandwidth
time_sample_rate = Bw;
carrier_freq = 2.4*1e9;
x = zeros([32, 1]);
x(1) = 1;

%% IEEE 802.11n multipath fading channel
tgn = wlanTGnChannel('SampleRate', Bw, 'CarrierFrequency', carrier_freq, 'DelayProfile', 'Model-B', ...
    'EnvironmentalSpeed', 0, 'PathGainsOutputPort',true);

[y, pg_n] = tgn(x);
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

%% IEEE 802.11ac multipath fading channel
tgac = wlanTGacChannel('SampleRate', Bw, 'CarrierFrequency', carrier_freq, 'DelayProfile', 'Model-B', ...
    'EnvironmentalSpeed', 0, 'PathGainsOutputPort',true);
[y, pg_ac] = tgac(x);
release(tgac);
info(tgac)

%% IEEE 802.11ah multipath fading channel
tgah = wlanTGahChannel('SampleRate', Bw, 'CarrierFrequency', carrier_freq, 'DelayProfile', 'Model-B', ...
    'EnvironmentalSpeed', 0, 'PathGainsOutputPort',true);
[y, pg_ah] = tgah(x);
release(tgah);
info(tgah)
