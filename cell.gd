extends Button

var puzzle_board: PuzzleBoard
var data: CellData

@onready var background: Panel = $Background
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

	update_borders()

	if data.is_invalid:
		modulate = Color(1.0, 0.5, 0.5)
	else:
		modulate = Color.WHITE


# Evenly spaces a pastel hue per region so the palette scales with however
# many regions the board actually has, instead of running out of colors.
func get_region_color(region_id: int) -> Color:
	var total_regions = puzzle_board.region_count()

	if total_regions <= 0:
		return Color.WHITE

	return Color.from_hsv(float(region_id) / total_regions, 0.3, 0.95)

func get_border_width(edge: PuzzleBoard.Edge) -> int:
	if puzzle_board.is_region_boundary(data, edge):
		return 4

	return 1

func update_borders():
	var style = StyleBoxFlat.new()

	style.bg_color = get_region_color(data.region_id)
	style.border_color = Color("#333333")

	style.border_width_top = get_border_width(PuzzleBoard.Edge.TOP)
	style.border_width_right = get_border_width(PuzzleBoard.Edge.RIGHT)
	style.border_width_bottom = get_border_width(PuzzleBoard.Edge.BOTTOM)
	style.border_width_left = get_border_width(PuzzleBoard.Edge.LEFT)

	background.add_theme_stylebox_override("panel", style)
