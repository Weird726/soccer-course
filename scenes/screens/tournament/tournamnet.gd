class_name Tournament

#记录状态的枚举
enum Stage {QUARTER_FINALS, SEMI_FINALS, FINAL, COMPLETE}

#当前阶段变量记录
var current_stage : Stage = Stage.QUARTER_FINALS
#数组字典(每个阶段都设置一个比赛数组)
var matches := {
	Stage.QUARTER_FINALS: [],
	Stage.SEMI_FINALS: [],
	Stage.FINAL: [],
}
#定义冠军的变量
var winner := ""

#从数据加载器获取国家列表
func _init() -> void:
	#这个方法返回所有类型数组,进行切片操作(不要第一个只要8个)
	var countries := DataLoader.get_countries().slice(1, 9)
	#打乱顺序
	countries.shuffle()
	#指定参数，与国家列表参数
	create_bracket(Stage.QUARTER_FINALS, countries)

func create_bracket(stage: Stage, countries: Array[String]) -> void:
	#创建循环，传入2.0会报错，所以要强制传入一个整数
	for i in range(int(countries.size() / 2.0)):
		#填充数组,追加新比赛
		matches[stage].append(Match.new(countries[i * 2], countries[i * 2 + 1]))

#下一阶段方法
func advance() -> void:
	#首先判断锦标赛是否结束
	if current_stage < Stage.COMPLETE:
		#当前阶段找出已存在场次
		var stage_matches : Array = matches[current_stage]
		#存储获胜者的变量
		var stage_winners : Array[String] = []
		#遍历当前比赛场次列表
		for current_match : Match in stage_matches:
			#处理比赛场次,生成带有比分的获胜者
			current_match.resolve()
			#保留获胜者,并加入获胜者数组
			stage_winners.append(current_match.winner)
		#当前阶段进行+1，因为这是枚举类型需要进行转换
		current_stage = current_stage + 1 as Stage
		#判断当前阶段是否已完成，完成指定获胜者
		if current_stage == Stage.COMPLETE:
			winner = stage_winners[0]
		else:
			#创建对阵表,将前一阶段的胜者传入对阵表
			create_bracket(current_stage, stage_winners)
