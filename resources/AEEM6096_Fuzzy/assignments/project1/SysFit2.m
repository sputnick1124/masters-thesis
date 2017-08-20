function P = SysFit2(sys,PID)

[A,B,C,D] = tf2ss(sys.num{:},sys.den{:});
[t,x] = ode45(@state_space,0:0.01:50,[0,0,0,0,0,0,0,0],[],A,B,C,0.01,PID);
x = C*x(:,1:5)';
R = stepinfo(x,t);

P = R.SettlingTime + R.Overshoot + R.RiseTime;

if isnan(P)
    P = Inf;
end

end
