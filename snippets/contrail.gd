# Excerpt from DroneDash — twin rotor contrails.
# Two Line2D trails sample each rotor tip in world space every
# physics frame, trim to a fixed length, and fade out with a
# tween when the boost ends. Lives as a child of the drone.

extends Node2D

# Two Line2D contrails — one per rotor tip, placed in scene for editor tweaking
@onready var trail_left: Line2D = $TrailLeft
@onready var trail_right: Line2D = $TrailRight

var is_trailing: bool = false
var _fade_tween: Tween = null
var _original_alpha_left: float = 1.0
var _original_alpha_right: float = 1.0

const MAX_POINTS: int = 30
const TRAIL_OFFSET_X: float = 22.0  # Distance from center to each rotor tip
const TRAIL_OFFSET_Y: float = 8.0   # Slightly below center
const FADE_DURATION: float = 0.6

func _ready():
	# Cache whatever alpha you set in the editor
	_original_alpha_left = trail_left.modulate.a
	_original_alpha_right = trail_right.modulate.a

func _physics_process(_delta: float):
	if not is_trailing:
		return

	# Record world positions of each rotor tip
	var drone = get_parent()
	var rot = drone.sprite.rotation if drone.sprite else 0.0
	var left_offset = Vector2(-TRAIL_OFFSET_X, TRAIL_OFFSET_Y).rotated(rot)
	var right_offset = Vector2(TRAIL_OFFSET_X, TRAIL_OFFSET_Y).rotated(rot)

	var left_pos = drone.global_position + left_offset
	var right_pos = drone.global_position + right_offset

	trail_left.add_point(left_pos)
	trail_right.add_point(right_pos)

	# Trim oldest points
	while trail_left.get_point_count() > MAX_POINTS:
		trail_left.remove_point(0)
	while trail_right.get_point_count() > MAX_POINTS:
		trail_right.remove_point(0)

func start_contrail():
	if is_trailing:
		return
	is_trailing = true
	# Kill any fade in progress
	if _fade_tween and _fade_tween.is_valid():
		_fade_tween.kill()
	# Restore editor-set alpha
	trail_left.modulate.a = _original_alpha_left
	trail_right.modulate.a = _original_alpha_right
	trail_left.clear_points()
	trail_right.clear_points()
	trail_left.visible = true
	trail_right.visible = true

func stop_contrail():
	if not is_trailing:
		return
	is_trailing = false
	# Fade out then hide
	if _fade_tween and _fade_tween.is_valid():
		_fade_tween.kill()
	_fade_tween = create_tween()
	_fade_tween.set_parallel(true)
	_fade_tween.tween_property(trail_left, "modulate:a", 0.0, FADE_DURATION)
	_fade_tween.tween_property(trail_right, "modulate:a", 0.0, FADE_DURATION)
	_fade_tween.chain().tween_callback(_clear_trails)

func _clear_trails():
	trail_left.clear_points()
	trail_right.clear_points()
	trail_left.visible = false
	trail_right.visible = false
