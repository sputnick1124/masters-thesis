function [Pin,Pout,Rin,Rout] = fisBreakdown(fis)

numInputs = length(fis.input);
numOutputs = length(fis.output);


for in = 1:numInputs
    for inMF = 1:length(fis.input(in).mf)
        Pin{in}{inMF} = fis.input(in).mf(inMF).params;
    end
end

for out = 1:numOutputs
    for outMF = 1:length(fis.output(out).mf)
        Pout{out}{outMF} = fis.output(out).mf(outMF).params;
    end
end

if nargout > 2
    Rin = zeros(numInputs,2);
    Rout = zeros(numOutputs,2);
    for in = 1:numInputs
        Rin(in,1:2) = fis.input(in).range;
    end
    for out = 1:numOutputs
        Rout(out,1:2) = fis.output(out).range;
    end
end
end