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
