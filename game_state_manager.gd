extends Node
class_name GameStateManager

enum GameState { MAIN_MENU, PLAYING, PAUSED, GAME_OVER }
	
signal state_changed(state: GameState)
signal score_changed(score: int)
signal lines_cleared(lines: int)
signal difficulty_changed(difficulty: float)
signal difficulty_progress_changed(difficulty_progress: float)

const MAX_DIFFICULTY: int = 10

@export var difficulty_scalar: float = 50.0

var _state: GameState = GameState.PLAYING
var _score: int = 0
var _lines_cleared: int = 0
var _difficulty: int = 1
var _difficulty_progress: float = 0.0

func reset_all() -> void:
	reset_score()
	reset_lines_cleared()
	reset_difficulty()
	reset_difficulty_progress()

func get_state() -> GameState:
	return _state

func set_state(s: GameState) -> void:
	_state = s
	state_changed.emit(s)
	
func toggle_pause() -> void:
	set_state(GameState.PAUSED if _state == GameState.PLAYING else GameState.PLAYING)
	
func get_score() -> int:
	return _score

func modify_score(amount: int) -> void:
	_score += amount
	score_changed.emit(_score)
	
func modify_score_by_lines_and_difficulty(lines: int) -> void:
	modify_score(lines * _difficulty * 100)
	
func reset_score() -> void:
	_score = 0
	score_changed.emit(_score)

func get_lines_cleared() -> int:
	return _lines_cleared

func modify_lines_cleared(amount: int) -> void:
	_lines_cleared += amount
	lines_cleared.emit(_lines_cleared)
	
func reset_lines_cleared() -> void:
	_lines_cleared = 0
	lines_cleared.emit(_lines_cleared)
	
func get_difficulty() -> int:
	return _difficulty

func reset_difficulty() -> void:
	_difficulty = 1
	difficulty_changed.emit(_difficulty)

func set_difficulty(d: int) -> void:
	_difficulty = d
	difficulty_changed.emit(d)
	
func increase_difficulty() -> void:
	if _difficulty < MAX_DIFFICULTY:
		_difficulty += 1
		difficulty_changed.emit(_difficulty)
	
func get_difficulty_progress() -> float:
	return _difficulty_progress

func reset_difficulty_progress() -> void:
	_difficulty_progress = 0.0
	difficulty_progress_changed.emit(0.0)

func set_difficulty_progress(d: float) -> void:
	_difficulty_progress = d
	difficulty_progress_changed.emit(d)
	
func increase_difficulty_progress_by_lines(amount: int) -> void:
	_difficulty_progress += amount * difficulty_scalar / _difficulty
	if _difficulty_progress >= 100.0:
		reset_difficulty_progress()
		increase_difficulty()
	difficulty_progress_changed.emit(_difficulty_progress)
	


	
