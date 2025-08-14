class_name Goal
extends Node2D

@onready var back_net_area: Area2D = %BackNetArea

#监听球何时进入该区域
func _ready() -> void:
	#添加一个监听器并创建一个函数（函数名的描述最好是非常清晰）用于监听
	back_net_area.body_entered.connect(on_ball_enter_back_net.bind())

#球进入网里时的函数
func on_ball_enter_back_net(ball: Ball) -> void:
	#进入网格范围让球停止
	ball.stop()
