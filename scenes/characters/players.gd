class_name Players
extends CharacterBody2D
#创建一个新的枚举类型
enum ControlScheme {CPU, P1, P2}
#创建一个变量来存储这个枚举，让它成为一个可导出变量
@export var control_scheme : ControlScheme

@export var speed : float

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player_sprite: Sprite2D = %PlayerSprite

#私有变量存储玩家面向的方向
var heading := Vector2.RIGHT

#函数后面下划线可以消除警告
func _process(_delta: float) -> void:
	#检测是我们控制玩家还是CPU控制玩家（AI处理）
	if control_scheme == ControlScheme.CPU:
		pass #这里是AI处理逻辑预留
	else:
		#包含角色移动方向等的方法
		handle_human_movement()
	
	#创建一个set_movement_animation()方法来重构代码
	set_movemont_animation()
	#判断人物动画方向方法
	set_heading()
	#调用方向判断后改变动画H属性的方法
	flip_sprites()
	#调用CharacterBody2D的方法来实现移动，这个方法是move_and_slide()
	move_and_slide()

func handle_human_movement() -> void:
		#针对Player 1 的控制方向代码
	var direction := KeyUtils.get_input_vector(control_scheme)
	# 方向 * 速度 = 调整的速度 velocity 是以每秒像素为单位的
	velocity = direction * speed

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
