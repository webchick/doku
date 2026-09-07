extends Control

const DIFFICULTY_SIZES = {
	"easy": 5,
	"medium": 6,
	"hard": 8,
}

@onready var difficulty_menu: Control = $DifficultyMenu
@onready var board: GridContainer = $MainLayout/Board

func _ready() -> void:
	$MainLayout.visible = false

	$DifficultyMenu/VBoxContainer/EasyButton.pressed.connect(_on_difficulty_selected.bind(DIFFICULTY_SIZES.easy))
	$DifficultyMenu/VBoxContainer/MediumButton.pressed.connect(_on_difficulty_selected.bind(DIFFICULTY_SIZES.medium))
	$DifficultyMenu/VBoxContainer/HardButton.pressed.connect(_on_difficulty_selected.bind(DIFFICULTY_SIZES.hard))

func _on_difficulty_selected(size: int) -> void:
	difficulty_menu.visible = false
	$MainLayout.visible = true
	board.start_new_game(size)
