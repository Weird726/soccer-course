#工厂类不需要被继承，它只是一个简单对象
class_name BallStateFactory

#创建一个字典
var states : Dictionary

#它将包含不同状态需要实例化的类
func _init() -> void:
	states ={
		Ball.State.CARRIED: BallStateCarried,
		Ball.State.FREEFORM: BallStateFreeform,
		Ball.State.SHOT: BallStateShot,
	}

#初始状态方法
func get_fresh_state(state: Ball.State) -> BallState:
	#判断是否可以访问该状态，负责会提供错误信息
	assert(states.has(state),"state doesn't exist!")
	return states.get(state).new()
