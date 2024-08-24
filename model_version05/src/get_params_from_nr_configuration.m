function [num_sc, n_ifft, delta_t, cp_len, guard_bands] = get_params_from_nr_configuration(bw, scs)
%returns the parameters in frequency and time samples for model running
% Input:    scs - subcarrier spacing [Hz]
%           bw  - channel bandwidth [Hz]

% Outputs: num_sc - number of sc to use
%          n_ifft - IFFT size
%          delta_t - time step [s]
%          cp_len - size of cyclic prefix
%          guard_bands - subcarriers to remain unused

assert(scs==15*1e3, "Only 15 kHz scs is suppurted in current version")

data_path = "ifft_ref_size.txt";
opts = detectImportOptions(data_path);
opts.DataLines = 2;
opts.Delimiter = ",";
opts.VariableNamesLine = 1;
df = readtable(data_path, opts);

n_ifft = df.ifft_len(df.bw==bw*1e-6);
cp_len = df.cp_len(df.bw==bw*1e-6);
delta_t = 1/(scs*n_ifft);
num_sc = 12*floor(bw/(12*scs));

used_sc = 12*df.num_RB(df.bw==bw*1e-6);
unused_sc = num_sc-used_sc;
guard_bands = ((num_sc/2-unused_sc/2+1):1:(num_sc/2+unused_sc/2));
end