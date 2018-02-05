function b = startswith(str, start)

%STARTSWITH(STR, START) is True if STR starts with START
%   If STR is shorter than START, it returns False. This function has been
%   implemented in newer versions of Matlab.

%--------------------------------------------------------------------------
% Etienne Gaudrain <etienne.gaudrain@crns.fr> - 2017-10-05
% CNRS UMR5292, CRNL, Lyon, FR - RuG, UMCG, KNO, Groningen, NL
%--------------------------------------------------------------------------

if length(str)<length(start)
    b = false;
else
    b = strcmp(str(1:length(start)), start);
end
    