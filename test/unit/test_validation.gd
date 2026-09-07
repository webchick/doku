extends GutTest

const REGION_MAP = [
	[0, 0, 1, 1],
	[0, 2, 2, 1],
	[3, 2, 2, 1],
	[3, 3, 3, 1]
]

var board_scene = preload("res://doku.tscn")

func test_board_creates_16_cells():
	var game = board_scene.instantiate()
	add_child_autofree(game)

	var board = game.get_node("MainLayout/Board")

	assert_eq(board.puzzle_board.board.size(), board.board_rows)
	assert_eq(board.puzzle_board.board[0].size(), board.board_columns)

func test_difficulty_menu_starts_a_new_sized_game():
	var game = board_scene.instantiate()
	add_child_autofree(game)

	var main_layout = game.get_node("MainLayout")
	var difficulty_menu = game.get_node("DifficultyMenu")
	var board = game.get_node("MainLayout/Board")

	assert_false(main_layout.visible)
	assert_true(difficulty_menu.visible)

	game.get_node("DifficultyMenu/VBoxContainer/HardButton").pressed.emit()
	await get_tree().process_frame
	await get_tree().process_frame

	assert_true(main_layout.visible)
	assert_false(difficulty_menu.visible)
	assert_eq(board.board_rows, 8)
	assert_eq(board.puzzle_board.rows, 8)

func test_update_validation_flags_both_cells_in_a_conflict():
	var game = board_scene.instantiate()
	add_child_autofree(game)

	var board = game.get_node("MainLayout/Board")
	var cell_a = board.puzzle_board.board[0][0]
	var cell_b = board.puzzle_board.board[0][1]

	# A lone YES is fine on its own...
	cell_a.state = CellData.CellState.YES
	board.update_validation(cell_a)

	assert_false(cell_a.is_invalid)

	# ...but placing an adjacent YES makes BOTH cells part of the conflict,
	# not just the one that was just placed.
	cell_b.state = CellData.CellState.YES
	board.update_validation(cell_b)

	assert_true(cell_a.is_invalid)
	assert_true(cell_b.is_invalid)

func test_row_conflict():
	var puzzle = PuzzleBoard.new(4, 4, REGION_MAP)

	puzzle.board[0][0].state = CellData.CellState.YES
	puzzle.board[0][2].state = CellData.CellState.YES

	assert_false(puzzle.is_row_valid(puzzle.board[0][2]))

func test_column_conflict():
	var puzzle = PuzzleBoard.new(4, 4, REGION_MAP)

	puzzle.board[0][0].state = CellData.CellState.YES
	puzzle.board[2][0].state = CellData.CellState.YES

	assert_false(puzzle.is_column_valid(puzzle.board[2][0]))

func test_region_conflict():
	var puzzle = PuzzleBoard.new(4, 4, REGION_MAP)

	puzzle.board[0][2].state = CellData.CellState.YES
	puzzle.board[2][3].state = CellData.CellState.YES

	assert_false(puzzle.is_region_valid(puzzle.board[2][3]))

func test_diagonal_adjacency_conflict():
	var puzzle = PuzzleBoard.new(4, 4, REGION_MAP)

	puzzle.board[1][1].state = CellData.CellState.YES
	puzzle.board[2][2].state = CellData.CellState.YES

	assert_false(puzzle.is_adjacency_valid(puzzle.board[2][2]))

func test_empty_row_is_valid():
	var puzzle = PuzzleBoard.new(4, 4, REGION_MAP)

	assert_true(puzzle.is_row_valid(puzzle.board[0][0]))

func test_is_solved_false_when_incomplete():
	var puzzle = PuzzleBoard.new(4, 4, REGION_MAP)

	puzzle.board[0][0].state = CellData.CellState.YES

	assert_false(puzzle.is_solved())

func test_is_solved_true_for_valid_full_solution():
	# One region per row, so a valid full solution is easy to construct.
	var row_regions = [
		[0, 0, 0, 0],
		[1, 1, 1, 1],
		[2, 2, 2, 2],
		[3, 3, 3, 3]
	]
	var puzzle = PuzzleBoard.new(4, 4, row_regions)

	# One YES per row/column/region, none adjacent.
	puzzle.board[0][1].state = CellData.CellState.YES
	puzzle.board[1][3].state = CellData.CellState.YES
	puzzle.board[2][0].state = CellData.CellState.YES
	puzzle.board[3][2].state = CellData.CellState.YES

	assert_true(puzzle.is_solved())
