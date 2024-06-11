function output = use_ZF_equalizer(frame_fd, initial_pilots, recieved_pilots, null_subcarriers)
% simple equalizer y=hx then h=y/x
% Inputs:       frame_fd        : Information frame in frequency domain
%               initial_pilots  : pilot symbols which are generated in transmitter
%               recieved_pilots : pilot symbols which are recieved

% Output:       output_signal : Signal after ZF equalization

assert(size(initial_pilots, 1) == size(recieved_pilots, 1) && size(frame_fd, 1) == size(initial_pilots, 1), ...
                'size of the pilots sequence is not the same as the size of information sequence.')

used_subcarriers = setdiff((1:1:size(frame_fd)), null_subcarriers);


% equalization
idx = 1;
output = zeros([length(used_subcarriers), 1]);
for k=used_subcarriers
    y = reshape(frame_fd(k,:), [length(frame_fd(k,:)), 1]);
    % channel estimation
    H = reshape(recieved_pilots(k,:)./initial_pilots(k,:), [length(frame_fd(k,:)), 1]);
    output(idx) = 1/(H'*H).*H'*y;
    idx = idx + 1;
end

% 06.06.2024.
% 1x2 SIMO equalizer