% x = [1 6 1 6 4 4 4 3 1 2 2 3 4 5 4 5 2 6 2 6 2 6];  % the Markov chain
% tm = full(sparse(x(1:end-1),x(2:end),1))            % the transition matrix

%# sequence of states
x = [1 1 2 3];
N = max(x);

%# extract contiguous sequences of 2 items from the above
bigrams = cellstr(num2str( [x(1:end-2);x(2:end-1)]' ));

%# all possible combinations of two symbols
[X,Y] = ndgrid(1:N,1:N);
xy = cellstr(num2str([X(:),Y(:)]));

%# map bigrams to numbers starting from 1
[g,gn] = grp2idx([xy;bigrams]);
s1 = g(N*N+1:end);

%# items following the bigrams
s2 = x(3:end);

%# transition matrix
tm = full( sparse(s1,s2,1,N*N,N) );
spy(tm)