% test_gui

options.language = 'nl_nl';

[training, test, options] = expe_build_conditions(options);

expe_gui(options);