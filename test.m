clc;clear;
x=round(5*rand([1,1000])+1);
[si sj] = ndgrid(1:6);
s2 = [si(:) sj(:)]; % combinations for 2 contiguous states
tm2 = zeros([numel(si),6]); % initialize transition matrix
for i = 3:numel(x) % construct transition matrix
    tm2(strmatch(num2str(x(i-2:i-1)),num2str(s2)),x(i))=...
    tm2(strmatch(num2str(x(i-2:i-1)),num2str(s2)),x(i))+1
end