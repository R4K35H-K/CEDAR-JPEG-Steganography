function ChangedDCT = CEDAR_RobustMsgEmb(MsgBit, QuantCoeff, CoverStep, ChannelStep)
    % CEDAR_RobustMsgEmb Routes the coefficient to appropriate embedding function depending on message bit
    %
    % Inputs:
    %   MsgBit       - Message bit (0 or 1)
    %   QuantCoeff   - Quantized DCT coefficient value
    %   CoverStep    - Quantization step size of the cover image
    %   ChannelStep  - Quantization step size of the channel
    %
    % Outputs:
    %   ChangedDCT   - Modified unquantized DCT coefficient

    if MsgBit == 1
        ChangedDCT = CEDAR_EmbedOne(QuantCoeff, CoverStep, ChannelStep);
    elseif MsgBit == 0
        ChangedDCT = CEDAR_EmbedZero(QuantCoeff, CoverStep, ChannelStep);
    else
        error('Invalid message bit: must be 0 or 1.');
    end
end
