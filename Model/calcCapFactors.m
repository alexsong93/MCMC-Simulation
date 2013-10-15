function [orig_capfactor,sim_capfactor,orig_max,sim_max,orig_min,sim_min] = ...
    calcCapFactors(season,timeOfDay,isLeap,numPeriods,max_data,data_orig,data_simul)
% calculate the annual average capacity factors for different time of the
% day for different seasons

%Constants
SUMMER_BEGIN_DAY = 120;      SUMMER_DAYS = 153;
SUMMER_MORNING_HOURS = 1071; SUMMER_AFTERNOON_HOURS = 765;
SUMMER_EVENING_HOURS = 612;  SUMMER_NIGHT_HOURS = 1224;

SPRFALL_BEGIN_DAY = 90;      SPRFALL_DAYS = 61;
SPRFALL_MORNING_HOURS = 427; SPRFALL_AFTERNOON_HOURS = 305;
SPRFALL_EVENING_HOURS = 244; SPRFALL_NIGHT_HOURS = 488;

WINTER_BEGIN_DAY = 304;      WINTER_DAYS = 151;
WINTER_MORNING_HOURS = 1057; WINTER_AFTERNOON_HOURS = 755;
WINTER_EVENING_HOURS = 604;  WINTER_NIGHT_HOURS = 1208;

MORNING_START_HOUR = 6;    MORNING_HOURS = 7;
AFTERNOON_START_HOUR = 13; AFTERNOON_HOURS = 5;
EVENING_START_HOUR = 18;   EVENING_HOURS = 4; 
NIGHT_START_HOUR = 22;     NIGHT_HOURS = 8;


% check season
begin = 0; numDays = 0;  numHours = 0;
if(strcmp(season, 'Summer') == 1)
    [numHours, numDays, begin] = calculateSeasonStats(timeOfDay, isLeap, ...
        SUMMER_BEGIN_DAY, SUMMER_DAYS, SUMMER_MORNING_HOURS,...
        SUMMER_AFTERNOON_HOURS, SUMMER_EVENING_HOURS, SUMMER_NIGHT_HOURS);
    
elseif(strcmp(season,'Spring/Fall') == 1)
    [numHours, numDays, begin] = calculateSeasonStats(timeOfDay, isLeap, ...
        SPRFALL_BEGIN_DAY, SPRFALL_DAYS, SPRFALL_MORNING_HOURS,...
        SPRFALL_AFTERNOON_HOURS, SPRFALL_EVENING_HOURS, SPRFALL_NIGHT_HOURS);
    
elseif(strcmp(season,'Winter') == 1)
    [numHours, numDays, begin] = calculateSeasonStats(timeOfDay, isLeap, ...
        WINTER_BEGIN_DAY, WINTER_DAYS, WINTER_MORNING_HOURS,...
        WINTER_AFTERNOON_HOURS, WINTER_EVENING_HOURS, WINTER_NIGHT_HOURS);
    if(isLeap == 1)
        numDays = numDays + 1;
    end
end

% check time of day
timeBegin = 0; timeRange = 0; timeToNext = 0;
if(strcmp(timeOfDay,'Morning'))
    timeBegin = MORNING_START_HOUR;
    timeRange = MORNING_HOURS;
    timeToNext = 17*numPeriods + 1;
elseif(strcmp(timeOfDay,'Afternoon'))
    timeBegin = AFTERNOON_START_HOUR;
    timeRange = AFTERNOON_HOURS;
    timeToNext = 19*numPeriods + 1;
elseif(strcmp(timeOfDay,'Evening'))
    timeBegin = EVENING_START_HOUR;
    timeRange = EVENING_HOURS;
    timeToNext = 20*numPeriods + 1;
elseif(strcmp(timeOfDay,'Night'))
    timeBegin = NIGHT_START_HOUR;
    timeRange = NIGHT_HOURS;
    timeToNext = 16*numPeriods + 1;
end




% perform calculations
orig = data_orig'; sim = data_simul';
start_index = (begin*24*numPeriods)+(numPeriods*timeBegin);
end_index = start_index + numPeriods*timeRange - 1;
numerator_orig = []; numerator_simu = [];
if(strcmp(season,'Summer'))
    for i = 1:numDays
        numerator_orig = [numerator_orig  orig(1,start_index:end_index)];
        numerator_simu = [numerator_simu  sim(1,start_index:end_index)];
        start_index = end_index + timeToNext;      
        end_index = start_index + numPeriods*timeRange - 1;
    end

elseif(strcmp(season,'Spring/Fall'))
    for i = 1:30
        numerator_orig = [numerator_orig  orig(1,start_index:end_index)];
        numerator_simu = [numerator_simu  sim(1,start_index:end_index)];
        start_index = end_index + timeToNext;      
        end_index = start_index + numPeriods*timeRange - 1;
    end
    start_index = (212*24*numPeriods) + numPeriods*timeBegin;
    end_index = start_index + numPeriods*timeRange - 1;
    for i = 1:31
        numerator_orig = [numerator_orig  orig(1,start_index:end_index)];
        numerator_simu = [numerator_simu  sim(1,start_index:end_index)];
        start_index = end_index + timeToNext;      
        end_index = start_index + numPeriods*timeRange - 1;
    end

elseif(strcmp(season,'Winter'))
    for i = 1:61
        if(i ~= 61)
            numerator_orig = [numerator_orig orig(1,start_index:end_index)];
        else %end of file
            numerator_orig = [numerator_orig orig(1,start_index:end)];
        end
        numerator_simu = [numerator_simu sim(1,start_index:end_index)];
        start_index = end_index + timeToNext;      
        end_index = start_index + numPeriods*timeRange - 1;
    end
    start_index = numPeriods*timeBegin;
    end_index = start_index + numPeriods*timeRange - 1;
    for i = 1:90
        numerator_orig = [numerator_orig orig(1,start_index:end_index)];
        numerator_simu = [numerator_simu sim(1,start_index:end_index)];
        start_index = end_index + timeToNext;      
        end_index = start_index + numPeriods*timeRange - 1;
    end
end
orig_max = max(numerator_orig/max_data);
sim_max = max(numerator_simu/max_data);
orig_min = min(numerator_orig/max_data);
sim_min = min(numerator_simu/max_data);
orig_sum = sum(numerator_orig);
sim_sum = sum(numerator_simu);
orig_capfactor = orig_sum/(max_data*numHours*numPeriods);
sim_capfactor = sim_sum/(max_data*numHours*numPeriods);
end