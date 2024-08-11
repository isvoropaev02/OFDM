function [path_delay, power_gain] = IEEE_channel(Model, sample_rate)
% outputs IR of Rayleigh channel from IEEE standart
% Inputs:       Model        : Name of the model {"A", "B", "C", "D", "E", "F"}
%               sample_rate  : Sample rate of transmitted signal in time domain

% Output:       channel_IR   : impulse response

assert(ismember(Model, ["A", "B", "C", "D", "E", "F"]), "There is no model '"+Model+"' in IEEE standart models");

% iport file
data_path = "D:\OFDM\WLAN_std_channels\WLAN_model"+Model+".txt";
opts = detectImportOptions(data_path);
opts.DataLines = 3;
opts.Delimiter = ",";
opts.VariableNamesLine = 1;
df = readtable(data_path, opts);

% delta in ns
delta_t_ns = 1*sample_rate*1e9;
max_time_idx = round(df.time_delay(end)/delta_t_ns)+1;

path_delay_full = (1:1:max_time_idx);
power_gain_abs = zeros(size(path_delay_full));
for t=1:length(df.time_delay)
    idx = round(df.time_delay(t)/delta_t_ns)+1;
    power_gain_abs(idx) = power_gain_abs(idx) + 10.^(df.power_gain(t)/10);
end

path_delay=path_delay_full(~~power_gain_abs);
power_gain = 10*log10(power_gain_abs(~~power_gain_abs));

figure()
stem(path_delay, 10.^(power_gain/20))
xlabel("Time Samples")
ylabel('Delay Profile, abs value')
title("IEEE Model "+Model)

end

%16.06.2024. function created