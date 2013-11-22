function [P,C,temp,mat,columnLength] = createTransitionMatrices(stateWidth,...
            dividedData,order,maxState,k,onePeriodRangeArray)
    
    if(max(dividedData{k}) < stateWidth*(maxState-1))
         difference = (maxState-1)*stateWidth - max(dividedData{k}) + 1;
         index = find(dividedData{k}==max(dividedData{k}));
         dividedData{k}(index) = dividedData{k}(index) + difference;
    end
    %convert data into states
    stateArray = ceil(dividedData{k}/stateWidth);
    %if converted value is 0, change to 1;
    stateArray(stateArray==0) = 1;
    
    
    % extract contiguous sequences of n items from the above
%     matrix = zeros(order,numel(stateArray(1:end-order)));
%     for i=1:order
%         matrix(i,1:end) = stateArray(i:end-(order-i+1));
%     end
%     ngrams = cellstr(num2str(matrix'));
    
    index = 0;
    matrixToAdd = zeros(order,onePeriodRangeArray(k));
    matrix = [];
    while index + 1 < numel(stateArray)
        for i=1:order
            index = index + 1;
            matrixToAdd(i,:) = stateArray(index:index + onePeriodRangeArray(k) - 1);
        end
    
        matrix = [matrix matrixToAdd];
        index = index + onePeriodRangeArray(k) - 1;
        matrixToAdd = zeros(order,onePeriodRangeArray(k));
    end
    matrix = matrix(:, 1:(end-order));
    ngrams = cellstr(num2str(matrix'));
    
    
    % create all possible combinations of the n items
    str1 = 'ndgrid(1:maxState';
    str2 = 'cellstr(num2str([out{1}(:)';
    for i = 1:order-1
        str1 = strcat(str1, ',1:maxState');
        str2 = strcat(str2, ',out{', num2str(i+1), '}(:)');
    end
    str1 = strcat(str1,')');
    str2 = strcat(str2,']))');
    out = {};
    for i = 1:order
        [out{1:order}] = eval(str1);
    end
    possibleCombinations = eval(str2);

    str = 'textscan(sprintf(''%s\n'',possibleCombinations{:}),''';
    for i = 1:order
        str = strcat(str,'%s');
    end
    str = strcat(str,''')');
    q = eval(str);
    mat = str2double([q{:}]);

    [g,~] = grp2idx([possibleCombinations;ngrams]);  % map ngrams to numbers starting from 1
    s1 = g(((maxState^order)+1):end);
    
    % items following the ngrams
    s2 = [];
    startIndex = order + 1;
    endIndex = onePeriodRangeArray(k) + order - 1;
    while true
        if(endIndex > numel(stateArray))
            break;
        end
        s2 = [s2 stateArray(startIndex:endIndex)];
        s2 = [s2 s2(end)];
        startIndex = endIndex + (order + 1);
        endIndex = endIndex + onePeriodRangeArray(k) + (order - 1);
    end
    s2 = s2(1:end-order);
    
%     s2 = stateArray((order+1):end);
    
    P = full(sparse(s1,s2,1,maxState^order,maxState));
    temp = P;  % trans matrix of frequencies (before dividing); used for BIC

    dim = size(P);
    columnLength = dim(1);
    rowLength = dim(2);

    s = zeros(1,columnLength);
    for iter = 1:columnLength
        s(iter) = sum(P(iter,:));
    end

    for i = 1:columnLength
        for j = 1:rowLength
            if(s(i) == 0)
                break;
            end
            P(i,j) = P(i,j)./s(i);    %trans matrix of probabilities
        end
    end
    %   figure(2)
    %   spy(P,5)                        % uncomment to see sparsity of transition matrix
    
    % cumulative transition matrix
    C = zeros(size(P));
    for i = 1:columnLength
        for j = 1:rowLength
            C(i,j) = sum(P(i,1:j));
        end
    end
end
