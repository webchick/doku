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

	var board = game.get_node("Board")

	assert_eq(board.puzzle_board.board.size(), 4)
	assert_eq(board.puzzle_board.board[0].size(), 4)

func test_row_conflict():
	var puzzle = PuzzleBoard.new(4, 4, REGION_MAP)

	puzzle.board[0][0].state = CellData.CellState.YES
	puzzle.board[0][2].state = CellData.CellState.YES

	assert_true(puzzle.has_row_conflict(puzzle.board[0][2]))

func test_column_conflict():
	var puzzle = PuzzleBoard.new(4, 4, REGION_MAP)

	puzzle.board[0][0].state = CellData.CellState.YES
	puzzle.board[2][0].state = CellData.CellState.YES

	assert_true(puzzle.has_column_conflict(puzzle.board[2][0]))

func test_region_conflict():
	var puzzle = PuzzleBoard.new(4, 4, REGION_MAP)

	puzzle.board[0][2].state = CellData.CellState.YES
	puzzle.board[2][3].state = CellData.CellState.YES

	assert_true(puzzle.has_region_conflict(puzzle.board[2][3]))

func test_diagonal_adjacency_conflict():
	var puzzle = PuzzleBoard.new(4, 4, REGION_MAP)

	puzzle.board[1][1].state = CellData.CellState.YES
	puzzle.board[2][2].state = CellData.CellState.YES

	assert_true(puzzle.has_adjacent_conflict(puzzle.board[2][2]))
