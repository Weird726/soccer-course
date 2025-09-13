class_name SoccerGame
extends Node

#创建枚举用于现有的各种类型
enum ScreenType {MAIN_MENU, TEAM_SELECTION, TOURNAMENT, IN_GAME}

#记录当前屏幕状态的变量
var current_screen : Screen = null
#实例化一个屏幕工厂
var screen_factory := ScreenFactory.new()

func _init() -> void:
	#游戏启动切换到主菜单
	switch_screen(ScreenType.MAIN_MENU)

#创建屏幕参数方法
func switch_screen(screen: ScreenType, data: ScreenData = ScreenData.new()) -> void:
	if current_screen != null:
		current_screen.queue_free()
	current_screen = screen_factory.get_fresh_screen(screen)
	#连接信号
	current_screen.setup(self, data)
	current_screen.screen_transition_requested.connect(switch_screen.bind())
	#添加为子节点
	call_deferred("add_child", current_screen)
