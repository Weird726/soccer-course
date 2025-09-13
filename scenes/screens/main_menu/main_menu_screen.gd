class_name MainMenuScreen
extends Screen

#菜单纹理常量,这是个多维数组
const MENU_TEXTURES := [
	[preload("res://assets/art/ui/mainmenu/1-player.png"), preload("res://assets/art/ui/mainmenu/1-player-selected.png")],
	[preload("res://assets/art/ui/mainmenu/2-players.png"), preload("res://assets/art/ui/mainmenu/2-players-selected.png")]
	]

#创建节点引用，声明未就绪变量(单人模式纹理和双人模式纹理)
@onready var selectable_menu_nodes : Array[TextureRect] = [%SinglePlayerTexture,%TwoPlayersTexture]
#未就绪变量跟踪选择图标
@onready var selection_icon : TextureRect = %SelectionIcon

#跟踪当前索引,玩家正在选择的索引
var current_selected_index := 0
#是否启动活跃状态变量
var is_active := false

func _ready() -> void:
	#直接调用方法
	refresh_ui()

func _process(_delta: float) -> void:
	#每当处理场景要确保当前场景处于激活状态
	if is_active:
		#检查是否按下了上键或下键
		if KeyUtils.is_action_just_pressed(Player.ControlScheme.P1, KeyUtils.Action.UP):
			change_selected_index(current_selected_index - 1)
		elif KeyUtils.is_action_just_pressed(Player.ControlScheme.P1, KeyUtils.Action.DOWN):
			change_selected_index(current_selected_index + 1)
		elif KeyUtils.is_action_just_pressed(Player.ControlScheme.P1, KeyUtils.Action.SHOOT):
			submit_selection()

#每次选择改变时都会调用这个方法
func refresh_ui() -> void:
	#用循环实现功能
	for i in range(selectable_menu_nodes.size()):
		#检查当前索引是否等于i
		if current_selected_index == i:
			#如果是将设置为准备的多个纹理
			selectable_menu_nodes[i].texture = MENU_TEXTURES[i][1]
			#选择图标并向左位移25像素
			selection_icon.position = selectable_menu_nodes[i].position + Vector2.LEFT * 25
		else:
			selectable_menu_nodes[i].texture = MENU_TEXTURES[i][0]

func change_selected_index(new_index) -> void:
	#确保选中索引保持在0和可选项目数量之间
	current_selected_index = clamp(new_index, 0, selectable_menu_nodes.size() - 1)
	#播放一个音效
	SoundPlayer.play(SoundPlayer.Sound.UI_NAV)
	refresh_ui()

func submit_selection() -> void:
	#播放选择音效
	SoundPlayer.play(SoundPlayer.Sound.UI_SELECT)
	#选择列表中的第一个国家
	var country_default := DataLoader.get_countries()[1]
	var player_two := "" if current_selected_index == 0 else country_default
	GameManager.player_setup = [country_default, player_two]
	#跳转界面
	transition_screen(SoccerGame.ScreenType.TEAM_SELECTION)

#回调函数
func on_set_active() -> void:
	refresh_ui()
	#从动画中调用这个函数
	is_active = true
