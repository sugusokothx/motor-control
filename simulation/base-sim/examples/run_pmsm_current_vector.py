"""Minimal IPMSM current-vector control example using ipmsim."""

from math import pi

from ipmsim.common.model import Simulation
from ipmsim.common.utils import BaseValues, NominalValues
from ipmsim.drive import control, model, utils


def main() -> None:
    # Nominal data for scaling (optional)
    nom = NominalValues(U=370, I=4.3, f=75, P=2.2e3, tau=14)
    base = BaseValues.from_nominal(nom, n_p=3)

    # Plant configuration (same numbers as the motulator 2.2 kW PMSM example)
    par = utils.SynchronousMachinePars(
        n_p=3,
        R_s=3.6,
        L_d=0.036,
        L_q=0.051,
        psi_f=0.545,
    )
    plant = model.Drive(
        machine=model.SynchronousMachine(par),
        mechanics=model.MechanicalSystem(J=0.015),
        converter=model.VoltageSourceConverter(u_dc=540),
    )

    # Controller configuration (sensored current-vector control)
    ctrl_cfg = control.sm.CurrentVectorControllerCfg(
        i_s_max=1.5 * base.i,
        k_f=lambda w_m: max(0.05 * (abs(w_m) - 0.2 * base.w), 0.0),
    )
    vector_ctrl = control.sm.CurrentVectorController(par, ctrl_cfg, sensorless=False)
    speed_ctrl = control.sm.SpeedController(J=0.015, alpha_s=2 * pi * 4)
    ctrl = control.sm.VectorControlSystem(vector_ctrl, speed_ctrl)

    ctrl.set_speed_ref(lambda t: (t > 0.2) * base.w_M)
    plant.mechanics.set_external_load_torque(lambda t: (t > 0.6) * nom.tau)

    sim = Simulation(plant, ctrl)
    res = sim.simulate(t_stop=1.2)

    # Example outputs (per-unit currents)
    i_s_pu = abs(res.mdl.machine.i_s_dq) / base.i
    print(f"Final stator current magnitude (p.u.): {i_s_pu[-1]:.3f}")
    print(f"Final speed (mechanical rad/s): {res.mdl.mechanics.w_M[-1]:.2f}")


if __name__ == "__main__":
    main()
