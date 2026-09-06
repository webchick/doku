extends Button

# Only three valid cell states; default to blank.
enum CellState {
	BLANK,
	NO,
	YES
}

var state: CellState = CellState.BLANK

@onready var x_mark: Label = $XMark
@onready var o_mark: Label = $OMark

var grid_row: int
var grid_col: int
var region_id: int = -1
var is_invalid: bool = false

signal state_changed(cell)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_on_pressed)
	update_display()

# Cycle through states on press.
func _on_pressed():
	match state:
		CellState.BLANK:
			state = CellState.NO

		CellState.NO:
			state = CellState.YES

		CellState.YES:
			state = CellState.BLANK

	update_display()
	state_changed.emit(self)

# Toggle visibility based on state.
func update_display():
	x_mark.visible = state == CellState.NO
	o_mark.visible = state == CellState.YES

	if is_invalid:
		modulate = Color(1.0, 0.5, 0.5)
	else:
		modulate = Color.WHITE
