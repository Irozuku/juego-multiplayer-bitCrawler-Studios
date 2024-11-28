extends AudioStreamPlayer

const MAIN_MENU = preload("res://resources/music/main_menu.ogg")
const GAMEPLAY = preload("res://resources/music/gameplay.ogg")
const VICTORY = preload("res://resources/music/victory.ogg")

func _play_music(music, volume = 0.0):
	if stream == music:
		return
	
	stream = music
	volume_db = volume
	play()

func play_music_mainmenu():
	_play_music(MAIN_MENU)

func play_music_level():
	_play_music(GAMEPLAY)

func play_music_victory():
	_play_music(VICTORY)

func stop_music():
	return
