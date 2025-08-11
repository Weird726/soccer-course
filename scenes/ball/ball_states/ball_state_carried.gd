class_name BallStateCarried
extends BallState

#创建一个方法用来确认是否有一个携带者
func _enter_tree() -> void:
	#检查携带者是否为空
	assert(carrier != null)

#设置球的位置方法
func _process(_delta: float) -> void:
	#设置为携带者的位置
	ball.position = carrier.position
	
