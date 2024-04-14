function h = Rayleigh_channel(path_delay, path_gain_db)
% generates IR of Rayleigh channel
% Inputs:       input_signal  : Signal in time domain
%               path_delay    : Array of time delays of the signal arrival to reciever
%               path_gain_db  : Array of level of delayed singals

% Output:       h : impulse response

%% channel generation
h = zeros(path_delay(end), 1);
h(path_delay(end)) = 1i*0;
L=length(path_delay);
path_gain_lin=10.^(path_gain_db/10); % power gain in linear scale
temp=(randn(1,L)+1i*randn(1,L)) ./ sqrt(2); % 1 W gain coefficients

for k=1:L
    h(path_delay(k))=sqrt(path_gain_lin(k)).*temp(k);
end

if h'*h > 1
    h = h ./ (h'*h);
end

end


% 14.04.2024.
% total channel gain is checked to be <= 1
