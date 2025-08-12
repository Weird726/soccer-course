#状态共有的东西将从这个类继承它,这是玩家的子节点
class_name PlayerState
extends Node

#过去式信号名称,传入下一个状态，新状态（玩家状态的枚举值）
signal state_transition_requested(new_state: Player.State, state_data: PlayerStateData)

#动画播放器的引用
var animation_player : AnimationPlayer = null
#对球的引用
var ball : Ball = null
#保留一个对玩家的引用
var player : Player = null
#存放状态数据的变量(创建一个实例）
var state_data : PlayerStateData = PlayerStateData.new()

#创建一个方法来设置这些状态节点,传入上下文玩家
#将动画播放器作为属性的一部分进行传递
func setup(context_player: Player, context_data : PlayerStateData,context_animation_player: AnimationPlayer, context_ball: Ball) -> void:
	player = context_player
	#设置正确的值
	animation_player = context_animation_player
	#设置正确的值
	state_data = context_data
	#设置正确的值
	ball = context_ball

#创建一个过渡状态方法,并传递参数(.new（）是设置为新实例）
func transition_state(new_state: Player.State, data: PlayerStateData = PlayerStateData.new()) -> void:
	state_transition_requested.emit(new_state, state_data)
	
#创建一个回调方法
func on_animation_complete() -> void:
	pass
