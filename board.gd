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
		if has_adjacent_conflict(cell):
			print("INVALID: another YES exists too close by... NO TOUCHING.")
	print(
		"Cell changed: ",
		cell.grid_row,
		",",
		cell.grid_col,
		" state=",
		cell.state
	)

# Only one yes per row / column.
func has_row_or_column_conflict(cell) -> bool:

	# First, check for duplicate yeses in the same row.
	for col in range(board_columns):
		if board[cell.grid_row][col].state == cell.CellState.YES && col != cell.grid_col:
			return true

	# Next, check for duplicate yeses in the same column.
	for row in range(board_rows):
		if board[row][cell.grid_col].state == cell.CellState.YES && row != cell.grid_row:
			return true

	# If we make it down here, we're good.
	return false

# A yes can't touch any other yes.
func has_adjacent_conflict(cell) -> bool:
	for row_offset in range(-1, 2):
		for col_offset in range(-1, 2):

			# Skip the cell itself.
			if row_offset == 0 and col_offset == 0:
				continue

			var check_row = cell.grid_row + row_offset
			var check_col = cell.grid_col + col_offset
	
			# Check for out of range values.
			if (
				check_row < 0
				or check_row >= board_rows
				or check_col < 0
				or check_col >= board_columns
			):
				continue
	
			# See if neighbouring cells are also yes.
			if board[check_row][check_col].state == cell.CellState.YES:
				return true
	
	# If we make it down here, we're good.
	return false
