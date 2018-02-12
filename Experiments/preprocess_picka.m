function preprocess_picka()

participant = default_participant();

fprintf('\nWould you like to preprocess all the stimuli? It takes about 5 min...\n');
r = input('yes | no: ', 's');

r = lower(r(1));

% TODO: move these to picka_definition
%    For each experiment, the PICKA structure will have a function call
%    definition that takes care of pre-processing.

fprintf('\n\n============== Preprocessing for FISHY ==============\n\n');
cd('fishy');
try
    fishy_preprocess(participant.language);
catch e
    warning(e.message);
end
cd('..');

fprintf('\n\n============== Preprocessing for GENDER ==============\n\n');
cd('gender')
try
    gender_run(struct('name', 'generation', 'language', participant.language, 'age', [], 'sex', ''));
catch e
    warning(e.message);
end
cd('..')

fprintf('\n\n============== Preprocessing for CRM ==============\n\n');
cd('CRM')
try
    expe_preprocess_corpus('all', participant.language);
catch e
    warning(e.message);
end
cd('..')

fprintf('\nAll done! (Check above if there''s any ugly warning...\n');
fprintf('Don''t forget to calibrate...\n');




