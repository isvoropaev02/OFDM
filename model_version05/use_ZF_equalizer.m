function output = use_ZF_equalizer(frame_fd, initial_pilots_full, recieved_pilots,null_subcarriers)
% simple equalizer y=hx then h=y/x
% Inputs:       frame_fd        : Information frame in frequency domain
%               initial_pilots  : pilot symbols which are generated in transmitter
%               recieved_pilots : pilot symbols which are recieved

% Output:       output_signal : Signal after ZF equalization

used_subcarriers = setdiff((1:1:size(initial_pilots_full,1)), null_subcarriers);
initial_pilots = initial_pilots_full(used_subcarriers,:,:);

% equalization
output = zeros([size(frame_fd,1),size(initial_pilots,3)]);
for k=1:size(frame_fd,1)
    y = reshape(squeeze(frame_fd(k,:)),[],1);
    % channel estimation
    H = squeeze(permute(recieved_pilots(k,:,:),[2 3 1]))*squeeze(initial_pilots(k,:,:));
    output(k, :) = (H'*H)\(H'*y);
end

% 12.06.2024.
% MIMO equalizer