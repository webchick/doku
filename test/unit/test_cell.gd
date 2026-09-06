extends GutTest

var cell_scene = preload("res://cell.tscn")

func test_cell_defaults_to_blank():
	var cell = cell_scene.instantiate()
	cell.data = CellData.new()
	add_child_autofree(cell)

	assert_eq(cell.data.state, CellData.CellState.BLANK)
