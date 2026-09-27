extends SceneTree

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var sfx: Node = (load("res://scripts/sfx.gd") as GDScript).new()
	root.add_child(sfx)
	await process_frame
	var expected := ["jump", "bounce", "dash", "hit", "attack_hit", "death", "checkpoint", "win", "shoot", "reflect", "double_jump", "powerup", "boss_down", "gate_open", "windup"]
	_check(sfx.samples.size() == expected.size(), "all fifteen gameplay sound cues are generated")
	_check(sfx.MASTER_SFX_VOLUME_DB <= -10.0, "the sound-effects mix uses the quieter global playback level")
	var durations: Dictionary = {}
	for kind in expected:
		var stream := sfx.samples.get(kind) as AudioStreamWAV
		_check(stream != null, "%s has a generated audio stream" % kind)
		if stream == null:
			continue
		_check(stream.mix_rate == sfx.SAMPLE_RATE and stream.format == AudioStreamWAV.FORMAT_16_BITS, "%s uses the full-rate 16-bit sound format" % kind)
		var duration := float(stream.data.size()) / 2.0 / float(stream.mix_rate)
		durations[snappedf(duration, 0.01)] = true
		var stats := _sample_stats(stream.data)
		_check(stats["peak"] > 0.15 and stats["rms"] > 0.025, "%s is audible (peak %.3f, rms %.3f)" % [kind, stats["peak"], stats["rms"]])
		_check(stats["clipped_ratio"] < 0.015, "%s avoids excessive clipping (%.2f%%)" % [kind, stats["clipped_ratio"] * 100.0])
	_check(durations.size() >= 6, "the sound set uses varied cue lengths rather than one repeated template")
	_check((sfx.samples["win"] as AudioStreamWAV).data.size() > (sfx.samples["checkpoint"] as AudioStreamWAV).data.size(), "the victory phrase is longer than the checkpoint cue")
	_check(sfx.music_stream != null and sfx.clock_stream != null, "the clockwork score and tick-tock ambience are generated")
	if sfx.music_stream != null and sfx.clock_stream != null:
		_check(sfx.music_stream.loop_mode == AudioStreamWAV.LOOP_FORWARD and sfx.clock_stream.loop_mode == AudioStreamWAV.LOOP_FORWARD, "both background layers loop continuously")
		var music_duration := float(sfx.music_stream.data.size()) / 2.0 / float(sfx.music_stream.mix_rate)
		var clock_duration := float(sfx.clock_stream.data.size()) / 2.0 / float(sfx.clock_stream.mix_rate)
		_check(is_equal_approx(music_duration, sfx.MUSIC_LOOP_DURATION) and is_equal_approx(clock_duration, sfx.CLOCK_LOOP_DURATION), "the score and clock use complete loop lengths")
		var music_stats := _sample_stats(sfx.music_stream.data)
		var clock_stats := _sample_stats(sfx.clock_stream.data)
		_check(music_stats["rms"] > 0.025 and music_stats["clipped_ratio"] < 0.015, "the layered music is audible and unclipped")
		_check(clock_stats["peak"] > 0.15 and clock_stats["clipped_ratio"] < 0.015, "the tick-tock layer is distinct and unclipped")
	_check(sfx.music_player != null and sfx.music_player.playing and sfx.clock_player != null and sfx.clock_player.playing, "both background layers begin playback")
	_check(sfx.CLOCK_AMBIENCE_VOLUME_DB < sfx.MUSIC_VOLUME_DB and sfx.MUSIC_VOLUME_DB < sfx.MASTER_SFX_VOLUME_DB, "tick-tock sits below music and music sits below gameplay effects")
	sfx.free()
	await process_frame
	if failures.is_empty():
		print("AUDIO PASS: fifteen gameplay cues, clock ambience, and layered looping music are audible, balanced, and unclipped")
		quit(0)
	else:
		for failure in failures:
			printerr("AUDIO FAIL: ", failure)
		quit(1)

func _sample_stats(data: PackedByteArray) -> Dictionary:
	var peak := 0.0
	var sum_squares := 0.0
	var clipped := 0
	var count := data.size() / 2
	for i in count:
		var encoded := int(data[i * 2]) | (int(data[i * 2 + 1]) << 8)
		var signed_sample := encoded - 65536 if encoded >= 32768 else encoded
		var value := absf(float(signed_sample) / 32767.0)
		peak = maxf(peak, value)
		sum_squares += value * value
		if value >= 0.999:
			clipped += 1
	return {
		"peak": peak,
		"rms": sqrt(sum_squares / float(count)),
		"clipped_ratio": float(clipped) / float(count),
	}

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
