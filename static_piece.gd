extends Control

@export var piece: Piece.PieceType = Piece.PieceType.None:
	set(value):
		piece = value
		queue_redraw()

@onready var border: Sprite2D = $Border


func _draw() -> void:
	draw_piece_centered(piece)


# Draws the piece centered inside the border sprite. Does nothing for None.
func draw_piece_centered(t: Piece.PieceType) -> void:
	if t == Piece.PieceType.None:
		return

	var texture: Texture2D = Piece.TEXTURE_DICT[t]
	var shape: Array = Piece.PIECE_DICT[t]["shape"]

	var bounds: Dictionary = Piece.get_bounds(t)
	

	# A one-cell span is one cell wide, hence the +1.
	var size_in_cells: Vector2i = bounds.max_cell - bounds.min_cell + Vector2i.ONE
	var pixel_size: Vector2 = Vector2(size_in_cells) * Piece.BLOCK_SIZE

	# Border's rect is in its own local space, so shift it into ours.
	var panel_center: Vector2 = border.position + border.get_rect().get_center()
	var top_left: Vector2 = panel_center - pixel_size / 2.0

	# Re-base each cell against min_cell so the shape starts at (0,0).
	for cell in shape:
		draw_texture(texture, top_left + Vector2(cell - bounds.min_cell) * Piece.BLOCK_SIZE)
