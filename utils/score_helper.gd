class_name ScoreHelper

#创建一些静态函数方便调用
static func get_score_text(score: Array[int]) -> String:
	#使用占位格%d来输入需要输入的数据
	return "%d - %d" % [score[0], score[1]]

#获取球员得分信息静态函数
static func get_current_score_info(countries: Array[String], score: Array[int]) -> String:
	#判断比分是否相同
	if score[0] == score[1]:
		#达成平局后用占位符显示具体比分
		return "TEAMS ARE TIED %d - %d" % [score[0], score[1]]
	#判断主队是否领先
	elif score[0] > score[1]:
		return "%s LEADS %d - %d" % [countries[0], score[0], score[1]]
	else:
		return "%s LEADS %d - %d" % [countries[1], score[1], score[0]]

static func get_final_score_info(countries: Array[String], score: Array[int]) -> String:
	#检查分数
	if score[0] > score[1]:
		#输出国家获胜和比分（也是用到占位符一个字符串和两个整数参数)
		return "%s WINS %d - %d" % [countries[0], score[0], score[1]]
	else:
		return "%s WINS %d - %d" % [countries[1], score[1], score[0]]
