extends Button

var data: CellData

@onready var x_mark: Label = $XMark
@onready var o_mark: Label = $OMark

signal state_changed(cell)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_on_pressed)
	update_display()

# Cycle through states on press.
func _on_pressed():
	match data.state:
		data.CellState.BLANK:
			data.state = CellData.CellState.NO

		data.CellState.NO:
			data.state = CellData.CellState.YES

		data.CellState.YES:
			data.state = CellData.CellState.BLANK

	update_display()
	state_changed.emit(self)

# Toggle visibility based on state.
func update_display():
	x_mark.visible = data.state == CellData.CellState.NO
	o_mark.visible = data.state == CellData.CellState.YES

	if data.is_invalid:
		modulate = Color(1.0, 0.5, 0.5)
	else:
		modulate = Color.WHITE
