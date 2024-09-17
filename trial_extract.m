
% Get Trial Table

% Load the MAT file from given path
% folderPath = '/Users/zhangpan/Matlab_Projects/MasterProject/5test';
% Stimulus_file = 'Vstim_2024-3-13_12032024_Charlie_Trials.mat';
% load(Stimulus_file, 'trials')
% 
% trial_file = 'Bpod_Charlie_Detection_Task_SR_20240313_141430';
% load(trial_file, 'SessionData')


n_trials = SessionData.nTrials
Trial_start = SessionData.TrialStartTimestamp(1)
Trial_end = SessionData.TrialStartTimestamp(end)


% Trial Start/End time Output
start_time = transpose(SessionData.TrialStartTimestamp);  % Using the transpose function
stop_time = transpose(SessionData.TrialEndTimestamp);

Trial_time_Matrix = horzcat(start_time, stop_time);



% Trial Performance Output

% initialization hit
hit = false(length(SessionData.RawEvents.Trial),1);
% loop through each trial 
for t = 1:length(SessionData.RawEvents.Trial)  
    % check conditions
    % if any of the Reset label is not NaN NaN
    % assume this is an hit trial 
    if any(~isnan(SessionData.RawEvents.Trial{t}.States.Reset))
        hit(t)=true;
    end
end


% Initialization miss
miss = false(length(SessionData.RawEvents.Trial), 1);

for t = 1:length(SessionData.RawEvents.Trial)
    % Check conditions
    % If any of the Miss labels contains a number, set miss(t) to true
    if any(~isnan(SessionData.RawEvents.Trial{t}.States.Miss))
        miss(t) = true;
    end
end

% Initialization FA
FA = false(length(SessionData.RawEvents.Trial), 1);

% Loop through each trial
for t = 1:length(SessionData.RawEvents.Trial)
    % Check conditions
    % If any of the FA labels contains a number, set FA(t) to true
    if any(~isnan(SessionData.RawEvents.Trial{t}.States.FalseAlarm))
        FA(t) = true;
    end
end


% Initialization CR
CR = false(length(SessionData.RawEvents.Trial), 1);

% Loop through each trial
for t = 1:length(SessionData.RawEvents.Trial)
    % Check conditions
    % If any of the CR labels contains a number, set CR(t) to true
    if any(~isnan(SessionData.RawEvents.Trial{t}.States.CorrectRejection))
        CR(t) = true;
    end
end


% Count the number of hit/miss/FA/CR trials
numHitTrials = sum(hit);
numMissTrials = sum(miss);
numFATrials = sum(FA);
numCRTrials = sum(CR);

% Display the result
% disp(['Number of hit trials: ' num2str(numHitTrials)]);

% Display the indices of hit trials
hitIndices = find(hit);
missIndices = find(miss);
FAIndices = find(FA);
CRIndices = find(CR);


% Combine the variables into a matrix
TrialPerformanceMatrix = [hit, miss, FA, CR];




% Trial Stimulus Presentation Output
originalContrast = transpose([trials.Contrast]);

% CR and FA indices where you want to replace values with zeros
if isempty(CRIndices)
    replaceIndices = FAIndices;
elseif isempty(FAIndices)
    replaceIndices = CRIndices;
else
    % Concatenate CRIndices and FAIndices
    allIndices = [CRIndices; FAIndices];
    
    % Create a logical array indicating the combined indices
    replaceIndices = false(length(originalContrast), 1);
    replaceIndices(allIndices) = true;
end

% Replace the values at replaceIndices with zeros
stimContrast = originalContrast;
stimContrast(replaceIndices) = 0;

% Cut the stim presentation after n_trial
stimContrast = stimContrast(1:n_trials);



% Get Vstim presentation time in each trial

% Initialization of start time of delay in each trial
Vstim_start_time = zeros(length(SessionData.RawEvents.Trial), 1);

% Loop through each trial 
for t = 1:length(SessionData.RawEvents.Trial)  
    % Check the first value of delay label and store in Vstim_start_time
    trial_Vstim_start = SessionData.RawEvents.Trial{t}.States.Delay(1);
    Vstim_start_time(t) = trial_Vstim_start;
end

stim_start_time = Vstim_start_time + start_time;



% Get the First Lick latency

% Initialization of start time of Vstim in each trial
Vstim = NaN(length(SessionData.RawEvents.Trial), 1);

% Loop through each trial 
for t = 1:length(SessionData.RawEvents.Trial)  
    % Check the first value of Vstim label and store in Vstim_start_time
    trial_Vstim = SessionData.RawEvents.Trial{t}.States.vStim;
    if ~isempty(trial_Vstim) && ~isnan(trial_Vstim(1))
        Vstim(t) = trial_Vstim(1);
    end
end


% Initialization of reward
reward = NaN(length(SessionData.RawEvents.Trial), 1);

% Loop through each trial
for t = 1:length(SessionData.RawEvents.Trial)
    % Check if there are any reward states and store the first value
    reward_state = SessionData.RawEvents.Trial{t}.States.Reward;
    if ~isempty(reward_state) && ~isnan(reward_state(1))
        reward(t) = reward_state(1);
    % Check if there are any FalseAlarm states and store the first value,
    % even if the reward state is NaN
    elseif isfield(SessionData.RawEvents.Trial{t}.States, 'FalseAlarm')
        false_alarm_state = SessionData.RawEvents.Trial{t}.States.FalseAlarm;
        if ~isempty(false_alarm_state)
            reward(t) = false_alarm_state(1);
        end
    end
end


% Get fl_latency
fl_latency = reward - Vstim;



% Combine trial table
combinedMatrix = [Trial_time_Matrix, TrialPerformanceMatrix, stimContrast, stim_start_time, fl_latency];
Trial_table = array2table(combinedMatrix, 'VariableNames', {'start_time', 'stop_time', 'hit', 'miss', 'false_alarm', 'correct_reject', 'stim_contrast', 'stim_start_time', 'fl_latency'});


% Save the matrix to a CSV file
writetable(Trial_table, 'New_trial_table_Day12_07052024_Chase.csv');

