function [cap_factors,simDataArray] = calculateCapFactors(dataForCapFactors,...
    simDataArray,maxData,numHoursArray,numPeriods,originalLength,simulationLength,...
    Seasons,TimeOfDays,sampleSelected)
    
    if(sampleSelected ~= 1)
        [numHoursArray,simDataArray,~,~] = divideData(Seasons,TimeOfDays,numPeriods,...
                simDataArray{13},simulationLength,1);
    end

    cap_factors = zeros(6,12);
    index = 1;
    for i = 1:2:5
        for j = 1:3:10
            orig_max = max(dataForCapFactors{index}/maxData);
            sim_max  = max(simDataArray{index}/maxData);
            orig_min = min(dataForCapFactors{index}/maxData);
            sim_min  = min(simDataArray{index}/maxData);
            orig_sum = sum(dataForCapFactors{index});
            sim_sum  = sum(simDataArray{index});
            orig_capfactor = orig_sum/(maxData*numHoursArray(index)*numPeriods*originalLength);
            sim_capfactor  = sim_sum/(maxData*numHoursArray(index)*numPeriods*simulationLength);

            cap_factors(i,j) = orig_capfactor;
            cap_factors(i,j+1) = orig_min;
            cap_factors(i,j+2) = orig_max;
            cap_factors(i+1,j) = sim_capfactor;
            cap_factors(i+1,j+1) = sim_min;
            cap_factors(i+1,j+2) = sim_max;

            index = index + 1;
        end
    end


end