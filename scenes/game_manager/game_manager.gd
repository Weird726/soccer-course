extends Node

#持续时间影响暂停
const DURATION_IMPACT_PAUSE := 100
const DURATION_GAME_SEC := 2 * 60

#创建一个枚举状态
enum State {IN_PLAY, SCORED, RESET, KICKOFF, OVERTIME, GAMEOVER}

#创建数组列表
var countries : Array[String] = ["FRANCE", "USA"]
var current_state : GameState = null
var player_setup : Array[String] = ["FRANCE", "FRANCE"]
var score : Array[int] = [0, 0]
var state_factory := GameStateFactory.new()
var time_left : float
#记录时间的变量
var time_since_paused := Time.get_ticks_msec()

func _ready() -> void:
	#将剩余时间设为比赛时长
	time_left = DURATION_GAME_SEC
	#监听事件创建回调函数
	GameEvents.impact_received.connect(on_impact_received.bind())

func _init() -> void:
	#设置进程模式始终运行
	process_mode = ProcessMode.PROCESS_MODE_ALWAYS

func _process(_delta: float) -> void:
	#检查是否处于暂停状态,检查暂停时间是否超过100毫秒
	if get_tree().paused and Time.get_ticks_msec() - time_since_paused > DURATION_IMPACT_PAUSE:
		#解除暂停
		get_tree().paused = false

#重置状态转换方法
func start_game() -> void:
	switch_state(State.RESET)

#调用一个默认值就不用修改所有调用此方法的地方
func switch_state(state: State, data: GameStateData = GameStateData.new()) -> void:
	#首先释放当前状态
	if current_state != null:
		current_state.queue_free()
	current_state = state_factory.get_fresh_state(state)
	current_state.setup(self, data)
	current_state.state_transition_requested.connect(switch_state.bind())
	current_state.name = "GameStateMachine: " + str(state)
	call_deferred("add_child", current_state)

#判断是否是合作方法
func is_coop() -> bool:
	return player_setup[0] == player_setup[1]

#判断是否是单人方法
func is_single_player() -> bool:
	return player_setup[1].is_empty()

#比赛平局的方法
func is_game_tied() -> bool:
	return score[0] == score[1]

#判断比赛是否结束的方法
func is_time_up() -> bool:
	return time_left <= 0

#辅助函数
func get_winner_country() -> String:
	#断言不是平局返回空字符串
	assert(not is_game_tied())
	return countries[0] if score[0] > score[1] else countries[1]

#创建一个增加分数的方法(该方法接收国家分数作为参数)
func increase_score(country_scored_on: String) -> void:
	var index_country_scoring := 1 if country_scored_on == countries[0] else 0
	score[index_country_scoring] += 1
	GameEvents.score_changed.emit()

func has_someone_scored() -> bool:
	return score[0] > 0 or score[1] > 0

#此回调函数需要参数，判断高强度撞击，影响的位置
func on_impact_received(_impact_position: Vector2, is_high_impact: bool) -> void:
	#判断是否是高强度撞击
	if is_high_impact:
		#每次暂停时记录开始时间
		time_since_paused = Time.get_ticks_msec()
		#暂停游戏
		get_tree().paused = true
