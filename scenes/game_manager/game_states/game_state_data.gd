class_name GameStateData

var country_scored_on : String

#静态方法
static func build() -> GameStateData:
	return GameStateData.new()

#创建一个SET方法(实现链式调用)
func set_country_scored_on(country: String) -> GameStateData:
	country_scored_on = country
	return self
