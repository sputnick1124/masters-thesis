function [P,t,x] = FISfit(fis)


options = simset('SrcWorkspace','current');
sim('Stockton_Project1_model2',[],options);
t = results.Time;
x = results.Data;
% plot(t,x) 
R = stepinfo(x,t);
P = 2*R.SettlingTime + 0.05*R.Overshoot + 4*R.RiseTime;
% P = R.SettlingTime;

if isnan(P)
    P = Inf;
end

end