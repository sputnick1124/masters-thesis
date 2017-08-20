function [t,p,ts,tr,tp,mp,fv] = run_sim(fis,num,den)
[A,B,C,D] = tf2ss(num,den);
if ~isstruct(fis)
    KP = 5.8;
    KI = 0.47;
    KD = 2.85;
end
t0 = 0; t_f = 10;
dt = 0.01;
t = t0:dt:t_f;
p = zeros(length(t),1);
x = zeros(length(t),5);
ep0 = 0;
ei = 0;
for t_cur = 2:length(t);
    if t_cur*dt == t(t_cur)
        fprintf('%f',t(t_cur));
    end
    ep = (1 - p(t_cur-1));
    if t_cur > 2
        ed = (ep - ep0)/dt;
    else
        ed = 0;
    end
    ei = ei + ep*dt;
    if isstruct(fis)
        gains = evalfis(min(max(([ep,ed,ei] + 12.5) ./ 25,[0,0,0]),[1,1,1]),fis);
        KP = gains(1) * 20;
        KI = gains(2) * 5;
        KD = gains(3) * 10;
    end
    u = KP*ep + KI*ei + KD*ed;
    x(t_cur,:) = (x(t_cur-1,:)' + A*x(t_cur-1,:)'*dt + B*u)';
    p(t_cur) = C*x(t_cur,:)'*dt;
    ep0 = ep;
end
R = stepinfo(p,t);

ts = R.SettlingTime;
tr = R.RiseTime;
tp = R.PeakTime;
mp = R.Peak;
fv = p(end);

end