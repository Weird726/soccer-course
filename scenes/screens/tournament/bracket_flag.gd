class_name BracketFlag
extends TextureRect

@onready var border: TextureRect = %Border
@onready var score_label: Label = %ScoreLabel

#判断当前是否是我们使用的队伍
func set_as_current_team() -> void:
	#将边框的可见性设置为 true
	border.visible = true

#指示该队伍赢得了比赛的函数.传入比分参数
func set_as_winner(score: String) -> void:
	#将标签的文本设置为比分
	score_label.text = score
	#标签可见性设置为true
	score_label.visible = true
	#将边框可见性设置为不可见
	border.visible = false

#为败者设置的方法，不显示比分
func set_as_loser() -> void:
	modulate = Color(0.2, 0.2, 0.2, 1)
