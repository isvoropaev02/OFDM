% 29.03.24.
% function created

function frame_without_prefix = remove_cyclic_prefix(frame_td_with_prefix, l)
% removes a cyclic prefix to signal in time domain
% Inputs:       frame_td_with_prefix  : The frame of symbols after ifft
%               l                     : The length of cyclic prefix (expected value = frame_size/2)

% Output:       frame_without_prefix : frame in time domain with prefix

frame_without_prefix = frame_td_with_prefix(l+1:length(frame_td_with_prefix));
end