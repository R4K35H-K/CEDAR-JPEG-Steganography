%% CEDAR (Efficient Content-adaptive Downward Robust Algorithm) Demo
%
% This script runs a batch test of the CEDAR steganography scheme on 10 cover images.
% It demonstrates:
%   1. Embedding a secret message using target robust DCT locations.
%   2. Recompressing the stego image at a lower quality factor to simulate channel loss.
%   3. Extracting the message directly via LSB parity at the receiver.
%   4. Computing BER (Bit Error Rate), PSNR, and SSIM.
%   5. Comparing two domain settings:
%      - Original Code Domain (all lattices satisfying the odd-multiple condition).
%      - Strict Paper Domain (restricting to u + v <= 6, Eq 3 of the paper).

clc;
clear;
close all;

% Set up paths
ScriptDir = fileparts(mfilename('fullpath'));
addpath(fullfile(ScriptDir, 'src'));

% Parameters
CoverQF = 95;
ChannelQF = 80;
EmbRate = 10; % Embedding rate in percentage (e.g. 10%)
NumImages = 10;

% Source and output paths
CoverDir = fullfile(ScriptDir, 'cover_images');
OutputDir = fullfile(ScriptDir, 'stego_images');
if ~exist(OutputDir, 'dir')
    mkdir(OutputDir);
end

% Load secret message payload
load(fullfile(ScriptDir, 'src', 'SecretMsg.mat'), 'msg');

% Configuration: Set to true to strictly restrict robust elements to the paper's 
% theoretical embedding domain E (u + v <= 6, Eq 3 of the paper). 
% Default is false, which matches the original codebase's unrestricted behavior.
RestrictToDomainE = false; 

fprintf('\n======================================================================\n');
fprintf(' Running CEDAR Batch Demo (RestrictToDomainE = %s)\n', mat2str(RestrictToDomainE));
fprintf('======================================================================\n\n');

% Initialize results trackers
PSNR_Values = zeros(1, NumImages);
SSIM_Values = zeros(1, NumImages);
BER_Values = zeros(1, NumImages);
EmbTimes = zeros(1, NumImages);
Capacity_Values = zeros(1, NumImages);

fprintf('%-10s | %-12s | %-10s | %-10s | %-10s | %-10s\n', ...
    'Image', 'Capacity (bp)', 'PSNR (dB)', 'SSIM', 'BER (%)', 'Time (s)');
fprintf('----------------------------------------------------------------------\n');

for i = 1:NumImages
    CoverPath = fullfile(CoverDir, sprintf('%d.jpg', i));
    StegoPath = fullfile(OutputDir, sprintf('stego_%d.jpg', i));
    RecomPath = fullfile(OutputDir, sprintf('recom_%d.jpg', i));
    
    CoverImg = imread(CoverPath);
    
    % Create a temporary recompressed cover to find capacity 
    TempRecomCoverPath = fullfile(OutputDir, 'temp_recom_cover.jpg');
    imwrite(CoverImg, TempRecomCoverPath, 'Quality', ChannelQF);
    ComStruct = jpeg_read(TempRecomCoverPath);
    nzAC = CEDAR_nnzAC(ComStruct.coef_arrays{1, 1});
    delete(TempRecomCoverPath);
    
    % Determine message payload length
    MsgLen = CEDAR_CalcMsgLen(EmbRate, nzAC);
    
    % Form the message bits vector
    if numel(msg) >= MsgLen
        SecretMsg = msg(1:MsgLen);
    else
        % Fallback if loaded message is smaller
        SecretMsg = randi([0, 1], 1, MsgLen);
    end
    
    % Generate channel quantization table
    ChannelQuantTable = CEDAR_GenQuantTable(ChannelQF);
    
    % 1. Embed secret message
    tic;
    [EmbedLoc, SelectedMsg, LowCapImg] = CEDAR_Embed(CoverPath, StegoPath, ChannelQuantTable, SecretMsg, RestrictToDomainE);
    EmbTimes(i) = toc;
    
    Capacity_Values(i) = numel(EmbedLoc);
    
    % 2. Measure PSNR & SSIM before channel recompression
    StegoImg = imread(StegoPath);
    PSNR_Values(i) = psnr(CoverImg, StegoImg);
    SSIM_Values(i) = ssim(CoverImg, StegoImg);
    
    % 3. Simulate channel recompression (downward recompression to QF 80)
    imwrite(StegoImg, RecomPath, 'Quality', ChannelQF);
    
    % 4. Extract secret message at receiver from recompressed stego image
    ExtractedMsg = CEDAR_Extract(RecomPath, EmbedLoc);
    
    % 5. Compute BER (Bit Error Rate)
    NumErrors = sum(bitxor(SelectedMsg, ExtractedMsg), 'all');
    BER_Values(i) = (NumErrors / numel(SelectedMsg)) * 100;
    
    % Print individual result
    fprintf('%-10s | %-12d | %-10.2f | %-10.4f | %-10.2f | %-10.4f\n', ...
        sprintf('%d.jpg', i), Capacity_Values(i), PSNR_Values(i), SSIM_Values(i), BER_Values(i), ...
        EmbTimes(i));
end

% Print Averages
fprintf('----------------------------------------------------------------------\n');
fprintf('%-10s | %-12.1f | %-10.2f | %-10.4f | %-10.2f | %-10.4f\n', ...
    'Average', mean(Capacity_Values), mean(PSNR_Values), mean(SSIM_Values), mean(BER_Values), mean(EmbTimes));

fprintf('\nDemo completed. All stego images saved in:\n%s\n', OutputDir);
