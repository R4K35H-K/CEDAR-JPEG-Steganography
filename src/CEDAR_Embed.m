function [EmbedLoc, SelectedMsg, LowCapImg] = CEDAR_Embed(CoverPath, StegoPath, ChannelQuantTable, SecretMsg, RestrictToDomainE)
    % CEDAR_Embed Embeds a secret message into cover image robust DCT coefficients
    %
    % Inputs:
    %   CoverPath          - Path to input Cover JPEG image
    %   StegoPath          - Path to output Stego JPEG image to be written
    %   ChannelQuantTable  - Anticipated quantization table of the channel (8x8)
    %   SecretMsg          - Secret message bits vector (0s and 1s)
    %   RestrictToDomainE  - Boolean to restrict robust elements to u + v <= 6 (paper Eq 3)
    %
    % Outputs:
    %   EmbedLoc           - Linear indices of DCT coefficients where message is embedded
    %   SelectedMsg        - Message bits that were actually embedded (truncated if capacity is low)
    %   LowCapImg          - Boolean flag indicating if cover image has insufficient capacity (1) or not (0)

    if nargin < 5
        RestrictToDomainE = false;
    end

    % Read Cover JPEG structure
    CoverStruct = jpeg_read(CoverPath);
    CoverQDCT = CoverStruct.coef_arrays{1, 1};
    CoverQuantTable = CoverStruct.quant_tables{1, 1};

    % Unquantize the Cover DCT coefficients (fast element-wise matrix math)
    CoverQuantMatrix = repmat(CoverQuantTable, size(CoverQDCT) / 8);
    UnquantizedQDCT = CoverQDCT .* CoverQuantMatrix;

    % Retrieve all robust candidate locations
    [SelectedLocations, QStep, Delta] = CEDAR_GetRobustLoc(CoverQDCT, CoverQuantTable, ChannelQuantTable, RestrictToDomainE);

    Selected_DCTCoeff = CoverQDCT(SelectedLocations);

    MsgLen = numel(SecretMsg);
    Capacity = numel(SelectedLocations);

    if MsgLen <= Capacity
        LowCapImg = 0;
        EmbedLoc = SelectedLocations(1:MsgLen);
        SelectedMsg = SecretMsg;
        
        Modified_DCTCoeff = zeros(1, MsgLen);
        for k = 1:MsgLen
            Modified_DCTCoeff(k) = CEDAR_RobustMsgEmb(SecretMsg(k), Selected_DCTCoeff(k), QStep(k), Delta(k));
        end
    else
        LowCapImg = 1;
        EmbedLoc = SelectedLocations;
        SelectedMsg = SecretMsg(1:Capacity);
        
        Modified_DCTCoeff = zeros(1, Capacity);
        for k = 1:Capacity
            Modified_DCTCoeff(k) = CEDAR_RobustMsgEmb(SecretMsg(k), Selected_DCTCoeff(k), QStep(k), Delta(k));
        end
    end

    % Update the coefficients and re-quantize
    Modified_DCT = UnquantizedQDCT;
    Modified_DCT(EmbedLoc) = Modified_DCTCoeff';
    
    NewStego_DCT = round(Modified_DCT ./ CoverQuantMatrix);

    % Write the stego JPEG image
    StegoStruct = CoverStruct;
    StegoStruct.coef_arrays{1, 1} = NewStego_DCT;
    jpeg_write(StegoStruct, StegoPath);
end
