function hostname = getHostname()

%GETHOSTNAME tries to determine the hostname of the machine.

%--------------------------------------------------------------------------
% Etienne Gaudrain <etienne.gaudrain@crns.fr> - 2017-10-05
% CNRS UMR5292, CRNL, Lyon, FR - RuG, UMCG, KNO, Groningen, NL
%--------------------------------------------------------------------------

try
    hostname = java.net.InetAddress.getLocalHost.getHostName();
catch
    [c,hostname] = system('hostname');
    if c~=0
        hostname = 'undetermined hostname';
    end
end

hostname = char(hostname);
