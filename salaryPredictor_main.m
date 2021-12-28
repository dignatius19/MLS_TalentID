%% Import Data
% Some preprocessing was already completed to remove GKs and place players in position/age specific categories

% Age Categories:
% Youth (Under 20), Rising (20-24), Prime (25-30), Aging (31-35), Veteran (30-36)

% Position Categories:
% Forwards, (including Attacking Midfielders), Midfielders, and Defenders

playerData = importPlayerDataNoGKs("Blind Data for Distribution No GKs.xlsx");

%% Cleaning Data Set

totalPlayerData = table(); % initialize summary table of all games for each player
playerList = unique(playerData.player); % list of all unique players

for i = 1:length(playerList)
    tempPlayerData = playerData(playerData.player == playerList(i), :); % all data for unique player "i"
    
    % Pull Player, Team, Salaries, Most Common Position & Position Category, and Age for Player "i"
    totalPlayerData.Player(i) = tempPlayerData.player(1);
    totalPlayerData.Team(i) = tempPlayerData.team(1);
    totalPlayerData.Base(i) = tempPlayerData.Base(1);
    totalPlayerData.Guaranteed(i) = tempPlayerData.Guaranteed(1);
    totalPlayerData.Position(i) = mode(tempPlayerData.Position);
    totalPlayerData.PosCat(i) = mode(tempPlayerData.PosCat);
    totalPlayerData.Age(i) = mode(tempPlayerData.Age);
    totalPlayerData.AgeGroup(i) = mode(tempPlayerData.AgeGroup);

    % Sum up all event data for unique player "i" and place in the summary table
    for j = [5 10:69]
        totalPlayerData.(tempPlayerData.Properties.VariableNames{j})(i) = sum(tempPlayerData{:,j});
    end

    % Clean up GPS/Running data
    if sum(isnan(tempPlayerData.TotalDistancekm))
        % If there are NaNs in the Running data, then find the per90 Running metrics (after removing games with NaNs)
        totalPlayerData{i, [62:68]} = sum(tempPlayerData{~isnan(tempPlayerData.TotalDistancekm), 62:68}) / sum(tempPlayerData{~isnan(tempPlayerData.TotalDistancekm), 5}) * 90;
        totalPlayerData{i, 69} = max(tempPlayerData{:, 69}); % top sustained speed across all games played
    else
        % Calculate the per90 Running metrics
        totalPlayerData{i, [62:68]} = sum(tempPlayerData{:, 62:68}) / sum(tempPlayerData{:, 5}) * 90;
        totalPlayerData{i, 69} = max(tempPlayerData{:, 69});
    end

end

% Create a table the normalizes all relevant metrics per 90 minutes played
totalPlayerData_90 = totalPlayerData;
totalPlayerData_90{:, 10:61} = totalPlayerData_90{:, 10:61} ./ (totalPlayerData_90{:,9} * 90);

%% Break Player Salaries into Categories

for i = 1:height(totalPlayerData_90)

    if totalPlayerData_90.Base(i) <= 200000
        totalPlayerData_90.Bin(i) = categorical("Bench");
    
    elseif totalPlayerData_90.Base(i) <= 700000
        totalPlayerData_90.Bin(i) = categorical("Sub");
            
    elseif totalPlayerData_90.Base(i) <= 1750000
        totalPlayerData_90.Bin(i) = categorical("Starter");
            
    elseif totalPlayerData_90.Base(i) <= 3500000
        totalPlayerData_90.Bin(i) = categorical("Captain");
            
    elseif totalPlayerData_90.Base(i) > 3500000
        totalPlayerData_90.Bin(i) = categorical("Elite");
        
    end
end

%% Create New Metrics
% Create summarized metrics to reduce the number of features

% Touches, Passes, Forward Passes, Shots, Crosses Attempted, Crosses Completed, Key Passes, Chances Created, Goals, Assists, Take Ons,
% Successful 1v1s, Defensive Actions, Defensive Actions in Attacking 3rd (A3)
sigActions = [10 20 33 38:47 60];
totalPlayerData_90.sigActions = sum(totalPlayerData_90{:, sigActions}, 2);

% Passes in A3, Shots, Crosses Completed, Key Passes, Chance Created, Goals, Assists, Successful 1v1, Def Action in A3, Recovery A3, Interception A3
sigActionsA3 = [22 38 40:44 46 48 54 58];
totalPlayerData_90.sigActionsA3 = sum(totalPlayerData_90{:, sigActionsA3}, 2);

% Passes in M3, Crosses Completed, Key Passes, Chance Created, Assists, Successful 1v1, Def Action M3, Recovery M3, Interception M3
sigActionsM3 = [24 40:42 44 46 49 55 59];
totalPlayerData_90.sigActionsM3 = sum(totalPlayerData_90{:, sigActionsM3}, 2);

% Passes in D2, Def Actions D3, Recovery D3, Interceptions D3
sigActionsD3 = [30 50 56 60];
totalPlayerData_90.sigActionsD3 = sum(totalPlayerData_90{:, sigActionsD3}, 2);

% Shots, Crosses Completed, Key Passes, Chances Created, Goals, Assists
GA_modified = [38 40:44];
totalPlayerData_90.ga_mod = sum(totalPlayerData_90{:, GA_modified}, 2);

% Goals, Assists
GplusA = [43 44];
totalPlayerData_90.GplusA = sum(totalPlayerData_90{:, GplusA}, 2);

% Passing Success Rate in A3
totalPlayerData_90.PassA3Success = totalPlayerData_90.PsCmpA3 ./ totalPlayerData_90.PsCmpA3;
totalPlayerData_90.PassForSuccess = totalPlayerData_90.PsCmpFor ./ totalPlayerData_90.PsAttFor;
totalPlayerData_90.TakeOnSuccess = totalPlayerData_90.Success1v1 ./ totalPlayerData_90.TakeOn;
totalPlayerData_90.CrossSuccess = totalPlayerData_90.CrossCmp ./ totalPlayerData_90.Crosses;

%% More Cleaning
% Here I'll remove players with less than 270 minutes played and those in
% the "Captain" and Elite" salary categories. There is very little data on
% these players and it can cause some issues with the ML model.

totalPlayerData_90 = totalPlayerData_90(totalPlayerData_90.Min >= 270, :);
totalPlayerData_90 = totalPlayerData_90(totalPlayerData_90.Base <= 1750000, :);

%% Train data on GPR ML model
% The function used below is generated through MATLAB's Regression Learner GUI

[GPR_trained, validationRMSE] = trainRegressionModel(totalPlayerData_90);

%% Run Model on dataset

GPR_predict = GPR_trained.predictFcn(totalPlayerData_90);

%% Post Processing
results = totalPlayerData_90;
results.Prediction = GPR_predict;
results.Difference = results.Prediction - results.Base;

% Compare all players to others in their age group
youth_results = compare_groups(results, results.AgeGroup, "Youth");
rising_results = compare_groups(results, results.AgeGroup, "rising");
prime_results = compare_groups(results, results.AgeGroup, "prime");
aging_results = compare_groups(results, results.AgeGroup, "aging");
veteran_results = compare_groups(results, results.AgeGroup, "veteran");

% Compare all players to other in their position group
forward_results = compare_groups(results, results.PosCat, "Forward");
midfielder_results = compare_groups(results, results.PosCat, "Midfielder");
defender_results = compare_groups(results, results.PosCat, "Defender"); 