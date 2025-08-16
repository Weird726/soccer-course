class_name Player
extends CharacterBody2D

#创建一个常量
const BALL_CONTROL_HEIGHT_MAX := 10.0
#创建一个字典，各种模式方案
const CONTROL_SCHEME_MAP : Dictionary = {
	ControlScheme.CPU: preload("res://assets/art/props/cpu.png"),
	ControlScheme.P1: preload("res://assets/art/props/1p.png"),
	ControlScheme.P2: preload("res://assets/art/props/2p.png"),
}
#重力常量
const GRAVITY := 8.0

#创建一个新的枚举类型
enum ControlScheme {CPU, P1, P2}
#为球队所创建的枚举，球员的职位
enum Role {GOALIE, DEFENSE, MIDFIELD, OFFENSE}
#为肤色创建一个枚举,浅色，中等，深色
enum SkinColor {LIGHT, MEDIUM, DARK}
#为所有不同的状态添加一个枚举
enum State {MOVING, TACKLING, RECOVERING, PREPPING_SHOT, SHOOTING, PASSING, VOLLEY_KICK, HEADER, BLCYCLE_KICK, CHEST_CONTROL}
#设置一个来自球的变量
@export var ball : Ball
#创建一个变量来存储这个枚举，让它成为一个可导出变量
@export var control_scheme : ControlScheme
@export var own_goal :Goal
#功率属性初始值变量
@export var power : float
@export var speed : float
@export var target_goal : Goal

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var ball_detection_area: Area2D = %BallDetectionArea
@onready var control_sprite: Sprite2D = %ControlSprite
@onready var player_sprite: Sprite2D = %PlayerSprite
@onready var teammate_detection_area: Area2D = %TeammateDetectionArea

#跟踪当前状态的节点
var current_state: PlayerState = null
#名字变量
var fullname := ""
#引用玩家工厂状态,实例化一次就行
var state_factory := PlayerStateFactory.new()
#添加一个高度变量
var height := 0.0
#添加一个角色变量
var role := Player.Role.MIDFIELD
#皮肤颜色
var skin_color := Player.SkinColor.MEDIUM
#添加一个高度向量变量
var height_velocity := 0.0
#准备函数
func _ready() -> void:
	#调用设置图片方法
	set_control_texture()
	#将状态且黄岛.moving
	switch_state(State.MOVING)

#私有变量存储玩家面向的方向
var heading := Vector2.RIGHT

#函数后面下划线可以消除警告
func _process(delta: float) -> void:
	#调用方向判断后改变动画H属性的方法
	flip_sprites()
	#设置精灵的可见性
	set_sprite_visibility()
	#处理重力
	process_gravity(delta)
	#调用CharacterBody2D的方法来实现移动，这个方法是move_and_slide()
	move_and_slide()

#初始化方法,传入位置,球，球门.目标球门，数据,带有上下文的玩家资源
func initialize(context_position: Vector2, context_ball: Ball, context_own_goal: Goal, context_target_goal: Goal,context_player_data: PlayerResource) -> void:
		#初始化我们属性的所有值
		position = context_position
		ball = context_ball
		own_goal = context_own_goal
		target_goal = context_target_goal
		speed = context_player_data.speed
		power = context_player_data.power
		role = context_player_data.role
		skin_color = context_player_data.skin_color
		fullname = context_player_data.full_name
		#根据目标球门位置与自身位置来决定X值的大小
		heading = Vector2.LEFT if target_goal.position.x < position.x else Vector2.RIGHT

#切换状态的方法(默认情况下让DATA处于一个空实例）
func switch_state(state: State, state_data: PlayerStateData = PlayerStateData.new()) -> void:
	#首先判断现有状态是否需要要进行销毁（存在即销毁）
	if current_state != null:
		#执行从树中移除的操作
		current_state.queue_free()
	#创建一个新状态，从状态工厂获取它并传入状态
	current_state = state_factory.get_fresh_state(state)
	#进行设置两个参数“玩家”与“动画机状态”(主对象)
	current_state.setup(self, state_data, animation_player, ball, teammate_detection_area, ball_detection_area, own_goal, target_goal)
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

#处理重力的方法
func process_gravity(delta: float) -> void:
	#判断高度是否为正数
	if height > 0:
		#让最后一帧独立了
		height_velocity -= GRAVITY * delta
		#影响高度
		height += height_velocity
		#确保不会穿过地面
		if height <= 0:
			#高度重新设为0
			height = 0
		#定位玩家时体现出高度
		player_sprite.position = Vector2.UP * height
		
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

#翻转精灵方法.可见或者不可见
func set_sprite_visibility() -> void:
	control_sprite.visible = has_ball() or not control_scheme == ControlScheme.CPU

#设置一个检查当前是否持有球的方法
func has_ball() -> bool:
	#返回携带球的玩家是否是当前玩家
	return ball.carrier == self

#用于设置正确的纹理方法
func set_control_texture() -> void:
	control_sprite.texture = CONTROL_SCHEME_MAP[control_scheme]

#创建一个回调方法
func on_animation_complete() -> void:
	#判断玩家数据是否为空
	if current_state != null:
		#如果不为空处理动画完成状态
		current_state.on_animation_complete()

func control_ball() -> void:
	if ball.height > BALL_CONTROL_HEIGHT_MAX:
		switch_state(Player.State.CHEST_CONTROL)
