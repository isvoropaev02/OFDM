function h = MIMO_Rayleigh_channel(path_delay, path_gain_db, Nr, Nt)
% generates IR of Rayleigh channel
% Inputs:       path_delay    : Array of time delays of the signal arrival to reciever
%               path_gain_db  : Array of level of delayed singals
%               Nt            : Number of transmitt antennas
%               Nr            : Number of recieve antennas

% Output:       h : impulse response - (Nr x Nt) matrix

assert(size(path_delay,2)==Nr & size(path_gain_db,2)==Nr, "Number of delay profiles must be the same as Nr");

%% channel generation
max_t = 0;
for ii = size(path_delay,2)
    if path_delay{1,ii}(end) > max_t
        max_t = path_delay{1,ii}(end);
    end
end
h = zeros(max_t, Nr, Nt);
h(max_t,1, 1) = 1i*0;

for id_r=1:Nr
    L=length(path_delay{1,id_r});
    path_gain_lin=10.^(path_gain_db{1,id_r}/10); % power gain in linear scale
    for id_t=1:Nt
        temp=(randn(1,L)+1i*randn(1,L)) ./ sqrt(2); % 1 W gain coefficients
%         if id_t ~= id_r
%             temp = temp*0;
%         end
        for k=1:L
            h(path_delay{1,id_r}(k), id_r, id_t)=sqrt(path_gain_lin(k)).*temp(k);
        end
    end
end

% figure()
% subplot(211)
% stem(abs(h(:,1,1)), 'DisplayName', 'h11')
% xlabel('Time [ns]')
% ylabel('h(t), abs')
% legend()
% title('Impulse response of the channel')
% subplot(212)
% stem(abs(h(:,Nr,Nt)), 'DisplayName', 'h_NrNt')
% xlabel('Time [ns]')
% ylabel('h(t), abs')
% legend()

end

% 11.06.2024.
% matrix output
