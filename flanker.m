% this version had the timing changes. stim tag after stim flip
function flanker()

% prompt = "Please Enter Subject Number: ";
% x      = input(prompt);

%add line of code that takes the subNum from memTask script and uses it 
%for the file identifier

%Basic screen structure and configuration
cfg = struct;

%custom subject RT based on correct practice times
%cfg.personalStim = 0.5; % test dummy value for debugging
cfg.personalStim = subjectHelper;

fid = fopen(['flanker_report', datestr(now,'dd-mm-yyyy'),'.csv'],'a+');
%fid = fopen(['flanker_report_', num2str(x, '%.0f'),'.csv'],'a+');

persistent blockCount
%set up one header per file and initialize counter
%must close matlab and restart to reboot the counter
    if isempty(blockCount); blockCount = 0;
        fprintf(fid,'Personal RT: %.4f \n', cfg.personalStim);
        fprintf(fid, 'BlockNumber '); 
        fprintf(fid,'Trial ');
        fprintf(fid,'Response ');
        fprintf(fid,'Time(secs) \n');
    end
    blockCount = blockCount + 1;
        
%take this line out for real experiment(only for prototype) -->WBC
Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference', 'VisualDebugLevel', 0);

%cfg.screen.bgColor = uint8((rgb('Black') * 255) + 0.5); %changed from white to black
cfg.screen.bgColor = uint8((rgb('Black'))); %changed from white to black


%NS Markers
cfg.flankerStartFC = 'FFCR';
cfg.flankerLeftCon = 'FLCO';
cfg.flankerRightCon = 'FRCO';
cfg.flankerLeftIn = 'FLIN';
cfg.flankerRightIn = 'FRIN';
cfg.flankerResp = 'FRSP';
cfg.flankerNoResp = 'NRSP';
cfg.flankerFeedBackCorr = 'FFBC';
cfg.flankerFeedBackIncor = 'FFBI';
cfg.flankerFeedBackSlow = 'FFBS'; % flanker slow feedback symbol
cfg.flankerTooR = 'FRRS'; % flanker too slow right key
cfg.flankerTooL = 'FLRS'; % flanker too slow left key

%Randomization for the ISI -> fixation cross
%200 - 400ms
xmin = 0.2;
xmax = 0.4;
cfg.randomInt = xmin + rand(1)*(xmax-xmin);

%standard time between stim and feedback
cfg.standTime = 0.9;

%Randomization for the ISI -> Post Feedback
zmin = 0.1;
zmax = 0.3;
cfg.randomIntPost = zmin + rand(1) * (zmax - zmin);

%Set Fixed onscreen stimuli time
cfg.stimTime = 0.1;

%Set Fixed onscreen feedback time
cfg.feedTime = 0.9;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%cfg.screenNumber = 2; %change back to 2/this setting is for my home external monitor
cfg.screenNumber = max(Screen('Screens'));
%screenRect = Screen('Rect', screenNumber);
% Width = RectWidth(screenRect);
% Height = RectHeight(screenRect);

% stimuli sizes
cfg.text.basicTextSize = 72;
cfg.text.instructTextSize = 36;
cfg.text.fixSize = 72;

% text colors
cfg.text.blankTextColor = uint8((rgb('Black') * 255) + 0.5); %blank screen - test
cfg.text.basicTextColor = uint8((rgb('White') * 255) + 0.5); %basic
cfg.text.instructColor = uint8((rgb('White') * 255) + 0.5);  %instructions
cfg.text.fixationColor = uint8((rgb('White') * 255) + 0.5); %fixation
cfg.text.correctColor = uint8((rgb('Green') * 255) + 0.5); %correct
cfg.text.incorrectColor = uint8((rgb('Red') * 255) + 0.5); %incorrect
cfg.text.tooSlowColor = uint8((rgb('Yellow') * 255) + 0.5); %slow

% font
cfg.text.basicFontName = 'Courier New';
cfg.text.basicFontStyle = 1;

% number of characters wide at which any text will wrap
cfg.text.instructCharWidth = 70;

% fixation info --> ADD OTHER CHARACTERS TO MAKE CONFIG FILE
cfg.text.fixSymbol = '+';

% Hide the mouse cursor:
HideCursor;

%make the double buffer screen
[w, wRect] = Screen('OpenWindow', cfg.screenNumber, cfg.screen.bgColor);
% store the screen dimensions
cfg.screen.wRect = wRect;

% Do dummy calls to GetSecs, WaitSecs, KbCheck to make sure
% they are loaded and ready when we need them - without delays
% in the wrong moment:
KbCheck;
WaitSecs(0.1);
GetSecs;

% Set priority for script execution to realtime priority:
priorityLevel = MaxPriority(w);
Priority(priorityLevel);

% wait until spacebar is pressed to dismiss the instructions
function dismiss()
    RestrictKeysForKbCheck(KbName('SPACE'));
    KbWait(-1,2);
    RestrictKeysForKbCheck([]);
    Screen('Flip', w);
    WaitSecs(1.000);
end

%Setup the Instructions Screen
Screen('TextSize', w, cfg.text.instructTextSize);
Screen('TextFont', w, cfg.text.basicFontName);
Screen('TextStyle', w, cfg.text.basicFontStyle);
message1 = sprintf('Welcome to the Flanker Task.\n\nPlease Press the Spacebar to Receive Instructions.');
message2 = sprintf('Your task is to determine the direction of the center arrow.\n\nPlease use the f and j keys to respond.\n\nRespond as quickly as you can.\n\nPress the spacebar to continue.');
message3 = sprintf('The green + indicates a correct response.\n\nThe red x indicates an incorrect response.\n\nThe yellow ! means respond faster.\n\nPress the spacebar to begin.');

%Instructions Sreen --> Screen 1
DrawFormattedText(w, message1, 'center', 'center', cfg.text.basicTextColor, cfg.text.instructCharWidth);
Screen('Flip', w);
dismiss()

%Instructions Screen --> Screen 2
DrawFormattedText(w, message2, 'center', 'center', cfg.text.basicTextColor, cfg.text.instructCharWidth);
Screen('Flip', w);
dismiss()

%Instructions Screen --> Screen 3
DrawFormattedText(w, message3, 'center', 'center', cfg.text.basicTextColor, cfg.text.instructCharWidth);
Screen('Flip', w);
dismiss()

% setup the subject responses
KbName('UnifyKeyNames');
left_key = KbName('f');
right_key = KbName('j');

%regular fix cross stim for before stim
function regCross()
    DrawFormattedText(w, cfg.text.fixSymbol, 'center', 'center', cfg.text.basicTextColor);
    Screen('Flip', w);
end

%fix cross stim for post feedback interval
function postFeed()
    DrawFormattedText(w, cfg.text.fixSymbol, 'center', 'center', cfg.text.basicTextColor);
    Screen('Flip', w);
    WaitSecs(cfg.randomIntPost);  
end
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%subject feedback screens

function correct()
    DrawFormattedText(w, '+', 'center', 'center', cfg.text.correctColor);
    Screen('Flip', w);
    NetStation('Event',cfg.flankerFeedBackCorr);
    WaitSecs(cfg.feedTime);
    postFeed();
end

function incorrect()
    DrawFormattedText(w, 'X', 'center', 'center', cfg.text.incorrectColor);
    Screen('Flip', w);
    NetStation('Event',cfg.flankerFeedBackIncor);
    WaitSecs(cfg.feedTime);
    postFeed();
end

function tooslow()
    DrawFormattedText(w, '!', 'center', 'center', cfg.text.tooSlowColor);
    Screen('Flip', w);
    NetStation('Event',cfg.flankerFeedBackSlow);
    WaitSecs(cfg.feedTime);
    postFeed();
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%flanker conditions

%congruent left
function conleft()
    response = 0;
    x = cfg.personalStim;
    Screen('TextSize', w, cfg.text.basicTextSize);
    DrawFormattedText(w, cfg.text.fixSymbol, 'center', 'center', cfg.text.basicTextColor);
    Screen('Flip', w);
    NetStation('Event',cfg.flankerStartFC);
    %fixation random interval
    WaitSecs(cfg.randomInt);
    %write to file the block Number + trial type 
    fprintf(fid, '%d ', blockCount); 
    fprintf(fid,'congruent-left ');

    %tic is the CPUs internal stopwatch
    tic;
    
    while toc < (cfg.stimTime + cfg.standTime)
        
        regCross()
   
        if toc < (x) %personal RT stim included
            
            [~,secs,keyCode,~] = KbCheck;

                %run the stim for stimTime
                if toc < (cfg.stimTime) %changed from while to if
                    Screen('TextSize', w, cfg.text.basicTextSize);
                    DrawFormattedText(w, '<<<<<', 'center', 'center', cfg.text.basicTextColor);
                    [~,StimulusOnsetTime,~] = Screen('Flip', w);
                    %NS Marker for stimulus
                    NetStation('Event',cfg.flankerLeftCon);
                    WaitSecs(cfg.stimTime);
                end
                
                if keyCode(left_key)
                    NetStation('Event',cfg.flankerResp);
                    RT = secs - StimulusOnsetTime;
                    fprintf(fid,'Correct ');
                    fprintf(fid,'%.4f \n',RT');
                    response = 1;
                    WaitSecs(cfg.standTime - RT);
                elseif keyCode(right_key)
                    NetStation('Event',cfg.flankerResp);
                    RT = secs - StimulusOnsetTime;
                    fprintf(fid,'Incorrect ');
                    fprintf(fid,'%.4f \n',RT');
                    response = 2;
                    WaitSecs(cfg.standTime - RT);
                end
        end
        %this is where we need to subdivide the responses for too slow 
        %reset the keycheck
        [~,secs,keyCode,~] = KbCheck;

        if keyCode(left_key) && response == 0
            response = 3;
            NetStation('Event',cfg.flankerTooL);
            RT = secs - StimulusOnsetTime;
            fprintf(fid,'SlowLeft ');
            fprintf(fid,'%.4f \n',RT');
            WaitSecs(cfg.standTime - RT);
            tooslow()
        elseif keyCode(right_key) && response == 0
            response = 4;
            NetStation('Event',cfg.flankerTooR);
            RT = secs - StimulusOnsetTime;
            fprintf(fid,'SlowRight ');
            fprintf(fid,'%.4f \n',RT');
            WaitSecs(cfg.standTime - RT);
            tooslow()
        end
    end
    if response == 0
        NetStation('Event',cfg.flankerNoResp);
        RT = secs - StimulusOnsetTime;
        fprintf(fid,'NoResp ');
        fprintf(fid,'%.4f \n',RT');
        tooslow()
    elseif response == 2
        incorrect()
    elseif response == 1
        correct()
    end 

end               

%congruent right
function conright()
    %set the response
    response = 0;
    x = cfg.personalStim;
    Screen('TextSize', w, cfg.text.basicTextSize);
    DrawFormattedText(w, cfg.text.fixSymbol, 'center', 'center', cfg.text.basicTextColor);
    Screen('Flip', w);
    NetStation('Event',cfg.flankerStartFC);
    % fixation random interval
    WaitSecs(cfg.randomInt);
    
    %write to file block count/trial type
    fprintf(fid, '%d ', blockCount); 
    fprintf(fid,'congruent-right ');

    %tic is the CPUs internal stopwatch
    tic;
    
    while toc < (cfg.stimTime + cfg.standTime)
        
        regCross()

        if toc < (x) %personal RT stim included
            
            [~,secs,keyCode,~] = KbCheck;

            %run the stim for stimTime
            if toc < (cfg.stimTime) %changed from while to if
                Screen('TextSize', w, cfg.text.basicTextSize);
                DrawFormattedText(w, '>>>>>', 'center', 'center', cfg.text.basicTextColor);
                [~,StimulusOnsetTime,~] = Screen('Flip', w);
                %NS Marker for Stimulus
                NetStation('Event',cfg.flankerRightCon);
                WaitSecs(cfg.stimTime);
            end
            
            if keyCode(right_key)
                NetStation('Event',cfg.flankerResp);
                RT = secs - StimulusOnsetTime;
                fprintf(fid,'Correct ');
                fprintf(fid,'%.4f \n',RT');
                response = 1;
                WaitSecs(cfg.standTime - RT);
            elseif keyCode(left_key)    
                NetStation('Event',cfg.flankerResp);
                RT = secs - StimulusOnsetTime;
                fprintf(fid,'Incorrect ');
                fprintf(fid,'%.4f \n',RT');
                response = 2;
                WaitSecs(cfg.standTime - RT);
            end
        end
        % this is where we need to subdivide the responses (FlRS / FRRS)
        [~,secs,keyCode,~] = KbCheck;

        if keyCode(left_key) && response == 0
            response = 3;
            NetStation('Event',cfg.flankerTooL);
            RT = secs - StimulusOnsetTime;
            fprintf(fid,'SlowLeft ');
            fprintf(fid,'%.4f \n',RT');
            WaitSecs(cfg.standTime - RT);
            tooslow()
        elseif keyCode(right_key) && response == 0
            response = 4;
            NetStation('Event',cfg.flankerTooR);
            RT = secs - StimulusOnsetTime;
            fprintf(fid,'SlowRight ');
            fprintf(fid,'%.4f \n',RT');
            WaitSecs(cfg.standTime - RT);
            tooslow()
        end
    end    
    if response == 0
        NetStation('Event',cfg.flankerNoResp);
        RT = secs - StimulusOnsetTime;
        fprintf(fid,'NoResp ');
        fprintf(fid,'%.4f \n',RT');
        tooslow()
    elseif response == 2
        incorrect()
    elseif response == 1
        correct()
    end

end    
        
%incongruent left
function inconleft()
  %set the response level
    response = 0;
    x = cfg.personalStim;
    Screen('TextSize', w, cfg.text.basicTextSize);
    DrawFormattedText(w, cfg.text.fixSymbol, 'center', 'center', cfg.text.basicTextColor);
    Screen('Flip', w);
    NetStation('Event',cfg.flankerStartFC);
    % fixation random interval
    WaitSecs(cfg.randomInt);
    
    fprintf(fid, '%d ', blockCount); 
    fprintf(fid,'incongruent-left ');

    %tic is the CPUs internal stopwatch
    tic;

    while toc < (cfg.stimTime + cfg.standTime)
        
        regCross()
    
        if toc < (x) %personal RT stim included
            
            [~,secs,keyCode,~] = KbCheck;

            %run the stim for stimTime
            if toc < (cfg.stimTime) %changed from while to if
                Screen('TextSize', w, cfg.text.basicTextSize);
                DrawFormattedText(w, '>><>>', 'center', 'center', cfg.text.basicTextColor);
                [~,StimulusOnsetTime,~] = Screen('Flip', w);
                %NS Marker
                NetStation('Event',cfg.flankerLeftIn);
                WaitSecs(cfg.stimTime);
            end
            
            if keyCode(left_key)
                NetStation('Event',cfg.flankerResp);
                RT = secs - StimulusOnsetTime;
                fprintf(fid,'Correct ');
                fprintf(fid,'%.4f \n',RT');
                response = 1;
                WaitSecs(cfg.standTime - RT);
            elseif keyCode(right_key)
                NetStation('Event',cfg.flankerResp);
                RT = secs - StimulusOnsetTime;
                fprintf(fid,'Incorrect ');
                fprintf(fid,'%.4f \n',RT');
                response = 2;
                WaitSecs(cfg.standTime - RT);
           end
        end
        % this is where we need to subdivide the responses
        [~,secs,keyCode,~] = KbCheck;

        if keyCode(left_key) && response == 0
            response = 3;
            NetStation('Event',cfg.flankerTooL);
            RT = secs - StimulusOnsetTime;
            fprintf(fid,'SlowLeft ');
            fprintf(fid,'%.4f \n',RT');
            WaitSecs(cfg.standTime - RT);
            tooslow()
        elseif keyCode(right_key) && response == 0
            response = 4;
            NetStation('Event',cfg.flankerTooR);
            RT = secs - StimulusOnsetTime;
            fprintf(fid,'SlowRight ');
            fprintf(fid,'%.4f \n',RT');
            WaitSecs(cfg.standTime - RT);
            tooslow()
        end
    end
    if response == 0
        NetStation('Event',cfg.flankerNoResp);
        RT = secs - StimulusOnsetTime;
        fprintf(fid,'NoResp ');
        fprintf(fid,'%.4f \n',RT');
        tooslow()
    elseif response == 2
        incorrect()
    elseif response == 1
        correct()
    end
    
end

%incongruent right
function inconright()
    %set the response level
    response = 0;
    x = cfg.personalStim;
    Screen('TextSize', w, cfg.text.basicTextSize);
    DrawFormattedText(w, cfg.text.fixSymbol, 'center', 'center', cfg.text.basicTextColor);
    Screen('Flip', w);
    NetStation('Event',cfg.flankerStartFC);
    % fixation random interval
    WaitSecs(cfg.randomInt);
    
    %write to file block count/trial type
    fprintf(fid, '%d ', blockCount); 
    fprintf(fid,'incongruent-right ');

    %tic is the CPUs internal stopwatch
    tic;
    
    while toc < (cfg.stimTime + cfg.standTime)
        
        regCross()
    
        if toc < (x) %personal RT stim included
            %run the stim for stimTime
            
            [~,secs,keyCode,~] = KbCheck;

            if (toc < (cfg.stimTime)) %changed from while to if
                Screen('TextSize', w, cfg.text.basicTextSize);
                DrawFormattedText(w, '<<><<', 'center', 'center', cfg.text.basicTextColor);
                [~,StimulusOnsetTime,~] = Screen('Flip', w); 
                %NS Marker for stimulus
                NetStation('Event',cfg.flankerRightIn);
                WaitSecs(cfg.stimTime);
            end
            
            if keyCode(right_key)
                NetStation('Event',cfg.flankerResp);
                RT = secs - StimulusOnsetTime;
                fprintf(fid,'Correct ');
                fprintf(fid,'%.4f \n',RT');
                response = 1;
                WaitSecs(cfg.standTime - RT);
            elseif keyCode(left_key)    
                NetStation('Event',cfg.flankerResp);
                RT = secs - StimulusOnsetTime;
                fprintf(fid,'Incorrect ');
                fprintf(fid,'%.4f \n',RT');
                response = 2;
                WaitSecs(cfg.standTime - RT);
            end
        end
        % this is where we need to subdivide the reponses
        [~,secs,keyCode,~] = KbCheck;

        if keyCode(left_key) && response == 0
            response = 3;
            NetStation('Event',cfg.flankerTooL);
            RT = secs - StimulusOnsetTime;
            fprintf(fid,'SlowLeft ');
            fprintf(fid,'%.4f \n',RT');
            WaitSecs(cfg.standTime - RT);
            tooslow()
        elseif keyCode(right_key) && response == 0
            response = 4;
            NetStation('Event',cfg.flankerTooR);
            RT = secs - StimulusOnsetTime;
            fprintf(fid,'SlowRight ');
            fprintf(fid,'%.4f \n',RT');
            WaitSecs(cfg.standTime - RT);
            tooslow()
        end
    end
    if response == 0
        NetStation('Event',cfg.flankerNoResp);
        RT = secs - StimulusOnsetTime;
        fprintf(fid,'NoResp ');
        fprintf(fid,'%.4f \n',RT');
        tooslow()
    elseif response == 2
        incorrect()
    elseif response == 1
        correct()
    end
    
end
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%main function loop
%create an array with the proportions you want for testing i.e.
% 1&2 == congruent / 3&4 == incongruent
%m = repelem([1 2 3 4], [3 3 7 7]); %this is 30% con / 70% incon --> 20 trials
m = repelem([1 2 3 4], [9 9 21 21]); %30% con / 70% incon --> 60 trials
%shuffle 
m = m(randperm(numel(m)));
%present the stimuli and increment the trials backwards
%k=20; %total number of trials for one block --> one minute
k=60; %number of trials in 3 minutes

%main loop for running stimuli
while k~=0   
    %congruent left
    if m(1,k)==1
        conleft()
        k=k-1;  
    %congruent right
    elseif m(1,k)==2
        conright()
        k=k-1;   
    %incongruent left
    elseif m(1,k)==3
        inconleft()
        k=k-1;
    %incongruent right
    elseif m(1,k)==4
        inconright()
        k=k-1;
    end

end

fclose(fid);
%close the PTB screen
Screen(w, 'Close')

end
