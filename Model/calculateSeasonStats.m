function [numHours,numDays,begin]  = calculateSeasonStats(timeOfDay, ...
    startDate, numberOfDays, morningHours, afternoonHours, eveningHours, nightHours)
    begin = startDate;
    numDays = numberOfDays;
    if(strcmp(timeOfDay, 'Morning')), numHours = morningHours;
    elseif(strcmp(timeOfDay, 'Afternoon')), numHours = afternoonHours;
    elseif(strcmp(timeOfDay, 'Evening')), numHours = eveningHours;
    elseif(strcmp(timeOfDay, 'Night')), numHours = nightHours;
    end
end