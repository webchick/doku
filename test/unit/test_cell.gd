extends GutTest

var cell_scene = preload("res://cell.tscn")

func test_cell_defaults_to_blank():
	var puzzle = PuzzleBoard.new(1, 1, [[0]])
	var cell = cell_scene.instantiate()

	cell.data = puzzle.board[0][0]
	cell.puzzle_board = puzzle
	add_child_autofree(cell)

	assert_eq(cell.data.state, CellData.CellState.BLANK)
