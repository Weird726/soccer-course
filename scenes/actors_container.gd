class_name ActorsContainer
extends Node2D

#引入一个常量用于权重缓存或计算
const DURATION_WEIGHT_CACHE := 200
#场景中玩家的引用以便实例化
const PLAYER_PREFAB := preload("res://scenes/characters/player.tscn")

#创建相关引用，访问球，访问主场和客场的引用
@export var ball : Ball
@export var goal_home : Goal
@export var goal_away : Goal

#创建一个未就绪变量来访问节点，这是一个二维节点
@onready var kickoffs: Node2D = %KickOffs
@onready var spawns: Node2D = %Spawns

var is_checking_for_kickoff_readiness := false
#用于访问主场阵容与客场阵容的权重
var squad_home : Array[Player] = []
var squad_away : Array[Player] = []
#用于存储时间缓存刷新的变量
var time_since_last_cache_refresh := Time.get_ticks_msec()

#在准备方法中，实例化队伍
func _ready() -> void:
	#创建一个生成玩家的方法并指定，队伍的名字与目标
	squad_home = spawn_players(GameManager.countries[0], goal_home)
	#初始化
	goal_home.initialize(GameManager.countries[0])
	#交换X轴的比例以便生成客场球员
	spawns.scale.x = -1
	#首先确保处理客队时X值缩放为-1
	kickoffs.scale.x = -1
	squad_away = spawn_players(GameManager.countries[1], goal_away)
	goal_away.initialize(GameManager.countries[1])
	
#创建一个用于测试的方法，来指定玩家
	var player : Player = get_children().filter(func(p): return p is Player)[4]
	player.control_scheme = Player.ControlScheme.P1
	#设置正确纹理
	player.set_control_texture()
	#监听全局重置事件
	GameEvents.team_reset.connect(on_team_reset.bind())
	
#检查时间的进程方法
func _process(_delta: float) -> void:
	#判断如果我们花费足够的时间该怎么办
	if Time.get_ticks_msec() - time_since_last_cache_refresh > DURATION_WEIGHT_CACHE:
		#首先确保更新时间戳
		time_since_last_cache_refresh = Time.get_ticks_msec()
		#调用方法
		set_on_duty_weights()
	#检查是否需要检测准备状态
	if is_checking_for_kickoff_readiness:
		check_for_kickoff_readiness()

func spawn_players(country: String, own_goal: Goal) -> Array[Player]:
	var player_nodes : Array[Player] = []
	#从数据加载器中获取玩家数据的访问权限
	var players := DataLoader.get_squad(country)
	#判断传入生成的目标
	var target_goal := goal_home if own_goal == goal_away else goal_away
	#遍历球员
	for i in players.size():
		#获取球员的位置，第i个子项的全局位置,强制转换为二维向量处理
		var player_position := spawns.get_child(i).global_position as Vector2
		#玩家数据将作为玩家资源中的i(as是或者的意思)
		var player_data := players[i] as PlayerResource
		#创建开球位置
		var kickoff_position := player_position
		#如果索引大于3
		if i > 3:
			#就将重生点设置为开球位置
			kickoff_position = kickoffs.get_child(i - 4).global_position as Vector2
		#继续使用创建玩家方法,首先使用传递玩家的位置
		var player := spawn_player(player_position, kickoff_position, own_goal, target_goal, player_data, country)
		#返回的节点中玩家
		player_nodes.append(player)
		#将节点添加为子节点
		add_child(player)
	return player_nodes

#创建一个生成玩家的方法(需要指定节点，各项依赖等)
func spawn_player(player_position: Vector2, kickoff_position: Vector2, own_goal: Goal, target_goal: Goal, player_data: PlayerResource, country: String) -> Player:
		#玩家预制体实例化
		var player : Player = PLAYER_PREFAB.instantiate()
		#将以上所有的值设置成玩家属性的一部分,直接调用初始化方法
		player.initialize(player_position, kickoff_position, ball, own_goal, target_goal, player_data, country)
		#监听信号,创建回调方法
		player.swap_requested.connect(on_player_swap_request.bind())
		#返回这个玩家
		return player

#分配权重的方法
func set_on_duty_weights() -> void:
	for squad in [squad_away, squad_home]:
		var cpu_players : Array[Player] = squad.filter(
			#自定义函数
			#判断是否由CPU操控的同时确保守门员没有被操控
			func(p: Player): return p.control_scheme == Player.ControlScheme.CPU and p.role != Player.Role.GOALIE
		)
		#cpu玩家的自定义排序
		cpu_players.sort_custom(func(p1: Player, p2: Player):
			#计算两个球之间的距离并且进行比较
			return p1.spawn_position.distance_squared_to(ball.position) < p2.spawn_position.distance_squared_to(ball.position))
		#使用缓动函数为权重赋值
		for i in range(cpu_players.size()):
			#将执行操作1 - 缓动函数
			cpu_players[i].weight_on_duty_steering = 1 - ease(float(i)/10.0, 0.1)

#球员交换请求回调方法
func on_player_swap_request(requester: Player) -> void:
	var squad := squad_home if requester.country == squad_home[0].country else squad_away
	var cpu_players : Array[Player] = squad.filter(
	#自定义函数
	#判断是否由CPU操控的同时确保守门员没有被操控
		func(p: Player): return p.control_scheme == Player.ControlScheme.CPU and p.role != Player.Role.GOALIE
	)
	#cpu玩家的自定义排序
	cpu_players.sort_custom(func(p1: Player, p2: Player):
		#计算两个球之间的距离并且进行比较
		return p1.position.distance_squared_to(ball.position) < p2.position.distance_squared_to(ball.position))
	#选择离球最近的那个玩家
	var closest_cpu_to_ball : Player = cpu_players[0]
	#判断他们之间的距离，距离更近就直接交换
	if closest_cpu_to_ball.position.distance_squared_to(ball.position) < requester.position.distance_squared_to(ball.position):
		#首先判断请求内存者是玩家1还是玩家2
		var player_control_scheme := requester.control_scheme
		#存储完毕后执行交换(改为CPU控制方案)
		requester.control_scheme = Player.ControlScheme.CPU
		#调用设置纹理来控制头上的球员图标
		requester.set_control_texture()
		#同时交换最近的CPU球员,赋予存储的值
		closest_cpu_to_ball.control_scheme = player_control_scheme
		#调用设置纹理来控制头上的球员图标
		closest_cpu_to_ball.set_control_texture()

func check_for_kickoff_readiness() -> void:
	#遍历两个小队
	for squad in [squad_home, squad_away]:
		#检查每个小队的玩家
		for player : Player in squad:
			#检查玩家是否做好开球准备
			if not player.is_ready_for_kickoff():
				return
	is_checking_for_kickoff_readiness = false
	#如果上游的工作全部已完成，通知上游准备我们已做好开球准备(触发信号)
	GameEvents.kickoff_ready.emit()

#创建回调方法
func on_team_reset() -> void:
	is_checking_for_kickoff_readiness = true
