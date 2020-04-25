extends KinematicBody
"""
Represents a surface which Turbo should not be able to land on. An optional 'foothold_radius' allows Turbo to land on
the surface with a precise jump.
"""

# A number which determines the how close Turbo needs to land to the object's center in order to not slip. A negative
# number means Turbo will always slip.
export (float) var foothold_radius := -1.0
