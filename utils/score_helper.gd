class_name ScoreHelper

#创建一些静态函数方便调用
static func get_score_text(current_match: Match) -> String:
	#使用占位格%d来输入需要输入的数据
	return "%d - %d" % [current_match.goals_home, current_match.goals_away]

#获取球员得分信息静态函数
static func get_current_score_info(current_match: Match) -> String:
	#判断比分是否相同
	if current_match.is_tied():
		#达成平局后用占位符显示具体比分
		return "TEAMS ARE TIED %d - %d" % [current_match.goals_home, current_match.goals_away]
	else:
		return "%s LEADS %s" % [current_match.winner, current_match.final_score]

static func get_final_score_info(current_match: Match) -> String:
		#返回国家获胜和比分（也是用到占位符一个字符串和两个整数参数)
		return "%s WINS %s" % [current_match.winner, current_match.final_score]
