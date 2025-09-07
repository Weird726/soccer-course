class_name PlayerStateCelebrating
extends PlayerState

#空气摩擦力
const AIR_FRICTION := 35.0
#初始速度常量(庆祝高度)
const CELEBRATING_HEIGHT := 2.0


func _enter_tree() -> void:
	celebrate()
	#监听队伍重置事件
	GameEvents.team_reset.connect(on_team_reset.bind())

func _process(delta: float) -> void:
	#每当他们落地时，让他们再次庆祝
	if player.height == 0:
		celebrate()
	player.velocity = player.velocity.move_toward(Vector2.ZERO, delta * AIR_FRICTION)

func celebrate() -> void:
	animation_player.play("celebrate")
	#上下跳跃表示庆祝行为
	player.height = 0.1
	#提供初始速度
	player.height_velocity = CELEBRATING_HEIGHT

func on_team_reset() -> void:
	transition_state(Player.State.RESETING, PlayerStateData.build().set_reset_position(player.spawn_position))
