class_name PuzzleGenerator

const MAX_ATTEMPTS = 100
const MAX_PUZZLE_ATTEMPTS = 200

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

# Grows one contiguous region per row out of its solution cell via randomized
# flood fill, so every region ends up with exactly its own YES seed and the
# whole board ends up tiled. Region id == the row that seeded it.
func build_regions(solution_columns: Array[int]) -> Array:
	var size = solution_columns.size()
	var region_map: Array = []

	for row in range(size):
		var row_data: Array = []

		for col in range(size):
			row_data.append(-1)

		region_map.append(row_data)

	var frontiers: Array = []

	for row in range(size):
		var seed_col = solution_columns[row]

		region_map[row][seed_col] = row
		frontiers.append([Vector2i(row, seed_col)])

	var unclaimed = size * size - size

	while unclaimed > 0:
		var region_id = _pick_growable_region(frontiers)
		var frontier: Array = frontiers[region_id]
		var cell: Vector2i = frontier.pop_at(randi() % frontier.size())

		for neighbor in _orthogonal_neighbors(cell, size):
			if region_map[neighbor.x][neighbor.y] == -1:
				region_map[neighbor.x][neighbor.y] = region_id
				frontiers[region_id].append(neighbor)
				unclaimed -= 1

	return region_map

# Any region that still has cells left to grow from.
func _pick_growable_region(frontiers: Array) -> int:
	var growable: Array[int] = []

	for region_id in range(frontiers.size()):
		if not frontiers[region_id].is_empty():
			growable.append(region_id)

	return growable[randi() % growable.size()]

func _orthogonal_neighbors(cell: Vector2i, size: int) -> Array[Vector2i]:
	var neighbors: Array[Vector2i] = []
	var offsets = [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]

	for offset in offsets:
		var neighbor = cell + offset

		if neighbor.x >= 0 and neighbor.x < size and neighbor.y >= 0 and neighbor.y < size:
			neighbors.append(neighbor)

	return neighbors

# Retries solution + region generation until PuzzleSolver confirms the
# result has exactly one solution. Returns {"solution": Array[int],
# "region_map": Array}. Random region growth means most attempts already
# land on a unique puzzle (regularly over half, in practice), so this
# converges fast.
func generate_puzzle(size: int) -> Dictionary:
	var solver = PuzzleSolver.new()
	var last_result: Dictionary = {}

	for attempt in range(MAX_PUZZLE_ATTEMPTS):
		var solution = generate_solution(size)

		if solution.is_empty():
			continue

		var region_map = build_regions(solution)

		last_result = {"solution": solution, "region_map": region_map}

		var puzzle = PuzzleBoard.new(size, size, region_map)

		if solver.count_solutions(puzzle, 2) == 1:
			return last_result

	return last_result
