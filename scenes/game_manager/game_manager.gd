extends Node

const DURATION_GAME_SEC := 2 * 60

#创建一个枚举状态
enum State {IN_PLAY, SCORED, RESET, KICKOFF, OVERTIME, GAMEOVER}

#创建数组列表
var countries : Array[String] = ["FRANCE", "USA"]
var current_state : GameState = null
var player_setup : Array[String] = ["FRANCE", ""]
var score : Array[int] = [0, 0]
var state_factory := GameStateFactory.new()
var time_left : float

func _ready() -> void:
	#将剩余时间设为比赛时长
	time_left = DURATION_GAME_SEC
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
