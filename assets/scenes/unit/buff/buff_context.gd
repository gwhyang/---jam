extends RefCounted
class_name BuffContext

var unit: Unit
var buff_manager: BuffManager
var buff_runtime: BuffRuntime
var source: Node
var delta := 0.0

var hitbox: HitboxComponent
var blocked := false
var damage := 0.0
