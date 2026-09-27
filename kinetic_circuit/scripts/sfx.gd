extends Node

const SAMPLE_RATE := 32000
const MASTER_SFX_VOLUME_DB := -10.0
const MUSIC_VOLUME_DB := -24.0
const CLOCK_AMBIENCE_VOLUME_DB := -34.0
const MUSIC_LOOP_DURATION := 8.0
const CLOCK_LOOP_DURATION := 2.0
const MUSIC_CHORDS := [
	[146.83, 174.61, 220.0, 293.66],
	[116.54, 146.83, 174.61, 220.0],
	[130.81, 164.81, 196.0, 261.63],
	[110.0, 138.59, 164.81, 220.0],
]
const MUSIC_BASS := [73.42, 58.27, 65.41, 55.0]
const MUSIC_ARP_PATTERN := [0, 2, 1, 3, 2, 1, 3, 2]
const MUSIC_MELODY := [
	293.66, 349.23, 440.0, 349.23,
	293.66, 261.63, 220.0, -1.0,
	261.63, 329.63, 392.0, 329.63,
	277.18, 329.63, 440.0, -1.0,
]
const SOUND_VOLUMES := {
	"jump": -7.0,
	"bounce": -5.5,
	"dash": -6.0,
	"hit": -5.0,
	"attack_hit": -3.5,
	"death": -5.5,
	"checkpoint": -6.5,
	"win": -6.0,
	"shoot": -7.0,
	"reflect": -4.5,
	"double_jump": -6.0,
	"powerup": -5.5,
	"boss_down": -4.0,
	"gate_open": -6.0,
	"windup": -10.0,
}
const SOUND_PITCH_VARIATION := {
	"jump": 0.025,
	"bounce": 0.02,
	"dash": 0.018,
	"hit": 0.045,
	"attack_hit": 0.035,
	"death": 0.015,
	"checkpoint": 0.0,
	"win": 0.0,
	"shoot": 0.025,
	"reflect": 0.02,
	"double_jump": 0.018,
	"powerup": 0.0,
	"boss_down": 0.0,
	"gate_open": 0.0,
	"windup": 0.0,
}

var samples: Dictionary = {}
var music_stream: AudioStreamWAV
var clock_stream: AudioStreamWAV
var music_player: AudioStreamPlayer
var clock_player: AudioStreamPlayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	samples["jump"] = _make_jump()
	samples["bounce"] = _make_bounce()
	samples["dash"] = _make_dash()
	samples["hit"] = _make_hit()
	samples["attack_hit"] = _make_attack_hit()
	samples["death"] = _make_death()
	samples["checkpoint"] = _make_checkpoint()
	samples["win"] = _make_win()
	samples["shoot"] = _make_shoot()
	samples["reflect"] = _make_reflect()
	samples["double_jump"] = _make_double_jump()
	samples["powerup"] = _make_powerup()
	samples["boss_down"] = _make_boss_down()
	samples["gate_open"] = _make_gate_open()
	samples["windup"] = _make_windup()
	music_stream = _make_clockwork_music()
	clock_stream = _make_clock_ambience()
	music_player = _loop_player("ClockworkMusic", music_stream, MUSIC_VOLUME_DB)
	clock_player = _loop_player("ClockAmbience", clock_stream, CLOCK_AMBIENCE_VOLUME_DB)

func _exit_tree() -> void:
	if is_instance_valid(music_player):
		music_player.stop()
	if is_instance_valid(clock_player):
		clock_player.stop()

func play(kind: String) -> void:
	if not samples.has(kind):
		return
	var player := AudioStreamPlayer.new()
	player.stream = samples[kind]
	player.volume_db = float(SOUND_VOLUMES.get(kind, -7.0)) + MASTER_SFX_VOLUME_DB
	var variation := float(SOUND_PITCH_VARIATION.get(kind, 0.0))
	player.pitch_scale = 1.0 + randf_range(-variation, variation)
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()

func _loop_player(node_name: String, stream: AudioStreamWAV, volume: float) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.name = node_name
	player.stream = stream
	player.volume_db = volume
	add_child(player)
	player.play()
	return player

func _make_jump() -> AudioStreamWAV:
	var duration := 0.15
	return _render(duration, func(time: float, progress: float, index: int) -> float:
		var envelope := _envelope(progress, 0.035, 1.8)
		var lift := _chirp(time, duration, 285.0, 690.0)
		var shimmer := _chirp(time, duration, 570.0, 1020.0) * 0.22
		var air := _noise(index, 11) * exp(-time * 38.0) * 0.12
		return (lift * 0.55 + shimmer + air) * envelope
	)

func _make_bounce() -> AudioStreamWAV:
	var duration := 0.22
	return _render(duration, func(time: float, progress: float, _index: int) -> float:
		var envelope := _envelope(progress, 0.018, 2.0)
		var spring := _chirp(time, duration, 430.0, 860.0)
		var overtone := _chirp(time, duration, 860.0, 1180.0) * 0.25
		var second_ping := _note(time, 0.055, 0.15, 980.0, 2.6) * 0.28
		return (spring * 0.48 + overtone + second_ping) * envelope
	)

func _make_dash() -> AudioStreamWAV:
	var duration := 0.19
	return _render(duration, func(time: float, progress: float, index: int) -> float:
		var motion_envelope := sin(PI * progress) * pow(1.0 - progress, 0.35)
		var rise := _chirp(time, duration, 190.0, 1250.0) * 0.34
		var high_rise := _chirp(time, duration, 760.0, 1840.0) * 0.16
		var whoosh := _noise(index, 29) * (0.22 + 0.18 * sin(TAU * 22.0 * time))
		return (rise + high_rise + whoosh) * motion_envelope
	)

func _make_hit() -> AudioStreamWAV:
	var duration := 0.18
	return _render(duration, func(time: float, progress: float, index: int) -> float:
		var body := _chirp(time, duration, 145.0, 62.0) * pow(1.0 - progress, 2.4) * 0.58
		var knock := signf(_chirp(time, duration, 235.0, 165.0)) * exp(-time * 24.0) * 0.2
		var impact_noise := _noise(index, 47) * exp(-time * 58.0) * 0.34
		var metal := sin(TAU * 510.0 * time) * exp(-time * 19.0) * 0.16
		return body + knock + impact_noise + metal
	)

func _make_attack_hit() -> AudioStreamWAV:
	var duration := 0.21
	return _render(duration, func(time: float, progress: float, index: int) -> float:
		var body_envelope := pow(1.0 - progress, 2.1)
		var low_crack := signf(_chirp(time, duration, 205.0, 118.0)) * body_envelope * 0.34
		var blade_ring := _chirp(time, duration, 680.0, 920.0) * exp(-time * 13.0) * 0.28
		var high_ring := sin(TAU * 1380.0 * time) * exp(-time * 20.0) * 0.12
		var transient := _noise(index, 71) * exp(-time * 82.0) * 0.42
		return low_crack + blade_ring + high_ring + transient
	)

func _make_death() -> AudioStreamWAV:
	var duration := 0.46
	return _render(duration, func(time: float, progress: float, index: int) -> float:
		var envelope := _envelope(progress, 0.012, 1.45)
		var fall := _chirp(time, duration, 255.0, 58.0) * 0.44
		var low_fall := _chirp(time, duration, 128.0, 38.0) * 0.34
		var crumble := _noise(index, 97) * pow(1.0 - progress, 2.8) * 0.2
		return (fall + low_fall + crumble) * envelope
	)

func _make_checkpoint() -> AudioStreamWAV:
	var duration := 0.48
	return _render(duration, func(time: float, _progress: float, _index: int) -> float:
		return (
			_bell_note(time, 0.0, 0.27, 523.25) * 0.42
			+ _bell_note(time, 0.09, 0.28, 659.25) * 0.38
			+ _bell_note(time, 0.18, 0.30, 783.99) * 0.4
		)
	)

func _make_win() -> AudioStreamWAV:
	var duration := 0.82
	return _render(duration, func(time: float, _progress: float, _index: int) -> float:
		var melody := (
			_bell_note(time, 0.0, 0.32, 523.25) * 0.32
			+ _bell_note(time, 0.12, 0.34, 659.25) * 0.32
			+ _bell_note(time, 0.24, 0.36, 783.99) * 0.34
			+ _bell_note(time, 0.39, 0.43, 1046.5) * 0.42
		)
		var final_chord := (
			_note(time, 0.41, 0.4, 523.25, 1.7)
			+ _note(time, 0.41, 0.4, 659.25, 1.7)
			+ _note(time, 0.41, 0.4, 783.99, 1.7)
		) * 0.08
		return melody + final_chord
	)

func _make_shoot() -> AudioStreamWAV:
	var duration := 0.14
	return _render(duration, func(time: float, progress: float, index: int) -> float:
		var envelope := _envelope(progress, 0.02, 2.0)
		var snap := _chirp(time, duration, 980.0, 260.0) * 0.42
		var pulse := signf(_chirp(time, duration, 310.0, 180.0)) * 0.14
		var spark := _noise(index, 131) * exp(-time * 55.0) * 0.16
		return (snap + pulse + spark) * envelope
	)

func _make_windup() -> AudioStreamWAV:
	var duration := 0.28
	return _render(duration, func(time: float, progress: float, _index: int) -> float:
		var rise := _chirp(time, duration, 160.0, 390.0) * 0.22
		var teeth := sin(TAU * 24.0 * time) * 0.09
		return (rise + teeth) * sin(PI * progress)
	)

func _make_reflect() -> AudioStreamWAV:
	var duration := 0.2
	return _render(duration, func(time: float, progress: float, index: int) -> float:
		var envelope := _envelope(progress, 0.012, 2.4)
		var ping := _chirp(time, duration, 720.0, 1320.0) * 0.46
		var ring := sin(TAU * 1740.0 * time) * exp(-time * 17.0) * 0.2
		var spark := _noise(index, 149) * exp(-time * 85.0) * 0.18
		return (ping + ring + spark) * envelope
	)

func _make_double_jump() -> AudioStreamWAV:
	var duration := 0.24
	return _render(duration, func(time: float, progress: float, index: int) -> float:
		var envelope := _envelope(progress, 0.025, 2.2)
		var lift := _chirp(time, duration, 420.0, 1180.0) * 0.38
		var second_lift := _chirp(time, duration, 690.0, 1560.0) * 0.22
		var wing := _noise(index, 307) * sin(PI * progress) * 0.13
		return (lift + second_lift + wing) * envelope
	)

func _make_powerup() -> AudioStreamWAV:
	var duration := 0.72
	return _render(duration, func(time: float, _progress: float, index: int) -> float:
		var phrase := (
			_bell_note(time, 0.0, 0.32, 440.0) * 0.3
			+ _bell_note(time, 0.11, 0.38, 659.25) * 0.35
			+ _bell_note(time, 0.24, 0.44, 880.0) * 0.42
		)
		var shimmer := _noise(index, 331) * sin(PI * clampf(time / duration, 0.0, 1.0)) * 0.035
		return phrase + shimmer
	)

func _make_boss_down() -> AudioStreamWAV:
	var duration := 0.9
	return _render(duration, func(time: float, progress: float, index: int) -> float:
		var fall := _chirp(time, duration, 230.0, 32.0) * pow(1.0 - progress, 1.25) * 0.38
		var impact := _noise(index, 359) * exp(-time * 9.0) * 0.2
		var bell := _bell_note(time, 0.28, 0.58, 110.0) * 0.35
		return fall + impact + bell
	)

func _make_gate_open() -> AudioStreamWAV:
	var duration := 0.68
	return _render(duration, func(time: float, progress: float, index: int) -> float:
		var mechanism := _noise(index, 383) * sin(PI * progress) * 0.12
		var motor := _chirp(time, duration, 74.0, 132.0) * sin(PI * progress) * 0.28
		var release := _bell_note(time, 0.38, 0.28, 523.25) * 0.32
		return mechanism + motor + release
	)

func _make_clockwork_music() -> AudioStreamWAV:
	var stream := _render(MUSIC_LOOP_DURATION, func(time: float, _progress: float, index: int) -> float:
		var chord_index := int(time / 2.0) % MUSIC_CHORDS.size()
		var chord: Array = MUSIC_CHORDS[chord_index]
		var chord_time := fmod(time, 2.0)
		var chord_envelope := sin(PI * clampf(chord_time / 2.0, 0.0, 1.0))
		var pad := 0.0
		for note_index in 3:
			pad += sin(TAU * float(chord[note_index]) * time + note_index * 0.7)
		pad *= chord_envelope * 0.035

		var eighth_time := fmod(time, 0.25)
		var eighth_index := int(time / 0.25)
		var arp_note := float(chord[MUSIC_ARP_PATTERN[eighth_index % MUSIC_ARP_PATTERN.size()]]) * 2.0
		var arpeggio := _music_pluck(eighth_time, 0.235, arp_note, 3.4) * 0.12

		var beat_time := fmod(time, 0.5)
		var bass := _music_bass(beat_time, float(MUSIC_BASS[chord_index])) * 0.15
		var melody_frequency := float(MUSIC_MELODY[int(time / 0.5) % MUSIC_MELODY.size()])
		var melody := 0.0 if melody_frequency < 0.0 else _music_pluck(beat_time, 0.42, melody_frequency, 2.2) * 0.11

		var measure_beat := fmod(time, 1.0)
		var kick := 0.0
		if measure_beat < 0.16:
			var kick_progress := measure_beat / 0.16
			kick = sin(TAU * (76.0 - kick_progress * 34.0) * measure_beat) * pow(1.0 - kick_progress, 2.5) * 0.16
		var offbeat := fmod(time + 0.25, 0.5)
		var metal_hat := _noise(index, 211) * exp(-offbeat * 42.0) * 0.035 if offbeat < 0.11 else 0.0
		return pad + arpeggio + bass + melody + kick + metal_hat
	)
	_set_loop(stream)
	return stream

func _make_clock_ambience() -> AudioStreamWAV:
	var stream := _render(CLOCK_LOOP_DURATION, func(time: float, _progress: float, index: int) -> float:
		var beat := int(time / 0.5)
		var local_time := fmod(time, 0.5)
		if local_time >= 0.075:
			return 0.0
		var progress := local_time / 0.075
		var frequency := 1480.0 if beat % 2 == 0 else 1040.0
		var wood := signf(sin(TAU * frequency * local_time)) * pow(1.0 - progress, 4.0) * 0.24
		var ring := sin(TAU * frequency * 1.48 * local_time) * exp(-local_time * 48.0) * 0.11
		var mechanism := _noise(index, 257 + beat) * exp(-local_time * 70.0) * 0.06
		return wood + ring + mechanism
	)
	_set_loop(stream)
	return stream

func _set_loop(stream: AudioStreamWAV) -> void:
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = stream.data.size() / 2

func _music_pluck(local_time: float, duration: float, frequency: float, release_power: float) -> float:
	if local_time < 0.0 or local_time >= duration:
		return 0.0
	var progress := local_time / duration
	var envelope := _envelope(progress, 0.035, release_power)
	var fundamental := sin(TAU * frequency * local_time)
	var bright_partial := sin(TAU * frequency * 2.01 * local_time) * 0.22
	return (fundamental + bright_partial) * envelope

func _music_bass(local_time: float, frequency: float) -> float:
	if local_time >= 0.44:
		return 0.0
	var progress := local_time / 0.44
	var envelope := _envelope(progress, 0.025, 1.5)
	var fundamental := sin(TAU * frequency * local_time)
	var harmonic := sin(TAU * frequency * 2.0 * local_time) * 0.24
	return (fundamental + harmonic) * envelope

func _render(duration: float, sampler: Callable) -> AudioStreamWAV:
	var count := int(duration * SAMPLE_RATE)
	var data := PackedByteArray()
	data.resize(count * 2)
	for i in count:
		var time := float(i) / float(SAMPLE_RATE)
		var progress := float(i) / float(count)
		var value := clampf(float(sampler.call(time, progress, i)), -1.0, 1.0)
		var sample := int(value * 32767.0)
		data[i * 2] = sample & 0xff
		data[i * 2 + 1] = (sample >> 8) & 0xff
	var sound := AudioStreamWAV.new()
	sound.format = AudioStreamWAV.FORMAT_16_BITS
	sound.mix_rate = SAMPLE_RATE
	sound.stereo = false
	sound.data = data
	return sound

func _chirp(time: float, duration: float, start_frequency: float, end_frequency: float) -> float:
	var sweep_rate := (end_frequency - start_frequency) / duration
	var phase := start_frequency * time + 0.5 * sweep_rate * time * time
	return sin(TAU * phase)

func _note(time: float, start: float, duration: float, frequency: float, release_power: float) -> float:
	if time < start or time >= start + duration:
		return 0.0
	var local_time := time - start
	var progress := local_time / duration
	return sin(TAU * frequency * local_time) * _envelope(progress, 0.025, release_power)

func _bell_note(time: float, start: float, duration: float, frequency: float) -> float:
	if time < start or time >= start + duration:
		return 0.0
	var local_time := time - start
	var progress := local_time / duration
	var envelope := _envelope(progress, 0.018, 2.2)
	var fundamental := sin(TAU * frequency * local_time)
	var first_partial := sin(TAU * frequency * 2.01 * local_time) * 0.28
	var second_partial := sin(TAU * frequency * 3.98 * local_time) * 0.1
	return (fundamental + first_partial + second_partial) * envelope

func _envelope(progress: float, attack: float, release_power: float) -> float:
	var attack_gain := minf(progress / attack, 1.0) if attack > 0.0 else 1.0
	return attack_gain * pow(maxf(0.0, 1.0 - progress), release_power)

func _noise(index: int, salt: int) -> float:
	var value := sin(float(index * 15731 + salt * 789221)) * 43758.5453
	return fposmod(value, 2.0) - 1.0
