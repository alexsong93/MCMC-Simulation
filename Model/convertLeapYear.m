function originalData = convertLeapYear(isLeap,leapValue,originalData,numPeriods)

    %remove feb 29th if leap year
    yearLength = numPeriods*24*365;
    if(isLeap==1)
        switch leapValue
            case '1st year'
                originalData(numPeriods*24*(31+28):(numPeriods*24*(31+29)-1)) = [];
            case '2nd year'
                originalData(yearLength + numPeriods*24*(31+28):...
                    yearLength + (numPeriods*24*(31+29)-1)) = [];
            case '3rd year'
                originalData(yearLength*2 + numPeriods*24*(31+28):...
                    yearLength*2 + (numPeriods*24*(31+29)-1)) = [];
            case '4th year'
                originalData(yearLength*3 + numPeriods*24*(31+28):...
                    yearLength*3 + (numPeriods*24*(31+29)-1)) = [];
        end
    end

end