"""Controls for synchronous machine drives (current-vector focus)."""

from ipmsim.drive.control._base import PIController, SpeedController, VectorControlSystem
from ipmsim.drive.control._sm_current_vector import (
    CurrentController,
    CurrentVectorController,
    CurrentVectorControllerCfg,
)
from ipmsim.drive.control._sm_observers import FluxObserver, ObserverOutputs
from ipmsim.drive.control._sm_reference_gen import ReferenceGenerator
from ipmsim.drive.utils._parameters import (
    SaturatedSynchronousMachinePars,
    SynchronousMachinePars,
)

__all__ = [
    "PIController",
    "CurrentVectorControllerCfg",
    "VectorControlSystem",
    "FluxObserver",
    "CurrentController",
    "CurrentVectorController",
    "ObserverOutputs",
    "ReferenceGenerator",
    "SaturatedSynchronousMachinePars",
    "SpeedController",
    "SynchronousMachinePars",
]
