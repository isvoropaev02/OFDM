function [path_delay, power_gain] = nr_TDL_channel(Model, delay_spread, sample_rate_Hz)
% outputs IR of Rayleigh channel from IEEE standart
% Inputs:       Model        : Name of the model {"A", "B", "C", "D", "E", "F"}
%               delay_spread : RMS of delay times
%               sample_rate_Hz  : Sample rate of transmitted signal in time domain

% Output:       channel_IR   : impulse response

assert(ismember(Model, ["A", "B", "C", "D", "E"]), "There is no model '"+Model+"' in IEEE standart models");

model = nrTDLChannel('DelayProfile',"TDL-"+Model, 'DelaySpread',delay_spread);
delays = model.info.PathDelays;
gains = model.info.AveragePathGains;

% delta in ns
delta_t = 1/sample_rate_Hz;
max_time_idx = round(delays(end)/delta_t)+1;

path_delay_full = (1:1:max_time_idx);
power_gain_abs = zeros(size(path_delay_full));
for t=1:length(delays)
    idx = round(delays(t)/delta_t)+1;
    power_gain_abs(idx) = power_gain_abs(idx) + 10.^(gains(t)/10);
end

path_delay=path_delay_full(~~power_gain_abs);
power_gain = 10*log10(power_gain_abs(~~power_gain_abs));
power_gain = power_gain-max(power_gain);

% figure('Position',[100 100 800 600])
% stem(path_delay, 10.^(power_gain/20))
% xlabel("Time Samples")
% ylabel('Delay Profile, abs value')
% grid('on')
% title("NR TDL-"+Model+" Model (delta t="+string(delta_t*1e9)+" ns; delay spread="+string(delay_spread*1e9)+" ns)")

end

%16.06.2024. function created