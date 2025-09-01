class_name PlayerStateDiving
extends PlayerState

#俯冲持续半秒种
const DURATION_DIVE := 500
#老步骤，时间重置
var time_start_dive := Time.get_ticks_msec()

#每当进入这个新状态时，就要播放这个正确的动画（有点复杂两套动画需要确定方向）
func _enter_tree() -> void:
	#目标位置
	var target_dive := Vector2(player.spawn_position.x, ball.position.y)
	#方向目标
	var direction := player.position.direction_to(target_dive)
	#判断检查Y值
	if direction.y > 0:
		animation_player.play("dive_down")
	else:
		animation_player.play("dive_up")
	player.velocity = direction * player.speed
	#在来一遍重置时间
	time_start_dive = Time.get_ticks_msec()

func _process(_delta: float) -> void:
	#判断检查经过的时间
	if Time.get_ticks_msec() - time_start_dive > DURATION_DIVE:
		transition_state(Player.State.RECOVERING)
	
