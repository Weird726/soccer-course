class_name BallStateData

#锁定的持续时间变量
var lock_duration : int

#创建一个静态方法来返回该例的实例
static func build() -> BallStateData:
	return BallStateData.new()

#返回类本身以便实现链式调用
func set_lock_duration(duration: int) -> BallStateData:
	lock_duration = duration
	return self
