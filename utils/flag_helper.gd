class_name FlagHelper

#保存各种纹理的引用,避免重复加载,使用字典结构存储
static var flag_textures : Dictionary[String, Texture2D] = {}

#创建国家旗帜纹理函数
static func get_texture(country: String) -> Texture2D:
	#先检查字典中是否以存在该纹理，如果不存在就进行添加
	if not flag_textures.has(country):
		#依旧使用到了百分号占位
		flag_textures.set(country, load("res://assets/art/ui/flags/flag-%s.png" % [country.to_lower()]))
	#直接返回
	return flag_textures[country]
