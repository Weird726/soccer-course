class_name TimeHelper

static func get_time_text(time_left: float) -> String:
	#检查是否有剩余时间
	if time_left < 0:
		return "OVERTIME!"
	else:
		#分钟的计算是用剩余秒数*60
		var minutes := int(time_left / 60.0)
		#计算剩余秒数，总秒数 - 分数 * 60
		var seconds := time_left - minutes * 60
		#%02d 表示这个占位符需要占据两位数,当数组不足两位数，前面会自动补0
		return "%02d : %02d" % [minutes, seconds]
