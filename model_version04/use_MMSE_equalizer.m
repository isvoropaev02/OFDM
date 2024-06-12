function output = use_MMSE_equalizer(frame_fd, initial_pilots_full, recieved_pilots, null_subcarriers,snr_db, relative_snr_error)
% 1D MMSE equalizer x = 1/(h+1/(h'*SNR))*y
% Inputs:       frame_fd        : Information frame in frequency domain
%               initial_pilots  : pilot symbols which are generated in transmitter
%               recieved_pilots : pilot symbols which are recieved
%               null_subcarriers: positions of nulls in frame
%               snr_db          : snr in the reciever (real value)
%               relative_snr_error: relative error of snr estimation

% Output:       output_signal : Signal after MMSE equalization

% snr estimation
snr_error_sign =2*(rand([1 1]) >= 0.5) - 1;
snr = 10^(snr_db/10);
snr = snr + snr_error_sign*snr*relative_snr_error;

used_subcarriers = setdiff((1:1:size(initial_pilots_full,1)), null_subcarriers);
initial_pilots = initial_pilots_full(used_subcarriers,:,:);

Nr = size(frame_fd,2);
Nt = size(initial_pilots_full,3);
% equalization
output = zeros([size(frame_fd,1),size(initial_pilots,3)]);
for k=1:size(frame_fd,1)
    y = reshape(squeeze(frame_fd(k,:)),[],1);
    % channel estimation
    H = squeeze(recieved_pilots(k,:,:))*squeeze(initial_pilots(k,:,:));
    output(k, :) = (H'*H+(Nr/snr).*diag(ones([Nt,1])))\(H'*y);
end

% 12.06.2024.
% mimo equalization
