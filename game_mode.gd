extends Node

@onready var game_state_manager: GameStateManager = $GameStateManager
@onready var audio_manager: AudioManager = %AudioManager
@onready var grid: Grid = $Grid
@onready var hold: Control = $Hold
@onready var next: Control = $Next
@onready var lock_timer: Timer = $LockTimer

# UI Elements
@onready var difficulty_value_label: Label = %DifficultyValue
@onready var score_value_label: Label = %ScoreValue
@onready var lines_cleared_value_label: Label = %LinesValue
@onready var difficulty_bar: ProgressBar = %DifficultyBar
@onready var pause_menu: Control = $PauseMenu
@onready var main_menu: Control = $MainMenu

@export var force_shape: Piece.PieceType = Piece.PieceType.None

const SPAWN_LOCATION: Vector2i = Vector2i(5, 0)
const PIECE_SCENE: PackedScene = preload("res://piece.tscn")
const FALL_INTERVAL: float = 1

var current_piece: Piece = null
var held_piece_type: Piece.PieceType = Piece.PieceType.None
var _next_piece_type: Piece.PieceType = Piece.PieceType.None
var current_piece_cell_location: Vector2i = Vector2i(0, 0)
var _should_lock_piece: bool = false
var _was_piece_held: bool = false

var time_elapsed: float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_state_manager.set_state(GameStateManager.GameState.MAIN_MENU)
		
func start_game() -> void:
	grid.reset_grid()
	game_state_manager.reset_all()
	_was_piece_held = false
	held_piece_type = Piece.PieceType.None
	hold.set_piece(Piece.PieceType.None)
	_should_lock_piece = false
	spawn_piece(force_shape)

	# Set Random BG Music
	audio_manager.set_random_bgm()
	if game_state_manager.get_state() == GameStateManager.GameState.PLAYING:
		audio_manager.play_bgm()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if game_state_manager.get_state() == GameStateManager.GameState.PLAYING:
		time_elapsed += delta
		handle_falling()
	handle_input()

func handle_falling() -> void:
	if current_piece == null:
		return
	
	if _should_lock_piece:
		grid.occupy_cells(current_piece.cells_at(
				current_piece_cell_location,
				current_piece.get_rotation_index()),
				current_piece.piece_type
		)
		current_piece.queue_free()
		_should_lock_piece = false
		grid.handle_full_rows()
		spawn_piece(_next_piece_type)
		_was_piece_held = false
	
	if time_elapsed > (FALL_INTERVAL / game_state_manager.get_difficulty()):
		move_current_piece(Vector2(0, 1), false)
		time_elapsed = 0
		
func handle_input() -> void:
	if current_piece == null:
		return
	if game_state_manager.get_state() == GameStateManager.GameState.PLAYING:
		if Input.is_action_just_pressed("rotate_shape"):
			#collision check
			if grid.can_place(current_piece.cells_at(current_piece_cell_location, current_piece.next_rotation_index())):
				current_piece.rotate_shape()
				audio_manager.play_sfx(audio_manager.SFX.Rotation)
		if Input.is_action_just_pressed("left"):
			move_current_piece(Vector2(-1, 0))
		elif Input.is_action_just_pressed("right"):
			move_current_piece(Vector2(1, 0))
		elif Input.is_action_just_pressed("down"):
			drop_current_piece()
		elif Input.is_action_just_pressed("up"):
			swap_held_piece()
	if game_state_manager.get_state() != GameStateManager.GameState.MAIN_MENU and game_state_manager.get_state() != GameStateManager.GameState.GAME_OVER:
		if Input.is_action_just_pressed("pause"):
			game_state_manager.toggle_pause()
			
func move_current_piece(direction: Vector2i, should_play_sound = true) -> void:
	var projected_origin: Vector2i = current_piece_cell_location + direction
	if !grid.can_place(current_piece.cells_at(projected_origin, current_piece.get_rotation_index())):
		if direction == Vector2i.DOWN:
			if lock_timer.is_stopped():
				lock_timer.start()
		return
	
	current_piece.position += Vector2(direction) * Piece.BLOCK_SIZE
	current_piece_cell_location += direction
	
	if should_play_sound:
		audio_manager.play_sfx(audio_manager.SFX.Click)
	
	# Check if there's room below to stop the lock timer
	projected_origin = current_piece_cell_location + Vector2i.DOWN
	if grid.can_place(current_piece.cells_at(
			projected_origin,
			current_piece.get_rotation_index())
	):
		lock_timer.stop()
		
func drop_current_piece() -> void:
	# Play sfx
	audio_manager.play_sfx(audio_manager.SFX.Drop)
	while grid.can_place(current_piece.cells_at(current_piece_cell_location + Vector2i.DOWN, current_piece.get_rotation_index())):
		move_current_piece(Vector2i.DOWN)

func choose_piece_type() -> Piece.PieceType:
	return Piece.PieceType.values()[randi_range(1, Piece.PieceType.values().size() - 1)]

func spawn_piece(t: Piece.PieceType = Piece.PieceType.None, should_choose_next_piece = true) -> void:
	var piece: Piece = PIECE_SCENE.instantiate()
	piece.set_type(t if t != Piece.PieceType.None else choose_piece_type())
	piece.position = SPAWN_LOCATION * Piece.BLOCK_SIZE
	current_piece_cell_location = SPAWN_LOCATION
	if not grid.can_place(piece.cells_at(current_piece_cell_location, 0)):
		# Game Over
		game_state_manager.set_state(GameStateManager.GameState.GAME_OVER)
		piece.queue_free()
		return
	current_piece = piece
	grid.add_child(piece)
	lock_timer.stop()
	if should_choose_next_piece:
		_next_piece_type = choose_piece_type()
	next.piece = _next_piece_type

func swap_held_piece()	-> void:
	if _was_piece_held:
		audio_manager.play_sfx(audio_manager.SFX.NoHold)
		return
	var new_piece_type: Piece.PieceType = Piece.PieceType.None
	if held_piece_type == Piece.PieceType.None:
		held_piece_type = current_piece.piece_type
	else:
		new_piece_type = held_piece_type
		held_piece_type = current_piece.piece_type
	hold.piece = held_piece_type
	_was_piece_held = true
	current_piece.queue_free()
	spawn_piece(new_piece_type, false)
	
func toggle_pause_menu() -> void:
	pause_menu.visible = !pause_menu.visible

func _on_lock_timer_timeout() -> void:
	_should_lock_piece = true


func _on_game_state_manager_difficulty_changed(difficulty: float) -> void:
	difficulty_value_label.text = str(difficulty)

func _on_game_state_manager_lines_cleared(lines: int) -> void:
	lines_cleared_value_label.text = str(lines)

func _on_game_state_manager_score_changed(score: int) -> void:
	score_value_label.text = str(score)


func _on_game_state_manager_state_changed(state: int) -> void:
	match state:
		GameStateManager.GameState.MAIN_MENU:
			lock_timer.stop()
			pause_menu.visible = false
			main_menu.visible = true
			main_menu.set_main_menu()
		GameStateManager.GameState.PAUSED:
			pause_menu.visible = true
			lock_timer.paused = true
			audio_manager.pause_all_players()
		GameStateManager.GameState.PLAYING:
			lock_timer.paused = false
			audio_manager.resume_all_players()
			main_menu.visible = false
			pause_menu.visible = false
		GameStateManager.GameState.GAME_OVER:
			main_menu.set_game_over_menu()
			main_menu.visible = true
			lock_timer.stop()
			current_piece = null
			audio_manager.stop_all_players()
			audio_manager.play_bgm_track(audio_manager.BGM.Menu)
			

func _on_grid_on_lines_cleared(lines: int) -> void:
	game_state_manager.modify_lines_cleared(lines)
	game_state_manager.modify_score_by_lines_and_difficulty(lines)
	game_state_manager.increase_difficulty_progress_by_lines(lines)
	if lines > 0 and lines < 4:
		audio_manager.play_sfx(audio_manager.SFX.LineClear)
	elif lines == 4:
		audio_manager.play_sfx(audio_manager.SFX.TetrisClear)
	
func _on_game_state_manager_difficulty_progress_changed(difficulty_progress: float) -> void:
	difficulty_bar.value = difficulty_progress

func _on_main_menu_button_pressed() -> void:
	game_state_manager.set_state(GameStateManager.GameState.PLAYING)
	start_game()
