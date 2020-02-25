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
    
    %% Flashing Dot Parameters
    % Set the radius of the circle
    circleStimulusRadius = 2;
    
    % Define minimum X coordinate and maximum X coordinate
    lowerx = cx-150;
    upperx = cx+150;
    
    % Define minimum Y coordinate and maximum Y coordinate
    lowery = cy-150;
    uppery = cy+150;
    
    % Find intermediate values
    potentialHorizontal = (lowerx:1:upperx);
    potentialVertical = (lowery:1:uppery);
    
    % Presentation Time for circle
    circleStimulusDuration = .3;
    
    %% Field of Dots (FoD) Parameters:
    % Set the radius of each dot in the array
    dotsize = 2;
    
    % Set how many dots you would like to appear in the array
    dotdensity = 30^2;
    
    % Define FoD width
    dotmatrixwidth = 300;
    
    % Define FoD height
    dotmatrixheight = 300;
    
    % Use the MakeUniformPlayground to make the X,Y coordinates that would
    % be implemented by Screen DrawDots Function below
    dotCoordinates = MakeUniformPlayground(dotmatrixwidth, dotmatrixheight, dotdensity);
    
    %% Experiment Instrutions
    
    % Adding Phone Photo here to test import and coordinates
    image = imread('iPhone X.png'); % Define image and store in array
    image_texture = Screen('MakeTexture', window, image); % Convert image to texture which is used in Screen
    
    % test image coordinates
    imScale = 1.5;
    imWidth = 433/imScale; % original width = 433
    imHeight = 864/imScale; % original heigth = 864
    
    % Image Coordinates to set image center of screen
    im_TopLeft_X = 0+cx-(imWidth/2);
    im_TopLeft_Y = 0+cy-(imHeight/2);
    im_BottomRight_X = 0+cx+(imWidth/2);
    im_BottomRight_Y = 0+cy+(imHeight/2);
    
    % Boundaries for dots within phone
    dot_Left = im_TopLeft_X+30;
    dot_Top = im_TopLeft_Y+40;
    dot_Right = im_BottomRight_X-40;
    dot_Bottom = im_BottomRight_Y-40;
    
    % Instructions
    Screen('DrawText',window,'In this experiment, you may or may not be presented with a Square somewhere within the display of Circles.',150,200, textColor);
    Screen('DrawText',window,'If there was a Square, press the "A" button.',150,225, textColor);
    Screen('DrawText',window,'If there was no Square, press the "L" button',150,250, textColor);
    Screen('DrawText',window,'You will be given # seconds to complete the task',150,300, textColor);
    Screen('DrawText',window,'Press any key to begin the experiment',150,500, textColor);
    
    % [write code for]: Example of Noise and Signal 
    
    Screen('DrawTexture',window,image_texture,[], [im_TopLeft_X im_TopLeft_Y  im_BottomRight_X im_BottomRight_Y]); % Place image into screen
    
    Screen('DrawText', window, 'o', cx, cy, textColor); %center dot
    Screen('DrawText', window, 'o', dot_Left, dot_Top, textColor); % dot top left coordinate of phone screen
    Screen('DrawText', window, 'o', dot_Right, dot_Top, textColor); % dot top right coordinate of phone screen
    Screen('DrawText', window, 'o', dot_Left, dot_Bottom, textColor); % dot bottom left coordinate of phone screen
    Screen('DrawText', window, 'o', dot_Right, dot_Bottom, textColor); % dot bottom right coordinate of phone screen

    Screen('Flip',window);
    
    
    KbWait;
    KbReleaseWait;
    WaitSecs(1);
    
    %% Set up Trial Structure
    nTrials = 100;
    
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
    trialMatrix = zeros(nTrials,1); % nTrials x 1 column vector 0f 0s
    trialMatrix(randperm(nTrials,30)) = 1; % randomly make 30 of those 0s, 1
    
    %% For loop to determine trial-to-trial sequence
    for t = 1:5
        
        if trialMatrix(t) == 1 % when noise
            dotColor = black;
        elseif trialMatrix(t) == 0 % when signal
            dotColor = red;
        end
        
        % Draw the fixation cross in white, 2 = high smoothing
        Screen('FillRect',window,black);
        Screen('DrawLines', window, fixationCross, fixationLineWidth, white, [cx cy], 2);
        Screen('Flip',window);
        WaitSecs(fixationCrossDuration);
        
        % Moved this to the for loop or else you will keep adding to these
        % coordinates ;)
        circleStimulus = [circleStimulusRadius*cosd(1:360); circleStimulusRadius*sind(1:360)]';
        
        % Move the circle randomly within the screen
        circlemoveX = randsample(potentialHorizontal,1);
        circlemoveY = randsample(potentialVertical,1);
        
        %Move the circle to the screen whatever that random X and Y may be
        circleStimulus(:,1) = circleStimulus(:,1) + circlemoveX;
        circleStimulus(:,2) = circleStimulus(:,2) + circlemoveY;
        
        % Draw the circle dot stimulus
        Screen('FillRect',window,black);
        Screen('FillPoly', window, dotColor, circleStimulus);
        Screen('DrawDots', window, dotCoordinates, dotsize, white, [cx-150 cy-150], 1);
        Screen('Flip',window);
        WaitSecs(circleStimulusDuration);
        
        % Ask the participant what you want to
        Screen('FillRect', window, black);
        Screen('TextSize',window, 24);
        Screen('DrawText',window,'Was a Square present? YES(A) or NO(L)?',cx-200,cy, textColor);
        Screen('Flip',window);
        
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
        
        %H=1 / M=2 / FA = 3 / CR = 4
        if trialMatrix(t) == 0 && touchtone == 1 %Signal + Yes [H]
            typeResponse = 1;
        elseif trialMatrix(t) == 0 && touchtone == 2 %Signal + No [M]
            typeResponse = 2;
        elseif trialMatrix(t) == 1 && touchtone == 1 %Noise + Yes [FA]
            typeResponse = 3;
        elseif trialMatrix(t) == 1 && touchtone == 2 %wNoise + No [CR]
            typeResponse = 4;
        end
        
        res.participantResponse(t) = touchtone; % value of key pressed in trial
        res.SDTresponse(t) = typeResponse;
        res.dotpositionX(t) = circlemoveX;
        res.dotpositionY(t) = circlemoveY;
        
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

