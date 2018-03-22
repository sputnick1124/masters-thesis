# -*- coding: utf-8 -*-
"""
Created on Tue Dec  6 04:53:42 2016

@author: nick
"""

import numpy as np
import skfuzzy as fuzz
from skfuzzy import control as ctrl

# New Antecedent/Consequent objects hold universe variables and membership
# functions
d = ctrl.Antecedent(np.arange(-1.5,1.5, 0.01), 'error')
dd = ctrl.Antecedent(np.arange(-1.5,1.5, 0.01), 'error_del')
v = ctrl.Consequent(np.arange(-1.5,1.5, 0.01), 'rate')

d['neg'] = fuzz.trimf(d.universe, [-1.5,-1,0])
d['sm_neg'] = fuzz.trimf(d.universe, [-1,-0.15, 0])
d['zero'] = fuzz.trimf(d.universe, [-0.5,0,0.5])
d['sm_pos'] = fuzz.trimf(d.universe, [0,0.15,1])
d['pos'] = fuzz.trimf(d.universe, [0,1,1.5])

dd['neg'] = fuzz.trimf(dd.universe, [-1.5,-1,0])
dd['sm_neg'] = fuzz.trimf(dd.universe, [-1,-0.15, 0])
dd['zero'] = fuzz.trimf(dd.universe, [-0.5,0,0.5])
dd['sm_pos'] = fuzz.trimf(dd.universe, [0,0.15,1])
dd['pos'] = fuzz.trimf(dd.universe, [0,1,1.5])

v['neg'] = fuzz.trimf(v.universe, [-1.5,-0.5,0])
v['sm_neg'] = fuzz.trimf(v.universe, [-1,-0.125, 0])
v['zero'] = fuzz.trimf(v.universe, [-0.5,0,0.5])
v['sm_pos'] = fuzz.trimf(v.universe, [0,0.125,1])
v['pos'] = fuzz.trimf(v.universe, [0,0.5,1.5])

rules = []
rules.append(ctrl.Rule(d['neg'] & dd['neg'],v['pos']))
rules.append(ctrl.Rule(d['sm_neg'] & dd['neg'],v['pos']))
rules.append(ctrl.Rule(d['zero']&dd['neg'],v['sm_pos']))
rules.append(ctrl.Rule(d['sm_pos']&dd['neg'],v['sm_pos']))
rules.append(ctrl.Rule(d['pos']&dd['neg'],v['zero']))

rules.append(ctrl.Rule(d['neg']&dd['sm_neg'],v['pos']))
rules.append(ctrl.Rule(d['sm_neg']&dd['sm_neg'],v['sm_pos']))
rules.append(ctrl.Rule(d['zero']&dd['sm_neg'],v['sm_pos']))
rules.append(ctrl.Rule(d['sm_pos']&dd['sm_neg'],v['zero']))
rules.append(ctrl.Rule(d['pos']&dd['sm_neg'],v['sm_neg']))

rules.append(ctrl.Rule(d['neg']&dd['zero'],v['sm_pos']))
rules.append(ctrl.Rule(d['sm_neg']&dd['zero'],v['sm_pos']))
rules.append(ctrl.Rule(d['zero']&dd['zero'],v['zero']))
rules.append(ctrl.Rule(d['sm_pos']&dd['zero'],v['sm_neg']))
rules.append(ctrl.Rule(d['pos']&dd['zero'],v['sm_neg']))

rules.append(ctrl.Rule(d['neg']&dd['sm_pos'],v['sm_pos']))
rules.append(ctrl.Rule(d['sm_neg']&dd['sm_pos'],v['zero']))
rules.append(ctrl.Rule(d['zero']&dd['sm_pos'],v['sm_neg']))
rules.append(ctrl.Rule(d['sm_pos']&dd['sm_pos'],v['sm_neg']))
rules.append(ctrl.Rule(d['pos']&dd['sm_pos'],v['neg']))

rules.append(ctrl.Rule(d['neg']&dd['pos'],v['zero']))
rules.append(ctrl.Rule(d['sm_neg']&dd['pos'],v['sm_neg']))
rules.append(ctrl.Rule(d['zero']&dd['pos'],v['sm_neg']))
rules.append(ctrl.Rule(d['sm_pos']&dd['pos'],v['neg']))
rules.append(ctrl.Rule(d['pos']&dd['pos'],v['neg']))

vel_ctrl = ctrl.ControlSystem(rules)
