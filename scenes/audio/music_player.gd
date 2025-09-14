extends AudioStreamPlayer

#创建所有包含音乐的枚举
enum Music {NONE, GAMEPLAY, MENU, TOURNAMENT, WIN}

#创建一个字典包含所有对应每个枚举的音频流(预加载)
const MUSIC_MAP : Dictionary[Music, AudioStream] = {
	Music.GAMEPLAY: preload("res://assets/music/gameplay.mp3"),
	Music.MENU: preload("res://assets/music/menu.mp3"),
	Music.TOURNAMENT: preload("res://assets/music/tournament.mp3"),
	Music.WIN: preload("res://assets/music/win.mp3"),
}

#记录当前播放的音乐(默认没有无播放状态)
var current_music := Music.NONE

func _ready() -> void:
	#确保该节点在游戏整个状态始终运行
	process_mode = Node.PROCESS_MODE_ALWAYS

func play_music(music: Music) -> void:
	#先检测是否播放该音乐，如果不是则无需操作
	if music != current_music and MUSIC_MAP.has(music):
		stream = MUSIC_MAP.get(music)
		#记录当前播放的音乐
		current_music = music
		play()
