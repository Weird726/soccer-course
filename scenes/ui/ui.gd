class_name UI
extends CanvasLayer

@onready var animation_player: AnimationPlayer = %AnimationPlayer
#声明变量获得旗帜纹理，定义为数组类型
@onready var flag_textures : Array[TextureRect] = [%HomeFlagTexture, %AwayFlagTexture]
@onready var goal_score_label: Label = %GoalScoreLabel
@onready var player_label: Label = %PlayerLabel
@onready var score_info_label: Label = %ScoreInfoLabel
@onready var score_label: Label = %ScoreLabel
@onready var time_label: Label = %TimeLabel

#失去控球权的球员变量
var last_ball_carrier := "" 

func _ready() -> void:
	#更新分数方法
	update_score()
	#更新旗帜显示
	update_flags()
	#更新时钟方法
	update_clock()
	#确保重置玩家标签
	player_label.text = ""
	#监听两个事件
	GameEvents.ball_possessed.connect(on_ball_possessed.bind())
	GameEvents.ball_released.connect(on_ball_released.bind())
	#球队得分事件
	GameEvents.score_changed.connect(on_score_changed.bind())
	#球队重置事件
	GameEvents.team_reset.connect(on_team_reset.bind())
	GameEvents.game_over.connect(on_game_over.bind())

func _process(_delta: float) -> void:
	update_clock()

func update_score() -> void:
	#设置分数标签文本
	score_label.text = ScoreHelper.get_score_text(GameManager.score)

func update_flags() -> void:
	#遍历所有旗帜节点
	for i in flag_textures.size():
		flag_textures[i].texture = FlagHelper.get_texture(GameManager.countries[i])

func update_clock() -> void:
	#检查是否还有剩余时间
	if GameManager.time_left < 0:
		#如果没有时间就用黄色显示
		time_label.modulate = Color.YELLOW
	#过于标签再次创建一个工具类
	time_label.text = TimeHelper.get_time_text(GameManager.time_left)

#这个方法接收名字参数
func on_ball_possessed(player_name: String) -> void:
	#更新玩家标签
	player_label.text = player_name
	last_ball_carrier = player_name

func on_ball_released() -> void:
	#传回空字符串
	player_label.text = ""

func on_score_changed() -> void:
	#只有在比赛时间结束时才播放此得分动画
	if not GameManager.is_time_up():
		goal_score_label.text = "%s SCORED!" % [last_ball_carrier]
		score_info_label.text = ScoreHelper.get_current_score_info(GameManager.countries, GameManager.score)
		animation_player.play("goal_appear")
	update_score()

func on_team_reset() -> void:
	if GameManager.has_someone_scored():
		animation_player.play("goal_hide")

#回调函数
func on_game_over(_country_winner: String) -> void:
	#更新得分信息标签的文本
	score_info_label.text = ScoreHelper.get_final_score_info(GameManager.countries, GameManager.score)
	#播放正确的动画
	animation_player.play("game_over")
