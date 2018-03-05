function session = getSession()

%GETSESSION returns a session struct containing:
%   - hostname
%   - working_directory: current directory
%   - date_time: date and time
%   - matlab_version: Matlab version
%   - matlab_license: Matlab license number

%--------------------------------------------------------------------------
% Etienne Gaudrain <etienne.gaudrain@crns.fr> - 2017-10-05
% CNRS UMR5292, CRNL, Lyon, FR - RuG, UMCG, KNO, Groningen, NL
%--------------------------------------------------------------------------

session = struct();
session.hostname = getHostname();
session.working_directory = pwd();
session.date_time = datestr(now(), 'yyyy-mm-dd HH:MM:SS');
session.matlab_version = ver();
session.matlab_license = license();