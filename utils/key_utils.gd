#全局引用
extends Node

#用枚举命名每一个可能的动作
enum Action {LEFT, RIGHT, UP, DOWN, SHOOT, PASS}

#创建一个字典包含玩家1和玩家2的预设,动作映射的类型为字典
const ACTIONS_MAP : Dictionary = {
	#为玩家1进行按键预设处理
	Player.ControlScheme.P1: {
		Action.LEFT: "p1_left",
		Action.RIGHT: "p1_right",
		Action.UP: "p1_up",
		Action.DOWN: "p1_down",
		Action.SHOOT:"p1_shoot",
		Action.PASS: "p1_pass",
	},
	#为玩家2进行按键预设处理
	Player.ControlScheme.P2: {
		Action.LEFT: "p2_left",
		Action.RIGHT: "p2_right",
		Action.UP: "p2_up",
		Action.DOWN: "p2_down",
		Action.SHOOT:"p2_shoot",
		Action.PASS: "p2_pass",
	},
}

#创建一个方法，一个包含当前使用ContrilScheme方向的归一化向量
func get_input_vector(scheme: Player.ControlScheme) -> Vector2:
	#map变量指，要么是这个字典，要么是那个字典
	var map : Dictionary = ACTIONS_MAP[scheme]
	#直接从Godot自带的向量中返回四个键映射
	return Input.get_vector(map[Action.LEFT],map[Action.RIGHT],map[Action.UP],map[Action.DOWN])

#返回布尔值的函数，返回isActionPressed的状态 可以在括号内部创建变量名赋值
func is_action_pressed(scheme: Player.ControlScheme,action: Action) -> bool:
	return Input.is_action_just_pressed(ACTIONS_MAP[scheme][action])

#同样对isactionjustpressed也是一样的处理，返回映射
func is_action_just_pressed(scheme: Player.ControlScheme, action: Action) -> bool:
	return Input.is_action_just_pressed(ACTIONS_MAP[scheme][action])

#对isActionJustReleased做同样处理
func is_Action_Just_Released(scheme: Player.ControlScheme,action: Action) -> bool:
	return Input.is_action_just_released(ACTIONS_MAP[scheme][action])
