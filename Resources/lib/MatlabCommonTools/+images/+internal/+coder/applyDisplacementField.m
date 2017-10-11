function out = applyDisplacementField(in,D,method,fillVal)%#codegen
%applyDisplacementField Apply a displacement field to an image.
%
% B = applyDisplacementField(A,D,METHOD,FILLVAL) applies a displacement
% field D to the input image A using an interpolation method specified by
% METHOD and a fill value for pixels that map to out of bounds locations in
% A specified by FILLVAL. 

% FOR INTERNAL USE ONLY -- This function is intentionally
% undocumented and is intended for use only within other toolbox
% classes and functions. Its behavior may change, or the feature
% itself may be removed in a future release.

% Copyright 2014 The MathWorks, Inc.

coder.inline('always');
coder.internal.prefer_const(in,D,method,fillVal);

xGrid = 1:size(D,2);
yGrid = 1:size(D,1);
[xGrid,yGrid] = meshgrid(xGrid,yGrid);

inputClass = class(in);

% Perform point mapping computation in single unless D was specified as double.
if ~isa(D,'double')
    D = single(D);
    in = single(in);
else
    in = double(in);
end

% Now map output grid into source image coordinate system using additive
% offsets in D.
xGrid = xGrid + D(:,:,1);
yGrid = yGrid + D(:,:,2);

out = images.internal.coder.interp2d(in,xGrid,yGrid,method,fillVal);

out = cast(out,inputClass);