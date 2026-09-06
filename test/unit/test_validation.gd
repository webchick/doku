extends GutTest
var board_scene = preload("res://doku.tscn")

func test_board_creates_16_cells():
	var game = board_scene.instantiate()
	add_child_autofree(game)

	var board = game.get_node("Board")

	assert_eq(board.board.size(), 4)
	assert_eq(board.board[0].size(), 4)

func test_row_conflict():
	var game = board_scene.instantiate()
	add_child_autofree(game)

	var board = game.get_node("Board")

	var first = board.board[0][0]
	var second = board.board[0][2]

	first.state = first.CellState.YES
	second.state = second.CellState.YES

	assert_true(board.has_row_conflict(second))

func test_column_conflict():
	var game = board_scene.instantiate()
	add_child_autofree(game)

	var board = game.get_node("Board")

	var first = board.board[0][0]
	var second = board.board[2][0]

	first.state = first.CellState.YES
	second.state = second.CellState.YES

	assert_true(board.has_column_conflict(second))

func test_region_conflict():
	var game = board_scene.instantiate()
	add_child_autofree(game)

	var board = game.get_node("Board")

	var first = board.board[0][2]
	var second = board.board[2][3]

	first.state = first.CellState.YES
	second.state = second.CellState.YES

	assert_true(board.has_region_conflict(second))
	
func test_diagonal_adjacency_conflict():
	var game = board_scene.instantiate()
	add_child_autofree(game)

	var board = game.get_node("Board")

	var first = board.board[1][1]
	var second = board.board[2][2]

	first.state = first.CellState.YES
	second.state = second.CellState.YES

	assert_true(board.has_adjacent_conflict(second))
