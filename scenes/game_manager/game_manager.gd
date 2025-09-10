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
