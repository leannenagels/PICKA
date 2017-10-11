function lut = lutbridge
%LUTBRIDGE Compute "bridge" look-up table.

%   Copyright 1993-2012 The MathWorks, Inc.  
    
%#codegen    

lut = logical([ ...
     0     0     0     0     0     0     0     0     0     0     0     0 ...
     1     1     0     0     1     1     1     1     1     1     1     1 ...
     1     1     1     1     1     1     1     1     0     1     0     0 ...
     0     1     0     0     1     1     0     0     1     1     0     0 ...
     1     1     1     1     1     1     1     1     1     1     1     1 ...
     1     1     1     1     0     0     1     1     1     1     1     1 ...
     0     0     0     0     1     1     0     0     1     1     1     1 ...
     1     1     1     1     1     1     1     1     1     1     1     1 ...
     1     1     1     1     1     1     1     1     1     1     0     0 ...
     1     1     0     0     1     1     1     1     1     1     1     1 ...
     1     1     1     1     1     1     1     1     0     1     1     1 ...
     1     1     1     1     0     0     0     0     1     1     0     0 ...
     1     1     1     1     1     1     1     1     1     1     1     1 ...
     1     1     1     1     0     1     0     0     0     1     0     0 ...
     0     0     0     0     0     0     0     0     1     1     1     1 ...
     1     1     1     1     1     1     1     1     1     1     1     1 ...
     0     1     1     1     1     1     1     1     0     0     0     0 ...
     1     1     0     0     1     1     1     1     1     1     1     1 ...
     1     1     1     1     1     1     1     1     0     1     0     0 ...
     0     1     0     0     0     0     0     0     0     0     0     0 ...
     1     1     1     1     1     1     1     1     1     1     1     1 ...
     1     1     1     1     0     1     1     1     0     1     1     1 ...
     1     1     1     1     1     1     1     1     1     1     1     1 ...
     1     1     1     1     1     1     1     1     1     1     1     1 ...
     0     1     0     0     0     1     0     0     1     1     0     0 ...
     1     1     0     0     1     1     1     1     1     1     1     1 ...
     1     1     1     1     1     1     1     1     0     1     1     1 ...
     1     1     1     1     1     1     1     1     1     1     1     1 ...
     1     1     1     1     1     1     1     1     1     1     1     1 ...
     1     1     1     1     1     1     1     1     1     1     1     1 ...
     1     1     0     0     1     1     0     0     1     1     1     1 ...
     1     1     1     1     1     1     1     1     1     1     1     1 ...
     0     1     1     1     1     1     1     1     0     0     0     0 ...
     1     1     0     0     1     1     1     1     1     1     1     1 ...
     1     1     1     1     1     1     1     1     0     1     0     0 ...
     0     1     0     0     0     0     0     0     0     0     0     0 ...
     1     1     1     1     1     1     1     1     1     1     1     1 ...
     1     1     1     1     0     1     1     1     1     1     1     1 ...
     0     0     0     0     1     1     0     0     1     1     1     1 ...
     1     1     1     1     1     1     1     1     1     1     1     1 ...
     0     1     0     0     0     1     0     0     0     0     0     0 ...
     0     0     0     0     1     1     1     1     1     1     1     1 ...
     1     1     1     1     1     1     1     1]);
 lut = lut(:);

