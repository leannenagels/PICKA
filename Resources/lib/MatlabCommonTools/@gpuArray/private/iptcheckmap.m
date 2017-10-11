function iptcheckmap(map, function_name, variable_name, argument_position)
%IPTCHECKMAP Check validity of colormap.
%   IPTCHECKMAP(MAP,FUNC_NAME,VAR_NAME,ARG_POS) checks to see if
%   MAP is a valid MATLAB colormap and issues a formatted error
%   message if it is invalid. 
%
%   FUNC_NAME is a string that specifies the name used in the formatted
%   error message to identify the function checking the colormap.
%
%   VAR_NAME is a string that specifies the name used in the formatted
%   error message to identify the argument being checked.
%
%   ARG_POS is a positive integer that indicates the position of
%   the argument being checked in the function argument list. 
%   IPTCHECKMAP includes this information in the formatted error message.
%
%   Example
%   -------
%    
%       bad_map = ones(10);
%       iptcheckmap(bad_map,'func_name','var_name',2)
%
%   See also IPTCHECKHANDLE

%   Copyright 2013-2015 The MathWorks, Inc.

mapClass = classUnderlying(map);

if (~strcmp(mapClass,'double') || isempty(map) || (~isreal(map))||...
      (~ismatrix(map)) || (size(map,2) ~= 3) || issparse(map))
    error(message('images:validate:badMapMatrix', ...
        upper( function_name ), argument_position, variable_name));
end

if (any(any(map(:) < 0) | any(map(:) > 1))>0)
    error(message('images:validate:badMapValues', ...
        upper( function_name ), argument_position, variable_name));
end
