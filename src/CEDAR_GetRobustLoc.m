function [SelectedLocations, QStep, Delta] = CEDAR_GetRobustLoc(CoverQDCT, CoverQuantTable, ChannelQuantTable, RestrictToDomainE)
    % CEDAR_GetRobustLoc Identifies robust element linear indices and quantization steps
    %
    % Inputs:
    %   CoverQDCT          - Cover quantized DCT coefficients matrix (HxW)
    %   CoverQuantTable    - Quantization table of the cover image (8x8)
    %   ChannelQuantTable  - Anticipated quantization table of the channel (8x8)
    %   RestrictToDomainE  - Boolean to restrict robust elements to u + v <= 6 (paper Eq 3)
    %
    % Outputs:
    %   SelectedLocations  - Vector of linear indices of robust AC coefficients
    %   QStep              - Cover quantization steps corresponding to SelectedLocations
    %   Delta              - Channel quantization steps corresponding to SelectedLocations

    if nargin < 4
        RestrictToDomainE = false;
    end

    % Get the robust coefficient lattices
    [~, ~, RobustLoc] = CEDAR_RobustCoverElements(CoverQuantTable, ChannelQuantTable, RestrictToDomainE);

    [H, W] = size(CoverQDCT);
    H_sub = H / 8;

    SelectedLocations = [];
    Delta = [];
    QStep = [];

    % Iterate through robust lattices
    for i = 1:numel(RobustLoc)
        for j = 1:size(RobustLoc{i, 1}, 1)
            x = RobustLoc{i, 1}(j, 1);
            y = RobustLoc{i, 1}(j, 2);

            % Extract subgrid of coefficients at (x, y) across all 8x8 blocks
            subgrid = CoverQDCT(x:8:H, y:8:W);

            % Find non-zero indices in subgrid (AC coefficients only)
            nonzero_idx = find(subgrid ~= 0);

            if ~isempty(nonzero_idx)
                % Convert subgrid coordinates back to main matrix coordinates
                r_sub = mod(nonzero_idx - 1, H_sub) + 1;
                c_sub = floor((nonzero_idx - 1) / H_sub) + 1;

                r_main = x + (r_sub - 1) * 8;
                c_main = y + (c_sub - 1) * 8;

                main_idx = r_main + (c_main - 1) * H;

                SelectedLocations = [SelectedLocations; main_idx];

                % Append the step sizes
                num_elements = numel(main_idx);
                Delta = [Delta, repmat(ChannelQuantTable(x, y), 1, num_elements)];
                QStep = [QStep, repmat(CoverQuantTable(x, y), 1, num_elements)];
            end
        end
    end
end
