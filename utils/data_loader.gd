extends Node

#此变量包含所有玩家变量数据：使用的是字典{字符串国家名字，值是玩家的列表，
var squads : Dictionary[String, Array]

#游戏启动时使用所有的数据（创建_init方法）
func _init() -> void:
	#文件访问(FileAccess方法）
	var json_file := FileAccess.open("res://assets/json/squads.json", FileAccess.READ)
	#判断传输是否为空
	if json_file == null:
		#如果没有，生成错误信息
		printerr("could not find or load squads.json")
	#创建一个文本方法
	var json_text := json_file.get_as_text()
	#gd提供的APL JSON来访问数据
	var json := JSON.new()
	#判断文件是否解析正常 gd自带parse数据
	if json.parse(json_text) != OK:
		printerr("could not parse squads.json")
	#遍历整个数组
	for team in json.data:
		#解析第一个字典的两个键
		var country_name := team["country"] as String
		var players := team["players"] as Array
		#检查一下是否已经有了顶级条目那个键
		if not squads.has(country_name):
			#初始化那个键的值为一个空数组,将玩家资源追加到那个数组中
			squads.set(country_name, [])
		#循环
		for player in players:
			#对所有类型进行类型转换
			var fullname := player["name"] as String
			var skin := player["skin"] as Player.SkinColor
			var role := player["role"] as Player.Role
			var speed := player["speed"] as float
			var power := player["power"] as float
			#最后一步创建玩家资源
			var player_resource := PlayerResource.new(fullname, skin, role, speed, power)
			#先把玩家资源添加到队伍中
			squads.get(country_name).append(player_resource)
		#添加一个断言，确保最后添加的队员 == 6位
		assert(players.size() == 6)
	#使用close（）方法，确保在交换控制权之前关闭它
	json_file.close()

#创建一个快捷方法，方便用于访问
func get_squad(country: String) -> Array:
	#返回玩家的资源数组
	if squads.has(country):
		return squads[country]
	#判断用于如果文件不存在，抛出一个错误,返回一个空数组
	return []
