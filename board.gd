extends GridContainer

# GridContainer already has a built-in "columns" property.
@export var board_rows: int = 4
@export var board_columns: int = 4
@onready var conflict_label: Label = $"../GameInfo/ConflictLabel"

var cell_scene = preload("res://cell.tscn")
var puzzle_board: PuzzleBoard

var region_map = [
	[0, 0, 1, 1],
	[0, 2, 2, 1],
	[3, 2, 2, 1],
	[3, 3, 3, 1]
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	columns = board_columns

	puzzle_board = PuzzleBoard.new(
		board_rows,
		board_columns,
		region_map
	)

	for row in range(board_rows):
		for col in range(board_columns):
			var cell = cell_scene.instantiate()

			cell.data = puzzle_board.board[row][col]
			cell.puzzle_board = puzzle_board
			cell.state_changed.connect(_on_cell_state_changed)

			add_child(cell)

func _on_cell_state_changed(cell):
	update_validation(cell.data)

# Each time a cell is clicked, indicate whether it's valid or not.
func update_validation(changed_cell: CellData):
	# The changed cell may become invalid OR become valid again.
	var conflicts = puzzle_board.get_conflicts(changed_cell)
	changed_cell.is_invalid = conflicts.size() > 0

	# Start fresh for THIS move.
	var messages: Array[String] = []

	# Show feedback for the move that was just made.
	if changed_cell.is_invalid:
		for conflict in conflicts:
			match conflict:
				PuzzleBoard.ConflictType.ROW:
					messages.append("MY row!")
				PuzzleBoard.ConflictType.COLUMN:
					messages.append("MY column!")
				PuzzleBoard.ConflictType.ADJACENT:
					messages.append("NO TOUCHING!")
				PuzzleBoard.ConflictType.REGION:
					messages.append("MY region!")

	conflict_label.text = "\n".join(messages)

	# Previously-invalid cells may clear if their conflict disappeared.
	for row in puzzle_board.board:
		for cell in row:
			if cell == changed_cell:
				continue

			if cell.is_invalid and puzzle_board.get_conflicts(cell).is_empty():
				cell.is_invalid = false

	# Data changed; refresh every visual cell to match.
	for child in get_children():
		child.update_display()

	if puzzle_board.is_solved():
		conflict_label.text = "Solved!"
