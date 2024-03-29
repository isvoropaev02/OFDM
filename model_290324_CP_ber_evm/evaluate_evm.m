function evm = evaluate_evm(frame_original, frame_recieved)
%evaluates BER
% Inputs:       frame_original  : Transmitted signal in FD (integers)
%               frame_recieved  : Decoded signal in FD at the reciever (integers)
%               fr_len          : Length of the frame

% Output:       evm : the MSE of recieved signal in minus transmitted signal in FD

diff_abs_squared = (frame_original - frame_recieved).*conj(frame_original - frame_recieved);

evm = sqrt(sum(diff_abs_squared)/length(frame_original));

end