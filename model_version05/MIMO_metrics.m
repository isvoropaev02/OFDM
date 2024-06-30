function [ber, evm] = MIMO_metrics(message, decoded_message, M, info_frame_equalized, info_frame_full, null_subcarriers)
% Decodes information frame
% Inputs:       message              : initial message
%               decoded_message      : recieved message
%               M                    : modulator order
%               info_frame_equalized : info frame after equalizer
%               info_frame           : initial info frame
%               guard_bands          : unused subcarriers

% Output:       ber, evm   : ber and evm metrics

used_subcarriers = setdiff((1:1:size(info_frame_full,1)), null_subcarriers);
info_frame = info_frame_full(used_subcarriers,:);
ber = evaluate_ber(reshape(message,[],1), reshape(decoded_message,[],1), M);
evm = evaluate_evm(reshape(info_frame_equalized,[],1), reshape(info_frame,[],1), []);
end