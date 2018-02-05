function check_sound_volume_warning(subject)

if nargin<1
    subject = num2str(now());
end

global CHECK_SOUND_VOLUME_WARNING;

if ~strcmp(CHECK_SOUND_VOLUME_WARNING, subject)
    warndlg('Make sure the SOUND VOLUME is at MAXIMUM!', 'Sound Volume Checker', 'modal');
    CHECK_SOUND_VOLUME_WARNING = subject;
end
