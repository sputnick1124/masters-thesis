function [dxdt] = state_space(t,x,A,B,C,u)

dxdt = A*x + B*u;
% fprintf('%0.2f\n',t);
end