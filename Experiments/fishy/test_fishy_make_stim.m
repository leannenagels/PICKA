% test_fishy_make_stim

addpath('../../Resources/lib/MatlabCommonTools');

options = fishy_options(struct('language', 'nl_nl'));
[expe, options] = fishy_build_conditions(options);

options.gain = -10;

condition = expe.test_1.conditions(1);

options_phase = 'test';

options.(options_phase).voices(condition.dir_voice).label

u_f0  = 12*log2(options.(options_phase).voices(condition.dir_voice).f0 / options.(options_phase).voices(condition.ref_voice).f0);
u_ser = 12*log2(options.(options_phase).voices(condition.dir_voice).ser / options.(options_phase).voices(condition.ref_voice).ser);
u = [u_f0, u_ser];
u = u / sqrt(sum(u.^2));

difference = 6;

[button_correct, player, isi, trial] = fishy_make_stim(options, difference, u, condition);

for i=1:3
    player{i}.playblocking();
end

