%% Problem 2
clear; clc;
t5 = 369.6;
w = 0.075;
tau = t5/log(2)
z = 1/(tau*w)

%% Problem 4
clear; clc;
syms s
A = [0.00501 0.00464 -72.9 -31.34
    -0.0857 -0.545 309 -7.4
    0.00185 -0.00767 -0.395 0.00132
    0 0 1 0];
B = [5.63;-23.8;-4.51576;0];
C = eye(4);
D = zeros(4,1);
[a,b] = eig(A);
L = diag(b);
eta_sp = abs(real(L(1)))
w_sp = abs(imag(L(1)))
t5_sp = log(2)/abs(eta_sp)

eta_lp = abs(real(L(3)))
w_lp = abs(imag(L(3)))
t5_lp = log(2)/abs(eta_lp)

sys = ss(A,B,C,D)
sys = tf(sys)
a = 1057.36;
M = 0.3;
u0 = M*a;
%Phugoid
wn_lp = sqrt(eta_lp^2 + w_lp^2)
z_lp = eta_lp/wn_lp
tau_lp = 1/abs(wn_lp*z_lp)
T2_lp = log(2)/abs(eta_lp)
% Short Period
wn_sp = sqrt(eta_sp^2 + w_sp^2)
z_sp = eta_sp/wn_sp
tau_sp = 1/abs(wn_sp*z_sp)
T2_sp = log(2)/abs(eta_sp)

%% Problem 5
clear; clc;
% Phugoid
CE_lp = [1 0.033 0.02]
wn_lp = sqrt(CE_lp(3))
z_lp = CE_lp(2)/(2*wn_lp)
roots(CE_lp)
-z_lp*wn_lp
wn_lp*sqrt(1-z_lp^2)
% Short period
CE_sp = [1 0.902 2.666]
wn_sp = sqrt(CE_sp(3))
z_sp = CE_sp(2)/(2*wn_sp)
roots(CE_sp)
-z_sp*wn_sp
wn_sp*sqrt(1-z_sp^2)

num = -4.516*conv([1 -0.008],[1 0.506]);
den = conv(CE_lp,CE_sp);
OLTF = tf(num,den)
step(pi/180*OLTF)
stepinfo(pi/180*OLTF)

%% Problem 6
clear; clc;
Gp = tf([2.87],conv([1 0.33 0.02],[1 10]));
PO = 15;
Ts = 3.25;
Ts=0;
[KP,KI,KD] = MyPIDTune(Gp,@SysFit,PO,Ts,7)
