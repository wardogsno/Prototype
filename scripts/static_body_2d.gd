extends StaticBody2D

@onready var sprite := $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.play("default")
	pass # Replace with function body.
