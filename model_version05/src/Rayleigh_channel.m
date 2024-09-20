function h = Rayleigh_channel(path_delay, path_gain_db)
% generates IR of Rayleigh channel
% Inputs:       path_delay    : Array of time delays of the signal arrival to reciever
%               path_gain_db  : Array of level of delayed singals

% Output:       h : impulse response of the channel

%% channel generation
h = zeros(path_delay(end), 1);
h(path_delay(end)) = 1i*0;
L=length(path_delay);
path_gain_lin=10.^(path_gain_db/10); % power gain in linear scale
temp=(randn(1,L)+1i*randn(1,L)) ./ sqrt(2); % 1 W gain coefficients

for k=1:L
    h(path_delay(k))=sqrt(path_gain_lin(k)).*temp(k);
end

end


% 27.04.2024.
% no normalization
