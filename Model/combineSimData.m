function combinedSimData = combineData(simDataArray, simulationLength, numPeriods)
   
MORNING_HOURS = 7;
AFTERNOON_HOURS = 5;
EVENING_HOURS = 4; 
NIGHT_HOURS = 8;

rangeArray = [MORNING_HOURS, AFTERNOON_HOURS, EVENING_HOURS, NIGHT_HOURS];

%Summer
summerMatrix = []; springFallMatrix = []; winterMatrix = [];
index = 1;
for i = 1:(numel(simDataArray)-1)
    if(index == 5 || index == 9), index = 1; end
    range = rangeArray(index)*numPeriods;
    
    if(i <= 4)
        matrix = reshape(simDataArray{i},range,[]);
        summerMatrix = [summerMatrix; matrix];
    elseif(i > 4 && i <= 8)
        matrix = reshape(simDataArray{i},range,[]);
        springFallMatrix = [springFallMatrix; matrix];
    elseif(i > 8)
        matrix = reshape(simDataArray{i},range,[]);
        winterMatrix = [winterMatrix; matrix];
    end
    
    index = index + 1;
end

combinedCellMatrix = cell([],simulationLength);

SUMMER_DAYS = 153;
mayJunJulAugSepMatrix = [];
startIndex = 1;
%divide summer into years
for j = 1:simulationLength
    mayJunJulAugSepMatrix = summerMatrix(:, startIndex:startIndex + SUMMER_DAYS - 1);
    combinedCellMatrix{j} = mayJunJulAugSepMatrix;
    startIndex = startIndex + SUMMER_DAYS;
end

%divide into april/october
APRIL_DAYS = 30;  OCTOBER_DAYS = 31;
aprilMatrix = []; octoberMatrix = [];
startIndex = 1;
for j = 1:simulationLength
    aprilMatrix = springFallMatrix(:, startIndex:startIndex + APRIL_DAYS - 1);
    combinedCellMatrix{j} = [aprilMatrix combinedCellMatrix{j}];
    startIndex = startIndex + APRIL_DAYS;
    
    octoberMatrix = springFallMatrix(:, startIndex:startIndex + OCTOBER_DAYS - 1);
    combinedCellMatrix{j} = [combinedCellMatrix{j} octoberMatrix];
    startIndex = startIndex + OCTOBER_DAYS;
end

%divide winter
WINTER_END_DAYS = 61;
WINTER_BEGINNING_DAYS = 90;
novDecMatrix = []; janFebMarMatrix = [];
startIndex = 1;
for j = 1:simulationLength
    novDecMatrix = winterMatrix(:, startIndex:startIndex + WINTER_END_DAYS - 1);
    combinedCellMatrix{j} = [combinedCellMatrix{j} novDecMatrix];
    startIndex = startIndex + WINTER_END_DAYS;
    
    janFebMarMatrix = winterMatrix(:, startIndex:startIndex + WINTER_BEGINNING_DAYS - 1);
    combinedCellMatrix{j} = [janFebMarMatrix combinedCellMatrix{j}];
    startIndex = startIndex + WINTER_BEGINNING_DAYS;
end

%combine into one vector
combinedSimData = [];
for i = 1:simulationLength
    combinedSimData = [combinedSimData;reshape(combinedCellMatrix{i},[],1)];
end




