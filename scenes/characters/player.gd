class_name Player
extends CharacterBody2D

#接收一个参数的信号
signal swap_requested(player: Player)

#创建一个常量
const BALL_CONTROL_HEIGHT_MAX := 10.0
#创建一个字典，各种模式方案
const CONTROL_SCHEME_MAP : Dictionary = {
	ControlScheme.CPU: preload("res://assets/art/props/cpu.png"),
	ControlScheme.P1: preload("res://assets/art/props/1p.png"),
	ControlScheme.P2: preload("res://assets/art/props/2p.png"),
}

#添加一个常量，只列出国家名单,它将是一个数组类型
const COUNTRIES := ["DEFAULT", "FRANCE", "ARGENTINA", "BRAZIL", "ENGLAND", "GERMANY", "ITALY", "SPAIN", "USA"]
#重力常量
const GRAVITY := 8.0
#设置一个步行记忆阈值常量
const WALK_ANIN_THRESHOLD := 0.6

#创建一个新的枚举类型
enum ControlScheme {CPU, P1, P2}
#为球队所创建的枚举，球员的职位
enum Role {GOALIE, DEFENSE, MIDFIELD, OFFENSE}
#为肤色创建一个枚举,浅色，中等，深色
enum SkinColor {LIGHT, MEDIUM, DARK}
#为所有不同的状态添加一个枚举
enum State {MOVING, TACKLING, RECOVERING, PREPPING_SHOT, SHOOTING, PASSING, HEADER, VOLLEY_KICK, BLCYCLE_KICK, CHEST_CONTROL, HURT, DIVING, CELEBRATING, MOURNING}
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
@onready var goalie_hands_collider: CollisionShape2D = %GoalieHandsCollider
@onready var opponent_detection_area: Area2D = %OpponentDetectionArea
@onready var permanent_damage_emitter_area: Area2D = %PermanentDamageEmitterArea
@onready var player_sprite: Sprite2D = %PlayerSprite
@onready var tackle_damage_emitter_area: Area2D = %TackleDamageEmitterArea
@onready var teammate_detection_area: Area2D = %TeammateDetectionArea

#存储AI数据的变量,从AI工厂获取
var ai_behavior_factory := AIBehaviorFactory.new()
#国家变量
var country := ""
#当前的AI行为变量
var current_ai_behavior : AIBehavior = null
#跟踪当前状态的节点
var current_state: PlayerState = null
#名字变量
var fullname := ""
#私有变量存储玩家面向的方向
var heading := Vector2.RIGHT
#添加一个高度变量
var height := 0.0
#添加一个高度向量变量
var height_velocity := 0.0
#添加一个角色变量
var role := Player.Role.MIDFIELD
#皮肤颜色
var skin_color := Player.SkinColor.MEDIUM
#存储位置的变量
var spawn_position := Vector2.ZERO
#引用玩家工厂状态,实例化一次就行
var state_factory := PlayerStateFactory.new()
#存储不同权重的变量
var weight_on_duty_steering := 0.0


#准备函数
func _ready() -> void:
	#调用设置图片方法
	set_control_texture()
	#AI行为方法
	setup_ai_behavior()
	#将状态且黄岛.moving
	switch_state(State.MOVING)
	#一个所有子节点都可以用的函数
	set_shader_properties()
	#专为守门员的信号发射
	permanent_damage_emitter_area.monitoring = role == Role.GOALIE
	#当角色不是守门员，将禁用此状态
	goalie_hands_collider.disabled = role != Role.GOALIE
	tackle_damage_emitter_area.body_entered.connect(on_tackle_player.bind())
	permanent_damage_emitter_area.body_entered.connect(on_tackle_player.bind())
	#初始化存储位置为当前位置
	spawn_position = position
	#监听信号调用回调
	GameEvents.team_scored.connect(on_team_scored.bind())

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

#创建一个所有子节点都可以用的函数
func set_shader_properties() -> void:
	#调用玩家精灵并且影响材质,此处还要一个设置着色器的方法 国家
	player_sprite.material.set_shader_parameter("skin_color", skin_color)
	#选择国家的颜色,实际调用查找方法(如果期间数据出现错误将返回-1)
	var country_color := COUNTRIES.find(country)
	#国家的颜色生成限制在一个数之间
	country_color = clampi(country_color, 0, COUNTRIES.size() - 1)
	#调用玩家精灵并且影响材质,此处还要一个设置着色器的方法 队伍
	player_sprite.material.set_shader_parameter("team_color", country_color)
	
#初始化方法,传入位置,球，球门.目标球门，数据,带有上下文的玩家资源
func initialize(context_position: Vector2, context_ball: Ball, context_own_goal: Goal, context_target_goal: Goal,context_player_data: PlayerResource, context_country: String) -> void:
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
		#国家名称参数
		country = context_country

#设置状态机
func setup_ai_behavior() -> void:
	#从工厂调用正确的参数，正确实例化
	current_ai_behavior = ai_behavior_factory.get_ai_behavior(role)
	current_ai_behavior.setup(self, ball, opponent_detection_area, teammate_detection_area)
	#取个名字
	current_ai_behavior.name = "AI Behavior"
	#添加子对象
	add_child(current_ai_behavior)


#切换状态的方法(默认情况下让DATA处于一个空实例）
func switch_state(state: State, state_data: PlayerStateData = PlayerStateData.new()) -> void:
	#首先判断现有状态是否需要要进行销毁（存在即销毁）
	if current_state != null:
		#执行从树中移除的操作
		current_state.queue_free()
	#创建一个新状态，从状态工厂获取它并传入状态
	current_state = state_factory.get_fresh_state(state)
	#进行设置两个参数“玩家”与“动画机状态”(主对象)
	current_state.setup(self, state_data, animation_player, ball, teammate_detection_area, ball_detection_area, own_goal, target_goal,tackle_damage_emitter_area, current_ai_behavior)
	#添加节点前先连接到信号，要绑定状态方法
	current_state.state_transition_requested.connect(switch_state.bind())
	#给节点起个特殊的名称，称之为玩家状态机,以字符串形式添加名称
	current_state.name = "PlayerStateMachine: " + str(state)
	#将该节点添加为子对象
	call_deferred("add_child", current_state)
	
func set_movemont_animation() -> void:
	#创建一个速度变量
	var vel_length := velocity.length()
	#用速度来控制动画状态
	#判断长度是否小于1
	if vel_length < 1:
		animation_player.play("idel")
	elif vel_length < speed * WALK_ANIN_THRESHOLD:
		animation_player.play("walk")
	else:
		animation_player.play("run")

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
		tackle_damage_emitter_area.scale.x = 1
		opponent_detection_area.scale.x = 1
	elif heading == Vector2.LEFT:
		player_sprite.flip_h = true
		tackle_damage_emitter_area.scale.x = -1
		opponent_detection_area.scale.x = -1

#翻转精灵方法.可见或者不可见
func set_sprite_visibility() -> void:
	control_sprite.visible = has_ball() or not control_scheme == ControlScheme.CPU

#抢断伤害方法
func get_hurt(hurt_origin: Vector2) -> void:
	#转换时传递正确信息
	switch_state(Player.State.HURT, PlayerStateData.build().set_hurt_direction(hurt_origin))

#设置一个检查当前是否持有球的方法
func has_ball() -> bool:
	#返回携带球的玩家是否是当前玩家
	return ball.carrier == self

#接收玩家请求传球参数
func get_pass_request(player: Player) -> void:
	#判断是否我们手里持有球
	if ball.carrier == self and current_state != null and current_state.can_pass():
		#切换到传球状态，同时传入相关信息
		switch_state(Player.State.PASSING, PlayerStateData.build().set_pass_target(player))

#用于设置正确的纹理方法
func set_control_texture() -> void:
	control_sprite.texture = CONTROL_SCHEME_MAP[control_scheme]

#此方法用判断是否面向目标
func is_facing_target_goal() -> bool:
	#其中使用的是归一化的向量
	var direction_to_target_goal := position.direction_to(target_goal.position)
	#返回一个大小为1的向量,同时确保角度小于90°，这才能保证余弦值才是正的
	return heading.dot(direction_to_target_goal) > 0

#判断球员持球
func can_carry_ball() -> bool:
	return current_state != null and  current_state.can_carry_ball()

#抢断方法
func on_tackle_player(player: Player) -> void:
	#判断玩家是否持球
	if player != self and player.country != country and player == ball.carrier:
		#抢断后的位置方向
		player.get_hurt(position.direction_to(player.position))

#创建一个回调方法
func on_animation_complete() -> void:
	#判断玩家数据是否为空
	if current_state != null:
		#如果不为空处理动画完成状态
		current_state.on_animation_complete()

func on_team_scored(team_scored_on: String) -> void:
	if country == team_scored_on:
		switch_state(Player.State.MOURNING)
	else:
		switch_state(Player.State.CELEBRATING)

func control_ball() -> void:
	if ball.height > BALL_CONTROL_HEIGHT_MAX:
		switch_state(Player.State.CHEST_CONTROL)
