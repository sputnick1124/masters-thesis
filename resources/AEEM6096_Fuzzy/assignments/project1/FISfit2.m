function [P] = FISfit2(fis)
A = [-10.8760   -9.3712   -6.0971   -0.2734   -0.1388
    1.0000         0         0         0         0
         0    1.0000         0         0         0
         0         0    1.0000         0         0
         0         0         0    1.0000         0];
B = [1;0;0;0;0];
C = [0, 0, 14.5750, 5.8846, 0.4432];
t0 = 0; t_f = 10;
dt = 0.001;
t = t0:dt:t_f;
p = zeros(length(t),1);
x = zeros(length(t),5);
ep0 = 0;
ei = 0;
for t_cur = 2:length(t);
    ep = (1 - p(t_cur-1));
    if t_cur > 2
        ed = (ep - ep0)/dt;
    else
        ed = 0;
    end
    ei = ei + ep*dt;
    gains = evalfis(min(abs([ep,ed,ei]),[19.9,19.9,19.9]),fis);
    KP = gains(1);
    KI = gains(2);
    KD = gains(3);
    u = KP*ep + KI*ei + KD*ed;
    x(t_cur,:) = (x(t_cur-1,:)' + A*x(t_cur-1,:)'*dt + B*u)';
    p(t_cur) = C*x(t_cur,:)'*dt;
    ep0 = ep;
end
R = stepinfo(p,t);
P = 2*R.SettlingTime + 0.05*R.Overshoot + 4*R.RiseTime;
% P = R.SettlingTime;

if isnan(P)
    P = Inf;
end

end