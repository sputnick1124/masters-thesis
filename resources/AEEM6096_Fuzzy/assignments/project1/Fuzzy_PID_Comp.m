load('lookup_table.mat');

f4_nom_num = [3361,1357,102.2];
f4_nom_den = [230.6,2508,2161,1406,63.04,32.01];

f4_deg_num = [3361,1372,105];
f4_deg_den = [230.6,2472,1731,744.8,36.92,16];

f4_sub_num = [9.99e4,5.105e4,623.4];
f4_sub_den = [877.6,9884,1.82e4,7.114e4,-61.19,-114.1];

f4_sup_num = [1.3e5,2.183e4,-31.29];
f4_sup_den = [1742,1.83e4,3.553e4,2.677e5,1247,123.9];

nums = {f4_nom_num, f4_deg_num, f4_sub_num, f4_sup_num};
dens = {f4_nom_den, f4_deg_den, f4_sub_den, f4_sup_den};

scalar = 25;

for i = 1:4
    num = nums{i}; den = dens{i};
    options = simset('SrcWorkspace','current');
    sim('Stockton_Project1_model',[],options)
    
    t_f = Fuzzy_results.Time;
    thetaf = Fuzzy_results.Data;
    t_p = PID_results.Time;
    thetap = PID_results.Data;
    
    si_f = stepinfo(thetaf,t_f);
    si_p = stepinfo(thetap,t_p);
    figure(i);
    plot(t_f,thetaf,t_p,thetap);
    legend('Fuzzy PID', 'PID');
    xlabel('Time, s');
    ylabel('Theta, deg');
    
    ts_f = si_f.SettlingTime;
    tr_f = si_f.RiseTime;
    tp_f = si_f.PeakTime;
    p_f = si_f.Peak;
    xf_f = thetaf(end);
    os_f = si_f.Overshoot;
    
    ts_p = si_p.SettlingTime;
    tr_p = si_p.RiseTime;
    tp_p = si_p.PeakTime;
    p_p = si_p.Peak;
    xf_p = thetap(end);
    os_p = si_p.Overshoot;
    
    results_f(i,:) = [ts_f, tr_f, tp_f, p_f, xf_f, os_f];
    results_p(i,:) = [ts_p, tr_p, tp_p, p_p, xf_p, os_p];
end
    