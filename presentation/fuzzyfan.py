# coding: utf-8

import yapflm
from yapflm import FIS
from yapflm import yapflm
f = yapflm.FIS()
f
print(f)
f.addvar('temp')
help(f)
help(f.addvar)
f.addvar('input','temp')
f.addvar('output','speed')
f.input[0].addmf('cool',[0, 0, 55, 65])
f.input[0].addmf('cool',[0, 55, 65])
f.input[0].addmf('warm',[55, 65, 75])
f.input[0].addmf('hot',[65, 75, 150])
f.output[0].addmf('off',[0,0,0.25])
f.output[0].addmf('low',[0,0.25,1])
f.output[0].addmf('high',[0.25,1,1])
rule = [[0,0,1,0],[1,1,1,0],[2,2,1,0]]
f.addrule(rule)
inp = range(50,81)
outp = [f.evalfis(i) for i in inp]
from matplotlib import pyplot as plt
plt.plot(inp, outp)
plt.show()
plt.plot(inp, outp)
plt.xlabel('Temperature, deg F')
plt.ylabel('Fan Speed, \%')
plt.show()
