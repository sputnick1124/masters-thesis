function [t,x] = state_space2(t,x,A,B,C,PID)

kp = PID(1);
ki = PID(2);
kd = PID(3);

p = C*x(1:5)';
ep = (1 - p);
ed = 

dxdt = zeros(8,1);
