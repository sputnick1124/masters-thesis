function fis = fisReconstruct(fis,params)

[Pin,Pout] = fisBreakdown(fis);

for in = 1:length(Pin)
    for inMF = 1:length(Pin{in})
        newPin{in}{inMF} = params(1:length(Pin{in}{inMF}));
        params = params(length(Pin{in}{inMF})+1:end);
    end
end

for out = 1:length(Pout)
    for outMF = 1:length(Pout{out})
        newPout{out}{outMF} = params(1:length(Pout{out}{outMF}));
        params = params(length(Pout{out}{outMF})+1:end);
    end
end

fis = fisBuild(fis,newPin,newPout);

end