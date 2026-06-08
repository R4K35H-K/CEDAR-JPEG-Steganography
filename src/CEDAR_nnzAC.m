function count = CEDAR_nnzAC(QuantDCT)
    % CEDAR_nnzAC Counts the number of non-zero AC coefficients in the quantized DCT coefficient matrix
    %
    % Input:
    %   QuantDCT - Quantized DCT coefficients matrix (HxW)
    %
    % Output:
    %   count    - Number of non-zero AC coefficients

    temp = QuantDCT;
    temp(1:8:end, 1:8:end) = 0; % Zero out all DC coefficients (top-left of each 8x8 block)
    count = nnz(temp);
end
