function MsgLen = CEDAR_CalcMsgLen(EmbRate, nzAC)
    % CEDAR_CalcMsgLen Calculates the message length based on embedding rate and non-zero AC count
    %
    % Inputs:
    %   EmbRate - Embedding rate in percentage (e.g. 10 for 10%)
    %   nzAC    - Number of non-zero AC coefficients
    %
    % Output:
    %   MsgLen  - Length of secret message vector

    MsgLen = ceil((EmbRate / 100) * nzAC);
end
