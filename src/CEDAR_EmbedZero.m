function ChangedDCT = CEDAR_EmbedZero(QuantCoeff, CoverStep, ChannelStep)
    % CEDAR_EmbedZero Modifies a DCT coefficient so that its parity is even after channel quantization
    %
    % Inputs:
    %   QuantCoeff   - Quantized DCT coefficient value
    %   CoverStep    - Quantization step size of the cover image at this frequency
    %   ChannelStep  - Quantization step size of the channel at this frequency
    %
    % Outputs:
    %   ChangedDCT   - Modified unquantized DCT coefficient

    % Unquantize cover coefficient
    UnquantCoeff = abs(QuantCoeff) * CoverStep;
    
    % Anticipated channel quantization value
    Quantization = UnquantCoeff / ChannelStep;
    ReceivedCoeff = round(Quantization);
    
    d = Quantization - floor(Quantization); % Fractional part
    z = floor(Quantization);                % Floored quotient
    
    Remainder = mod(UnquantCoeff, ChannelStep);
    X = ChannelStep * (0.5 - (Remainder / ChannelStep)); % Offset to half-integer boundary
    
    ChangedDCT = zeros(1, length(UnquantCoeff));
    
    for i = 1:length(UnquantCoeff)
        % If already received as even, leave unchanged (minimum distortion)
        if mod(ReceivedCoeff(i), 2) == 0 && ReceivedCoeff(i) > 0
            ChangedDCT(i) = UnquantCoeff(i);
        else
            if ReceivedCoeff(i) > 0
                if mod(z(i), 2) == 0  % If quotient is even
                    if d(i) >= 0.5    % If fractional part >= 0.5, it rounds to z+1 (odd). Adjust to round to z (even)
                        ChangedDCT(i) = UnquantCoeff(i) - 1 + X(i);
                    else              % Dead branch in standard execution
                        ChangedDCT(i) = UnquantCoeff(i) - X(i);
                    end
                else                  % If quotient is odd, add X to reach z+0.5 (rounds to z+1, which is even)
                    ChangedDCT(i) = UnquantCoeff(i) + X(i);
                end
            else
                % If coefficient is zero/inactive, leave it unchanged
                ChangedDCT(i) = UnquantCoeff(i);
            end
        end
    end
    
    % Restore sign and round to integer
    ChangedDCT = sign(QuantCoeff) .* round(ChangedDCT);
end
