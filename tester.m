clc, clear
order = 2;
M = 3;

% vars = {'X','Y'};
% S = [];
% for i = 1:2
%     S.(vars{i}) = rand(10,1);
% end

C = {};
% for i = 1:2
%   C{i} = rand(10,1);
% end

%[C{1:2}] = ndgrid(1:M,1:M);


%[C{1:2}] = eval(str)
% str = 'ndgrid(1:M,1:M';
% for i = 2:order-1
%     str = strcat(str, ',1:M');
% end
% 
% str = strcat(str,')');
% 
% str1 = 'ndgrid(1:M,1:M';
% str2 = 'cellstr(num2str([out{1}(:),out{2}(:)';
% for i = 2:order-1
%     str1 = strcat(str1, ',1:M');
%     str2 = strcat(str2, ',out{', num2str(i+1), '}(:)');
% end
% str1 = strcat(str1,')');
% str2 = strcat(str2,']))');
% 
% out = {};
% for i = 1:order
%     [out{1:order}] = eval(str1);
% end
% 
% xy = eval(str2);
numstates = 5;
next_state = 3;

toAdd = 0;
for i = order:-1:1
    toAdd = toAdd + (numstates.^i).*(next_state-1)
end
