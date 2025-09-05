class_name PlayerStateMourning
extends PlayerState

func _enter_tree() -> void:
	animation_player.play("mourn")
	#突然停止表现悲剧效果
	player.velocity = Vector2.ZERO
