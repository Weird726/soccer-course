extends Node

#用枚举列出所有音效
enum Sound {BOUNCE, HURT, PASS, POWERSHOT, SHOT, TACKLING, UI_NAV, UI_SELECT, WHISTLE}

#频道常量限制设置(上限为4)
const NB_CHANNELS := 4
#创建字典，以Sound枚举为键，以音频流为值
const SFX_MAP: Dictionary[Sound, AudioStream] = {
	#预加载引用
	Sound.BOUNCE: preload("res://assets/sfx/bounce.wav"),
	Sound.HURT: preload("res://assets/sfx/hurt.wav"),
	Sound.PASS: preload("res://assets/sfx/pass.wav"),
	Sound.POWERSHOT: preload("res://assets/sfx/power-shot.wav"),
	Sound.SHOT: preload("res://assets/sfx/shoot.wav"),
	Sound.TACKLING: preload("res://assets/sfx/tackle.wav"),
	Sound.UI_NAV: preload("res://assets/sfx/ui-navigate.wav"),
	Sound.UI_SELECT: preload("res://assets/sfx/ui-select.wav"),
	Sound.WHISTLE: preload("res://assets/sfx/whistle.wav"),
}

#引用音频流播放器（创建一个空数组)
var stream_players : Array[AudioStreamPlayer] = []

func _ready() -> void:
	#处理四个通道，为每个通道创建一个新的音频流播放器
	for i in range(NB_CHANNELS):
		var stream_player := AudioStreamPlayer.new()
		stream_players.append(stream_player)
		#作为子对象
		add_child(stream_player)

#选择性播放方法
func play(sound: Sound) -> void:
	var stream_player := find_first_available_player()
	if stream_player != null:
		stream_player.stream = SFX_MAP[sound]
		stream_player.play()

#创建一个方法用来判断流播放器是否可用
func find_first_available_player() -> AudioStreamPlayer:
	for stream_player in stream_players:
		if not stream_player.playing:
			return stream_player
	return null
