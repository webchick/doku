extends GridContainer

# GridContainer already has a built-in "columns" property.
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
	if cell.state == cell.CellState.YES:
		if has_row_or_column_conflict(cell):
			print("INVALID: another YES exists in this row / column")
	print(
		"Cell changed: ",
		cell.grid_row,
		",",
		cell.grid_col,
		" state=",
		cell.state
	)

func has_row_or_column_conflict(cell):

	# First, check for duplicate yeses in the same row.
	for col in range(board_columns):
		if board[cell.grid_row][col].state == cell.CellState.YES && col != cell.grid_col:
			return true

	# Next, check for duplicate yeses in the same column.
	for row in range(board_rows):
		if board[row][cell.grid_col].state == cell.CellState.YES && row != cell.grid_row:
			return true

	# If we get here, no conflict.
	return false
