extends Node
## Efek suara, musik latar, dan pembacaan teks (text-to-speech bawaan perangkat).

const DIR := "res://assets/audio/"
const SOUNDS := ["click", "pop", "correct", "wrong", "star", "win", "whoosh", "flip", "tick", "bonk", "chime"]
const MUSIC_DB := -12.0

var _pool: Array[AudioStreamPlayer] = []
var _streams := {}
var _music: AudioStreamPlayer
var _voice := ""
var _voice_checked := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for s: String in SOUNDS:
		var path := DIR + s + ".wav"
		if ResourceLoader.exists(path):
			_streams[s] = load(path)
	for i in 6:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_pool.append(p)
	_music = AudioStreamPlayer.new()
	_music.volume_db = MUSIC_DB
	var m: AudioStream = load(DIR + "music.ogg") if ResourceLoader.exists(DIR + "music.ogg") else null
	if m is AudioStreamOggVorbis:
		(m as AudioStreamOggVorbis).loop = true
	_music.stream = m
	add_child(_music)
	Game.settings_changed.connect(_apply_settings)
	_apply_settings()


func _apply_settings() -> void:
	if Game.setting("music"):
		if not _music.playing and _music.stream:
			_music.play()
	else:
		_music.stop()


func play(name: String, pitch: float = 1.0, volume_db: float = 0.0) -> void:
	if not Game.setting("sfx") or not _streams.has(name):
		return
	var player: AudioStreamPlayer = null
	for p in _pool:
		if not p.playing:
			player = p
			break
	if player == null:
		player = _pool[0]
	player.stream = _streams[name]
	player.pitch_scale = pitch
	player.volume_db = volume_db
	player.play()


## Kecilkan musik sementara (mis. saat suara bacaan aktif).
func duck(on: bool) -> void:
	if _music:
		var tw := create_tween()
		tw.tween_property(_music, "volume_db", MUSIC_DB - 14.0 if on else MUSIC_DB, 0.3)


func _notification(what: int) -> void:
	if not is_instance_valid(_music):
		return
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		_music.stream_paused = true
	elif what == NOTIFICATION_APPLICATION_RESUMED or what == NOTIFICATION_APPLICATION_FOCUS_IN:
		_music.stream_paused = false


# --- Suara bacaan (TTS) -----------------------------------------------------------
func can_speak() -> bool:
	if not _voice_checked:
		_voice_checked = true
		if OS.get_name() in ["Android", "iOS", "Windows", "macOS"] and DisplayServer.has_feature(DisplayServer.FEATURE_TEXT_TO_SPEECH):
			var voices := DisplayServer.tts_get_voices_for_language("id")
			if voices.size() > 0:
				_voice = voices[0]
	return _voice != ""


func speak(text: String) -> bool:
	if not can_speak():
		return false
	DisplayServer.tts_stop()
	DisplayServer.tts_speak(UI.plain(text), _voice, 80, 1.0, 0.95)
	return true


func stop_speaking() -> void:
	if _voice != "" and DisplayServer.has_feature(DisplayServer.FEATURE_TEXT_TO_SPEECH):
		DisplayServer.tts_stop()


func is_speaking() -> bool:
	return _voice != "" and DisplayServer.tts_is_speaking()
