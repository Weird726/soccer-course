class_name Ball
extends AnimatableBody2D

#为状态定义一个枚举 “携带状态”，“自由状态”，“发射状态”
enum State {CARRIED, FREEFORM, SHOT}

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var ball_sprite: Sprite2D = %BallSprite
@onready var player_dectection_area: Area2D = %PlayerDectectionArea
#类型为玩家的携带者属性
var carrier : Player = null
#定义一个当前的状态，初始值为空
var current_state : BallState = null
#创建一个高度属性
var height := 0.0
#新属性高度速度
var height_velocity := 0.0
#引用状态工厂
var state_factory := BallStateFactory.new()
#私有的速度变量
var velocity := Vector2.ZERO

#确保开始时进入正常的状态
func _ready() -> void:
	#将状态切换到自由状态
	switch_state(State.FREEFORM)

#查看在哪里访问球体精灵的方法
func _process(_sadelta: float) -> void:
	ball_sprite.position = Vector2.UP * height

#创建一个方法用来切换状态
func switch_state(state: Ball.State) -> void:
	#判断初始当前状态是否为空
	if current_state != null:
		#如果为空就将其树中移除
		current_state.queue_free()
	#然后创建一个新的状态
	current_state = state_factory.get_fresh_state(state)
	#设置运行方法（尽在此处传递这个方法）
	current_state.setup(self, player_dectection_area, carrier, animation_player, ball_sprite)
	#连接到状态转换请求,连接到刚创建的状态切换方法
	current_state.state_transition_requested.connect(switch_state.bind())
	#最后为其命名，方便进行调试 球状态机
	current_state.name = "BallStateMachine"
	#将其添加为子对象,将其调用为延迟调用添加
	call_deferred("add_child", current_state)

#射门方法（需要射门速度）
func shoot (shot_velocity : Vector2) -> void:
	#射门速度替换当前速度
	velocity = shot_velocity
	#每当进行射门动作时，应该表明球类携带者现已为空
	carrier = null
	#切换状态
	switch_state(Ball.State.SHOT)
	
