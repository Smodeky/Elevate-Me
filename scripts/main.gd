extends Node3D

@onready var main_camera: Camera3D = $main_camera
@onready var start_camera: Camera3D = $start_game_camera
@onready var start_button: Button = $start
@onready var anim_player: AnimationPlayer = $start_game_camera/AnimationPlayer
@onready var lift_button_anim: AnimationPlayer = $assets/outside/btn_start_game/AnimationPlayer
@onready var corridor_light: OmniLight3D = $lights/outside
@onready var outside: Node3D = $assets/outside
@onready var elevator_music: AudioStreamPlayer3D = $audio/ElevatorMusic
@onready var corridor_music: AudioStreamPlayer3D = $audio/CorridorMusic
@onready var quit: Button = $quit

@onready var red_light: OmniLight3D = $assets/outside/red_elev_btn/OmniLight3D
@onready var inside: OmniLight3D = $lights/inside
@onready var inside_2: OmniLight3D = $lights/inside2
@onready var elevator_break_sound: AudioStreamPlayer3D = $audio/ElevatorBreak
@onready var monster_laugh: AudioStreamPlayer3D = $assets/elev2/AudioStreamPlayer3D
@onready var monster: Node3D = $assets/elev2/monster
@onready var anim_monster: AnimationPlayer = $assets/elev2/monster/AnimationPlayer

@onready var podskazulka: Label3D = $assets/elev/panel/podskazulka
@onready var task_text: Label = $CanvasLayer/VBoxContainer/TaskText
@onready var input_text: Label = $CanvasLayer/VBoxContainer/InputText

@onready var btn_click: AudioStreamPlayer3D = $audio/BtnClick
@onready var elevator_start: AudioStreamPlayer3D = $audio/ElevatorStart
@onready var dzin_start: AudioStreamPlayer3D = $audio/Dzin_start
@onready var elev_running: AudioStreamPlayer3D = $audio/Elev_running
@onready var tabletka: Label = $tabletka

@onready var btn_call: StaticBody3D = $assets/btns/btn_call
@onready var floor_buttons := [
	$assets/btns/btn_1, $assets/btns/btn_2, $assets/btns/btn_3, $assets/btns/btn_4, $assets/btns/btn_5, $assets/btns/btn_6, $assets/btns/btn_7, $assets/btns/btn_8, $assets/btns/btn_9
]

var player_input: String = ""
var correct_answer: String = "4"  
var current_task: String = "2 + 2"
var task_active: bool = false
var current_stage: int = 1

func _ready() -> void:
	main_camera.current = false
	start_camera.current = true
	start_button.visible = true
	inside.visible = true
	inside_2.visible = true
	monster.visible = false
	red_light.visible = false
	tabletka.visible = false
	podskazulka.visible = false

	corridor_music.volume_db = 0.0
	corridor_music.play()
	
	for i in range(1, 10):
		var btn_path = "assets/btns/btn_%d" % i
		var btn = get_node(btn_path)
		if btn and not btn.is_connected("input_event", Callable(self, "_on_floor_button_pressed")):
			btn.connect("input_event", Callable(self, "_on_floor_button_pressed").bind(i))

	var btn_call = get_node("assets/btns/btn_call")
	if btn_call and not btn_call.is_connected("input_event", Callable(self, "_on_call_pressed")):
		btn_call.connect("input_event", Callable(self, "_on_call_pressed"))

func _start_task(text: String, answer: String):
	current_task = text
	correct_answer = answer
	player_input = ""
	task_text.text = text
	input_text.text = "Your answer: "
	task_active = true  

func _on_floor_button_pressed(camera, event, position, normal, shape_idx, floor_number):
	if not task_active:
		return
	
	if event is InputEventMouseButton and event.pressed:
		player_input += str(floor_number)
		input_text.text = "Your answer: " + player_input

func _on_call_pressed(camera, event, position, normal, shape_idx):
	if not task_active:
		return

	if player_input == "":
		return

	if event is InputEventMouseButton and event.pressed:
		_check_answer()

func _generate_random_task() -> void:
	var a = randi_range(1, 9)
	var b = randi_range(1, 9)
	while (a + b) % 10 == 0:
		b = randi_range(1, 9)
	current_task = str(a) + " + " + str(b)
	correct_answer = str(a + b)

func _check_answer():
	if player_input == correct_answer:
		_on_correct_answer()
	else:
		_on_wrong_answer()

func _on_correct_answer():
	task_text.text = "Correct!"
	input_text.text = ""
	task_active = false
	
	await get_tree().create_timer(3.0).timeout
	podskazulka.visible = false
	elevator_music.stop()
	elevator_break_sound.play()
	
	await get_tree().create_timer(1.0)
	elev_running.play()
	$lights/AnimationPlayer.play("light_move")
	inside.visible = false
	inside_2.visible = false
	task_text.text = "Floor " + str(current_stage + 1)
	
	await get_tree().create_timer(3.0).timeout
	podskazulka.visible = true
	elevator_start.play()
	elevator_music.play()
	inside.visible = true
	inside_2.visible = true

	current_stage += 1
	await get_tree().create_timer(1.0).timeout
	_next_task()

func _on_wrong_answer():
	task_text.text = "Wrong!"
	input_text.text = ""
	player_input = ""  
	task_active = false
	elevator_break_sound.play()
	podskazulka.visible = false
	inside.visible = false
	inside_2.visible = false
	
	$audio/loh.play()
	await get_tree().create_timer(3.0).timeout
	
	elevator_start.play()
	inside.visible = true
	inside_2.visible = true
	podskazulka.visible = true

	task_text.text = current_task
	input_text.text = "Your answer: "
	task_active = true

func _next_task():
	match current_stage:
		2:
			_generate_random_task()
			_start_task(current_task, correct_answer)
		3:
			_start_task("Ты выиграл!", "0")
			input_text.visible = false
			task_active = false
			podskazulka.visible = false
			$audio/WinSound.play()
			await get_tree().create_timer(3.0).timeout
			elevator_music.stop()
			$audio/winsong.play()
			

func _on_button_pressed() -> void:
	start_button.visible = false
	quit.visible = false
	await get_tree().create_timer(1.0).timeout
	lift_button_anim.play("btn_str_g")
	btn_click.play()
	
	await get_tree().create_timer(0.25).timeout
	red_light.visible = true
	await get_tree().create_timer(3.0).timeout
	dzin_start.play()
	
	await get_tree().create_timer(3.0).timeout
	
	_crossfade_music(corridor_music, elevator_music, 3)
	
	start_button.visible = false
	anim_player.play("start_camera")
	anim_player.animation_finished.connect(_on_camera_fly_finished)
	await get_tree().create_timer(3.0).timeout
	red_light.visible = false

func _on_camera_fly_finished(anim_name: String):
	if anim_name == "start_camera":
		corridor_light.visible = false
		outside.visible = false
		main_camera.current = true
		start_camera.current = false
		tabletka.visible = true
		
		
		await get_tree().create_timer(5.0).timeout
		tabletka.visible = false
		_start_elevator_break_sequence()

func _crossfade_music(from_music: AudioStreamPlayer3D, to_music: AudioStreamPlayer3D, duration: float):
	to_music.volume_db = -80.0
	to_music.play()
	var tween = get_tree().create_tween()
	tween.tween_property(from_music, "volume_db", -80.0, duration)
	tween.tween_property(to_music, "volume_db", -10.0, duration)

func _start_elevator_break_sequence() -> void:
	elevator_break_sound.play()
	inside.visible = false
	inside_2.visible = false
	elevator_music.stop()
	
	
	await get_tree().create_timer(1.0).timeout
	_play_monster_laugh()

func _play_monster_laugh() -> void:
	monster_laugh.play()
	
	await get_tree().create_timer(monster_laugh.stream.get_length()).timeout
	_show_monster()

func _show_monster() -> void:
	inside.visible = true
	inside_2.visible = true
	monster.visible = true
	podskazulka.visible = true
	elevator_start.play()
	anim_monster.play("Armature|mixamo_com|Layer0")
	await get_tree().create_timer(1.0).timeout
	elevator_music.play()
	$audio/SubaBratik.play()
	
	await get_tree().create_timer(2.0).timeout
	
	_generate_random_task()
	_start_task(current_task, correct_answer)


func _on_quit_pressed() -> void:
	get_tree().quit()
