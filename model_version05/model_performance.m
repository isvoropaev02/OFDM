% 25.08.2024
% created
clear all; close all; clc
addpath(genpath('src'))

rng(1);

%% system configuration
config = struct();

config.modulator_order = 64; % e.g. 2, 4, 8 -> PSK; 16, 64... -> QAM
config.SNR_dB = 30; % [dBW] the signal power is normalized to 1 W
config.Nr = 2; % number of recieve antennas
config.Nt = 2; % number of transmitt antennas

% spectral parameters
channel_bw = 20*1e6; % Hz
scs = 15*1e3; % Hz - subcarrier spacing
[config.fr_len, config.n_ifft, ~, config.cp_len, config.guard_bands] = ...
    get_params_from_nr_configuration(channel_bw, scs);

