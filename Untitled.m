x = [1 4 2 6 4 8 4 6 465 3];
n = sin(x);
m = cos(x);

figure(1)
p = plot(m);
figure(2)
q = plot(m);
axes(handles.p);
xticklabel_rotate([],45,[]);
