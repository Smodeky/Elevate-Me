extends StaticBody3D

enum STATE{
	ON,
	OFF
}

@onready var state = STATE.OFF

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

signal on_state_changed

func get_interaction_text():
	if state == STATE.ON:
		return "to turn off"
	return "to turn on"

func interact():
	if anim_player.is_playing():
		return
	if state == STATE.ON:
		turn_off()
	else:
		turn_on()

func turn_on():
	if anim_player.is_playing():
		return
	if state == STATE.ON:
		return
	
	state = STATE.ON
	anim_player.play("btn_7")
	audio_player.play()
	
func turn_off():
	if anim_player.is_playing():
		return
	if state == STATE.OFF:
		return
	
	state = STATE.OFF
	anim_player.play("btn_7")
	audio_player.play()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if state == STATE.ON:
		emit_signal("on_state_changed", true)
	else:
		emit_signal("on_state_changed", false)
