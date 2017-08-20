% clear all; close all; clc;

%Setup Plant Transfer Functions
num = [3361,1357,102.2];
den = [230.6,2508,2161,1406,63.04,32.01];
approach = tf(num,den);
approach50 = tf([3361,1372,105],[230.6,2472,1731,744.8,36.92,16]);
f4sub = tf([9.99e4,5.105e4,623.4],[877.6,9884,1.82e4,7.114e4,-61.19,-114.1]);
f4sup = tf([1.3e5,2.183e4,-31.29],[1742,1.83e4,3.553e4,2.677e5,1247,123.9]);

%Setup PID TF (taken from Bossert and Cohen, 2002)
Gc = tf([2.85,5.8,0.47],[0,1,0]);


OLTF = series(Gc,f4sup);
CLTF = feedback(OLTF,1);
step(CLTF)
%%
% step(CLTF)
[KP,KI,KD] = MyPIDTune(approach,@SysFit2,7);
%%
% f4num = [3361,1357,102.2];
% f4den = [230.6,2508,2161,1406,63.04,32.01];
supnum = [1.3e5,2.183e4,-31.29];
supden = [1742,1.83e4,3.553e4,2.677e5,1247,123.9];
% fis = readfis('bestfis2.fis');
% [A,B,C,D] = tf2ss(f4num,f4den);
[A,B,C,D] = tf2ss(supnum,supden);
t0 = 0; t_f = 10;
dt = 0.001;
t = t0:dt:t_f;
p = zeros(length(t),1);
x0 = [0,0,0,0,0]';
x = zeros(length(t),5);
e_ = zeros(length(t),3);
ep0 = 1;
ei = 0;
KP = 5.8;
KI = 0.47;
KD = 2.85;
tic
for t_cur = 2:length(t);
    ep = (1 - p(t_cur-1));
    if t_cur > 2
        ed = (ep - ep0)/dt;
    else
        ed = 0;
    end
    ei = ei + ep*dt;
%     gains = evalfis(abs([ep,ei,ed]),fis);
%     KP = gains(1);
%     KI = gains(2);
%     KD = gains(3);
    u = KP*ep + KI*ei + KD*ed;
    x(t_cur,:) = (x(t_cur-1,:)' + A*x(t_cur-1,:)'*dt + B*u)';
    p(t_cur) = C*x(t_cur,:)'*dt;
    ep0 = ep;
    e_(t_cur,:) = [ep,ei,ed];
end
toc
plot(t,p)

%%
fisproto = newfis('F4_control');

fisproto = addvar(fisproto,'input','theta_error',[-0.1,20]);
    fisproto = addmf(fisproto,'input',1,'Zero','trapmf',[-0.1,-0.1,0.0,5]);
    fisproto = addmf(fisproto,'input',1,'Small','trimf',[0.0,5,10]);
    fisproto = addmf(fisproto,'input',1,'Large','trapmf',[5,10,15,20]);
fisproto = addvar(fisproto,'input','theta_rate',[-0.1,20]);
    fisproto = addmf(fisproto,'input',2,'Zero','trapmf',[-0.1,-0.1,0.0,5]);
    fisproto = addmf(fisproto,'input',2,'Small','trimf',[0.0,5,10]);
    fisproto = addmf(fisproto,'input',2,'Large','trapmf',[5,10,15,20]);
fisproto = addvar(fisproto,'input','theta_acc',[-0.1,20]);
    fisproto = addmf(fisproto,'input',3,'Zero','trapmf',[-0.1,-0.1,0.0,5]);
    fisproto = addmf(fisproto,'input',3,'Small','trimf',[0.0,5,10]);
    fisproto = addmf(fisproto,'input',3,'Large','trapmf',[5,10,15,20]);
fisproto = addvar(fisproto,'output','KP',[0,15]);
    fisproto = addmf(fisproto,'output',1,'Small','trimf',[0.0,3.0,6.0]);
    fisproto = addmf(fisproto,'output',1,'Medium','trimf',[3.0,6.0,10.0]);
    fisproto = addmf(fisproto,'output',1,'Large','trimf',[6.0,10.0,15.0]);
fisproto = addvar(fisproto,'output','KI',[0,2]);
    fisproto = addmf(fisproto,'output',2,'Small','trimf',[0.0,0.5,1.0]);
    fisproto = addmf(fisproto,'output',2,'Medium','trimf',[0.5,1.0,1.5]);
    fisproto = addmf(fisproto,'output',2,'Large','trimf',[1.0,1.5,2.0]);
fisproto = addvar(fisproto,'output','KD',[0,6]);
    fisproto = addmf(fisproto,'output',3,'Small','trimf',[0.0,1.5,3.0]);
    fisproto = addmf(fisproto,'output',3,'Medium','trimf',[1.5,3.0,4.5]);
    fisproto = addmf(fisproto,'output',3,'Large','trimf',[3.0,4.5,6.0]);
rules = [
% |theta_error|theta_rate|theta_acc|KP|KI|KD|weight|connection|
        1           0         0      1  0  0   1          1
        2           0         0      2  0  0   1          1
        3           0         0      3  0  0   1          1
        0           1         0      0  0  1   1          1
        0           2         0      0  0  2   1          1
        0           3         0      0  0  3   1          1
        0           0         1      0  1  0   1          1
        0           0         2      0  2  0   1          1
        0           0         3      0  3  0   1          1];
fisproto = addrule(fisproto,rules);

[bestfis,fithist,inds,pop] = MyFISTuner(fisproto,@FISfit2,50,true);
%% Robustness Testing
clear all; clc; close all;
fis = readfis('bestfis2');

% Nominal plant
f4num = [3361,1357,102.2];
f4den = [230.6,2508,2161,1406,63.04,32.01];

% Deg 50%
f450num = [3361,1372,105];
f450den = [230.6,2472,1731,744.8,36.92,16];

% Subsonic
subnum = [9.99e4,5.105e4,623.4];
subden = [877.6,9884,1.82e4,7.114e4,-61.19,-114.1];

% Supersonic 
supnum = [1.3e5,2.183e4,-31.29];
supden = [1742,1.83e4,3.553e4,2.677e5,1247,123.9];

nums = {f4num,f450num,subnum,supnum};
dens = {f4den,f450den,subden,supden};

colors = {'r','b','g','m'};

for i = 1:4
    
    [tpid,xpid,tspid,trpid,tppid,mppid,fvpid] = run_sim([],nums{i},dens{i});
    [t,x,ts,tr,tp,mp,fv] = run_sim(fis,nums{i},dens{i});
    figure(i)
    plot(t,x,strcat(colors{i},'-'),tpid,xpid,strcat(colors{i},'--'))
    legend('Fuzzy PID', 'PID');
    f_results(i,:) = [ts,tr,tp,mp,fv];
end


