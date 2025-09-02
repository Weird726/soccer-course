#不需要扩展，做成一个简单容器
class_name PlayerStateData

#伤害的方向变量
var hurt_direction: Vector2
#代表一个球员
var pass_target : Player
#创建一个射击方向变量，它是一个二维方向变量
var shot_direction : Vector2
#创建一个设计力度变量，它是一个浮点数
var shot_power : float 

#创建一个静态函数
static func build() -> PlayerStateData:
	#返回玩家的实例
	return PlayerStateData.new()

#设置射门方向方法
func set_shot_direction(direction: Vector2) -> PlayerStateData:
	#设定射门方向
	shot_direction = direction
	#返回父类
	return self

#设置射门力量方法
func set_shot_power(power: float) -> PlayerStateData:
	#设定力量强度
	shot_power = power
	#返回父类
	return self

func set_hurt_direction(direction: Vector2) -> PlayerStateData:
	hurt_direction = direction
	return self

func set_pass_target(player: Player) -> PlayerStateData:
	pass_target = player
	return self
