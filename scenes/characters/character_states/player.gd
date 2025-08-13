class_name Player
extends CharacterBody2D
#创建一个新的枚举类型
enum ControlScheme {CPU, P1, P2}
#为所有不同的状态添加一个枚举
enum State {MOVING, TACKLING, RECOVERING, PREPPING_SHOT, SHOOTING, PASSING}
#设置一个来自球的变量
@export var ball : Ball
#创建一个变量来存储这个枚举，让它成为一个可导出变量
@export var control_scheme : ControlScheme
#功率属性初始值变量
@export var power : float
@export var speed : float

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player_sprite: Sprite2D = %PlayerSprite
@onready var teammate_detection_area: Area2D = %TeammateDetectionArea

#跟踪当前状态的节点
var current_state: PlayerState = null
#引用玩家工厂状态,实例化一次就行
var state_factory := PlayerStateFactory.new()
#准备函数
func _ready() -> void:
	#将状态且黄岛.moving
	switch_state(State.MOVING)

#私有变量存储玩家面向的方向
var heading := Vector2.RIGHT

#函数后面下划线可以消除警告
func _process(_delta: float) -> void:
	#调用方向判断后改变动画H属性的方法
	flip_sprites()
	#调用CharacterBody2D的方法来实现移动，这个方法是move_and_slide()
	move_and_slide()

#切换状态的方法(默认情况下让DATA处于一个空实例）
func switch_state(state: State, state_data: PlayerStateData = PlayerStateData.new()) -> void:
	#首先判断现有状态是否需要要进行销毁（存在即销毁）
	if current_state != null:
		#执行从树中移除的操作
		current_state.queue_free()
	#创建一个新状态，从状态工厂获取它并传入状态
	current_state = state_factory.get_fresh_state(state)
	#进行设置两个参数“玩家”与“动画机状态”(主对象)
	current_state.setup(self, state_data, animation_player, ball, teammate_detection_area)
	#添加节点前先连接到信号，要绑定状态方法
	current_state.state_transition_requested.connect(switch_state.bind())
	#给节点起个特殊的名称，称之为玩家状态机,以字符串形式添加名称
	current_state.name = "PlayerStateMachine: " + str(state)
	#将该节点添加为子对象
	call_deferred("add_child", current_state)
	
func set_movemont_animation() -> void:
	#用速度来控制动画状态
	#如果速度大于0，播放跑步动画，如果速度小于0，播放闲置动画
	if velocity.length() > 0:
		animation_player.play("run")
	else:
		animation_player.play("idel")

#设置一个速度向量判断方向的方法
func set_heading() -> void:
	if velocity.x > 0:
		heading = Vector2.RIGHT
	elif velocity.x < 0:
		heading = Vector2.LEFT

#人物动画方向控制方法 通过判断来控制图片的H属性旋转
func flip_sprites() -> void:
	if heading == Vector2.RIGHT:
		player_sprite.flip_h = false
	elif heading == Vector2.LEFT:
		player_sprite.flip_h = true

#设置一个检查当前是否持有球的方法
func has_ball() -> bool:
	#返回携带球的玩家是否是当前玩家
	return ball.carrier == self

#创建一个回调方法
func on_animation_complete() -> void:
	#判断玩家数据是否为空
	if current_state != null:
		#如果不为空处理动画完成状态
		current_state.on_animation_complete()
