class_name PuzzleGenerator

const MAX_ATTEMPTS = 100

# Generates a hidden YES layout for a square board: one entry per row,
# holding that row's YES column. Since it's a permutation, row and column
# uniqueness are already guaranteed; only adjacency needs checking.
func generate_solution(size: int) -> Array[int]:
	var columns: Array[int] = []

	for col in range(size):
		columns.append(col)

	for attempt in range(MAX_ATTEMPTS):
		columns.shuffle()

		if is_valid_solution_layout(columns):
			return columns.duplicate()

	return []

# No two consecutive rows may place their YES in touching columns.
func is_valid_solution_layout(columns: Array[int]) -> bool:
	for row in range(1, columns.size()):
		if abs(columns[row] - columns[row - 1]) <= 1:
			return false

	return true
