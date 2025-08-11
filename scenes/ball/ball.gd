class_name Ball
extends AnimatableBody2D

#为状态定义一个枚举 “携带状态”，“自由状态”，“发射状态”
enum State {CARRIED, FREEFORM, SHOT}

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var player_dectection_area: Area2D = %PlayerDectectionArea
#类型为玩家的携带者属性
var carrier : Player = null
#定义一个当前的状态，初始值为空
var current_state : BallState = null
#引用状态工厂
var state_factory := BallStateFactory.new()
#私有的速度变量
var velocity := Vector2.ZERO

#确保开始时进入正常的状态
func _ready() -> void:
	#将状态切换到自由状态
	switch_state(State.FREEFORM)

#创建一个方法用来切换状态
func switch_state(state: Ball.State) -> void:
	#判断初始当前状态是否为空
	if current_state != null:
		#如果为空就将其树中移除
		current_state.queue_free()
	#然后创建一个新的状态
	current_state = state_factory.get_fresh_state(state)
	#设置运行方法（尽在此处传递这个方法）
	current_state.setup(self, player_dectection_area, carrier, animation_player)
	#连接到状态转换请求,连接到刚创建的状态切换方法
	current_state.state_transition_requested.connect(switch_state.bind())
	#最后为其命名，方便进行调试 球状态机
	current_state.name = "BallStateMachine"
	#将其添加为子对象,将其调用为延迟调用添加
	call_deferred("add_child", current_state)
	
