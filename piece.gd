extends Node2D
class_name Piece

enum PieceType { None, I, O, T, S, Z, J, L }

@export var override_type: PieceType = PieceType.None
@export var block_count: int = 4

const BLOCK_SIZE: int = 32

const TEXTURE_DICT: Dictionary = {
	PieceType.None: preload("res://assets/UI/grid/grid.png"),
	PieceType.I: preload("res://assets/blocks/cyan_block.png"),
	PieceType.O: preload("res://assets/blocks/yellow_block.png"),
	PieceType.T: preload("res://assets/blocks/purple_block.png"),
	PieceType.S: preload("res://assets/blocks/green_block.png"),
	PieceType.Z: preload("res://assets/blocks/red_block.png"),
	PieceType.J: preload("res://assets/blocks/pink_block.png"),
	PieceType.L: preload("res://assets/blocks/blue_block.png")
}

const PIECE_DICT: Dictionary = {
	# Cells are offsets from the rotation pivot, which sits at this node's origin.
	# T/S/Z/J/L pivot on the center of a 3x3 box; I pivots on a cell; O does not rotate.
	# rotation_states: how many distinct orientations the piece has before repeating.
	PieceType.I: {
		"shape": [
			Vector2i(-1,0),
			Vector2i(0,0),
			Vector2i(1,0),
			Vector2i(2,0)
		],
		"rotation_states": 2,
	},
	PieceType.O: {
		"shape": [
			Vector2i(0,0),
			Vector2i(1,0),
			Vector2i(0,1),
			Vector2i(1,1)
		],
		"rotation_states": 1,
	},
	PieceType.T: {
		"shape": [
			Vector2i(-1,0),
			Vector2i(0,0),
			Vector2i(1,0),
			Vector2i(0,-1)
		],
		"rotation_states": 4,
	},
	PieceType.S: {
		"shape": [
			Vector2i(0,-1),
			Vector2i(1,-1),
			Vector2i(-1,0),
			Vector2i(0,0)
		],
		"rotation_states": 2,
	},
	PieceType.Z: {
		"shape": [
			Vector2i(-1,-1),
			Vector2i(0,-1),
			Vector2i(0,0),
			Vector2i(1,0)
		],
		"rotation_states": 2,
	},
	PieceType.J: {
		"shape": [
			Vector2i(-1,-1),
			Vector2i(-1,0),
			Vector2i(0,0),
			Vector2i(1,0)
		],
		"rotation_states": 4,
	},
	PieceType.L: {
		"shape": [
			Vector2i(1,-1),
			Vector2i(-1,0),
			Vector2i(0,0),
			Vector2i(1,0)
		],
		"rotation_states": 4,
	},
}

var block_refs: Array = []
var piece_type: PieceType = PieceType.None
var _rotation_index: int = 0
var current_shape: Array[Vector2i] = []
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if override_type != PieceType.None:
		set_type(override_type)
		
func get_rotation_index() -> int:
	return _rotation_index

func next_rotation_index() -> int:
	return (_rotation_index + 1) % PIECE_DICT[piece_type]["rotation_states"]

func set_type(t: PieceType) -> void:
	piece_type = t
	_rotation_index = 0
	for block in block_refs:
		block.queue_free()
	block_refs.clear()
	generate_shape(t)
	current_shape = get_rotated_shape(0)

func generate_shape(t: PieceType) -> void:
	var shape: Array = PIECE_DICT[t]["shape"]

	for i in range(shape.size()):
		var block: Sprite2D = Sprite2D.new()
		block.texture = TEXTURE_DICT[t]
		block.position = Vector2(shape[i].x * BLOCK_SIZE, shape[i].y * BLOCK_SIZE)
		block.visible = true
		block.centered = false
		block_refs.append(block)
		add_child(block)
		
func rotate_shape() -> void:
	_rotation_index = (_rotation_index + 1) % PIECE_DICT[piece_type]["rotation_states"]
	current_shape = get_rotated_shape(_rotation_index)
	update_block_locations()
	
func get_rotated_shape(rot: int) -> Array[Vector2i]:
	var shape: Array = PIECE_DICT[piece_type]["shape"]
	var new_shape: Array[Vector2i] = []
	new_shape.assign(shape)
	for i in range(shape.size()):
		for j in range(rot):
			new_shape[i] = Vector2i(new_shape[i].y, -new_shape[i].x)
	return new_shape

func set_rotation_index(index: int) -> void:
	_rotation_index = index
	current_shape = get_rotated_shape(index)
	update_block_locations()
	
func update_block_locations() -> void:
	for i in range(block_refs.size()):
		block_refs[i].position = current_shape[i] * BLOCK_SIZE
		
		
func cells_at(origin: Vector2i, rot: int) -> Array[Vector2i]:
	var projected_shape: Array[Vector2i] = []
	projected_shape = get_rotated_shape(rot)
	for i in range(projected_shape.size()):
		projected_shape[i] = Vector2i(projected_shape[i].x + origin.x, projected_shape[i].y + origin.y)
	return projected_shape
		
			
	

# Bounding box of the shape, in cells.
static func get_bounds(t: PieceType) -> Dictionary:
	var shape: Array = Piece.PIECE_DICT[t]["shape"]
	var min_cell: Vector2i = shape[0]
	var max_cell: Vector2i = shape[0]
	for cell in shape:
		min_cell.x = min(min_cell.x, cell.x)
		min_cell.y = min(min_cell.y, cell.y)
		max_cell.x = max(max_cell.x, cell.x)
		max_cell.y = max(max_cell.y, cell.y)
		
	return {
		"min_cell": min_cell,
		"max_cell": max_cell,
	}	
	