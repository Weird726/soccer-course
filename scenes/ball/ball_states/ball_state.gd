#这样设置的好处是所有状态都能访问Ball
#并且所有状态的逻辑都能改变球的属性
class_name BallState
extends Node

#设置一个信号来转换状态
signal state_transition_requested(new_state: BallState)

#设置一个对Ball对象的引用
var ball : Ball = null
#类型为玩家的携带者参数
var carrier : Player = null
#创建一个变量,初始值为空
var player_detection_area : Area2D = null

#设置一个方法来设置这些状态,添加Area2d后所有的状态逻辑都能访问它
func setup(context_ball: Ball, context_player_detection_area : Area2D, context_carrier : Player) -> void:
	#设置Ball对象
	ball = context_ball
	#设置赋值检测区域
	player_detection_area = context_player_detection_area
	#传递后赋值
	carrier = context_carrier
