extends Area2D


@export var are_radius:float = 3001920
@export var exist_time:float = 0.3

@onready var collision_shape_2d: CollisionShape2D = %CollisionShape2D
@onready var timer: Timer = $Timer

func _ready() -> void:
	var shape = collision_shape_2d.shape as CircleShape2D
	shape.radius = are_radius
	timer.wait_time = exist_time

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	draw_circle(Vector2.ZERO,are_radius,Color.WEB_GREEN)
	
	
