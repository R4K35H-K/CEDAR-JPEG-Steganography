function [RobustQStep, RobustDelta, RobustElementsLoc] = CEDAR_RobustCoverElements(CoverQuantTable, ChannelQuantTable, RestrictToDomainE)
    % CEDAR_RobustCoverElements Selects robust DCT locations using the odd multiples approach
    %
    % Inputs:
    %   CoverQuantTable    - Quantization table of the cover image (8x8)
    %   ChannelQuantTable  - Anticipated quantization table of the channel (8x8)
    %   RestrictToDomainE  - Boolean to restrict robust elements to u + v <= 6 (paper Eq 3)
    %
    % Outputs:
    %   RobustQStep        - Cover step sizes at robust locations (sorted)
    %   RobustDelta        - Channel step sizes at robust locations (sorted)
    %   RobustElementsLoc  - Cell array of [Row, Col] coordinates grouping locations

    if nargin < 3
        RestrictToDomainE = false;
    end

    % Case 3 of table relationships: channel step size is an odd multiple of cover step size
    isOddMultiple = (mod(ChannelQuantTable, CoverQuantTable) == 0) & ...
                    (mod(ChannelQuantTable ./ CoverQuantTable, 2) == 1);
    
    % The DC coefficient is always non-robust
    isOddMultiple(1, 1) = 0;

    % Apply theoretical embedding domain restriction E(u,v) if toggled
    if RestrictToDomainE
        [V, U] = meshgrid(1:8, 1:8);
        DomainE = (U + V <= 6) & ~(U == 1 & V == 1);
        isOddMultiple = isOddMultiple & DomainE;
    end

    Channel_QStep = ChannelQuantTable .* isOddMultiple;
    Cover_QStep = CoverQuantTable .* isOddMultiple;

    RobustQStep = sort(nonzeros(Cover_QStep));
    RobustDelta = sort(nonzeros(Channel_QStep));

    Channel_QStepX = unique(nonzeros(Channel_QStep));
    RobustElementsLoc = cell(numel(Channel_QStepX), 1);
    for i = 1:numel(Channel_QStepX)
        [Row, Col] = find(Channel_QStep == Channel_QStepX(i));
        RobustElementsLoc{i, 1} = [Row, Col];
    end
end
