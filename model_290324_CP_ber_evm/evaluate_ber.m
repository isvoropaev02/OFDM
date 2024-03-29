function ber = evaluate_ber(original_message, decoded_message, M)
    %evaluates BER
    % Inputs:       original_message  : Transmitted message (integers)
    %               decoded_message   : Decoded message at the reciever (integers)
    
    % Output:       ber : the ratio of number of bit errors to the total number of transmitted bits
    
    bin_original_message = dec2bin(original_message, log2(M));
    bin_decoded_message = dec2bin(decoded_message, log2(M));
    sum_error = 0;
    num_bits = 0;

    for k=1:length(original_message)
        vec1 = str2num(char(num2cell(bin_original_message(k))));
        vec2 = str2num(char(num2cell(bin_decoded_message(k))));
        sum_error = sum_error + sum(abs(vec1-vec2));
        num_bits = num_bits + length(vec1);
    end
    ber = sum_error / num_bits;
end

% 29.03.24.
% conversion from integer to binary updated; an error improved