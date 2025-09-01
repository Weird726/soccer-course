#工厂模式，负责创建并返回对象的类(节点状态机）
class_name PlayerStateFactory

#包含所有状态的字典
var states : Dictionary

#初始化字典，状态名，值就是各个类
func _init() -> void:
	states = {
		Player.State.BLCYCLE_KICK:PlayerStateBicycleKick,
		Player.State.CHEST_CONTROL:PlayerStateChestControl,
		Player.State.DIVING: PlayerStateDiving,
		Player.State.HURT:PlayerStateHurt,
		Player.State.MOVING:PlayerStateMoving,
		Player.State.PASSING:PlayerStatePassing,
		Player.State.PREPPING_SHOT:PlayerStatePreppingShot,
		Player.State.RECOVERING:PlayerStateRecovering,
		Player.State.SHOOTING:PlayerStateShooting,
		Player.State.TACKLING:PlayerStateTackling,
		Player.State.VOLLEY_KICK:PlayerStateVolleyKick,
		Player.State.HEADER:PlayerStateHeader,
	}

#获取新状态的方法，并返回一个玩家状态的实例
func get_fresh_state(state:Player.State) -> PlayerState:
	#如果不包含就抛出一个错误
	assert(states.has(state),"state doesn't exist!")
	#负责从字典中获取类
	return states.get(state).new()
