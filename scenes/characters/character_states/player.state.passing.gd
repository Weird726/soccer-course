class_name PlayerStatePassing
extends PlayerState

#传统步骤，先播放动画
func _enter_tree() -> void:
	animation_player.play("kick")
	#阻止玩家移动
	player.velocity = Vector2.ZERO

#监听器方法
func on_animation_complete() -> void:
	#寻找传球的目标
	var pass_target := find_teammate_in_view()
	print(pass_target)
	transition_state(Player.State.MOVING)

#创建返回一个玩家的方法
func find_teammate_in_view() -> Player:
	#创建一个用于保存所有视野内玩家的变量
	var player_in_view := teammate_detection_area.get_overlapping_bodies()
	#用于过滤的方法（包括玩家自身）
	var teammates_in_view := player_in_view.filter(
		func (p: Player): return p != player
	)
	#自定义排序(接受一个带有两个参数的可调用函数(这是一个数组）
	teammates_in_view.sort_custom(
		func (p1: Player, p2: Player):return p1.position.distance_squared_to(player.position) < p2.position.distance_squared_to(player.position)
	)
	#如果队友数组的大小 > 0 我们就返回第一个对象
	if teammates_in_view.size() > 0:
		return teammates_in_view[0]
		return null
		
	
