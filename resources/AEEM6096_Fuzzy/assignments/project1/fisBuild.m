function fis = fisBuild(fis,Pin,Pout)

for in = 1:length(Pin)
    for inMF = 1:length(Pin{in})
        fis.input(in).mf(inMF).params = Pin{in}{inMF};
    end
end

for out = 1:length(Pout)
    for outMF = 1:length(Pout{out})
        fis.output(out).mf(outMF).params = Pout{out}{outMF};
    end
end

end