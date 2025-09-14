class_name Screen
extends Node

#定义信号以便在界面边切换
signal screen_transition_requested(new_screen: SoccerGame.ScreenType, data: ScreenData)

#指定导出变量选择要播放的音乐
@export var music: MusicPlayer.Music

#变量引用
var game : SoccerGame = null
var screen_data : ScreenData = null

func _enter_tree() -> void:
	MusicPlayer.play_music(music)

#引用方法
func setup(context_game: SoccerGame, context_data: ScreenData) -> void:
	#赋值变量
	game = context_game
	screen_data = context_data

#创建界面切换方法,默认情况下传入空对象
func transition_screen(new_screen: SoccerGame.ScreenType, data: ScreenData = ScreenData.new()) -> void:
	#发出信号
	screen_transition_requested.emit(new_screen, data)
