function BIC = calculateBIC(P,temp,numStates,order,originalData)

num_row = numel(P(1:end,1));
num_col = numel(P(1,1:end));

LL = 0;
for i = 1:num_row
    for j = 1:num_col
        if(P(i,j) == 0 || isnan(P(i,j)))
            continue;
        else
            LL = LL + temp(i,j).*log(P(i,j));       % log likelihood
        end
    end
end
phi = (numStates.^order).*(numStates-1);           % no. of independent parameters 
BIC = -2.*LL + phi.*log(numel(originalData));

end