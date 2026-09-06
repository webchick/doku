extends GridContainer

# "columns" is a reserved word; wrap it with board concept.
@export var board_rows: int = 4
@export var board_columns: int = 4

var cell_scene = preload("res://cell.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	columns = board_columns

	# Fill rows x columns with Cells.
	for row in range(board_rows):
		for column in range(board_columns):
			var cell = cell_scene.instantiate()
			add_child(cell)
