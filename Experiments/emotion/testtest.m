str = 'hello world what a beautiful world';

% if (strcmp(str, 'x') == 0) 
%   disp('yes.')
% else
%     disp('No')
% end

emotionvoices = dir('C:/Users/Leanne/sounds/Emotion_new/*.wav');

%training = (emotionsounds.name(2)=('1'|'3'|'7'|'8'))
% speaker = s1:8;



nFile = length (emotionvoices);

for iFile = 1:nFile 
switch (emotionvoices(iFile).name)
        case (contains(emotionvoices(iFile).name, 'angry')==1)
            emotionvoices(iFile).emotion = 'angry'; 
            display(emotionvoices(iFile).emotion);
        case (contains(emotionvoices(iFile).name, 'sad')==1)
            emotionvoices(iFile).emotion = 'sad';
            display(emotionvoices(iFile).emotion);
        case (contains(emotionvoices(iFile).name, 'happy')==1)
            emotionvoices(iFile).emotion = 'joyful';
            display(emotionvoices(iFile).emotion);
end 
        
end