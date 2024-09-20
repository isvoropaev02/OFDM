function evm = evaluate_evm(frame_recieved, frame_original, null_subcarriers)
%evaluates EVM
% Inputs:       frame_recieved  : Decoded signal in FD at the reciever (integers)
%               frame_original  : Transmitted signal in FD (integers)
%               null_subcarriers : subcarriers with 0 symbol

% Output:       evm : the MSE of recieved signal in minus transmitted signal in FD

used_subcarriers = setdiff((1:1:length(frame_original)), null_subcarriers);
frame_original = frame_original(used_subcarriers);

diff_abs_squared = (frame_original - frame_recieved).*conj(frame_original - frame_recieved);
refference_power = dot(frame_original, frame_original) / length(frame_original);

evm = sqrt(sum(diff_abs_squared)/length(frame_original)/refference_power);

end

% 18.05.2024.
% null subcarriers removed