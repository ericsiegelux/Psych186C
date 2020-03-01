% Homework #2: Leveling balllaUp

% Task #1: Make 70 signal trials, Make 30 noise trials.

% Task #2: In the for loop, please randomize
% whether a given trial presents a flashing dot (SIGNAL) or not (NOISE).
% This has already been started in the script using the randperm function
% for task #1.

% Task #3: Add variables to record whatever you need to calculate (i) hits,
% (ii) correct rejections, (iii) false alarms, and (iv) misses
% Task #4: Add some noise to each trial. In the folder on CCLE you will see
% the function MakeUniformPlayground. It allows the users to easily create
% a uniform Field of Dots (FoD) based on the desired width, height, and density
% requested. It has been implemented, incorrectly, in the current script.

% Task #4a: The FoD should appear at the same time as the flashing dot to
% make it difficult for the participant to determine if there was a flash
% present during the trial. As it is currently implemented, the FoD
% appears AFTER the flashing dot stimulus. Please make it appear at
% the same time.

% Task #4B: The FoD appears in the bottom-riqht quadrant of the screen. Please
% adjust  its location such that it occupies the 300 x 300 region
% where the flashing dot can appear. In other words, the FoD should be a
% 300 x 300 field centered on the center of the screen.

% ## FoD TIP: You will need to reposition the code in the trial loop to
% manage this.

% GOOD LUCK / HAVE FUN / BE CREATIVE

Screen('Preference', 'SkipSyncTests', 1);
clear; close all;
KbName('UnifyKeyNames');
debugMode = 1;

try
    %% Participant Information
    %If statement to determine whether the dialogue box to acquire participant information appears
    if debugMode == 0 %if not in debug mode, then present the box
        while 1
            % get user information
            prompt = {'Participant ID:','Age:','Gender:','Experimenter ID:'};
            dlg_title = 'Subject Information';
            num_lines = 1; %How big each box is
            options.Resize = 'on';
            options.WindowStyle = 'normal';
            subjInfo = inputdlg(prompt,dlg_title,num_lines,{'','','',''},options); %'' = default values (empty)
            % store information in a structure called res (for "results")
            res.subjID = subjInfo{1};
            res.age = str2double(subjInfo{2});
            res.gender = subjInfo{3};
            res.experimenterID = subjInfo{4};
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
    fixationCrossDuration = .5;
    
  
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
    Screen('DrawText',window,'You will be given 6 seconds to complete the task',150,300, textColor);
    Screen('DrawText',window,'Press any key to practice.',150,500, textColor);
    
    Screen('Flip',window);
    KbWait;
    KbReleaseWait;
    WaitSecs(1);
    
    %% Practice
    
    %Fixation Cross for Practice 1
    Screen('DrawLines', window, fixationCross, fixationLineWidth, white, [cx cy], 2);
    Screen('Flip',window);
    WaitSecs(fixationCrossDuration);
    
    %Practice 1
    Screen('DrawTexture',window,practiceP1_texture,[], [im_TopLeft_X im_TopLeft_Y  im_BottomRight_X im_BottomRight_Y]); % Place image into screen
    Screen('DrawText',window,'Was a "T" present? YES(A) or NO(L)?',cx-200,100, textColor);
    Screen('Flip',window);
    %KbWait;
    %KbReleaseWait;
    WaitSecs(1);
    
    %Results
    Screen('DrawTexture',window,practiceP1_texture,[], [im_TopLeft_X im_TopLeft_Y  im_BottomRight_X im_BottomRight_Y]); % Place image into screen
    Screen('DrawText',window,'Was a "T" present? YES(A) or NO(L)?',cx-200,100, textColor);
    Screen('DrawText',window,'"T" was present on row 1 and column 1',cx-200,900, textColor);
    Screen('DrawText',window,'Press any key to continue.',cx-200,950, textColor);
    Screen('Flip',window);
    %KbWait;
    %KbReleaseWait;
    WaitSecs(1);
    
    %Fixation Cross for Practice 2
    Screen('DrawLines', window, fixationCross, fixationLineWidth, white, [cx cy], 2);
    Screen('Flip',window);
    WaitSecs(fixationCrossDuration);
    
    %Practice 2
    Screen('DrawTexture',window,practiceP2_texture,[], [im_TopLeft_X im_TopLeft_Y  im_BottomRight_X im_BottomRight_Y]); % Place image into screen
    Screen('DrawText',window,'Was a "T" present? YES(A) or NO(L)?',cx-200,100, textColor);
    Screen('Flip',window);
    %KbWait;
    %KbReleaseWait;
    WaitSecs(1);
    
    %Results
    Screen('DrawTexture',window,practiceP2_texture,[], [im_TopLeft_X im_TopLeft_Y  im_BottomRight_X im_BottomRight_Y]); % Place image into screen
    Screen('DrawText',window,'Was a "T" present? YES(A) or NO(L)?',cx-200,100, textColor);
    Screen('DrawText',window,'"T" was present on row 1 and column 10',cx-200,900, textColor);
    Screen('DrawText',window,'Press any key to continue.',cx-200,950, textColor);
    Screen('Flip',window);
    %KbWait;
    %KbReleaseWait;
    WaitSecs(1);
    
    %Fixation Cross for Practice 3
    Screen('DrawLines', window, fixationCross, fixationLineWidth, white, [cx cy], 2);
    Screen('Flip',window);
    WaitSecs(fixationCrossDuration);
    
    %Practice 3
    Screen('DrawTexture',window,practiceL1_texture,[], [L.im_TopLeft_X L.im_TopLeft_Y  L.im_BottomRight_X L.im_BottomRight_Y]); % Place image into screen
    Screen('DrawText',window,'Was a "T" present? YES(A) or NO(L)?',cx-200,100, textColor);
    Screen('Flip',window);
    %KbWait;
    %KbReleaseWait;
    WaitSecs(1);
    
    %Results
    Screen('DrawTexture',window,practiceL1_texture,[], [L.im_TopLeft_X L.im_TopLeft_Y  L.im_BottomRight_X L.im_BottomRight_Y]); % Place image into screen
    Screen('DrawText',window,'Was a "T" present? YES(A) or NO(L)?',cx-200,100, textColor);
    Screen('DrawText',window,'"T" was present on row 1 and column 2',cx-200,900, textColor);
    Screen('DrawText',window,'Press any key to continue.',cx-200,950, textColor);
    Screen('Flip',window);
    %KbWait;
    %KbReleaseWait;
    WaitSecs(1);
    
    %Fixation Cross for Practice 4
    Screen('DrawLines', window, fixationCross, fixationLineWidth, white, [cx cy], 2);
    Screen('Flip',window);
    WaitSecs(fixationCrossDuration);
    
    %Practice 4
    Screen('DrawTexture',window,practiceL2_texture,[], [L.im_TopLeft_X L.im_TopLeft_Y  L.im_BottomRight_X L.im_BottomRight_Y]); % Place image into screen
    Screen('DrawText',window,'Was a "T" present? YES(A) or NO(L)?',cx-200,100, textColor);
    Screen('Flip',window);
    %KbWait;
    %KbReleaseWait;
    WaitSecs(1);
    
    %Results
    Screen('DrawTexture',window,practiceL2_texture,[], [L.im_TopLeft_X L.im_TopLeft_Y  L.im_BottomRight_X L.im_BottomRight_Y]); % Place image into screen
    Screen('DrawText',window,'Was a "T" present? YES(A) or NO(L)?',cx-200,100, textColor);
    Screen('DrawText',window,'"T" was present on row 1 and column 1',cx-200,900, textColor);
    Screen('DrawText',window,'Press any key to continue.',cx-200,950, textColor);
    Screen('Flip',window);
    %KbWait;
    %KbReleaseWait;
    WaitSecs(1);
    
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
    res.dotpositionX = zeros(1,nTrials); % X-distance from center
    res.dotpositionY = zeros(1,nTrials); % Y-distance from center
    
    % Here add a res structure to record whether the response was 1/4 types
    % of responses: Hit, CR, Miss, FA
    res.SDTresponse = zeros(1,nTrials);
    
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
    
    
    %% For loop to determine trial-to-trial sequence
    for t = 1:5
        
        pic = 0;
        portrait = 0;
        landscape = 0;
        
         % Draw the fixation cross in white, 2 = high smoothing
        Screen('FillRect',window,black);
        Screen('DrawLines', window, fixationCross, fixationLineWidth, white, [cx cy], 2);
        Screen('Flip',window);
        WaitSecs(fixationCrossDuration);
        
        % Portrait - Read Images and Convert to Texture
        rand_index = randi(length(pic_index));
        switch rand_index
          case 1
            pic = imread('P.N.png');
          case 2
            pic = imread('P.N.png');
          case 3
            pic = imread('P.N.png');
          case 4
            pic = imread('P.N.png');
          case 5
            pic = imread('P.N.png');
          case 6
            pic = imread('P.N.png');
          case 7
            pic = imread('P.N.png');
          case 8
            pic = imread('P.N.png');
          case 9
            pic = imread('P.N.png');
          case 10
            pic = imread('P.N.png');
          case 11
            pic = imread('P.N.png');
          case 12
            pic = imread('P.N.png');
          case 13
            pic = imread('P.N.png');
          case 14
            pic = imread('P.N.png');
          case 15
            pic = imread('P.N.png');
          case 16
            pic = imread('P.N.png');
          case 17
            pic = imread('L.N.png');
          case 18
            pic = imread('L.N.png');
          case 19
            pic = imread('L.N.png');
          case 20
            pic = imread('L.N.png');
          case 21
            pic = imread('L.N.png');
          case 22
            pic = imread('L.N.png');
          case 23
            pic = imread('L.N.png');
          case 24
            pic = imread('L.N.png');
          case 25
            pic = imread('L.N.png');
          case 26
            pic = imread('L.N.png');
          case 27
            pic = imread('L.N.png');
          case 28
            pic = imread('L.N.png');
          case 29
            pic = imread('L.N.png');
          case 30
            pic = imread('L.N.png');
          case 31
            pic = imread('L.N.png');
          case 32
            pic = imread('L.N.png');
          case 33
            pic = imread('P.Q1.1.png');
          case 34
            pic = imread('P.Q1.2.png');
          case 35
            pic = imread('P.Q1.3.png');
          case 36
            pic = imread('P.Q1.4.png');
          case 37
            pic = imread('P.Q2.1.png');
          case 38
            pic = imread('P.Q2.2.png');
          case 39
            pic = imread('P.Q2.3.png');
          case 40
            pic = imread('P.Q2.4.png');
          case 41
            pic = imread('P.Q3.1.png');
          case 42
            pic = imread('P.Q3.2.png');
          case 43
            pic = imread('P.Q3.3.png');
          case 44
            pic = imread('P.Q3.4.png');
          case 45
            pic = imread('P.Q4.1.png');
          case 46
            pic = imread('P.Q4.2.png');
          case 47
            pic = imread('P.Q4.3.png');
          case 48
            pic = imread('P.Q4.4.png');
          case 49
            pic = imread('L.Q1.1.png');
          case 50
            pic = imread('L.Q1.2.png');
          case 51
            pic = imread('L.Q1.3.png');
          case 52
            pic = imread('L.Q1.4.png');
          case 53
            pic = imread('L.Q2.1.png');
          case 54
            pic = imread('L.Q2.2.png');
          case 55
            pic = imread('L.Q2.3.png');
          case 56
            pic = imread('L.Q2.4.png');
          case 57
            pic = imread('L.Q3.1.png');
          case 58
            pic = imread('L.Q3.2.png');
          case 59
            pic = imread('L.Q3.3.png');
          case 60
            pic = imread('L.Q3.4.png');
          case 61
            pic = imread('L.Q4.1.png');
          case 62
            pic = imread('L.Q4.2.png');
          case 63
            pic = imread('L.Q4.3.png');
          case 64
            pic = imread('L.Q4.4.png');
        end
        
        if rand_index >= 1 && rand_index <= 16
            portrait = 1;
            
            % Image (Portrait) Coordinates - to set image center of screen
            im_TopLeft_X = 0+cx-(imWidth/2);
            im_TopLeft_Y = 0+cy-(imHeight/2);
            im_BottomRight_X = 0+cx+(imWidth/2);
            im_BottomRight_Y = 0+cy+(imHeight/2);

        elseif rand_index >= 17 && rand_index <= 32
            landscape = 1;

            % Image (Landscape) Coordinates - to set image center of screen
            im_TopLeft_X = 0+cx-(L.imWidth/2);
            im_TopLeft_Y = 0+cy-(L.imHeight/2);
            im_BottomRight_X = 0+cx+(L.imWidth/2);
            im_BottomRight_Y = 0+cy+(L.imHeight/2);
            
            
        elseif rand_index >= 33 && rand_index <= 48
            portrait = 1;
            
            % Image (Portrait) Coordinates - to set image center of screen
            im_TopLeft_X = 0+cx-(imWidth/2);
            im_TopLeft_Y = 0+cy-(imHeight/2);
            im_BottomRight_X = 0+cx+(imWidth/2);
            im_BottomRight_Y = 0+cy+(imHeight/2);
            
            
        else
             landscape = 1;

            % Image (Landscape) Coordinates - to set image center of screen
            im_TopLeft_X = 0+cx-(L.imWidth/2);
            im_TopLeft_Y = 0+cy-(L.imHeight/2);
            im_BottomRight_X = 0+cx+(L.imWidth/2);
            im_BottomRight_Y = 0+cy+(L.imHeight/2);
            
        end
        
        pic_index(rand_index) = [];

        pic_texture = Screen('MakeTexture', window, pic); % Convert image to texture which is used in Screen
                
        
        Screen('DrawTexture',window,pic_texture,[], [im_TopLeft_X im_TopLeft_Y  im_BottomRight_X im_BottomRight_Y]); % Place image into screen
        Screen('DrawText',window,'Was a "T" present? YES(A) or NO(L)?',cx-200,100, textColor);
        Screen('Flip',window);
        KbWait;
        KbReleaseWait;
        %WaitSecs(6);
        
        
        
        % Ask the participant what you want to
        % Screen('FillRect', window, black);
        % Screen('TextSize',window, 24);
        % Screen('DrawText',window,'Was a "T" present? YES(A) or NO(L)?',cx-200,cy, textColor);
        % Screen('Flip',window);
        
        % Let them respond to your question
        while 1
            
            [keyDown secs keycode] = KbCheck;
            
            if keycode(abutton) == 1
                touchtone = 1;
                KbReleaseWait;
                break;
            elseif keycode(lbutton) == 1
                touchtone = 2;
                KbReleaseWait;
                break;
            elseif keycode(exit_button) == 1
                EXIT_NOW = true;
                break;
            end
        end
        
        % H=1 / M=2 / FA = 3 / CR = 4
        if trialMatrix(rand_index) == 1 && touchtone == 1 %Signal + Yes [H]
            typeResponse = 1;
        elseif trialMatrix(rand_index) == 1 && touchtone == 2 %Signal + No [M]
            typeResponse = 2;
        elseif trialMatrix(rand_index) == 0 && touchtone == 1 %Noise + Yes [FA]
            typeResponse = 3;
        elseif trialMatrix(rand_index) == 0 && touchtone == 2 %wNoise + No [CR]
            typeResponse = 4;
        end
        
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

