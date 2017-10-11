function B = imresize(varargin)
%IMRESIZE Resize image.
%   B = IMRESIZE(A, SCALE) returns a GPUARRAY image that is SCALE times the
%   size of A, which is a grayscale or RGB gpuArray image.
%
%   B = IMRESIZE(A, [NUMROWS NUMCOLS]) resizes the GPUARRAY image so that
%   it has the specified number of rows and columns.  Either NUMROWS or
%   NUMCOLS may be NaN, in which case IMRESIZE computes the number of rows
%   or columns automatically in order to preserve the image aspect ratio.
%
%   The GPU implementation of this function supports only the cubic
%   interpolation method.
%
%   Examples
%   --------
%   Shrink by factor of two using bicubic interpolation and antialiasing.
%
%       I = im2double(gpuArray(imread('rice.png')));
%       J = imresize(I, 0.5);
%       figure, imshow(I), figure, imshow(J)
%
%   Resize an RGB image to be twice as large.
%
%       RGB = gpuArray(im2single(imread('peppers.png')));
%       RGB2 = imresize(RGB, 2);
%  
%   Notes
%   -----
%   1.  The GPU implementation of this function supports only the cubic
%       interpolation method. For cubic interpolation, the output image may
%       have some values slightly outside the range of pixel values in the 
%       input image.
%   2.  The GPU implementation of this function always performs
%       antialiasing.
%   3.  The input gpuArray A can have at most 2^27 elements.
%
%   Class Support
%   -------------
%   The input image A can be a single- or double-precision gpuArray.  The 
%   output image is of the same underlying class as the input image.
%
%   See also IMRESIZE, GPUARRAY/IMROTATE, IMTRANSFORM, TFORMARRAY,
%            GPUARRAY.

%   Copyright 2013-2016 The MathWorks, Inc.

%   B = IMRESIZE(A, SCALE, METHOD) returns a gpuArray image that is SCALE
%   times the size of A using the METHOD interpolation method. METHOD can
%   be one of the following strings: 'cubic' or 'bicubic'. Note that both
%   correspond to the same interpolation method.

B = images.internal.gpu.imresize(varargin{:});

end

