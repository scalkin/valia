extends Node

@onready var player = $AudioStreamPlayer

var current_track = 0
var prev_track = 0
var prev_track_category = 0
var position_in_last_track = 0.0
var monsters_on_screen = 0
var background_track_position = 0.0
var background_track = 4:
	set(value):
		background_track_position = 0.0

enum {
	HERO,
	BATTLE_1,
	BATTLE_2,
	BATTLE_3,
	PRAIRIE,
	TRIUMPH,
}

enum {
	RANDOM_BATTLE
}

var music = [
	load("res://music/BGM01hero.wav"),
	load("res://music/BGM07battle4.wav"),
	load("res://music/OLDBGM07battle6.wav"),
	load("res://music/BGM07battle2.wav"),
	load("res://music/BGM03prairie.wav"),
	load("res://music/MS01triumph3NL.wav"),
]

func _ready():
	transition_audio(background_track, false)

func transition_audio(track, is_category):
	if current_track == TRIUMPH and player.playing:
		return
	if current_track == background_track:
		background_track_position = player.get_playback_position()
	#if we have a category and not a specific track, decide a track from the category
	if is_category:
		match track:
			RANDOM_BATTLE:
				track = randi_range(1, 3)
	
	position_in_last_track = player.get_playback_position()
	player.stream = music[track]
	if track == background_track:
		player.play(background_track_position)
		current_track = track
		return
	player.play()
	current_track = track
	
func peaceful_track():
	transition_audio(background_track, false)

func update_mosters(value):
	#if combat state hasn't changed, don't change the music
	if monsters_on_screen > 0 and value > 0:
		return
	monsters_on_screen = value
	
	#if there are now monsters, play a battle track
	if monsters_on_screen > 0:
		transition_audio(RANDOM_BATTLE, true)
	else:
		#otherwise, play the background track
		transition_audio(background_track, false)

func monster_slain():
	if monsters_on_screen == 0:
		$Timer.start()


func _on_audio_stream_player_finished():
	transition_audio(background_track, false)


func _on_timer_timeout():
	transition_audio(TRIUMPH, false)
