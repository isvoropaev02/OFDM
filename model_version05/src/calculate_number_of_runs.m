function number_of_runs = calculate_number_of_runs(config, desired_precision)
% calculates amount of runs to evaluate ber with 'desired_precision'
% Input:        config - config structure
%               desired_precision - double desired precision of BER
% Output:       number_of_runs - number of runs enough to evaluate ber with
% given precision

num_used_sc = config.fr_len-length(config.guard_bands);
num_required_bits = 100*desired_precision.^-1;

number_of_runs = ceil(num_required_bits/(num_used_sc*log2(config.modulator_order)));

end