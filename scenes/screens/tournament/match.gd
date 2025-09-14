class_name Match

#添加比赛相关信息
var country_home : String
var country_away : String
var goals_home : int
var goals_away : int
var final_score : String
var winner : String

#初始化方法，传入主场客场参数
func _init(team_home: String, team_away: String) -> void:
	#初始化变量
	country_home = team_home
	country_away = team_away

#判断平局的方法
func is_tied() -> bool:
	return goals_home == goals_away

func has_someone_scored() -> bool:
	return goals_home > 0 or goals_away > 0

#增加比分的方法
func increase_score(country_scored_on: String) -> void:
	#检查是否主场队伍进球
	if country_scored_on == country_home:
		goals_away += 1
	else:
		goals_home += 1
	#每次进球更新信息
	update_match_info()

#用来更新比赛信息的方法
func update_match_info() -> void:
	#指定获胜者
	winner = country_home if goals_home > goals_away else country_away
	#分数显示
	final_score = "%d - %d" % [max(goals_home, goals_away), min(goals_home, goals_away)]

#解决方案
func resolve() -> void:
	#开始循环
	while  is_tied():
		goals_home = randi_range(0, 5)
		goals_away = randi_range(0, 5)
	update_match_info()
