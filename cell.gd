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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_on_pressed)
	update_display()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

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

# Toggle visibility based on cell state.
func update_display():
	x_mark.visible = state == CellState.NO
	o_mark.visible = state == CellState.YES
