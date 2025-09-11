class_name TeamSelectionScreen
extends Control

#锚点常量
const FLAG_ANCHOR_POINT := Vector2(35, 80)
#预制体命名是好习惯
const FLAG_SELECTOR_PREFAB := preload("res://scenes/screens/team_selection/flag_selector.tscn")
#列数
const NB_COLS := 4
#行数
const NB_ROWS := 2

@onready var flags_container: Control = %FlagsContainer

#字典处理特定方向
var move_dirs : Dictionary[KeyUtils.Action, Vector2i] = {
	KeyUtils.Action.UP: Vector2i.UP,
	KeyUtils.Action.DOWN: Vector2i.DOWN,
	KeyUtils.Action.LEFT: Vector2i.LEFT,
	KeyUtils.Action.RIGHT: Vector2i.RIGHT,
}

#追踪选择状态
var selection : Array[Vector2i] = [Vector2i.ZERO, Vector2i.ZERO]
#记录实例
var selectors : Array[FlagSelector] = []

func _ready() -> void:
	#用于放置国旗的方法
	place_flags()
	place_selectors()

func _process(_delta: float) -> void:
	#首先判断是否有多个选择器
	for i in range(selectors.size()):
		#获取选择器的引用
		var selector = selectors[i]
		#检测玩家是否按下键位
		if not selector.is_selected:
			#遍历字典的所有键
			for action : KeyUtils.Action in move_dirs.keys():
				#通过选择器的控制方案实现的功能
				if KeyUtils.is_action_just_pressed(selector.control_scheme, action):
					#如果按下右键左上角的选择器向右移动一格
					try_navigate(i, move_dirs[action])

func try_navigate(selector_index: int, direction: Vector2i) -> void:
	#使用矩形类型
	var rect : Rect2i = Rect2i(0, 0, NB_COLS, NB_ROWS)
	#检查当前点是否可能成为目标位置
	if rect.has_point(selection[selector_index] + direction):
		selection[selector_index] += direction
		#旗帜索引
		var flag_index := selection[selector_index].x + selection[selector_index].y * NB_COLS
		#设置选择器的位置
		selectors[selector_index].position = flags_container.get_child(flag_index).position
		#为导航添加音效
		SoundPlayer.play(SoundPlayer.Sound.UI_NAV)

func place_flags() -> void:
	#循环行与列数组
	for j in range(NB_ROWS):
		for i in range(NB_COLS):
			#创建纹理矩形
			var flag_texture := TextureRect.new()
			#旗帜间的水平距离与垂直距离
			flag_texture.position = FLAG_ANCHOR_POINT + Vector2(55 * i, 50 * j)
			#国家索引
			var country_index := 1 + i + NB_COLS * j
			#要先确定选择哪个国家
			var country := DataLoader.get_countries()[country_index]
			#设置纹理
			flag_texture.texture = FlagHelper.get_texture(country)
			#放大国家旗帜缩放向量为2
			flag_texture.scale = Vector2(2, 2)
			flag_texture.z_index = 1
			#将纹理矩形添加到节点
			flags_container.add_child(flag_texture)

func place_selectors() -> void:
	add_selector(Player.ControlScheme.P1)
	if not GameManager.player_setup[1].is_empty():
		add_selector(Player.ControlScheme.P2)

func add_selector(control_scheme: Player.ControlScheme) -> void:
	#实例化这个选择器场景
	var selector := FLAG_SELECTOR_PREFAB.instantiate()
	selector.position = flags_container.get_child(0).position
	selector.control_scheme = control_scheme
	#将选择器添加到选择器数组中
	selectors.append(selector)
	#作为国旗容器的一部分添加
	flags_container.add_child(selector)
