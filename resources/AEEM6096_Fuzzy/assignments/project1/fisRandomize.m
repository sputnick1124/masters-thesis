function fis = fisRandomize(fis,method,scale)

if nargin == 1
    method = 2;
end
if nargin == 2
    scale = 1;
end

[Pin,Pout,Rin,Rout] = fisBreakdown(fis);

numInputs = length(Pin);
numOutputs = length(Pout);
switch method
    case 1
        for in = 1:numInputs
            for inMF = 1:length(Pin{in})
                newPin{in}{inMF} = sort(rand(1,length(Pin{in}{inMF}))*diff(Rin(in,:)) + Rin(in,1));
            end
        end

        for out = 1:numOutputs
            for outMF = 1:length(Pout{out})
                newPout{out}{outMF} = sort(rand(1,length(Pout{out}{outMF}))*diff(Rout(out,:)) + Rout(out,1));
            end
        end
    case 2
        for in = 1:numInputs
            for inMF = 1:length(Pin{in})
                numPs = length(Pin{in}{inMF});
                params = Pin{in}{inMF};
                for inMFP = 1:numPs
                    if inMFP == 1
                        params(inMFP) = Rin(in,1) + diff([Rin(in,1) params(inMFP+1)])*rand/scale;
                    elseif inMFP == numPs
                        params(inMFP) = params(inMFP-1) + diff([params(inMFP-1) Rin(in,2)])*rand/scale;
                    else
                        params(inMFP) = params(inMFP-1) + diff(params([inMFP-1,inMFP+1]))*rand/scale;
                    end
                end
                newPin{in}{inMF} = params;
            end
        end

        for out = 1:numOutputs
            for outMF = 1:length(Pout{out})
                numPs = length(Pout{out}{outMF});
                params = Pout{out}{outMF};
                for outMFP = 1:numPs
                    if outMFP == 1
                        params(outMFP) = Rout(out,1) + diff([Rout(out,1) params(2)])*rand/scale;
                    elseif outMFP == numPs
                        params(outMFP) = params(outMFP-1) + diff([params(outMFP-1) Rout(out,2)])*rand/scale;
                    else
                        params(outMFP) = params(outMFP-1) + diff(params([outMFP-1,outMFP+1]))*rand/scale;
                    end
                end
                newPout{out}{outMF} = params;
            end
        end
    case 3
        for in = 1:numInputs
            for inMF = 1:length(Pin{in})
                numPs = length(Pin{in}{inMF});
                params = Pin{in}{inMF};
                for inMFP = 1:numPs
                    if inMFP == 1
                        params(inMFP) = Rin(in,1) + diff([Rin(in,1) params(inMFP+1)])*rand/scale;
                    elseif inMFP == numPs
                        params(inMFP) = params(inMFP-1) + diff([params(inMFP-1) Rin(in,2)])*rand/scale;
                    else
                        params(inMFP) = params(inMFP-1) + diff([params(inMFP-1) Rin(in,2)])*rand/scale;
                    end
                end
                newPin{in}{inMF} = params;
            end
        end

        for out = 1:numOutputs
            for outMF = 1:length(Pout{out})
                numPs = length(Pout{out}{outMF});
                params = Pout{out}{outMF};
                for outMFP = 1:numPs
                    if outMFP == 1
                        params(outMFP) = Rout(out,1) + diff([Rout(out,1) params(2)])*rand/scale;
                    elseif outMFP == numPs
                        params(outMFP) = params(outMFP-1) + diff([params(outMFP-1) Rout(out,2)])*rand/scale;
                    else
                        params(outMFP) = params(outMFP-1) + diff([params(outMFP-1) Rout(out,2)])*rand/scale;
                    end
                end
                newPout{out}{outMF} = params;
            end
        end
end

fis = fisBuild(fis,newPin,newPout);

end
        