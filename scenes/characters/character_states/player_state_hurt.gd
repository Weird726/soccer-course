class_name PlayerStateHurt
extends PlayerState

const AIR_FRICTION := 35.0
const BALL_TUMBLE_SPEED := 100.0
const DURATION_HURT := 1000
const HURT_HEIGHT_VELOCITY := 3.0

var time_start_hurt := Time.get_ticks_msec()

func _enter_tree() -> void:
	animation_player.play("hurt")
	time_start_hurt = Time.get_ticks_msec()
	player.height_velocity = HURT_HEIGHT_VELOCITY
	#判断是否持球
	if ball.carrier == player:
		#球的下跌速度
		ball.tumble(state_data.hurt_direction * BALL_TUMBLE_SPEED)

func _process(delta: float) -> void:
	#检查以流失的时间是否超过1秒
	if Time.get_ticks_msec() - time_start_hurt > DURATION_HURT:
		#如果超时，回复状态
		transition_state(Player.State.RECOVERING)
	#玩家的向量赋值
	player.velocity = player.velocity.move_toward(Vector2.ZERO, delta * AIR_FRICTION)
