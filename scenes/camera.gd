class_name Camera
extends Camera2D

#设定一个距离目标常量
const DISTANCE_TARGET := 100.0
#持球时的平滑速度
const SMOOTHING_BALL_CARRIED := 2
#默认平滑速度
const SMOOTHING_BALL_DEFAULT := 8

#导出的变量即硬引用
@export var ball : Ball

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
