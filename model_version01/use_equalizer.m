function output = use_equalizer(frame_fd, initial_pilots, recieved_pilots)
% simple equalizer y=hx then h=y/x
% Inputs:       frame_fd        : Information frame in frequency domain
%               initial_pilots  : pilot symbols which are generated in transmitter
%               recieved_pilots : pilot symbols which are recieved

% Output:       output_signal : Signal after propagating through channel

assert(length(initial_pilots) == length(recieved_pilots) && length(frame_fd) == length(initial_pilots), ...
                'Length of the pilots sequence is not the same as the length of information sequence.')

h = recieved_pilots ./ initial_pilots;
output = frame_fd ./ h;
end

% 10.04.2024.
% created