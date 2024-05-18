function output = use_ZF_equalizer(frame_fd, initial_pilots, recieved_pilots, null_subcarriers)
% simple equalizer y=hx then h=y/x
% Inputs:       frame_fd        : Information frame in frequency domain
%               initial_pilots  : pilot symbols which are generated in transmitter
%               recieved_pilots : pilot symbols which are recieved

% Output:       output_signal : Signal after ZF equalization

assert(length(initial_pilots) == length(recieved_pilots) && length(frame_fd) == length(initial_pilots), ...
                'Length of the pilots sequence is not the same as the length of information sequence.')

used_subcarriers = setdiff((1:1:length(frame_fd)), null_subcarriers);

% channel estimation
h = recieved_pilots(used_subcarriers) ./ initial_pilots(used_subcarriers);

% equalization
output = frame_fd(used_subcarriers) ./ h;
end

% 18.05.2024.
% null subcarriers are removed