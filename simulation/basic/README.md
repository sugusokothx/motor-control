# ipmsim

`ipmsim` is a pared-down simulator for interior permanent-magnet synchronous machines
(IPMSM). It extracts the synchronous machine drive pieces from the motulator project and
keeps the original continuous-time plant + discrete-time control architecture so that
paper-based prototypes (e.g., MRAS estimators) can be validated alongside MATLAB/Simulink
models.

## What is included

- Runge–Kutta based simulation loop (`ipmsim.common.model.Simulation`)
- Ideal three-phase voltage-source converter, single-inertia mechanics, and PMSM model
  with separate `L_d`, `L_q`, `ψ_f` parameters
- Current-vector control stack with sensored flux observer and MTPA/MTPV reference
  generator (same equations as the 2014 Flah et al. paper)
- Dataclasses for synchronous machine parameters and control loci utilities

## Notable omissions vs. motulator

- All induction-machine, grid-converter, signal injection, and flux-vector control files
  are removed
- Example scripts focus on synchronous IPM drives only
- Logging API is the same as motulator so existing plotting utilities can be reused if
  needed

## Quick start

```python
from ipmsim.common.model import Simulation
from ipmsim.drive import model, control, utils

par = utils.SynchronousMachinePars(n_p=3, R_s=3.6, L_d=0.036, L_q=0.051, psi_f=0.545)
machine = model.SynchronousMachine(par)
mechanics = model.MechanicalSystem(J=0.015)
converter = model.VoltageSourceConverter(u_dc=540)
plant = model.Drive(machine, mechanics, converter)

cfg = control.sm.CurrentVectorControllerCfg(i_s_max=10.0)
vector_ctrl = control.sm.CurrentVectorController(par, cfg, sensorless=False)
speed_ctrl = control.sm.SpeedController(J=0.015, alpha_s=2 * 3.1416 * 4)
ctrl = control.sm.VectorControlSystem(vector_ctrl, speed_ctrl)

ctrl.set_speed_ref(lambda t: (t > 0.2) * 157.0)
plant.mechanics.set_external_load_torque(lambda t: (t > 0.6) * 14.0)

sim = Simulation(plant, ctrl)
results = sim.simulate(t_stop=1.2)
```

The resulting `results.mdl` and `results.ctrl` objects share the same structure as in motulator.
