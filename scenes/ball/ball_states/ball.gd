class_name Ball
extends AnimatableBody2D

#常量，弹跳因子
const BOUNCINESS := 0.8
#距离高度阈值
const DISTANCE_HIGH_PASS := 130
#时间常量
const DURATION_TUMBLE_LOCK := 200
const DURATION_PASS_LOCK := 500
const KICKOFF_PASS_DISTANCE := 30.0
#下跌高度速度
const TUMBLE_HEIGHT_VELOCITY := 3.0

#为状态定义一个枚举 “携带状态”，“自由状态”，“发射状态”
enum State {CARRIED, FREEFORM, SHOT}

#定义一个摩擦力中的空气为浮点数
@export var friction_air : float
#定义一个地面摩擦力为浮点数
@export var friction_ground : float

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var ball_sprite: Sprite2D = %BallSprite
@onready var player_dectection_area: Area2D = %PlayerDectectionArea
@onready var scoring_raycast: RayCast2D = %ScoringRaycast

#类型为玩家的携带者属性
var carrier : Player = null
#定义一个当前的状态，初始值为空
var current_state : BallState = null
#创建一个高度属性
var height := 0.0
#新属性高度速度
var height_velocity := 0.0
#初始位置
var spawn_position := Vector2.ZERO
#引用状态工厂
var state_factory := BallStateFactory.new()
#私有的速度变量
var velocity := Vector2.ZERO

#确保开始时进入正常的状态
func _ready() -> void:
	#将状态切换到自由状态
	switch_state(State.FREEFORM)
	#记录位置
	spawn_position = position
	#监听全局事件(并创建一个回调方法）
	GameEvents.team_reset.connect(on_team_reset.bind())
	#监听开始信号
	GameEvents.Kickoff_started.connect(on_kickoff_started.bind())

#查看在哪里访问球体精灵的方法
func _process(_sadelta: float) -> void:
	ball_sprite.position = Vector2.UP * height
	#通过rotation获取角度进行旋转sd
	scoring_raycast.rotation = velocity.angle()

#创建一个方法用来切换状态
func switch_state(state: Ball.State, data: BallStateData = BallStateData.new()) -> void:
	#判断初始当前状态是否为空
	if current_state != null:
		#如果为空就将其树中移除
		current_state.queue_free()
	#然后创建一个新的状态
	current_state = state_factory.get_fresh_state(state)
	#设置运行方法（尽在此处传递这个方法）
	current_state.setup(self, data, player_dectection_area, carrier, animation_player, ball_sprite)
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

func tumble(tumble_velocity: Vector2) -> void:
	velocity = tumble_velocity
	carrier = null
	height_velocity = TUMBLE_HEIGHT_VELOCITY
	switch_state(Ball.State.FREEFORM, BallStateData.build().set_lock_duration(DURATION_TUMBLE_LOCK))

#设置一个速度方法，不会返回任何内容的向量
func pass_to(destination: Vector2, lock_duration: int = DURATION_PASS_LOCK) -> void:
	#传入两个摩擦力
	var direction := position.direction_to(destination)
	var distance := position.distance_to(destination)
	var intensity := sqrt(2 * distance * friction_ground)
	#强度*方向向量
	velocity = intensity * direction
	#判断我们的距离是否大于阈值
	if distance > DISTANCE_HIGH_PASS:
		height_velocity = BallState.GRAVITY * distance / (1.8 * intensity)
	carrier = null
	switch_state(Ball.State.FREEFORM, BallStateData.build().set_lock_duration(lock_duration))

#创建一个停止的方法
func stop() -> void:
	#将速度设置为0
	velocity = Vector2.ZERO

#创建一个空气是否存在交互的方法
func can_air_interact() -> bool:
	#直接返回当前状态提供的信息
	return current_state != null and current_state.can_air_interact()

#是否能进行空中连接
func can_air_connect(air_connect_min_height: float, air_connect_max_height: float) -> bool:
	#球的当前高度是否在该区间内
	return height >= air_connect_min_height and height <= air_connect_max_height

#创建一个朝着得分区域前进的射线
func is_headed_for_scoring_area(scoring_area: Area2D) -> bool:
	#判断射线是否碰撞
	if not scoring_raycast.is_colliding():
		return false
	return scoring_raycast.get_collider() == scoring_area

#创建回调方法
func on_team_reset() -> void:
	#把球的位置重置到生成位置
	position = spawn_position
	#并且让它停止移动
	velocity = Vector2.ZERO
	#设置强制状态(以防万一)
	switch_state(State.FREEFORM)

#开球开始方法
func on_kickoff_started() -> void:
	#将球传送到出生位置，场地中央
	pass_to(spawn_position + Vector2.DOWN * KICKOFF_PASS_DISTANCE, 0)
