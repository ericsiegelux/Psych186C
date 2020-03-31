Screen('Preference', 'SkipSyncTests', 1);
clear; close all;
KbName('UnifyKeyNames');
debugMode = 0;
rng('shuffle');

try
    %% Participant Information
    %If statement to determine whether the dialogue box to acquire participant information appears
    if debugMode == 0 %if not in debug mode, then present the box
        while 1
            % get user information
            prompt = {'Participant ID:','Age:','Gender:'};
            dlg_title = 'Subject Information';
            num_lines = 1; %How big each box is
            options.Resize = 'on';
            options.WindowStyle = 'normal';
            subjInfo = inputdlg(prompt,dlg_title,num_lines,{'','','',''},options); %'' = default values (empty)
            % store information in a structure called res (for "results")
            res.subjID = subjInfo{1};
            res.age = str2double(subjInfo{2});
            res.gender = subjInfo{3};
            % create savefile pathname
            if ~exist('data','dir')
                mkdir data; %make the directory data if it does not exist yet
            end
            addpath('data');
            savename = ['data/LAB_' res.subjID '.mat']; %Lab_yzx.mat
            
            % check to see if a file of that name already exists and ask to overwrite
            % if it does
            if exist(savename,'file')
                overwrite = input('A file with that name already exists. Do you want to overwrite? y/n: ','s');
                if strcmp(overwrite,'y')
                    break;
                end
                % if response is no, prompt for subject information again
            else
                % if no such file exists, keep going with the experiment
                break;
            end %End if structure that checks to see if file is already present
            
        end %end while loop
    end % debug mode
    
    %% Basic Information
    % Colors
    black = [0 0 0];
    red = [220 0 0];
    blue = [0 0 200 200];
    green = [0 220 0];
    white = [255 255 255];
    textColor = white;
    dotColor = red;
    
    %Define keyboard names
    abutton = KbName('a');
    lbutton = KbName('l');
    spacebar = KbName('space');
    exit_button = KbName('ESCAPE');
    
    % Get Screen information
    screenNum=max(Screen('Screens'));
    
    [window, screenRect]=Screen('OpenWindow',screenNum, black);
    Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    HideCursor;
    
    [width height] = RectSize(screenRect);
    [cx cy] = RectCenter(screenRect);
    
    %% Fixation Cross Parameters
    % Set the diameter of the fixation cross
    fixationCrossDiameter = 25;
    
    % Set the line width for the fixation cross
    fixationLineWidth = 2;
    
    % Set the coordinates for the fixation cross
    fixationXCoordinates = [-fixationCrossDiameter fixationCrossDiameter 0 0];
    fixationYCoordinates = [0 0 -fixationCrossDiameter fixationCrossDiameter];
    fixationCross = [fixationXCoordinates; fixationYCoordinates];
    
    % Set the duration for how long the fixation cross appears each trial
    fixationCrossDuration = 1.625;
    phone_image_duration = .625;
    
    
    %% Images
    % Practice - Read Images and Convert to Texture
    image = imread('iPhone X.png'); % Define image and store in array
    practiceP1 = imread('Practice.P1.png');
    practiceP2 = imread('Practice.P2.png');
    practiceL1 = imread('Practice.L1.png');
    practiceL2 = imread('Practice.L2.png');
    
    practiceP1_texture = Screen('MakeTexture', window, practiceP1); % Convert image to texture which is used in Screen
    practiceP2_texture = Screen('MakeTexture', window, practiceP2); % Convert image to texture which is used in Screen
    practiceL1_texture = Screen('MakeTexture', window, practiceL1); % Convert image to texture which is used in Screen
    practiceL2_texture = Screen('MakeTexture', window, practiceL2); % Convert image to texture which is used in Screen
    
    
    
    % Image (Portrait)
    imScale = 1.5;
    imWidth = 326; % original width = 433
    imHeight = 648; % original heigth = 864
    
    % Image (Portrait) Coordinates - to set image center of screen
    im_TopLeft_X = 0+cx-(imWidth/2);
    im_TopLeft_Y = 0+cy-(imHeight/2);
    im_BottomRight_X = 0+cx+(imWidth/2);
    im_BottomRight_Y = 0+cy+(imHeight/2);
    
    % Image (Landscape)
    imScale = 1.5;
    L.imWidth = 648;
    L.imHeight = 326;
    
    % Image (Landscape) Coordinates - to set image center of screen
    L.im_TopLeft_X = 0+cx-(L.imWidth/2);
    L.im_TopLeft_Y = 0+cy-(L.imHeight/2);
    L.im_BottomRight_X = 0+cx+(L.imWidth/2);
    L.im_BottomRight_Y = 0+cy+(L.imHeight/2);
    
    
    %% Instructions
    
    % Instructions
    Screen('DrawText',window,'In this experiment, you may or may not be presented with "T" somewhere within the display of "L".',150,200, textColor);
    Screen('DrawText',window,'If there was a "T", press the "A" button.',150,225, textColor);
    Screen('DrawText',window,'If there was no "T", press the "L" button',150,250, textColor);
    Screen('DrawText',window,'You will be given 0.625 seconds to look at the stimulus',150,300, textColor);
    Screen('DrawText',window,'Press any key to practice.',150,500, textColor);
    
    Screen('Flip',window);
    KbWait;
    KbReleaseWait;
    
    %% Practice
    
    %Fixation Cross for Practice 1
    Screen('DrawLines', window, fixationCross, fixationLineWidth, white, [cx cy], 2);
    Screen('Flip',window);
    WaitSecs(fixationCrossDuration);
    
    % Practice 1
    Screen('DrawTexture',window,practiceP1_texture,[], [im_TopLeft_X im_TopLeft_Y  im_BottomRight_X im_BottomRight_Y]); % Place image into screen
    %Screen('DrawText',window,'Was a "T" present? YES(A) or NO(L)?',cx-200,100, textColor);
    Screen('Flip',window);
    WaitSecs(phone_image_duration);
%   
    Screen('DrawText',window,'Was a "T" present? YES(A) or NO(L)?',cx-200,cy, textColor);
    Screen('Flip',window);
    KbWait;
    KbReleaseWait;
    
    %Results
    Screen('DrawTexture',window,practiceP1_texture,[], [im_TopLeft_X im_TopLeft_Y  im_BottomRight_X im_BottomRight_Y]); % Place image into screen
    Screen('DrawText',window,'"T" was present on row 1 and column 1',cx-200,900, textColor);
    Screen('DrawText',window,'Press any key to continue.',cx-200,950, textColor);
    Screen('Flip',window);
    KbWait;
    KbReleaseWait;
    %WaitSecs(1);
    
    %Fixation Cross for Practice 2
    Screen('DrawLines', window, fixationCross, fixationLineWidth, white, [cx cy], 2);
    Screen('Flip',window);
    WaitSecs(fixationCrossDuration);
    
    %Practice 2
    Screen('DrawTexture',window,practiceP2_texture,[], [im_TopLeft_X im_TopLeft_Y  im_BottomRight_X im_BottomRight_Y]); % Place image into screen
    Screen('Flip',window);
    WaitSecs(phone_image_duration);
    
    Screen('DrawText',window,'Was a "T" present? YES(A) or NO(L)?',cx-200,cy, textColor);
    Screen('Flip',window);
    KbWait;
    KbReleaseWait;
    
    %Results
    Screen('DrawTexture',window,practiceP2_texture,[], [im_TopLeft_X im_TopLeft_Y  im_BottomRight_X im_BottomRight_Y]); % Place image into screen
    Screen('DrawText',window,'"T" was present on row 1 and column 10',cx-200,900, textColor);
    Screen('DrawText',window,'Press any key to continue.',cx-200,950, textColor);
    Screen('Flip',window);
    KbWait;
    KbReleaseWait;
    %WaitSecs(1);
    
    %Fixation Cross for Practice 3
    Screen('DrawLines', window, fixationCross, fixationLineWidth, white, [cx cy], 2);
    Screen('Flip',window);
    WaitSecs(fixationCrossDuration);
    
    %Practice 3
    Screen('DrawTexture',window,practiceL1_texture,[], [L.im_TopLeft_X L.im_TopLeft_Y  L.im_BottomRight_X L.im_BottomRight_Y]); % Place image into screen
    Screen('Flip',window);
    WaitSecs(phone_image_duration);
    
    Screen('DrawText',window,'Was a "T" present? YES(A) or NO(L)?',cx-200,cy, textColor);
    Screen('Flip',window);
    KbWait;
    KbReleaseWait;
    
    %Results
    Screen('DrawTexture',window,practiceL1_texture,[], [L.im_TopLeft_X L.im_TopLeft_Y  L.im_BottomRight_X L.im_BottomRight_Y]); % Place image into screen
    Screen('DrawText',window,'"T" was present on row 1 and column 2',cx-200,900, textColor);
    Screen('DrawText',window,'Press any key to continue.',cx-200,950, textColor);
    Screen('Flip',window);
    KbWait;
    KbReleaseWait;
    %WaitSecs(1);
    
    %Fixation Cross for Practice 4
    Screen('DrawLines', window, fixationCross, fixationLineWidth, white, [cx cy], 2);
    Screen('Flip',window);
    WaitSecs(fixationCrossDuration);
    
    %Practice 4
    Screen('DrawTexture',window,practiceL2_texture,[], [L.im_TopLeft_X L.im_TopLeft_Y  L.im_BottomRight_X L.im_BottomRight_Y]); % Place image into screen
    Screen('Flip',window);
    WaitSecs(phone_image_duration);
    
    Screen('DrawText',window,'Was a "T" present? YES(A) or NO(L)?',cx-200,cy, textColor);
    Screen('Flip',window);
    KbWait;
    KbReleaseWait;
    
    %Results
    Screen('DrawTexture',window,practiceL2_texture,[], [L.im_TopLeft_X L.im_TopLeft_Y  L.im_BottomRight_X L.im_BottomRight_Y]); % Place image into screen
    Screen('DrawText',window,'"T" was present on row 1 and column 1',cx-200,900, textColor);
    Screen('DrawText',window,'Press any key to continue.',cx-200,950, textColor);
    Screen('Flip',window);
    KbWait;
    KbReleaseWait;
    %WaitSecs(1);
    
    % End Practice
    Screen('DrawText',window,'You are finished with the practice trials.  Press any key to continue to the experiment.',500,cy, textColor);
    Screen('Flip',window);
    KbWait;
    KbReleaseWait;
    %WaitSecs(1);
    
    %% Set up Trial Structure
    nTrials = 64;
    
    % Set up some recording material:
    res.participantResponse = zeros(1,nTrials); % Yes = 1; No = 2
    
    % Here add a res structure to record whether the response was 1/4 types
    % of responses: Hit, CR, Miss, FA
    res.SDTresponse = zeros(1,nTrials);
    res.orientation = zeros(1,nTrials);
    res.quadrant = zeros(1,nTrials);
    res.response_time = zeros(1,nTrials);
    res.index = zeros(1,nTrials);
    
    % Set up flags
    touchtone = 0;
    spacebarcount = 0;
    typeResponse = 0; %  %hit=1 / miss=2 / fa = 3 / CR = 4
    
    % Make some of these trials noise
    noise_index = repelem(0,1,32);
    signal_index = repelem (1,1,32);
    trialMatrix = [noise_index signal_index];
    
    pic = 0;
    pic_index = [1:64];
    rand_array = [1:64];
    
    %% For loop to determine trial-to-trial sequence
    for t = 1:1
        
        pic = 0;
        q = 0;
        
        if(length(pic_index) == 32)
            Screen('DrawText',window,'Take a 5 second break',cx-200,cy, textColor);
            Screen('Flip',window);
            WaitSecs(5);
        end
        
        % Draw the fixation cross in white, 2 = high smoothing
        Screen('FillRect',window,black);
        Screen('DrawLines', window, fixationCross, fixationLineWidth, white, [cx cy], 2);
        Screen('Flip',window);
        WaitSecs(fixationCrossDuration);
        
        % Portrait - Read Images and Convert to Texture
        rand_index = randperm(length(rand_array),1);
        res.index(t) = pic_index(rand_index);
        
        if(pic_index(rand_index) == 1)
                pic = imread('P.N.png');
                res.quadrant(t) = 0;
            elseif(pic_index(rand_index) ==  2)
                pic = imread('P.N.png');
                res.quadrant(t) = 0;
            elseif(pic_index(rand_index) ==  3)
                pic = imread('P.N.png');
                res.quadrant(t) = 0;
            elseif(pic_index(rand_index) ==  4)
                pic = imread('P.N.png');
                res.quadrant(t) = 0;
            elseif(pic_index(rand_index) ==  5)
                pic = imread('P.N.png');
                res.quadrant(t) = 0;
            elseif(pic_index(rand_index) ==  6)
                pic = imread('P.N.png');
                res.quadrant(t) = 0;
            elseif(pic_index(rand_index) ==  7)
                pic = imread('P.N.png');
                res.quadrant(t) = 0;
            elseif(pic_index(rand_index) ==  8)
                pic = imread('P.N.png');
                res.quadrant(t) = 0;
            elseif(pic_index(rand_index) ==  9)
                pic = imread('P.N.png');
                res.quadrant(t) = 0;
            elseif(pic_index(rand_index) ==  10)
                pic = imread('P.N.png');
                res.quadrant(t) = 0;
            elseif(pic_index(rand_index) ==  11)
                pic = imread('P.N.png');
                res.quadrant(t) = 0;
            elseif(pic_index(rand_index) ==  12)
                pic = imread('P.N.png');
                res.quadrant(t) = 0;
            elseif(pic_index(rand_index) ==  13)
                pic = imread('P.N.png');
                res.quadrant(t) = 0;
            elseif(pic_index(rand_index) ==  14)
                pic = imread('P.N.png');
                res.quadrant(t) = 0;
            elseif(pic_index(rand_index) ==  15)
                pic = imread('P.N.png');
                res.quadrant(t) = 0;
            elseif(pic_index(rand_index) ==  16)
                pic = imread('P.N.png');
                res.quadrant(t) = 0;
            elseif(pic_index(rand_index) ==  17)
                pic = imread('L.N.png');
                res.quadrant(t) = 0;
            elseif(pic_index(rand_index) ==  18)
                pic = imread('L.N.png');
                res.quadrant(t) = 0;
            elseif(pic_index(rand_index) ==  19)
                pic = imread('L.N.png');
                res.quadrant(t) = 0;
            elseif(pic_index(rand_index) ==  20)
                pic = imread('L.N.png');
                res.quadrant(t) = 0;
            elseif(pic_index(rand_index) ==  21)
                pic = imread('L.N.png');
                res.quadrant(t) = 0;
            elseif(pic_index(rand_index) ==  22)
                pic = imread('L.N.png');
                res.quadrant(t) = 0;
            elseif(pic_index(rand_index) ==  23)
                pic = imread('L.N.png');
                res.quadrant(t) = 0;
            elseif(pic_index(rand_index) ==  24)
                pic = imread('L.N.png');
                res.quadrant(t) = 0;
            elseif(pic_index(rand_index) ==  25)
                pic = imread('L.N.png');
                res.quadrant(t) = 0;
            elseif(pic_index(rand_index) ==  26)
                pic = imread('L.N.png');
                res.quadrant(t) = 0;
            elseif(pic_index(rand_index) ==  27)
                pic = imread('L.N.png');
                res.quadrant(t) = 0;
            elseif(pic_index(rand_index) ==  28)
                pic = imread('L.N.png');
                res.quadrant(t) = 0;
            elseif(pic_index(rand_index) ==  29)
                pic = imread('L.N.png');
                res.quadrant(t) = 0;
            elseif(pic_index(rand_index) ==  30)
                pic = imread('L.N.png');
                res.quadrant(t) = 0;
            elseif(pic_index(rand_index) ==  31)
                pic = imread('L.N.png');
                res.quadrant(t) = 0;
            elseif(pic_index(rand_index) ==  32)
                pic = imread('L.N.png');
                res.quadrant(t) = 0;
            elseif(pic_index(rand_index) ==  33)
                pic = imread('P.Q1.1.png');
                res.quadrant(t) = 1;
            elseif(pic_index(rand_index) ==  34)
                pic = imread('P.Q1.2.png');
                res.quadrant(t) = 1;
            elseif(pic_index(rand_index) ==  35)
                pic = imread('P.Q1.3.png');
                res.quadrant(t) = 1;
            elseif(pic_index(rand_index) ==  36)
                pic = imread('P.Q1.4.png');
                res.quadrant(t) = 1;
            elseif(pic_index(rand_index) ==  37)
                pic = imread('P.Q2.1.png');
                res.quadrant(t) = 2;
            elseif(pic_index(rand_index) ==  38)
                pic = imread('P.Q2.2.png');
                res.quadrant(t) = 2;
            elseif(pic_index(rand_index) ==  39)
                pic = imread('P.Q2.3.png');
                res.quadrant(t) = 2;
            elseif(pic_index(rand_index) ==  40)
                pic = imread('P.Q2.4.png');
                res.quadrant(t) = 2;
            elseif(pic_index(rand_index) ==  41)
                pic = imread('P.Q3.1.png');
                res.quadrant(t) = 3;
            elseif(pic_index(rand_index) ==  42)
                pic = imread('P.Q3.2.png');
                res.quadrant(t) = 3;
            elseif(pic_index(rand_index) ==  43)
                pic = imread('P.Q3.3.png');
                res.quadrant(t) = 3;
            elseif(pic_index(rand_index) ==  44)
                pic = imread('P.Q3.4.png');
                res.quadrant(t) = 3;
            elseif(pic_index(rand_index) ==  45)
                pic = imread('P.Q4.1.png');
                res.quadrant(t) = 4;
            elseif(pic_index(rand_index) ==  46)
                pic = imread('P.Q4.2.png');
                res.quadrant(t) = 4;
            elseif(pic_index(rand_index) ==  47)
                pic = imread('P.Q4.3.png');
                res.quadrant(t) = 4;
            elseif(pic_index(rand_index) ==  48)
                pic = imread('P.Q4.4.png');
                res.quadrant(t) = 4;
            elseif(pic_index(rand_index) ==  49)
                pic = imread('L.Q1.1.png');
                res.quadrant(t) = 1;
            elseif(pic_index(rand_index) ==  50)
                pic = imread('L.Q1.2.png');
                res.quadrant(t) = 1;
            elseif(pic_index(rand_index) ==  51)
                pic = imread('L.Q1.3.png');
                res.quadrant(t) = 1;
            elseif(pic_index(rand_index) ==  52)
                pic = imread('L.Q1.4.png');
                res.quadrant(t) = 1;
            elseif(pic_index(rand_index) ==  53)
                pic = imread('L.Q2.1.png');
                res.quadrant(t) = 2;
            elseif(pic_index(rand_index) ==  54)
                pic = imread('L.Q2.2.png');
                res.quadrant(t) = 2;
            elseif(pic_index(rand_index) ==  55)
                pic = imread('L.Q2.3.png');
                res.quadrant(t) = 2;
            elseif(pic_index(rand_index) ==  56)
                pic = imread('L.Q2.4.png');
                res.quadrant(t) = 2;
            elseif(pic_index(rand_index) ==  57)
                pic = imread('L.Q3.1.png');
                res.quadrant(t) = 3;
            elseif(pic_index(rand_index) ==  58)
                pic = imread('L.Q3.2.png');
                res.quadrant(t) = 3;
            elseif(pic_index(rand_index) ==  59)
                pic = imread('L.Q3.3.png');
                res.quadrant(t) = 3;
            elseif(pic_index(rand_index) ==  60)
                pic = imread('L.Q3.4.png');
                res.quadrant(t) = 3;
            elseif(pic_index(rand_index) ==  61)
                pic = imread('L.Q4.1.png');
                res.quadrant(t) = 4;
            elseif(pic_index(rand_index) ==  62)
                pic = imread('L.Q4.2.png');
                res.quadrant(t) = 4;
            elseif(pic_index(rand_index) ==  63)
                pic = imread('L.Q4.3.png');
                res.quadrant(t) = 4;
            elseif(pic_index(rand_index) ==  64)
                pic = imread('L.Q4.4.png');
                res.quadrant(t) = 4;
        end
        
        if pic_index(rand_index) >= 1 && pic_index(rand_index) <= 16
            res.orientation(t) = 0;
            
            % Image (Portrait) Coordinates - to set image center of screen
            im_TopLeft_X = 0+cx-(imWidth/2);
            im_TopLeft_Y = 0+cy-(imHeight/2);
            im_BottomRight_X = 0+cx+(imWidth/2);
            im_BottomRight_Y = 0+cy+(imHeight/2);
            
        elseif pic_index(rand_index) >= 17 && pic_index(rand_index) <= 32
            res.orientation(t) = 1;
            
            % Image (Landscape) Coordinates - to set image center of screen
            im_TopLeft_X = 0+cx-(L.imWidth/2);
            im_TopLeft_Y = 0+cy-(L.imHeight/2);
            im_BottomRight_X = 0+cx+(L.imWidth/2);
            im_BottomRight_Y = 0+cy+(L.imHeight/2);
            
            
        elseif pic_index(rand_index) >= 33 && pic_index(rand_index) <= 48
            res.orientation(t) = 0;
            
            % Image (Portrait) Coordinates - to set image center of screen
            im_TopLeft_X = 0+cx-(imWidth/2);
            im_TopLeft_Y = 0+cy-(imHeight/2);
            im_BottomRight_X = 0+cx+(imWidth/2);
            im_BottomRight_Y = 0+cy+(imHeight/2);
            
            
        else
            res.orientation(t) = 1;
            
            % Image (Landscape) Coordinates - to set image center of screen
            im_TopLeft_X = 0+cx-(L.imWidth/2);
            im_TopLeft_Y = 0+cy-(L.imHeight/2);
            im_BottomRight_X = 0+cx+(L.imWidth/2);
            im_BottomRight_Y = 0+cy+(L.imHeight/2);
            
        end
        
        pic_texture = Screen('MakeTexture', window, pic); % Convert image to texture which is used in Screen
        
        Screen('DrawTexture',window,pic_texture,[], [im_TopLeft_X im_TopLeft_Y  im_BottomRight_X im_BottomRight_Y]); % Place image into screen
        Screen('Flip',window);
        WaitSecs(phone_image_duration);
        
        start_time = GetSecs;
        
        % Ask the participant what you want to
        Screen('FillRect', window, black);
        Screen('TextSize',window, 24);
        Screen('DrawText',window,'Was a "T" present? YES(A) or NO(L)?',cx-200,cy, textColor);
        Screen('Flip',window);
        
        while 1
            
            [keyDown secs keycode] = KbCheck;
            
            if keycode(abutton) == 1
                touchtone = 1;
                endTime = GetSecs;
                KbReleaseWait;
                break;
            elseif keycode(lbutton) == 1
                touchtone = 2;
                endTime = GetSecs;
                KbReleaseWait;
                break;
            elseif keycode(exit_button) == 1
                endTime = GetSecs;
                EXIT_NOW = true;
                break;
            end
        end
        
        
        responseTime = endTime - start_time;
        res.response_time(t) = responseTime;
        
        
        % H=1 / M=2 / FA = 3 / CR = 4
        if trialMatrix(pic_index(rand_index)) == 1 && touchtone == 1 %Signal + Yes [H]
            typeResponse = 1;
        elseif trialMatrix(pic_index(rand_index)) == 1 && touchtone == 2 %Signal + No [M]
            typeResponse = 2;
        elseif trialMatrix(pic_index(rand_index)) == 0 && touchtone == 1 %Noise + Yes [FA]
            typeResponse = 3;
        elseif trialMatrix(pic_index(rand_index)) == 0 && touchtone == 2 %wNoise + No [CR]
            typeResponse = 4;
        end
        
        pic_index(rand_index) = [];
        rand_array(rand_index) = [];
        
        res.participantResponse(t) = touchtone; % value of key pressed in trial
        res.SDTresponse(t) = typeResponse;
        
        if debugMode == 0
            save(savename,'res');
        end
        
    end
    
    ShowCursor;
    sca;
    
catch
    ShowCursor;
    sca;
    psychrethrow(psychlasterror);
    
end

