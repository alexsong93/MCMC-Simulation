%# some random vector (load your data here instead)
x = randn(1000,1);

%# discretization/quantization into 8 levels
edges = linspace(min(x),max(x),8+1);
[counts,bins] = histc(x, edges);

%# fix last level of histc output
last = numel(counts);
bins(bins==last) = last - 1;
counts(last-1) = counts(last-1) + counts(last);
counts(last) = [];

%# show histogram
bar(edges(1:end-1), counts, 'histc')

%# transition matrix
trans = full(sparse(bins(1:end-1), bins(2:end), 1));
trans = bsxfun(@rdivide, trans, sum(trans,2))