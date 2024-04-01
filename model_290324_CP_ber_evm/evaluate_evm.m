function evm = evaluate_evm(frame_recieved, frame_original)
%evaluates EVM
% Inputs:       frame_recieved  : Decoded signal in FD at the reciever (integers)
%               frame_original  : Transmitted signal in FD (integers)

% Output:       evm : the MSE of recieved signal in minus transmitted signal in FD

diff_abs_squared = (frame_original - frame_recieved).*conj(frame_original - frame_recieved);
refference_power = dot(frame_original, frame_original) / length(frame_original);

evm = sqrt(sum(diff_abs_squared)/length(frame_original)/refference_power);

end

% 01.04.2024.
% devision by refference power added