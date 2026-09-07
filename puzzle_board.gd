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


# At most one YES per row. A row with zero YESes is still valid mid-play.
func is_row_valid(cell: CellData) -> bool:
	for col in range(columns):
		var other_cell = board[cell.grid_row][col]

		if (
			other_cell != cell
			and other_cell.state == CellData.CellState.YES
		):
			return false

	return true

# At most one YES per column.
func is_column_valid(cell: CellData) -> bool:
	for row in range(rows):
		var other_cell = board[row][cell.grid_col]

		if (
			other_cell != cell
			and other_cell.state == CellData.CellState.YES
		):
			return false

	return true

# A YES can't touch any other YES.
func is_adjacency_valid(cell: CellData) -> bool:
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
				return false

	return true

# At most one YES within the same regional boundary.
func is_region_valid(cell: CellData) -> bool:
	for row in board:
		for other_cell in row:
			if (
				other_cell != cell
				and other_cell.region_id == cell.region_id
				and other_cell.state == CellData.CellState.YES
			):
				return false

	return true

func get_conflicts(cell: CellData) -> Array[ConflictType]:
	var conflicts: Array[ConflictType] = []

	# Only YES placements participate in these rules.
	if cell.state != CellData.CellState.YES:
		return conflicts

	if not is_row_valid(cell):
		conflicts.append(ConflictType.ROW)

	if not is_column_valid(cell):
		conflicts.append(ConflictType.COLUMN)

	if not is_region_valid(cell):
		conflicts.append(ConflictType.REGION)

	if not is_adjacency_valid(cell):
		conflicts.append(ConflictType.ADJACENT)

	return conflicts

# Every row must contain exactly one YES.
func all_rows_complete() -> bool:
	for row in board:
		var yes_count := 0

		for cell in row:
			if cell.state == CellData.CellState.YES:
				yes_count += 1

		if yes_count != 1:
			return false

	return true

# Every column must contain exactly one YES.
func all_columns_complete() -> bool:
	for col in range(columns):
		var yes_count := 0

		for row in range(rows):
			if board[row][col].state == CellData.CellState.YES:
				yes_count += 1

		if yes_count != 1:
			return false

	return true

# Every region must contain exactly one YES.
func all_regions_complete() -> bool:
	var region_ids := {}

	for row in region_map:
		for id in row:
			region_ids[id] = true

	for region_id in region_ids:
		var yes_count := 0

		for row in board:
			for cell in row:
				if cell.region_id == region_id and cell.state == CellData.CellState.YES:
					yes_count += 1

		if yes_count != 1:
			return false

	return true

# No YES touches another YES anywhere on the board.
func board_has_valid_adjacency() -> bool:
	for row in board:
		for cell in row:
			if cell.state == CellData.CellState.YES and not is_adjacency_valid(cell):
				return false

	return true

# valid = nothing is broken yet; solved = everything required is present.
func is_solved() -> bool:
	return (
		all_rows_complete()
		and all_columns_complete()
		and all_regions_complete()
		and board_has_valid_adjacency()
	)
