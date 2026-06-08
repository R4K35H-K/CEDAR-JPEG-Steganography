function ExtractedMsg = CEDAR_Extract(StegoPath, EmbedLoc)
    % CEDAR_Extract Extracts the secret message from stego image coefficients
    %
    % Inputs:
    %   StegoPath    - Path to the received/recompressed stego JPEG image
    %   EmbedLoc     - Linear indices of DCT coefficients where message is embedded
    %
    % Output:
    %   ExtractedMsg - Extracted secret message bits vector (0s and 1s)

    StegoStruct = jpeg_read(StegoPath);
    DCTRx = StegoStruct.coef_arrays{1, 1};
    
    % Extract coefficients at the stego embedding locations
    RxCoeff = DCTRx(EmbedLoc);
    
    % Extract message bits using the direct LSB parity check
    ExtractedMsg = mod(RxCoeff, 2);
    
    % Ensure the extracted message is a row vector to align with the source format
    if iscolumn(ExtractedMsg)
        ExtractedMsg = ExtractedMsg';
    end
end
