class_name AIBehaviorFactory

#工厂字典变量
var roles : Dictionary

#不同的类方法传入
func _init() -> void:
	roles = {
		Player.Role.DEFENSE: AIBehaviorField,
		Player.Role.GOALIE: AIBehaviorGoalie,
		Player.Role.MIDFIELD: AIBehaviorField,
		Player.Role.OFFENSE: AIBehaviorField,
	}

#创建一个返回合适的AI行为的方法(具体返回根据角色决定)
func get_ai_behavior(role: Player.Role) -> AIBehavior:
	assert(roles.has(role), "role doesn't exist!")
	return roles.get(role).new()
