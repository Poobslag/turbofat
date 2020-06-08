extends KinematicBody
"""
Represents a surface which Spira should not be able to land on. An optional 'foothold_radius' allows Spira to land on
the surface with a precise jump.
"""

# A number which determines the how close Spira needs to land to the object's center in order to not slip. A negative
# number means Spira will always slip.
export (float) var foothold_radius := -1.0
