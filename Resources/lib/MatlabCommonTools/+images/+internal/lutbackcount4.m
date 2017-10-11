function lut = lutbackcount4
%LUTBACKCOUNT4 Compute "4-connected background count" look-up table.

%   Copyright 2008-2012 The MathWorks, Inc.

% lut was created using the following function.
%
% function lut = makeBackgroundObjCountLUT()
% lut = makelut(@count_fcn, 3);
%-------------------------------------------------------------------%
% function count = count_fcn(nhood)
% if (nhood(2,2))
%        [L, count] = bwlabel(~nhood, 4);
% else
%        count = 	0;
% end
% %
% REFERENCES
% T.Yung Kong and Azriel Rosenfeld, editors. Topological Algorithms for
% Digital Image Processing, 101-106. Elsevier Science Inc., New York, NY, 
% USA, 1996. 

%#codegen

lut = [ ...
     0     0     0     0     0     0     0     0     0     0     0     0 ...
     0     0     0     0     1     1     1     1     1     2     1     1 ...
     1     1     2     1     2     2     2     1     0     0     0     0 ...
     0     0     0     0     0     0     0     0     0     0     0     0 ...
     1     2     2     2     1     2     1     1     2     2     3     2 ...
     2     2     2     1     0     0     0     0     0     0     0     0 ...
     0     0     0     0     0     0     0     0     1     2     2     2 ...
     2     3     2     2     1     1     2     1     2     2     2     1 ...
     0     0     0     0     0     0     0     0     0     0     0     0 ...
     0     0     0     0     2     3     3     3     2     3     2     2 ...
     2     2     3     2     2     2     2     1     0     0     0     0 ...
     0     0     0     0     0     0     0     0     0     0     0     0 ...
     1     2     2     2     2     3     2     2     2     2     3     2 ...
     3     3     3     2     0     0     0     0     0     0     0     0 ...
     0     0     0     0     0     0     0     0     2     3     3     3 ...
     2     3     2     2     3     3     4     3     3     3     3     2 ...
     0     0     0     0     0     0     0     0     0     0     0     0 ...
     0     0     0     0     1     2     2     2     2     3     2     2 ...
     1     1     2     1     2     2     2     1     0     0     0     0 ...
     0     0     0     0     0     0     0     0     0     0     0     0 ...
     2     3     3     3     2     3     2     2     2     2     3     2 ...
     2     2     2     1     0     0     0     0     0     0     0     0 ...
     0     0     0     0     0     0     0     0     1     2     2     2 ...
     2     3     2     2     2     2     3     2     3     3     3     2 ...
     0     0     0     0     0     0     0     0     0     0     0     0 ...
     0     0     0     0     1     2     2     2     1     2     1     1 ...
     2     2     3     2     2     2     2     1     0     0     0     0 ...
     0     0     0     0     0     0     0     0     0     0     0     0 ...
     2     3     3     3     3     4     3     3     2     2     3     2 ...
     3     3     3     2     0     0     0     0     0     0     0     0 ...
     0     0     0     0     0     0     0     0     2     3     3     3 ...
     2     3     2     2     2     2     3     2     2     2     2     1 ...
     0     0     0     0     0     0     0     0     0     0     0     0 ...
     0     0     0     0     1     2     2     2     2     3     2     2 ...
     2     2     3     2     3     3     3     2     0     0     0     0 ...
     0     0     0     0     0     0     0     0     0     0     0     0 ...
     1     2     2     2     1     2     1     1     2     2     3     2 ...
     2     2     2     1     0     0     0     0     0     0     0     0 ...
     0     0     0     0     0     0     0     0     1     2     2     2 ...
     2     3     2     2     1     1     2     1     2     2     2     1 ...
     0     0     0     0     0     0     0     0     0     0     0     0 ...
     0     0     0     0     1     2     2     2     1     2     1     1 ...
     1     1     2     1     1     1     1     0];
     
lut = lut(:);