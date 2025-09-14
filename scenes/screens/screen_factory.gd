class_name ScreenFactory

var screens : Dictionary

#初始化设置
func _init() -> void:
	#针对每种屏幕类型需要在游戏内进行具体设置
	screens = {
		SoccerGame.ScreenType.IN_GAME: preload("res://scenes/screens/world/world_screen.tscn"),
		SoccerGame.ScreenType.MAIN_MENU: preload("res://scenes/screens/main_menu/main_menu_screen.tscn"),
		SoccerGame.ScreenType.TEAM_SELECTION: preload("res://scenes/screens/team_selection/team_selection_screen.tscn"),
		SoccerGame.ScreenType.TOURNAMENT: preload("res://scenes/screens/tournament/tournament_screen.tscn"),
	}

#返回屏幕新实例的方法
func get_fresh_screen(screen: SoccerGame.ScreenType) -> Screen:
	#首先确保有创建实例的能力
	assert(screens.has(screen), "screen does not exist")
	return screens.get(screen).instantiate()
