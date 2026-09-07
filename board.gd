extends GridContainer

# GridContainer already has a built-in "columns" property.
@export var board_rows: int = 4
@export var board_columns: int = 4
@onready var conflict_label: Label = $"../GameInfo/ConflictLabel"

var cell_scene = preload("res://cell.tscn")
var puzzle_board: PuzzleBoard

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_new_game(board_rows)

# Builds a fresh board at the given size, replacing any existing one.
func start_new_game(size: int) -> void:
	board_rows = size
	board_columns = size
	columns = board_columns

	for child in get_children():
		child.queue_free()

	var generator = PuzzleGenerator.new()
	var puzzle_data = generator.generate_puzzle(board_rows)

	puzzle_board = PuzzleBoard.new(
		board_rows,
		board_columns,
		puzzle_data.region_map
	)

	for row in range(board_rows):
		for col in range(board_columns):
			var cell = cell_scene.instantiate()

			cell.data = puzzle_board.board[row][col]
			cell.puzzle_board = puzzle_board
			cell.state_changed.connect(_on_cell_state_changed)

			add_child(cell)

	conflict_label.text = ""

	# Let the grid settle its layout for the new board size before reading it.
	await get_tree().process_frame
	get_window().size = Vector2i(get_parent().get_combined_minimum_size())

func _on_cell_state_changed(cell):
	update_validation(cell.data)

# Each time a cell is clicked, indicate whether it's valid or not.
func update_validation(changed_cell: CellData):
	# This move may have made other cells newly invalid (e.g. a cell that
	# was a lone YES now has a neighbor), or cleared an existing conflict --
	# so recompute every cell's validity from scratch rather than just the
	# one that changed.
	for row in puzzle_board.board:
		for cell in row:
			cell.is_invalid = not puzzle_board.get_conflicts(cell).is_empty()

	# Show feedback for the move that was just made.
	var messages: Array[String] = []

	if changed_cell.is_invalid:
		for conflict in puzzle_board.get_conflicts(changed_cell):
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

	# Data changed; refresh every visual cell to match.
	for child in get_children():
		child.update_display()

	if puzzle_board.is_solved():
		conflict_label.text = "Solved!"
