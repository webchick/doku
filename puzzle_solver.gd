class_name PuzzleSolver

# Brute-force backtracking solver over a puzzle's region map alone (it never
# touches the puzzle's actual cell states). Counts up to `limit` distinct
# solutions and stops as soon as it gets there -- the generator only needs
# to know whether a puzzle is unique, not how ambiguous a bad one is.
func count_solutions(puzzle: PuzzleBoard, limit: int = 2) -> int:
	var chosen_columns: Array[int] = []

	return _count_from_row(puzzle, 0, chosen_columns, {}, limit)

func _count_from_row(
	puzzle: PuzzleBoard,
	row: int,
	chosen_columns: Array[int],
	used_regions: Dictionary,
	limit: int
) -> int:
	if limit <= 0:
		return 0

	if row == puzzle.rows:
		return 1

	var found := 0

	for col in range(puzzle.columns):
		# One YES per column.
		if chosen_columns.has(col):
			continue

		# One YES per region.
		var region_id = puzzle.region_map[row][col]

		if used_regions.has(region_id):
			continue

		# No touching the previous row's YES (only adjacent rows can touch,
		# since each row places exactly one YES).
		if row > 0 and abs(col - chosen_columns[row - 1]) <= 1:
			continue

		chosen_columns.append(col)
		used_regions[region_id] = true

		found += _count_from_row(puzzle, row + 1, chosen_columns, used_regions, limit - found)

		chosen_columns.pop_back()
		used_regions.erase(region_id)

		if found >= limit:
			break

	return found
