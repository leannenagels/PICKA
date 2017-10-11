function outputImage = ippgeotrans(inputImage, tForm, imageSize, method, fillVal) %#codegen
% Copyright 2013-2015 The MathWorks, Inc.

coder.inline('always');
coder.internal.prefer_const(inputImage, tForm, imageSize, method, fillVal);


eml_invariant(eml_is_const(method),...
              eml_message('images:ippgeotrans:methodStringNotConst'),...
              'IfNotConst','Fail');
        
validatestring(method, {'nearest', 'linear'}, mfilename, 'InterpolationMethod'); %#ok<*EMCA>

outputImageSize = size(inputImage);
outputImageSize(1) = imageSize(1);
outputImageSize(2) = imageSize(2);

outputImage = coder.nullcopy(zeros((outputImageSize), 'like', inputImage));

if (strcmp(method, 'nearest'))
    methodEnum = 1;
elseif (strcmp(method, 'linear'))
    methodEnum = 2;
end

outputImage = images.internal.coder.buildable.IppgeotransBuildable.ippgeotrans(inputImage,  ...
                                                                               outputImage, ...
                                                                               tForm, ...
                                                                               imageSize, ...
                                                                               int8(methodEnum), ...
                                                                               fillVal);
