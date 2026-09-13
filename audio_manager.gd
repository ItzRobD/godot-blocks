extends Node
class_name AudioManager

enum SFX { Click, Drop, GameOver, Hold, LineClear, NoHold, Rotation, TetrisClear }
	
enum BGM { None = -1, Menu, TypeA, TypeB }

const SFX_DICT: Dictionary = {
	SFX.Click: preload("res://assets/sound/click.mp3"),
	SFX.Drop: preload("res://assets/sound/drop.mp3"),
	SFX.GameOver: preload("res://assets/sound/game_over.mp3"),
	SFX.Hold: preload("res://assets/sound/hold.mp3"),
	SFX.LineClear: preload("res://assets/sound/line_clear.mp3"),
	SFX.NoHold: preload("res://assets/sound/no_hold.mp3"),
	SFX.Rotation: preload("res://assets/sound/rotation.mp3"),
	SFX.TetrisClear: preload("res://assets/sound/tetris_clear.mp3")
}

const BGM_DICT: Dictionary = {
	BGM.Menu: preload("res://assets/music/Main Menu.mp3"),
	BGM.TypeA: preload("res://assets/music/Type A.mp3"),
	BGM.TypeB: preload("res://assets/music/Type B.mp3")
}

@onready var bg_music: AudioStreamPlayer = %BGMusic
@onready var sfx_1: AudioStreamPlayer = %SFX1
@onready var sfx_2: AudioStreamPlayer = %SFX2
@onready var sfx_3: AudioStreamPlayer = %SFX3

var _sfx_players: Array[AudioStreamPlayer] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_sfx_players = [sfx_1, sfx_2, sfx_3]

func clear_streams() -> void:
	bg_music.stop()
	bg_music.stream = null
	for player in _sfx_players:
		player.stop()
		player.stream = null

# Plays on the first idle player. If they are all busy the sound is dropped.
# Pass an index into _sfx_players to force a specific player instead.
func play_sfx(sfx: SFX, override_player: int = -1) -> void:
	if override_player >= 0:
		_play_on(_sfx_players[override_player], sfx)
		return

	for player in _sfx_players:
		if not player.playing:
			_play_on(player, sfx)
			return

func _play_on(player: AudioStreamPlayer, sfx: SFX) -> void:
	player.stream = SFX_DICT[sfx]
	player.play()

func stop_sfx_player(player: AudioStreamPlayer) -> void:
	player.stop()
	
func pause_sfx_player(player: AudioStreamPlayer) -> void:
	player.stream_paused = true
	
func resume_sfx_player(player: AudioStreamPlayer) -> void:
	player.stream_paused = false
	
func get_sfx_player(index: int) -> AudioStreamPlayer:
	return _sfx_players[index]

func play_bgm_track(bgm: BGM) -> void:
	bg_music.stream = BGM_DICT[bgm]
	bg_music.play()
	
func play_bgm() -> void:
	bg_music.play()
	
func stop_bgm() -> void:
	bg_music.stop()
	
func pause_bgm() -> void:
	bg_music.stream_paused = true
	
func resume_bgm() -> void:
	bg_music.stream_paused = false
	
func get_bgm_count() -> int:
	return BGM_DICT.size()

func set_random_bgm() -> void:
	bg_music.stream = BGM_DICT[randi() % BGM_DICT.size()]

func pause_all_players() -> void:
	bg_music.stream_paused = true
	for player in _sfx_players:
		player.stream_paused = true
		
func resume_all_players() -> void:
	bg_music.stream_paused = false
	for player in _sfx_players:
		player.stream_paused = false

func stop_all_players() -> void:
	bg_music.stop()
	for player in _sfx_players:
		player.stop()