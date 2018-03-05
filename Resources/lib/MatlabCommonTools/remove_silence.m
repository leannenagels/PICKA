function [y, bounds] = remove_silence(y, fs, sample_duration)
%REMOVE_SILENCE - Removes silence at beginning and end of sound file
% This function removes the silence at the beginning and end of a sound
% file by analysing a segment of the sound file that should be considered
% silent. From these segments, it calculates a threshold that will be used
% to chop the file.
%
% Y = REMOVE_SILENCE(X, FS)
%   Removes the silence by analysing the first and last 750 ms of the
%   stimulus (suitable for NVA words).
%
% Y = REMOVE_SILENCE(X, FS, SAMPLE_DURATION)
%   Same as above but the duration of the analysis window is specified with
%   SAMPLE_DURATION.
%
% Y = REMOVE_SILENCE(X, FS, [BEGIN_DURATION, END_DURATION])
%   Specifies different durations for beginning and end samples.
%
% [Y, BOUNDS] = REMOVE_SILENCE(...)
%   Also returns the indices used for chopping.
%
% Once the non-silent segment found based on the threshold, the stimulus is
% chopped 20 ms before the onset, and 20 ms after the offset. A 1-ms ramp
% is added to smooth any residual discontinuity at onset and offset.
%
% Y must be a single channel signal. For stereo, apply to the average of
% the two channels and use the BOUNDS output option.


%------------------------------------------------------
% Etienne Gaudrain <e.p.c.gaudrain@rug.nl>,<etienne.gaudrain@cnrs.fr>
% RUG/UMCG, Groningen, NL; CNRS, CRNL, Lyon, FR
% 2014, 2017-11-08
%------------------------------------------------------

    %EG: 2017-11-07 Removed path addition to common tools (we are now in
    %common tools).
    
    if nargin<3 || isempty(sample_duration)
        sample_duration = 750e-3;
    end
    if length(sample_duration)==1
        sample_duration = repmat(sample_duration, 1, 2);
    end
    
    d1 = sample_duration(1);
    d2 = sample_duration(2);

    [b, a] = butter(3, 50*2/fs, 'low');
    e = max(filtfilt(b, a, max(y, 0)), 0);

    e = cosgate(e, fs, 20e-3);

    c = 2*max([e(1:floor(d1*fs)); e(end-floor(d2*fs):end)]);

    % Onset
    i1 = find(e(1:end-1)<c & e(2:end)>=c, 1);

    % Offset
    i2 = find(e(1:end-1)>=c & e(2:end)<c, 1, 'last');

    m = floor(20e-3*fs);

    i1 = max(1, i1 - m);
    i2 = min(length(y), i2 + m);

    y = cosgate(y(i1:i2), fs, 1e-3);
    
    bounds = [i1, i2];
    
end