function b = is_empty(obj)

%IS_EMPTY is True for empty objects
%   This function is like Matlab's ISEMPTY but also handles struct arrays.
%   If the struct array has no field or one of its dimensions is 0, then it
%   is considered empty.
%
%   If the input is not a struct array, the function returns the result of
%   Matlab's ISEMPTY.
%
%   See also ISEMPTY

%--------------------------------------------------------------------------
% Etienne Gaudrain <etienne.gaudrain@crns.fr> - 2017-10-05
% CNRS UMR5292, CRNL, Lyon, FR - RuG, UMCG, KNO, Groningen, NL
%--------------------------------------------------------------------------

if isstruct(obj)
    b = isempty(fieldnames(obj)) || any(size(obj)==0);
else
    b = isempty(obj);
end