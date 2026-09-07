extends GutTest

func test_generates_one_position_per_row():
	var generator = PuzzleGenerator.new()
	var solution = generator.generate_solution(4)

	assert_eq(solution.size(), 4)

func test_uses_every_column_exactly_once():
	var generator = PuzzleGenerator.new()
	var solution = generator.generate_solution(4)

	var sorted_columns = solution.duplicate()
	sorted_columns.sort()

	assert_eq(sorted_columns, [0, 1, 2, 3])

func test_no_consecutive_rows_touch():
	var generator = PuzzleGenerator.new()
	var solution = generator.generate_solution(4)

	for row in range(1, solution.size()):
		assert_true(abs(solution[row] - solution[row - 1]) > 1)

func test_positions_within_board_bounds():
	var generator = PuzzleGenerator.new()
	var solution = generator.generate_solution(4)

	for col in solution:
		assert_true(col >= 0 and col < 4)

func test_is_valid_solution_layout_rejects_adjacent_columns():
	var generator = PuzzleGenerator.new()

	assert_false(generator.is_valid_solution_layout([0, 1, 2, 3]))

func test_is_valid_solution_layout_accepts_spaced_columns():
	var generator = PuzzleGenerator.new()

	assert_true(generator.is_valid_solution_layout([1, 3, 0, 2]))

func test_build_regions_assigns_every_cell():
	var generator = PuzzleGenerator.new()
	var region_map = generator.build_regions([1, 3, 0, 2])

	for row in region_map:
		for region_id in row:
			assert_ne(region_id, -1)

func test_build_regions_uses_one_region_per_row():
	var generator = PuzzleGenerator.new()
	var region_map = generator.build_regions([1, 3, 0, 2])

	var region_ids = {}

	for row in region_map:
		for region_id in row:
			region_ids[region_id] = true

	assert_eq(region_ids.size(), 4)

func test_build_regions_seeds_each_region_with_its_solution_cell():
	var generator = PuzzleGenerator.new()
	var solution: Array[int] = [1, 3, 0, 2]
	var region_map = generator.build_regions(solution)

	for row in range(solution.size()):
		assert_eq(region_map[row][solution[row]], row)

func test_build_regions_are_orthogonally_contiguous():
	var generator = PuzzleGenerator.new()
	var solution: Array[int] = [1, 3, 0, 2]
	var region_map = generator.build_regions(solution)
	var size = solution.size()

	for region_id in range(size):
		var seed_col = solution[region_id]
		var expected_count := 0

		for row in region_map:
			for id in row:
				if id == region_id:
					expected_count += 1

		# Flood fill from the seed using only orthogonal steps within the region.
		var visited = {Vector2i(region_id, seed_col): true}
		var queue = [Vector2i(region_id, seed_col)]

		while not queue.is_empty():
			var cell: Vector2i = queue.pop_back()

			for offset in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
				var neighbor = cell + offset

				if (
					neighbor.x >= 0 and neighbor.x < size
					and neighbor.y >= 0 and neighbor.y < size
					and not visited.has(neighbor)
					and region_map[neighbor.x][neighbor.y] == region_id
				):
					visited[neighbor] = true
					queue.append(neighbor)

		assert_eq(visited.size(), expected_count)

func test_generated_solution_and_regions_form_a_solved_board():
	var generator = PuzzleGenerator.new()
	var solution = generator.generate_solution(4)
	var region_map = generator.build_regions(solution)
	var puzzle = PuzzleBoard.new(4, 4, region_map)

	for row in range(solution.size()):
		puzzle.board[row][solution[row]].state = CellData.CellState.YES

	assert_true(puzzle.is_solved())
