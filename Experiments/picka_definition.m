function PICKA = picka_definition()

% Definition of the PICKA test battery.

%--------------------------------------------------------------------------
% Etienne Gaudrain <etienne.gaudrain@cnrs.fr> - 2018-05-02
% CNRS UMR 5292, FR | University of Groningen, UMCG, NL
%--------------------------------------------------------------------------

PICKA = struct();

i = 1;
PICKA(i).folder = 'fishy';
PICKA(i).prefix = 'fishy';
%PICKA(i).preprocess = {'

i = i+1;
PICKA(i).folder = 'gender';
PICKA(i).prefix = 'gender';

i = i+1;
PICKA(i).folder = 'CRM';
PICKA(i).prefix = 'expe';

i = i+1;
PICKA(i).folder = 'emotion';
PICKA(i).prefix = 'emotion';