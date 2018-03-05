function participant = default_participant()

% Default values for the participant structure.

%--------------------------------------------------------------------------
% Etienne Gaudrain <etienne.gaudrain@cnrs.fr> - 2018-05-02
% CNRS UMR 5292, FR | University of Groningen, UMCG, NL
%--------------------------------------------------------------------------

    participant = struct();
    participant.name = '';
    participant.age = 0;
    participant.sex = ''; % 'm' or 'f'
    participant.language = 'nl_nl'; % 'nl_nl' or 'en_gb'

end