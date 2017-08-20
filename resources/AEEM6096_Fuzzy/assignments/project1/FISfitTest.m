function J = FISfitTest(fis)

i = 0:20;
j = 0:20;

[k] = evalfis([i',j'],fis);

J = abs(mean(k(:,1)) - 5.8) + abs(mean(k(:,2)) - 0.47) + abs(mean(k(:,3)) - 2.85);

end