function P = SysFit(sys)

R = stepinfo(sys);
S = step(sys);
[~,locs] = findpeaks(abs(S));
numpeaks = sum(locs>0);
P = R.SettlingTime + R.Overshoot + R.RiseTime;

if isnan(P)
    P = Inf;
end

end
