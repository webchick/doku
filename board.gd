extends GridContainer

# "columns" is a reserved word; wrap it with board concept.
@export var board_rows: int = 4
@export var board_columns: int = 4

var board: Array = []
var cell_scene = preload("res://cell.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	columns = board_columns

	# Fill rows x columns with Cells.
	for row in range(board_rows):
		var row_data: Array = []

		for col in range(board_columns):
			var cell = cell_scene.instantiate()
			cell.state_changed.connect(_on_cell_state_changed)
			cell.grid_row = row
			cell.grid_col = col
			row_data.append(cell)
			add_child(cell)

		board.append(row_data)

func _on_cell_state_changed(cell):
	print(
		"Cell changed: ",
		cell.grid_row,
		",",
		cell.grid_col,
		" state=",
		cell.state
	)
