class_name TournamentScreen
extends Screen

#舞台纹理的常量
const STAGE_TEXTURES := {
	Tournament.Stage.QUARTER_FINALS: preload("res://assets/art/ui/teamselection/quarters-label.png"),
	Tournament.Stage.SEMI_FINALS: preload("res://assets/art/ui/teamselection/semis-label.png"),
	Tournament.Stage.FINAL: preload("res://assets/art/ui/teamselection/finals-label.png"),
	Tournament.Stage.COMPLETE: preload("res://assets/art/ui/teamselection/winner-label.png")
}

#创建字典，存储容器的数组
@onready var flag_containers : Dictionary = {
	Tournament.Stage.QUARTER_FINALS: [%QFLeftContainer, %QFRightContainer],
	Tournament.Stage.SEMI_FINALS: [%SFLeftContainer, %SFRightContainer],
	Tournament.Stage.FINAL: [%FinalLeftContainer, %FinalRightContainer],
	Tournament.Stage.COMPLETE: [%WinnerContainer],
}
#未就绪变量，用来调整舞台纹理
@onready var stage_texture : TextureRect = %StageTexture

#引用玩家国家
var player_country : String = GameManager.player_setup[0]
#锦标赛引用变量
var tournament : Tournament = null

func _ready() -> void:
	#初始化比赛
	tournament = screen_data.tournament
	#检查当前所处阶段
	if tournament.current_stage == Tournament.Stage.COMPLETE:
		MusicPlayer.play_music(MusicPlayer.Music.WIN)
	#刷新比赛的方法
	refresh_brackets()

func _process(_delta: float) -> void:
	#检查是否按下玩家1的射击键
	if KeyUtils.is_action_just_pressed(Player.ControlScheme.P1, KeyUtils.Action.SHOOT):
		#锦标赛当前界面判断
		if tournament.current_stage < Tournament.Stage.COMPLETE:
			#如果锦标赛尚未完成，切换到游戏状态
			transition_screen(SoccerGame.ScreenType.IN_GAME, screen_data)
		else:
			#直接返回主菜单
			transition_screen(SoccerGame.ScreenType.MAIN_MENU)
		#添加音效
		SoundPlayer.play(SoundPlayer.Sound.UI_SELECT)

func refresh_brackets() -> void:
	#刷新单个赛程的方法
	for stage in range(tournament.current_stage + 1):
		#刷新当前赛程的方法
		refresh_bracket_stage(stage)

func refresh_bracket_stage(stage: Tournament.Stage) -> void:
	#旗帜节点的获取
	var flag_nodes := get_flag_nodes_fer_stage(stage)
	#刷新纹理
	stage_texture.texture = STAGE_TEXTURES.get(stage)
	#判断锦标赛是否结束
	if stage < Tournament.Stage.COMPLETE:
		var matches : Array = tournament.matches[stage]
		#标志节点数量应等于比赛场次的两倍
		assert(flag_nodes.size() == 2 * matches.size())
		#开始遍历比赛场次
		for i in  range(matches.size()):
			#确定当前是哪场比赛
			var current_match : Match = matches[i]
			#找出主队旗帜
			var flag_home : BracketFlag = flag_nodes[i * 2]
			#同时获取客队旗帜的引用
			var flag_away : BracketFlag = flag_nodes[i * 2 + 1]
			#设置主队有客队的旗帜纹理
			flag_home.texture = FlagHelper.get_texture(current_match.country_home)
			flag_away.texture = FlagHelper.get_texture(current_match.country_away)
			#首先确保存在获胜方
			if not current_match.winner.is_empty():
				#识别获胜方和败方的对应旗帜
				var flag_winner := flag_home if current_match.winner == current_match.country_home else flag_away
				#败者旗帜也可以通过获胜旗帜来推断
				var flag_loser := flag_home if flag_winner == flag_away else flag_away
				#调用赛程标记方法
				flag_winner.set_as_winner(current_match.final_score)
				flag_loser.set_as_loser()
			#检查当前对阵中是否包含球队国家，以及玩家国家,仅保留当前阶段
			elif [current_match.country_home, current_match.country_away].has(player_country) and stage == tournament.current_stage:
				#确定具体比赛中的对应旗帜
				var flag_player := flag_home if current_match.country_home == player_country else flag_away
				#添加边框
				flag_player.set_as_current_team()
				#将游戏管理器设置为当前比赛
				GameManager.current_match = current_match
	#如果锦标赛已完成，直接设置标记节点将只包含胜者
	else:
		flag_nodes[0].texture = FlagHelper.get_texture(tournament.winner)

#此方法接收当前阶段,返回赛程国旗数组
func get_flag_nodes_fer_stage(stage: Tournament.Stage) -> Array[BracketFlag]:
	#先创建空数组返回
	var flag_nodes : Array[BracketFlag] = []
	#遍历现有的各个容器,每个容器可以包含两个元素
	for container in flag_containers.get(stage):
		#逐个检查这些容器,并选取这些容器的子节点
		for node in container.get_children():
			#如果节点是方括号标志
			if node is BracketFlag:
				#添加到标志节点集合中
				flag_nodes.append(node)
	return flag_nodes
	
