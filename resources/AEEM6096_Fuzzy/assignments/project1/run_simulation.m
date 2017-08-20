function [t,p] = run_simulation(fn,timespan,x0,opts,A,B,C)

nTime = length(timespan);
dt = diff(timespan(1:2));
x_list    = zeros(nTime, length(x0));
x_list(1, :) = x0;
p = zeros(nTime,1);
p(1) = C*x_list(1,:)';
PID = [5.8,0.47,2.85];
ei = 0;
for iTime = 2:nTime
    kp = PID(1);
    ki = PID(2);
    kd = PID(3);
    ep = (1 - p(iTime-1));
    ei = (ei + ep*dt);
    if iTime > 2
        ed = ((1 - p(iTime-1)) - (1 - p(iTime-2)))/dt;
    else
        ed = 0;
    end
    
    u = kp*ep + ki*ei + kd*ed;
    [~, x_] = ode45(fn, timespan(iTime-1:iTime), x0, opts, A, B, C, u);
    x0       = x_(end, :);
    x_list(iTime, :) = x0;
    p(iTime) = C*x0';
end
t = timespan;