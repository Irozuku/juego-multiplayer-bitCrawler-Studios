extends AudioStreamPlayer

const menu_music = preload("res://resources/music/main_menu.ogg")

func _play_music(music, volume = 0.0):
	if stream == music:
		return
	
	stream = music
	volume_db = volume
	play()

func play_music_mainmenu():
	_play_music(menu_music, -5.0)

func play_music_level():
	_play_music(menu_music, -5.0)

func stop_music():
	return
