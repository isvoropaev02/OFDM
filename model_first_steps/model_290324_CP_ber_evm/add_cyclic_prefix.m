function frame_with_prefix = add_cyclic_prefix(frame_td, l)
% adds a cyclic prefix to signal in time domain
% Inputs:       frame_td  : The frame of symbols after ifft
%               l         : The length of cyclic prefix (expected value = frame_size/2)

% Output:       frame_with_prefix : frame in time domain with prefix

frame_size = size(frame_td);
frame_with_prefix = zeros(frame_size(1)+l, 1);
frame_with_prefix(l+1:frame_size(1)+l) = frame_td;
frame_with_prefix(1:l) = frame_td(frame_size-l+1:frame_size);
end

% 29.03.24.
% function created