function decoded_message = MIMO_decode_frame(frame_fd, M)
% Decodes information frame
% Inputs:       frame     : Array of modulated signal in frequency domain
%               M         : The order of the modulator (2, 4, 8, 16...)

% Output:       message   : Aray of decoded information symbols in the frame
decoded_message = zeros(size(frame_fd));
for id_r=1:size(frame_fd,2)
    decoded_message(:,id_r) = decode_frame(frame_fd(:,id_r), M);
end
end