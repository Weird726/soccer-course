class_name WorldScreen
extends Screen

@onready var game_over_timer: Timer = %GameOverTimer

func _enter_tree() -> void:
	#监听游戏事件
	GameEvents.game_over.connect(on_game_over.bind())
	#调用游戏裁判重置
	GameManager.start_game()

func _ready() -> void:
	#连接到超时信号
	game_over_timer.timeout.connect(on_transition.bind())

func on_game_over(_winner: String) -> void:
	#启动计时器
	game_over_timer.start()

func on_transition() -> void:
	#判断是否处于锦标赛并赢得了当前比赛
	if screen_data.tournament != null and GameManager.current_match.winner == GameManager.player_setup[0]:
		#先推进锦标赛进度
		screen_data.tournament.advance()
		#返回锦标赛界面（要传入屏幕数据 ）
		transition_screen(SoccerGame.ScreenType.TOURNAMENT, screen_data)
	else:
		#无论是输了还是1V1都可以切换回主菜单
		transition_screen(SoccerGame.ScreenType.MAIN_MENU)
