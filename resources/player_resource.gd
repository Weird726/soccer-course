class_name PlayerResource
#继承资源
extends Resource

#创建的一切都用来储存玩家的数据，非常经典的写法
#全名属性，字符串类型
@export var full_name : String
#肤色,玩家肤色类型
@export var skin_color : Player.SkinColor
#角色，职位类型
@export var role : Player.Role
#速度，浮点数类型
@export var speed : float
#力量，浮点数类型
@export var power : float

#创建一个方法允许直接使用以上5个属性初始化玩家资源
func _init(player_name: String, player_skin: Player.SkinColor, player_role: Player.Role, player_speed: float, player_power: float) -> void:
	#这个方法不会返回任何值
	#现在初始化方法
	full_name = player_name
	skin_color = player_skin
	role = player_role
	speed = player_speed
	power = player_power
