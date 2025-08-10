#状态共有的东西将从这个类继承它,这是玩家的子节点
class_name PlayerState
extends Node

#过去式信号名称,传入下一个状态，新状态（玩家状态的枚举值）
signal state_transition_requested(new_state: Players.State)

#动画播放器的引用
var animation_player : AnimationPlayer = null
#保留一个对玩家的引用
var player : Players = null

#创建一个方法来设置这些状态节点,传入上下文玩家
#将动画播放器作为属性的一部分进行传递
func setup(context_player: Players,context_animation_player: AnimationPlayer) -> void:
	player = context_player
	#设置正确的值
	animation_player = context_animation_player
