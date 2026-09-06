extends GridContainer

# GridContainer already has a built-in "columns" property.
@export var board_rows: int = 4
@export var board_columns: int = 4

enum ConflictType {
	ROW,
	COLUMN,
	REGION,
	ADJACENT
}

var board: Array = []
var cell_scene = preload("res://cell.tscn")
var region_map = [
	[0, 0, 1, 1],
	[0, 2, 2, 1],
	[3, 2, 2, 1],
	[3, 3, 3, 1]
]

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
			cell.region_id = region_map[row][col]
			row_data.append(cell)
			add_child(cell)

		board.append(row_data)

func _on_cell_state_changed(cell):
	update_validation(cell)

	print(
		"Cell changed: ",
		cell.grid_row,
		",",
		cell.grid_col,
		" state=",
		cell.state
	)

func get_conflicts(cell) -> Array[String]:
	var conflicts: Array[String] = []

	# Only YES placements participate in these rules.
	if cell.state != cell.CellState.YES:
		return conflicts

	if has_row_conflict(cell):
		conflicts.append("row")

	if has_column_conflict(cell):
		conflicts.append("column")

	if has_region_conflict(cell):
		conflicts.append("region")

	if has_adjacent_conflict(cell):
		conflicts.append("adjacent")

	return conflicts

# Only one yes per row.
func has_row_conflict(cell) -> bool:
	for col in range(board_columns):
		if board[cell.grid_row][col].state == cell.CellState.YES && col != cell.grid_col:
			return true

	# If we make it down here, we're good.
	return false

# Only one yes per column.
func has_column_conflict(cell) -> bool:
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

# Also can't repeat a yes within the same regional boundary.
func has_region_conflict(cell) -> bool:
	for row in board:
		for other_cell in row:
			if (
				other_cell != cell
				and other_cell.region_id == cell.region_id
				and other_cell.state == cell.CellState.YES
			):
				return true

	return false

# Each time a cell is clicked, indicate whether it's valid or not.
func update_validation(changed_cell):
	# The changed cell may become invalid OR become valid again.
	var conflicts = get_conflicts(changed_cell)
	changed_cell.is_invalid = conflicts.size() > 0
	changed_cell.update_display()

	# Previously-invalid cells may clear if their conflict disappeared.
	for row in board:
		for cell in row:
			if cell == changed_cell:
				continue

			if cell.is_invalid and get_conflicts(cell).is_empty():
				cell.is_invalid = false
				cell.update_display()
