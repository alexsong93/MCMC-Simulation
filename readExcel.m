% filename = 'Minute Wind Data - 0';
% file = [];
% for i = 1:9
%     filename = strcat(filename,num2str(i),'-2011.xlsx');
%     file(end+1) = xlsread(filename,'O2:O44641');
% end

filename = 'Minute Wind Data - 01-2011.xlsx';
%file = xlsread('Minute Wind Data - 01-2011.xlsx','O2:O5');
%filename = [1 2;3 4];
csvwrite('file.dat',filename)
type file.dat
