function y = to_noise(x, fs, do_am, smooth)

% y = to_noise(x, fs, do_am, smooth)
%   Makes a noise from any sound.
%   Input:
%       x: a vector containing the sound.
%       fs: the sampling frequency.
%       do_am: a flag to specify whether to apply the temporal envelope to
%         the noise.
%       smooth: a flag to specify whether the spectrum should be smoothed.
%
%   The temporal envelope is extracted with half-wave rectification and
%   30 Hz low-pass filtering. The spectrum smoothing is done using a
%   500 Hz wide Hann window.

if nargin<3
    do_am = false;
end
if nargin<4
    smooth = false;
end

X = fft(x);
n = length(x);
if mod(n,2)==0
    p = rand((n-2)/2, 1);
    p = [0; p; 0; -p(end:-1:1)];
else
    p = [rand((n-1)/2, 1)];
    p = [0; p; -p(end:-1:1)];
end
if smooth
    w = hann(floor(500/fs*n));
    Y = conv2(abs(X), w, 'same')/sum(w) .* exp(1i*2*pi*p);
else
    Y = abs(X) .* exp(1i*2*pi*p);
end
y = real(ifft(Y));

if do_am
    env = max(x, 0);
    [b, a] = butter(4, 30*2/fs, 'low');
    env = filtfilt(b, a, env);
    env = max(env, 0);
    %env = env / max(env);
    y = env .* y;
end

y = y * rms(x) / rms(y);

