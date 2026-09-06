class_name PuzzleBoard

enum ConflictType {
	ROW,
	COLUMN,
	REGION,
	ADJACENT
}

var board: Array = []
var region_map: Array = []
var rows: int
var columns: int

func _init(p_rows: int, p_columns: int, regions: Array):
	rows = p_rows
	columns = p_columns
	region_map = regions

	for row in range(rows):
		var row_data: Array = []

		for col in range(columns):
			var cell = CellData.new()
			cell.grid_row = row
			cell.grid_col = col
			cell.region_id = region_map[row][col]

			row_data.append(cell)

		board.append(row_data)


# Only one yes per row.
func has_row_conflict(cell: CellData) -> bool:
	for col in range(columns):
		var other_cell = board[cell.grid_row][col]

		if (
			other_cell != cell
			and other_cell.state == CellData.CellState.YES
		):
			return true

	# If we make it down here, we're good.
	return false

# Only one yes per column.
func has_column_conflict(cell: CellData) -> bool:
	for row in range(rows):
		var other_cell = board[row][cell.grid_col]

		if (
			other_cell != cell
			and other_cell.state == CellData.CellState.YES
		):
			return true

	# If we make it down here, we're good.
	return false

# A yes can't touch any other yes.
func has_adjacent_conflict(cell: CellData) -> bool:
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
				or check_row >= rows
				or check_col < 0
				or check_col >= columns
			):
				continue

			# See if neighbouring cells are also yes.
			if board[check_row][check_col].state == CellData.CellState.YES:
				return true

	# If we make it down here, we're good.
	return false

# Also can't repeat a yes within the same regional boundary.
func has_region_conflict(cell: CellData) -> bool:
	for row in board:
		for other_cell in row:
			if (
				other_cell != cell
				and other_cell.region_id == cell.region_id
				and other_cell.state == CellData.CellState.YES
			):
				return true

	return false

func get_conflicts(cell: CellData) -> Array[ConflictType]:
	var conflicts: Array[ConflictType] = []

	# Only YES placements participate in these rules.
	if cell.state != CellData.CellState.YES:
		return conflicts

	if has_row_conflict(cell):
		conflicts.append(ConflictType.ROW)

	if has_column_conflict(cell):
		conflicts.append(ConflictType.COLUMN)

	if has_region_conflict(cell):
		conflicts.append(ConflictType.REGION)

	if has_adjacent_conflict(cell):
		conflicts.append(ConflictType.ADJACENT)

	return conflicts
