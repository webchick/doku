class_name CellData

enum CellState {
	BLANK,
	NO,
	YES
}

var state: CellState = CellState.BLANK
var grid_row: int
var grid_col: int
var region_id: int = -1
var is_invalid: bool = false
