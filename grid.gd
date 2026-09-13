extends Node2D
class_name Grid

const GRID_SIZE: Vector2i = Vector2i(10,20)

signal on_lines_cleared(lines: int)

var grid: Array[Array] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialize_grid()
	clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW

func _draw() -> void:
	for y in range(GRID_SIZE.y):
		for x in range(GRID_SIZE.x):
			var texture: Texture2D = Piece.TEXTURE_DICT[grid[y][x]]
			draw_texture(texture, Vector2(x, y) * Piece.BLOCK_SIZE)
				

func initialize_grid() -> void:
	for i in range(GRID_SIZE.y):
		var row: Array = []
		for j in range(GRID_SIZE.x):
			row.append(Piece.PieceType.None)
		grid.append(row)
		
func reset_grid() -> void:
	grid.clear()
	initialize_grid()
	queue_redraw()
		
			
func can_place(projected_shape: Array[Vector2i]) -> bool:
	for cell in projected_shape:
		# Bounds check
		if cell.x < 0 or cell.x >= GRID_SIZE.x or cell.y >= GRID_SIZE.y:
			return false
		if cell.y < 0:
			continue
		
		# Occupancy check
		if grid[cell.y][cell.x] != Piece.PieceType.None:
			return false
	return true
	
func occupy_cells(shape_cells: Array[Vector2i], t: Piece.PieceType) -> void:
	for cell in shape_cells:
		if cell.y < 0:
			continue
		grid[cell.y][cell.x] = t
	queue_redraw()
	
func is_row_full(y: int) -> bool:
	var full: bool = true
	for x in range(GRID_SIZE.x):
		if grid[y][x] == Piece.PieceType.None:
			full = false
	return full
	
func clear_row(y: int) -> void:
	for x in range(GRID_SIZE.x):
		grid[y][x] = Piece.PieceType.None
	queue_redraw()
	
func get_full_row_indices() -> Array[int]:
	var result: Array[int] = []
	for y in range(GRID_SIZE.y):
		if is_row_full(y):
			result.append(y)
	return result
	
func handle_full_rows() -> void:
	var full_rows: Array[int] = get_full_row_indices()
	var full_rows_count: int = full_rows.size()
	for y in full_rows:
		clear_row(y)
	if full_rows_count > 0:
		on_lines_cleared.emit(full_rows_count)
	shift_blocks_down(full_rows)

func shift_blocks_down(cleared_row_indices: Array[int]) -> void:
	for y in cleared_row_indices:
		var row: Array = grid.pop_at(y)
		grid.insert(0, row)
	queue_redraw()		
		
	
