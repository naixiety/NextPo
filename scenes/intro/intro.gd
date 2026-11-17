
extends Control

const MAIN_MENU = "res://scenes/menus/main_menu.tscn"

const DEFAULT_DURATION := 6.0
const FADE_DURATION := 0.5
const TYPEWRITER_SPEED := 0.035

const SLIDES = [
	{
		"image": "res://assets/backgrounds/intro/intro_indiego.png",
		"text": "",
		"duration": 3.0
	},
	{
		"image": "res://assets/backgrounds/intro/intro_town.png",
		"text": "In the municipality of San Ignacio, life goes on as it always has.",
		"duration": DEFAULT_DURATION
	},
	{
		"image": "res://assets/backgrounds/intro/intro_community.png",
		"text": "But as the town grows, so do the needs of its people.",
		"duration": DEFAULT_DURATION
	},
	{
		"image": "res://assets/backgrounds/intro/intro_masa.png",
		"text": "At MASA, requests for assistance and public services continue to pile up.",
		"duration": DEFAULT_DURATION
	},
	{
		"image": "res://assets/backgrounds/intro/intro_appointment.png",
		"text": "You have been assigned as a Public Service Officer.",
		"duration": DEFAULT_DURATION
	},
	{
		"image": "res://assets/backgrounds/intro/intro_first_day.png",
		"text": "Today is your first day. The first applicants are already waiting.",
		"duration": DEFAULT_DURATION
	}
]

@onready var scene_image: TextureRect = $SceneImage
@onready var narration_panel: PanelContainer = $NarrationPanel
@onready var narration_text: Label = $NarrationPanel/NarrationText
@onready var skip_button: Button = $SkipButton

var skipped := false


func _ready() -> void:
	skip_button.pressed.connect(skip_intro)
	run_intro()


func run_intro() -> void:
	for slide in SLIDES:
		if skipped:
			return

		await show_slide(slide)

	if not skipped:
		skip_intro()


func show_slide(slide: Dictionary) -> void:
	var image_path: String = slide["image"]
	var narration: String = slide["text"]
	var duration: float = slide["duration"]

	# Set image and narration.
	scene_image.texture = load(image_path)
	scene_image.modulate.a = 0.0

	narration_panel.visible = not narration.is_empty()
	narration_panel.modulate.a = 0.0
	narration_text.text = narration
	narration_text.visible_characters = 0

	# Fade in image and narration together.
	var fade_in := create_tween().set_parallel(true)
	fade_in.tween_property(
		scene_image, "modulate:a", 1.0, FADE_DURATION
	)
	fade_in.tween_property(
		narration_panel, "modulate:a", 1.0, FADE_DURATION
	)

	# Typewriter effect.
	if not narration.is_empty():
		var character_count := narration_text.get_total_character_count()
		var typing_duration := minf(
			character_count * TYPEWRITER_SPEED,
			duration - FADE_DURATION * 2
		)

		var typing_tween := create_tween()
		typing_tween.tween_property(
			narration_text,
			"visible_characters",
			character_count,
			typing_duration
		)

	# Wait until the fade-out portion begins.
	await get_tree().create_timer(
		duration - FADE_DURATION
	).timeout

	if skipped:
		return

	# Fade out image and narration together.
	var fade_out := create_tween().set_parallel(true)
	fade_out.tween_property(
		scene_image, "modulate:a", 0.0, FADE_DURATION
	)
	fade_out.tween_property(
		narration_panel, "modulate:a", 0.0, FADE_DURATION
	)

	await fade_out.finished


func skip_intro() -> void:
	if skipped:
		return

	skipped = true
	get_tree().change_scene_to_file(MAIN_MENU)
