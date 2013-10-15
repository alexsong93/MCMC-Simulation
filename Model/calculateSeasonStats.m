function [numHours,numDays,begin]  = calculateSeasonStats(timeOfDay, isLeap, ...
    startDate, numberOfDays, morningHours, afternoonHours, eveningHours, nightHours)
    if(isLeap == 0), begin = startDate;
    elseif(isLeap == 1), begin = startDate + 1;
    end
    numDays = numberOfDays;
    if(strcmp(timeOfDay, 'Morning')), numHours = morningHours;
    elseif(strcmp(timeOfDay, 'Afternoon')), numHours = afternoonHours;
    elseif(strcmp(timeOfDay, 'Evening')), numHours = eveningHours;
    elseif(strcmp(timeOfDay, 'Night')), numHours = nightHours;
    end
end