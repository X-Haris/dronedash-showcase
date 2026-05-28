# Excerpt from DroneDash — ground-level flower-petal particles.
# The petal texture is generated procedurally at runtime (no PNG
# imported), so there are zero art-pipeline dependencies. Attach
# this script to a CPUParticles2D and it configures itself.

extends CPUParticles2D

# Flower petal particles for low altitude (ground level)
# Generates petal texture programmatically at runtime
# Drift from left to right across screen

func _ready():
	texture = create_petal_texture()

	emitting = false
	amount = 15
	lifetime = 12.0
	preprocess = 12.0
	local_coords = false

	# Emit from left side of screen, tall vertical strip
	emission_shape = EMISSION_SHAPE_RECTANGLE
	emission_rect_extents = Vector2(50, 1200)
	position = Vector2(-600, 0)  # Left side of camera

	# Drift rightward with slight downward angle
	direction = Vector2(1.0, 0.3)
	spread = 20.0
	initial_velocity_min = 20.0
	initial_velocity_max = 45.0

	# Light gravity pulling down, wind pushing right
	gravity = Vector2(15.0, 8.0)

	# Slow tumbling rotation
	angular_velocity_min = -50.0
	angular_velocity_max = 50.0

	# Horizontal wobble
	tangential_accel_min = -15.0
	tangential_accel_max = 15.0

	# Some damping for floaty feel
	damping_min = 2.0
	damping_max = 5.0

	# Size
	scale_amount_min = 0.8
	scale_amount_max = 1.5

	# Warm white color
	color = Color(1.0, 0.97, 0.93, 0.8)

	# Color variation
	color_ramp = create_color_gradient()

	# Fade in/out curve
	var fade_curve = Curve.new()
	fade_curve.add_point(Vector2(0.0, 0.0))
	fade_curve.add_point(Vector2(0.1, 1.0))
	fade_curve.add_point(Vector2(0.85, 1.0))
	fade_curve.add_point(Vector2(1.0, 0.0))
	scale_amount_curve = fade_curve

func create_petal_texture() -> ImageTexture:
	var img = Image.create(16, 16, false, Image.FORMAT_RGBA8)

	for y in range(16):
		for x in range(16):
			var dx = (x - 8.0) / 8.0
			var dy = (y - 8.0) / 5.0  # Elongated = petal shape
			var dist = sqrt(dx * dx + dy * dy)

			if dist < 1.0:
				var alpha = 1.0 - dist
				alpha = pow(alpha, 0.7)
				img.set_pixel(x, y, Color(1.0, 0.97, 0.94, alpha))
			else:
				img.set_pixel(x, y, Color(0, 0, 0, 0))

	return ImageTexture.create_from_image(img)

func create_color_gradient() -> Gradient:
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1.0, 0.92, 0.88, 1.0))
	gradient.add_point(0.5, Color(1.0, 0.97, 0.94, 1.0))
	gradient.add_point(1.0, Color(1.0, 1.0, 1.0, 1.0))
	return gradient
