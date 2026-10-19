extends Node2D

var lifetime = 0.5

@export var type = 0

func _ready() -> void:
	
	if type == 0:
		var tween = create_tween()
		tween.tween_property(get_child(0),"modulate:a", 1.0, 0.0)
		tween.tween_property(self, "position:y", position.y - 100, 1.0)

	if type == 1:
		rotation_degrees = randf_range(-60.0, 25.0)
		var tween = create_tween()
		tween.tween_property(get_child(0),"scale", Vector2(2.0, 2.0), 1.0) \
			.set_ease(Tween.EASE_IN)
	
	var reactionTimer = Timer.new()
	reactionTimer.set_one_shot(true)
	reactionTimer.timeout.connect(_on_timer_timeout)
	add_child(reactionTimer)
	reactionTimer.start(lifetime)

func _on_timer_timeout() -> void:
	Die.rpc()

@rpc("authority", "call_local")
func Die() -> void:
	self.queue_free()
