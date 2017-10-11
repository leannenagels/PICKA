
% This file must edited to contain the participant's details

participant.name = 'test1'; % Don't enter initials, but the participant's ID number
participant.age = 5;
participant.sex = 'f'; % 'm' or 'f'
participant.language = 'nl'; % 'nl or 'en'

% participant tasks set is specified through the name of the directories holding the experiments
% NOTE: keep NVA first

% participant.expDir = {'NVA', 'fishy', 'emotion', 'MCI', 'gender', 'sos'};
participant.expDir = {'fishy', 'emotion', 'gender', 'sos'};



%%-------- do not edit from here -----------
participant.kidsOrAdults = 'kid';
if participant.age > 18
    participant.kidsOrAdults = 'adult';
end

participant.sentencesCourpus = 'VU_zinnen';
