class_name Camera
extends Camera2D

#设定一个距离目标常量
const DISTANCE_TARGET := 100.0
#震动持续时间常量
const DURATION_SHAKE := 120
#震动的强度值
const SHAKE_INTENSITY := 5
#持球时的平滑速度
const SMOOTHING_BALL_CARRIED := 2
#默认平滑速度
const SMOOTHING_BALL_DEFAULT := 8

#记录当前是否在震动状态的变量
var is_shaking := false
#记录时间的变量
var time_start_shake := Time.get_ticks_msec()

#导出的变量即硬引用
@export var ball : Ball

func _init() -> void:
	GameEvents.impact_received.connect(on_impact_received.bind())

#处理方法
func _process(_delta: float) -> void:
	#判断球是否有持球者
	if ball.carrier != null:
		#将自身定位到持球定位方向
		position = ball.carrier.position + ball.carrier.heading * DISTANCE_TARGET
		#当我们持球时，赋值持球的平滑度
		position_smoothing_speed = SMOOTHING_BALL_CARRIED
	else:
		#直接跳转直视球体
		position = ball.position
		#当我们持球时，赋值默认平滑度
		position_smoothing_speed = SMOOTHING_BALL_DEFAULT
	#检查当前时间与开始震动的时间的差值
	if is_shaking and Time.get_ticks_msec() - time_start_shake < DURATION_SHAKE:
		#符合条件时就设置随机偏移量
		offset = Vector2(randf_range(-SHAKE_INTENSITY, SHAKE_INTENSITY),randf_range(-SHAKE_INTENSITY, SHAKE_INTENSITY))
	else:
		#停止震动
		is_shaking = false
		#重置偏移量
		offset = Vector2.ZERO

#这次回调不关心回调位置
func on_impact_received(_impact_position: Vector2, is_high_impact: bool) -> void:
	#检查是否为高强度碰撞
	if is_high_impact:
		is_shaking =true
		time_start_shake = Time.get_ticks_msec()
