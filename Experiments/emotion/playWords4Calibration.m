sndFiles = dir(['~/sounds/emotion_norm/*.wav']);
tstart = tic;
for ifile = 1 : length(sndFiles)
    [y, fs] = audioread(['~/sounds/emotion_norm/' sndFiles(ifile).name]);
    p = audioplayer(y, fs);
    playblocking(p);
    telapsed = toc(tstart);
    if telapsed > 90
        break
    end
end


