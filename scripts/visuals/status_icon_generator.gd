## StatusIconGenerator - Generates status effect icons programmatically
## Part of: Blood & Gold Prototype
## Spec: docs/features/5.1-programmatic-visual-assets.md
class_name StatusIconGenerator
extends RefCounted

# ===== CONSTANTS =====
const ICON_SIZE: int = 16

# ===== COLORS =====
const COLOR_GREEN: Color = Color("#27ae60")
const COLOR_GOLD: Color = Color("#f1c40f")
const COLOR_RED: Color = Color("#e74c3c")
const COLOR_PURPLE: Color = Color("#9b59b6")
const COLOR_WHITE: Color = Color("#ffffff")
const COLOR_BLACK: Color = Color("#1a1a1a")
const COLOR_DARK_GRAY: Color = Color("#2c3e50")

# ===== STATIC GENERATION METHODS =====

static func generate_icon(effect_type: String) -> ImageTexture:
	## Generate icon based on status effect type
	match effect_type:
		"ATTACK_BUFF":
			return generate_attack_buff_icon()
		"BLESSED":
			return generate_blessed_icon()
		"TAUNTED":
			return generate_taunted_icon()
		"STUNNED":
			return generate_stunned_icon()
		"POISONED", "POISON_BLADE":
			return generate_poisoned_icon()
		"LAST_STAND":
			return generate_last_stand_icon()
		_:
			return generate_attack_buff_icon()  # Default

static func generate_attack_buff_icon() -> ImageTexture:
	## Attack Buff - Sword with upward arrow
	var image = _create_base_image()

	# Sword (diagonal)
	_draw_line(image, Vector2i(3, 12), Vector2i(10, 5), COLOR_WHITE, 2)
	# Crossguard
	_draw_horizontal_line(image, Vector2i(7, 8), 4, COLOR_WHITE, 1)

	# Upward arrow
	_draw_vertical_line(image, Vector2i(12, 4), 8, COLOR_GREEN, 1)
	_draw_arrow_up(image, Vector2i(12, 4), COLOR_GREEN)

	return ImageTexture.create_from_image(image)

static func generate_blessed_icon() -> ImageTexture:
	## Blessed - Sun/halo symbol
	var image = _create_base_image()

	# Central sun
	_draw_circle(image, Vector2i(8, 8), 3, COLOR_GOLD)

	# Rays
	for i in range(8):
		var angle = i * PI / 4
		var end_x = 8 + int(cos(angle) * 6)
		var end_y = 8 + int(sin(angle) * 6)
		if end_x >= 0 and end_x < ICON_SIZE and end_y >= 0 and end_y < ICON_SIZE:
			image.set_pixel(end_x, end_y, COLOR_GOLD)

	return ImageTexture.create_from_image(image)

static func generate_taunted_icon() -> ImageTexture:
	## Taunted - Angry face
	var image = _create_base_image()

	# Face circle
	_draw_circle(image, Vector2i(8, 8), 6, COLOR_RED)

	# Angry eyes (diagonal lines)
	_draw_line(image, Vector2i(4, 5), Vector2i(6, 7), COLOR_BLACK, 1)
	_draw_line(image, Vector2i(12, 5), Vector2i(10, 7), COLOR_BLACK, 1)

	# Frown
	_draw_horizontal_line(image, Vector2i(5, 11), 6, COLOR_BLACK, 1)

	return ImageTexture.create_from_image(image)

static func generate_stunned_icon() -> ImageTexture:
	## Stunned - Circling stars
	var image = _create_base_image()

	# Stars in a circle pattern
	_draw_star(image, Vector2i(4, 4), COLOR_PURPLE)
	_draw_star(image, Vector2i(12, 4), COLOR_PURPLE)
	_draw_star(image, Vector2i(8, 10), COLOR_PURPLE)

	# Swirl lines connecting them
	_draw_arc_simple(image, Vector2i(8, 6), 4, COLOR_PURPLE)

	return ImageTexture.create_from_image(image)

static func generate_poisoned_icon() -> ImageTexture:
	## Poisoned - Skull with drip
	var image = _create_base_image()

	# Skull
	_draw_circle(image, Vector2i(8, 6), 4, COLOR_GREEN)

	# Eye sockets
	image.set_pixel(6, 5, COLOR_BLACK)
	image.set_pixel(10, 5, COLOR_BLACK)

	# Nose
	image.set_pixel(8, 7, COLOR_BLACK)

	# Teeth line
	_draw_horizontal_line(image, Vector2i(6, 9), 5, COLOR_BLACK, 1)

	# Drip
	_draw_vertical_line(image, Vector2i(8, 11), 4, COLOR_GREEN, 1)
	image.set_pixel(8, 14, COLOR_GREEN.lightened(0.3))

	return ImageTexture.create_from_image(image)

static func generate_last_stand_icon() -> ImageTexture:
	## Last Stand - Cracked shield
	var image = _create_base_image()

	# Shield shape (kite)
	for y in range(2, 14):
		var row = y - 2
		var half_width: int
		if row < 8:
			half_width = 5
		else:
			half_width = 5 - (row - 8)
		if half_width > 0:
			for x in range(8 - half_width, 8 + half_width + 1):
				if x >= 0 and x < ICON_SIZE:
					image.set_pixel(x, y, COLOR_GOLD)

	# Crack lines
	_draw_line(image, Vector2i(8, 3), Vector2i(6, 8), COLOR_BLACK, 1)
	_draw_line(image, Vector2i(6, 8), Vector2i(9, 11), COLOR_BLACK, 1)

	return ImageTexture.create_from_image(image)

# ===== HELPER METHODS =====

static func _create_base_image() -> Image:
	## Create base transparent image
	var image = Image.create(ICON_SIZE, ICON_SIZE, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	return image

static func _draw_circle(image: Image, center: Vector2i, radius: int, color: Color) -> void:
	## Draw filled circle
	for x in range(center.x - radius, center.x + radius + 1):
		for y in range(center.y - radius, center.y + radius + 1):
			if x >= 0 and x < ICON_SIZE and y >= 0 and y < ICON_SIZE:
				if Vector2(x - center.x, y - center.y).length() <= radius:
					image.set_pixel(x, y, color)

static func _draw_horizontal_line(image: Image, start: Vector2i, length: int, color: Color, width: int) -> void:
	## Draw horizontal line
	for x in range(start.x, start.x + length):
		for w in range(width):
			var y = start.y + w
			if x >= 0 and x < ICON_SIZE and y >= 0 and y < ICON_SIZE:
				image.set_pixel(x, y, color)

static func _draw_vertical_line(image: Image, start: Vector2i, length: int, color: Color, width: int) -> void:
	## Draw vertical line
	for y in range(start.y, start.y + length):
		for w in range(width):
			var x = start.x + w
			if x >= 0 and x < ICON_SIZE and y >= 0 and y < ICON_SIZE:
				image.set_pixel(x, y, color)

static func _draw_line(image: Image, from: Vector2i, to: Vector2i, color: Color, width: int) -> void:
	## Draw line using Bresenham
	var dx = abs(to.x - from.x)
	var dy = abs(to.y - from.y)
	var sx = 1 if from.x < to.x else -1
	var sy = 1 if from.y < to.y else -1
	var err = dx - dy
	var x = from.x
	var y = from.y

	while true:
		for wx in range(width):
			for wy in range(width):
				var px = x + wx
				var py = y + wy
				if px >= 0 and px < ICON_SIZE and py >= 0 and py < ICON_SIZE:
					image.set_pixel(px, py, color)
		if x == to.x and y == to.y:
			break
		var e2 = 2 * err
		if e2 > -dy:
			err -= dy
			x += sx
		if e2 < dx:
			err += dx
			y += sy

static func _draw_arrow_up(image: Image, tip: Vector2i, color: Color) -> void:
	## Draw upward arrow head
	if tip.y + 1 < ICON_SIZE:
		if tip.x - 1 >= 0:
			image.set_pixel(tip.x - 1, tip.y + 1, color)
		if tip.x + 1 < ICON_SIZE:
			image.set_pixel(tip.x + 1, tip.y + 1, color)
	if tip.y + 2 < ICON_SIZE:
		if tip.x - 2 >= 0:
			image.set_pixel(tip.x - 2, tip.y + 2, color)
		if tip.x + 2 < ICON_SIZE:
			image.set_pixel(tip.x + 2, tip.y + 2, color)

static func _draw_star(image: Image, center: Vector2i, color: Color) -> void:
	## Draw a small 4-point star
	image.set_pixel(center.x, center.y, color)
	if center.x - 1 >= 0:
		image.set_pixel(center.x - 1, center.y, color)
	if center.x + 1 < ICON_SIZE:
		image.set_pixel(center.x + 1, center.y, color)
	if center.y - 1 >= 0:
		image.set_pixel(center.x, center.y - 1, color)
	if center.y + 1 < ICON_SIZE:
		image.set_pixel(center.x, center.y + 1, color)

static func _draw_arc_simple(image: Image, center: Vector2i, radius: int, color: Color) -> void:
	## Draw a simple arc (top half of circle)
	for i in range(8):
		var angle = PI + i * PI / 8
		var x = center.x + int(cos(angle) * radius)
		var y = center.y + int(sin(angle) * radius)
		if x >= 0 and x < ICON_SIZE and y >= 0 and y < ICON_SIZE:
			image.set_pixel(x, y, color)
