function options = expe_options(options)

options.result_path   = './results';
options.result_prefix = 'pickacrm_';

options.experiment_label = 'PICKA CRM';

options.path.straight = '../../Resources/lib/STRAIGHTV40_006b';
options.path.tools    = '../../Resources/lib/MatlabCommonTools';
options.path.mksqlite = '../../Resources/lib/mksqlite';

options.force_rebuild_straight_output = false;