## AbilityIconGenerator - Generates ability icons programmatically
## Part of: Blood & Gold Prototype
## Spec: docs/features/5.1-programmatic-visual-assets.md
class_name AbilityIconGenerator
extends RefCounted

# ===== CONSTANTS =====
const ICON_SIZE: int = 64

# ===== COLORS =====
# Common
const COLOR_SILVER: Color = Color("#bdc3c7")
const COLOR_LIGHT_GRAY: Color = Color("#ecf0f1")
const COLOR_DARK_GRAY: Color = Color("#34495e")
const COLOR_GOLD: Color = Color("#f1c40f")
const COLOR_YELLOW: Color = Color("#f7dc6f")
const COLOR_WHITE: Color = Color("#ffffff")
const COLOR_TAN: Color = Color("#d4a574")
const COLOR_RED: Color = Color("#e74c3c")
const COLOR_DARK_RED: Color = Color("#922b21")
const COLOR_CRIMSON: Color = Color("#c0392b")
const COLOR_ORANGE: Color = Color("#e67e22")
const COLOR_ORANGE_RED: Color = Color("#d35400")
const COLOR_STEEL: Color = Color("#5d6d7e")
const COLOR_BONE_WHITE: Color = Color("#ecf0f1")
const COLOR_PURPLE: Color = Color("#9b59b6")
const COLOR_DEEP_PURPLE: Color = Color("#4a235a")
const COLOR_DARK: Color = Color("#2c2c2c")
const COLOR_CHARCOAL: Color = Color("#2c3e50")
const COLOR_BLACK: Color = Color("#1a1a1a")
const COLOR_GREEN: Color = Color("#27ae60")
const COLOR_BRIGHT_GREEN: Color = Color("#2ecc71")
const COLOR_DARK_GREEN: Color = Color("#1e8449")
const COLOR_BLUE: Color = Color("#2980b9")
const COLOR_LIGHT_BLUE: Color = Color("#3498db")
const COLOR_HOLY_YELLOW: Color = Color("#f39c12")

# ===== STATIC GENERATION METHODS =====

static func generate_icon(ability_id: String) -> ImageTexture:
	## Generate icon based on ability ID
	match ability_id:
		"basic_attack", "matthias_basic_attack":
			return generate_attack_icon()
		"ranged_attack":
			return generate_ranged_attack_icon()
		"rally":
			return generate_rally_icon()
		"power_attack":
			return generate_commanders_strike_icon()
		"shield_bash":
			return generate_execute_icon()
		"cleave":
			return generate_cleave_icon()
		"taunt":
			return generate_taunt_icon()
		"last_stand":
			return generate_last_stand_icon()
		"backstab":
			return generate_backstab_icon()
		"poison_blade":
			return generate_poison_blade_icon()
		"shadowstep":
			return generate_shadow_step_icon()
		"matthias_smite":
			return generate_divine_smite_icon()
		"matthias_heal":
			return generate_healing_word_icon()
		"matthias_bless":
			return generate_bless_icon()
		_:
			return generate_attack_icon()  # Default

static func generate_attack_icon() -> ImageTexture:
	## Basic Attack - Silver sword with motion blur
	var image = _create_base_image(COLOR_DARK_GRAY)

	# Motion blur lines
	for i in range(3):
		var offset = i * 8
		_draw_line(image, Vector2i(52 - offset, 8 + offset), Vector2i(12 - offset + 4, 48 + offset - 4), COLOR_LIGHT_GRAY, 1)

	# Sword blade (diagonal)
	_draw_sword_diagonal(image, Vector2i(50, 10), Vector2i(18, 42), COLOR_SILVER, 4)

	# Sword handle
	_draw_circle(image, Vector2i(14, 48), 4, COLOR_DARK_GRAY.lightened(0.3))

	# Border
	_draw_border(image, COLOR_SILVER, 2)

	return ImageTexture.create_from_image(image)

static func generate_ranged_attack_icon() -> ImageTexture:
	## Ranged Attack - Bow with arrow
	var image = _create_base_image(COLOR_DARK_GRAY)

	# Bow (arc)
	_draw_bow_shape(image, Vector2i(20, 12), Color("#8b4513"))

	# Arrow
	_draw_horizontal_line(image, Vector2i(22, 32), 30, Color("#8b4513"), 2)
	# Arrow head
	_draw_arrow_head(image, Vector2i(52, 32), COLOR_SILVER)
	# Fletching
	_draw_fletching(image, Vector2i(22, 32), COLOR_LIGHT_GRAY)

	# Border
	_draw_border(image, COLOR_GREEN, 2)

	return ImageTexture.create_from_image(image)

static func generate_rally_icon() -> ImageTexture:
	## Rally - Golden fist with radiating light rays
	var image = _create_base_image(COLOR_BLUE)

	# Light rays emanating outward
	for i in range(8):
		var angle = i * PI / 4
		var start_x = 32 + int(cos(angle) * 12)
		var start_y = 20 + int(sin(angle) * 12)
		var end_x = 32 + int(cos(angle) * 28)
		var end_y = 20 + int(sin(angle) * 28)
		_draw_line(image, Vector2i(start_x, start_y), Vector2i(end_x, end_y), COLOR_YELLOW, 2)

	# Golden fist
	_draw_fist(image, Vector2i(32, 38), COLOR_GOLD)

	# Border
	_draw_border(image, COLOR_GOLD, 2)

	return ImageTexture.create_from_image(image)

static func generate_commanders_strike_icon() -> ImageTexture:
	## Commander's Strike - Pointing hand with sword
	var image = _create_base_image(COLOR_BLUE)

	# Pointing hand
	_draw_pointing_hand(image, Vector2i(10, 18), COLOR_TAN)

	# Sword pointing forward
	_draw_horizontal_line(image, Vector2i(16, 36), 36, COLOR_SILVER, 4)
	# Sword tip
	_draw_arrow_head(image, Vector2i(52, 36), COLOR_SILVER)

	# Target indicator
	_draw_target_indicator(image, Vector2i(44, 52), COLOR_RED)

	# Border
	_draw_border(image, COLOR_GOLD, 2)

	return ImageTexture.create_from_image(image)

static func generate_execute_icon() -> ImageTexture:
	## Execute - Sword plunging into skull
	var image = _create_base_image(COLOR_CRIMSON)

	# Sword plunging down
	_draw_vertical_line(image, Vector2i(30, 4), 28, COLOR_STEEL, 4)
	# Sword tip
	_draw_rect(image, Rect2i(28, 30, 8, 6), COLOR_STEEL)

	# Skull
	_draw_skull(image, Vector2i(32, 44), COLOR_BONE_WHITE)

	# Blood splatter
	_draw_splatter(image, Vector2i(20, 54), COLOR_DARK_RED)
	_draw_splatter(image, Vector2i(44, 52), COLOR_DARK_RED)

	# Border
	_draw_border(image, COLOR_RED, 2)

	return ImageTexture.create_from_image(image)

static func generate_cleave_icon() -> ImageTexture:
	## Cleave - Large sword with arc trail
	var image = _create_base_image(COLOR_ORANGE_RED)

	# Arc trail
	for i in range(5):
		var offset = i * 6
		_draw_line(image, Vector2i(8 + offset, 8 + offset / 2), Vector2i(56 - offset / 2, 20 + offset), COLOR_ORANGE, 2)

	# Large sword
	_draw_sword_diagonal(image, Vector2i(12, 24), Vector2i(48, 48), COLOR_STEEL, 6)

	# Multiple target indicators
	_draw_circle(image, Vector2i(18, 54), 4, COLOR_RED)
	_draw_circle(image, Vector2i(32, 54), 4, COLOR_RED)
	_draw_circle(image, Vector2i(46, 54), 4, COLOR_RED)

	# Border
	_draw_border(image, COLOR_ORANGE, 2)

	return ImageTexture.create_from_image(image)

static func generate_taunt_icon() -> ImageTexture:
	## Taunt - Angry face with sound waves
	var image = _create_base_image(COLOR_DARK_RED)

	# Sound waves
	for i in range(3):
		var radius = 20 + i * 6
		_draw_arc(image, Vector2i(10, 32), radius, -PI/3, PI/3, COLOR_ORANGE)
		_draw_arc(image, Vector2i(54, 32), radius, PI*2/3, PI*4/3, COLOR_ORANGE)

	# Angry face
	_draw_angry_face(image, Vector2i(32, 32), COLOR_RED)

	# Arrows pointing in
	_draw_arrow_indicator(image, Vector2i(18, 52), Vector2i(1, 0), COLOR_YELLOW)
	_draw_arrow_indicator(image, Vector2i(32, 56), Vector2i(0, -1), COLOR_YELLOW)
	_draw_arrow_indicator(image, Vector2i(46, 52), Vector2i(-1, 0), COLOR_YELLOW)

	# Border
	_draw_border(image, COLOR_RED, 2)

	return ImageTexture.create_from_image(image)

static func generate_last_stand_icon() -> ImageTexture:
	## Last Stand - Cracked shield with backlight
	var image = _create_base_image(COLOR_BLACK)

	# Dramatic backlight
	for i in range(8):
		var angle = i * PI / 4
		var start_x = 32 + int(cos(angle) * 8)
		var start_y = 16 + int(sin(angle) * 8)
		var end_x = 32 + int(cos(angle) * 20)
		var end_y = 16 + int(sin(angle) * 20)
		_draw_line(image, Vector2i(start_x, start_y), Vector2i(end_x, end_y), COLOR_YELLOW, 2)

	# Cracked shield
	_draw_cracked_shield(image, Vector2i(32, 36), COLOR_GOLD)

	# Figure silhouette behind shield
	_draw_rect(image, Rect2i(28, 24, 8, 16), COLOR_BLACK)

	# "1 HP" text area
	_draw_rect(image, Rect2i(20, 54, 24, 8), COLOR_DARK_GRAY)

	# Border
	_draw_border(image, COLOR_GOLD, 2)

	return ImageTexture.create_from_image(image)

static func generate_backstab_icon() -> ImageTexture:
	## Backstab - Dagger into silhouette from behind
	var image = _create_base_image(COLOR_DEEP_PURPLE)

	# Target silhouette (from behind)
	_draw_rounded_rect(image, Rect2i(18, 14, 20, 36), COLOR_CHARCOAL, 4)

	# Dagger entering from right
	_draw_horizontal_line(image, Vector2i(38, 32), 20, COLOR_SILVER, 3)
	# Dagger handle
	_draw_rect(image, Rect2i(54, 30, 6, 6), COLOR_DARK)

	# Shadow wisps
	_draw_wisp(image, Vector2i(14, 50), COLOR_PURPLE)
	_draw_wisp(image, Vector2i(26, 52), COLOR_PURPLE)
	_draw_wisp(image, Vector2i(42, 50), COLOR_PURPLE)

	# Border
	_draw_border(image, COLOR_PURPLE, 2)

	return ImageTexture.create_from_image(image)

static func generate_poison_blade_icon() -> ImageTexture:
	## Poison Blade - Dagger dripping with poison
	var image = _create_base_image(COLOR_DARK_GREEN)

	# Skull vapor at top
	_draw_mini_skull(image, Vector2i(32, 12), COLOR_BONE_WHITE)

	# Dagger blade (vertical)
	_draw_dagger_vertical(image, Vector2i(32, 22), COLOR_SILVER)

	# Poison coating (green tint on blade)
	_draw_poison_drip(image, Vector2i(32, 30), COLOR_GREEN)

	# Poison drops falling
	_draw_circle(image, Vector2i(26, 54), 3, COLOR_BRIGHT_GREEN)
	_draw_circle(image, Vector2i(32, 56), 3, COLOR_BRIGHT_GREEN)
	_draw_circle(image, Vector2i(38, 54), 3, COLOR_BRIGHT_GREEN)

	# Border
	_draw_border(image, COLOR_GREEN, 2)

	return ImageTexture.create_from_image(image)

static func generate_shadow_step_icon() -> ImageTexture:
	## Shadow Step - Ghostly teleport figure
	var image = _create_base_image(COLOR_BLACK)

	# Fading figure on left (transparent effect)
	_draw_ghost_figure(image, Vector2i(16, 20), COLOR_PURPLE, 0.4)

	# Arrow indicating movement
	_draw_horizontal_line(image, Vector2i(26, 32), 12, COLOR_PURPLE, 2)
	_draw_arrow_head(image, Vector2i(38, 32), COLOR_PURPLE)

	# Solid figure on right
	_draw_ghost_figure(image, Vector2i(46, 20), COLOR_DARK, 1.0)

	# Shadow trails at bottom
	_draw_shadow_trails(image, Vector2i(16, 48), COLOR_DEEP_PURPLE)
	_draw_shadow_trails(image, Vector2i(46, 48), COLOR_DEEP_PURPLE)

	# Border
	_draw_border(image, COLOR_PURPLE, 2)

	return ImageTexture.create_from_image(image)

static func generate_divine_smite_icon() -> ImageTexture:
	## Divine Smite - Golden hammer with holy light
	var image = _create_base_image(COLOR_HOLY_YELLOW)

	# Holy light rays
	for i in range(8):
		var angle = i * PI / 4 - PI / 2
		var start_x = 32 + int(cos(angle) * 6)
		var start_y = 12 + int(sin(angle) * 6)
		var end_x = 32 + int(cos(angle) * 18)
		var end_y = 12 + int(sin(angle) * 18)
		_draw_line(image, Vector2i(start_x, start_y), Vector2i(end_x, end_y), COLOR_YELLOW, 2)

	# Golden hammer head
	_draw_rect(image, Rect2i(16, 20, 32, 12), COLOR_GOLD)
	# Hammer border
	_draw_rect_outline(image, Rect2i(16, 20, 32, 12), COLOR_WHITE, 1)

	# Handle
	_draw_vertical_line(image, Vector2i(30, 32), 20, COLOR_GOLD, 4)

	# Sparkles
	_draw_sparkle(image, Vector2i(12, 50), COLOR_WHITE)
	_draw_sparkle(image, Vector2i(52, 50), COLOR_WHITE)

	# Border
	_draw_border(image, COLOR_GOLD, 2)

	return ImageTexture.create_from_image(image)

static func generate_healing_word_icon() -> ImageTexture:
	## Healing Word - Hands with healing heart
	var image = _create_base_image(COLOR_DARK_GREEN)

	# Sparkles at top
	_draw_sparkle(image, Vector2i(20, 8), COLOR_YELLOW)
	_draw_sparkle(image, Vector2i(32, 6), COLOR_YELLOW)
	_draw_sparkle(image, Vector2i(44, 8), COLOR_YELLOW)

	# Heart with plus
	_draw_heart(image, Vector2i(32, 20), COLOR_GREEN)
	_draw_plus(image, Vector2i(32, 20), COLOR_WHITE)

	# Open hands
	_draw_open_hand(image, Vector2i(16, 38), COLOR_TAN)
	_draw_open_hand(image, Vector2i(48, 38), COLOR_TAN)

	# Healing waves
	_draw_wave(image, Vector2i(24, 52), COLOR_GOLD)
	_draw_wave(image, Vector2i(32, 54), COLOR_GOLD)
	_draw_wave(image, Vector2i(40, 52), COLOR_GOLD)

	# Border
	_draw_border(image, COLOR_GREEN, 2)

	return ImageTexture.create_from_image(image)

static func generate_bless_icon() -> ImageTexture:
	## Bless - Sun radiating down onto figures
	var image = _create_base_image(COLOR_HOLY_YELLOW)

	# Sun symbol at top
	_draw_sun(image, Vector2i(32, 12), COLOR_GOLD)

	# Light beams down
	_draw_vertical_line(image, Vector2i(28, 20), 20, COLOR_YELLOW, 2)
	_draw_vertical_line(image, Vector2i(32, 18), 22, COLOR_YELLOW, 2)
	_draw_vertical_line(image, Vector2i(36, 20), 20, COLOR_YELLOW, 2)

	# Downward arrows
	_draw_arrow_indicator(image, Vector2i(28, 38), Vector2i(0, 1), COLOR_YELLOW)
	_draw_arrow_indicator(image, Vector2i(32, 40), Vector2i(0, 1), COLOR_YELLOW)
	_draw_arrow_indicator(image, Vector2i(36, 38), Vector2i(0, 1), COLOR_YELLOW)

	# Multiple figures being blessed
	_draw_blessed_figure(image, Vector2i(16, 48), COLOR_LIGHT_BLUE)
	_draw_blessed_figure(image, Vector2i(32, 48), COLOR_LIGHT_BLUE)
	_draw_blessed_figure(image, Vector2i(48, 48), COLOR_LIGHT_BLUE)

	# Border
	_draw_border(image, COLOR_GOLD, 2)

	return ImageTexture.create_from_image(image)

# ===== HELPER METHODS =====

static func _create_base_image(bg_color: Color) -> Image:
	## Create base image with background
	var image = Image.create(ICON_SIZE, ICON_SIZE, false, Image.FORMAT_RGBA8)
	image.fill(bg_color)
	return image

static func _draw_rect(image: Image, rect: Rect2i, color: Color) -> void:
	## Fill a rectangle
	for x in range(rect.position.x, rect.position.x + rect.size.x):
		for y in range(rect.position.y, rect.position.y + rect.size.y):
			if x >= 0 and x < ICON_SIZE and y >= 0 and y < ICON_SIZE:
				image.set_pixel(x, y, color)

static func _draw_rounded_rect(image: Image, rect: Rect2i, color: Color, radius: int) -> void:
	## Fill rectangle with rounded corners
	for x in range(rect.position.x, rect.position.x + rect.size.x):
		for y in range(rect.position.y, rect.position.y + rect.size.y):
			if x >= 0 and x < ICON_SIZE and y >= 0 and y < ICON_SIZE:
				var local_x = x - rect.position.x
				var local_y = y - rect.position.y
				var in_corner = false

				if local_x < radius and local_y < radius:
					in_corner = Vector2(local_x - radius, local_y - radius).length() > radius
				elif local_x >= rect.size.x - radius and local_y < radius:
					in_corner = Vector2(local_x - (rect.size.x - radius - 1), local_y - radius).length() > radius
				elif local_x < radius and local_y >= rect.size.y - radius:
					in_corner = Vector2(local_x - radius, local_y - (rect.size.y - radius - 1)).length() > radius
				elif local_x >= rect.size.x - radius and local_y >= rect.size.y - radius:
					in_corner = Vector2(local_x - (rect.size.x - radius - 1), local_y - (rect.size.y - radius - 1)).length() > radius

				if not in_corner:
					image.set_pixel(x, y, color)

static func _draw_rect_outline(image: Image, rect: Rect2i, color: Color, width: int) -> void:
	## Draw rectangle outline only
	for x in range(rect.position.x, rect.position.x + rect.size.x):
		for y in range(rect.position.y, rect.position.y + rect.size.y):
			if x >= 0 and x < ICON_SIZE and y >= 0 and y < ICON_SIZE:
				var on_edge = (
					x < rect.position.x + width or
					x >= rect.position.x + rect.size.x - width or
					y < rect.position.y + width or
					y >= rect.position.y + rect.size.y - width
				)
				if on_edge:
					image.set_pixel(x, y, color)

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
		for w in range(-width/2, width/2 + 1):
			var y = start.y + w
			if x >= 0 and x < ICON_SIZE and y >= 0 and y < ICON_SIZE:
				image.set_pixel(x, y, color)

static func _draw_vertical_line(image: Image, start: Vector2i, length: int, color: Color, width: int) -> void:
	## Draw vertical line
	for y in range(start.y, start.y + length):
		for w in range(-width/2, width/2 + 1):
			var x = start.x + w
			if x >= 0 and x < ICON_SIZE and y >= 0 and y < ICON_SIZE:
				image.set_pixel(x, y, color)

static func _draw_line(image: Image, from: Vector2i, to: Vector2i, color: Color, width: int) -> void:
	## Draw line using Bresenham with width
	var dx = abs(to.x - from.x)
	var dy = abs(to.y - from.y)
	var sx = 1 if from.x < to.x else -1
	var sy = 1 if from.y < to.y else -1
	var err = dx - dy
	var x = from.x
	var y = from.y

	while true:
		for wx in range(-width/2, width/2 + 1):
			for wy in range(-width/2, width/2 + 1):
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

static func _draw_border(image: Image, color: Color, width: int) -> void:
	## Draw border around image
	for x in range(ICON_SIZE):
		for y in range(ICON_SIZE):
			if x < width or x >= ICON_SIZE - width or y < width or y >= ICON_SIZE - width:
				image.set_pixel(x, y, color)

static func _draw_arc(image: Image, center: Vector2i, radius: int, start_angle: float, end_angle: float, color: Color) -> void:
	## Draw an arc
	var steps = 32
	for i in range(steps):
		var angle = start_angle + (end_angle - start_angle) * i / steps
		var x = center.x + int(cos(angle) * radius)
		var y = center.y + int(sin(angle) * radius)
		if x >= 0 and x < ICON_SIZE and y >= 0 and y < ICON_SIZE:
			image.set_pixel(x, y, color)

# ===== SPECIAL SHAPE METHODS =====

static func _draw_sword_diagonal(image: Image, from: Vector2i, to: Vector2i, color: Color, width: int) -> void:
	## Draw a diagonal sword blade
	_draw_line(image, from, to, color, width)
	# Highlight
	_draw_line(image, Vector2i(from.x + 1, from.y + 1), Vector2i(to.x + 1, to.y + 1), color.lightened(0.3), 1)

static func _draw_fist(image: Image, center: Vector2i, color: Color) -> void:
	## Draw a raised fist
	_draw_rounded_rect(image, Rect2i(center.x - 8, center.y - 12, 16, 20), color, 3)
	# Knuckles
	_draw_horizontal_line(image, Vector2i(center.x - 6, center.y - 10), 12, color.darkened(0.2), 3)

static func _draw_pointing_hand(image: Image, start: Vector2i, color: Color) -> void:
	## Draw a pointing hand
	# Palm
	_draw_rounded_rect(image, Rect2i(start.x, start.y, 12, 16), color, 2)
	# Pointing finger
	_draw_horizontal_line(image, Vector2i(start.x + 10, start.y + 6), 20, color, 4)

static func _draw_target_indicator(image: Image, center: Vector2i, color: Color) -> void:
	## Draw a target indicator
	_draw_rect_outline(image, Rect2i(center.x - 6, center.y - 6, 12, 12), color, 2)
	_draw_circle(image, center, 2, color)

static func _draw_skull(image: Image, center: Vector2i, color: Color) -> void:
	## Draw a skull
	_draw_rounded_rect(image, Rect2i(center.x - 10, center.y - 8, 20, 14), color, 4)
	# Eye sockets
	_draw_circle(image, Vector2i(center.x - 4, center.y - 2), 3, COLOR_BLACK)
	_draw_circle(image, Vector2i(center.x + 4, center.y - 2), 3, COLOR_BLACK)
	# Nose
	_draw_rect(image, Rect2i(center.x - 1, center.y + 2, 2, 3), COLOR_BLACK)
	# Teeth
	_draw_horizontal_line(image, Vector2i(center.x - 6, center.y + 4), 12, COLOR_BLACK, 2)

static func _draw_splatter(image: Image, center: Vector2i, color: Color) -> void:
	## Draw blood splatter
	for i in range(5):
		var angle = randf() * TAU
		var dist = randi() % 6 + 2
		var x = center.x + int(cos(angle) * dist)
		var y = center.y + int(sin(angle) * dist)
		_draw_circle(image, Vector2i(x, y), randi() % 2 + 1, color)

static func _draw_angry_face(image: Image, center: Vector2i, color: Color) -> void:
	## Draw an angry face
	_draw_rounded_rect(image, Rect2i(center.x - 12, center.y - 12, 24, 20), color, 4)
	# Angry eyes (diagonal lines)
	_draw_line(image, Vector2i(center.x - 8, center.y - 6), Vector2i(center.x - 2, center.y - 2), COLOR_BLACK, 2)
	_draw_line(image, Vector2i(center.x + 8, center.y - 6), Vector2i(center.x + 2, center.y - 2), COLOR_BLACK, 2)
	# Shouting mouth
	_draw_rect(image, Rect2i(center.x - 6, center.y + 2, 12, 6), COLOR_BLACK)

static func _draw_arrow_indicator(image: Image, tip: Vector2i, direction: Vector2i, color: Color) -> void:
	## Draw a directional arrow
	var base = Vector2i(tip.x - direction.x * 8, tip.y - direction.y * 8)
	_draw_line(image, base, tip, color, 2)
	# Arrow head
	if direction.x != 0:
		_draw_line(image, tip, Vector2i(tip.x - direction.x * 3, tip.y - 3), color, 1)
		_draw_line(image, tip, Vector2i(tip.x - direction.x * 3, tip.y + 3), color, 1)
	else:
		_draw_line(image, tip, Vector2i(tip.x - 3, tip.y - direction.y * 3), color, 1)
		_draw_line(image, tip, Vector2i(tip.x + 3, tip.y - direction.y * 3), color, 1)

static func _draw_cracked_shield(image: Image, center: Vector2i, color: Color) -> void:
	## Draw a cracked shield
	# Shield shape
	for y in range(center.y - 14, center.y + 14):
		var row = y - (center.y - 14)
		var width: int
		if row < 16:
			width = 20
		else:
			width = 20 - (row - 16)
		for x in range(center.x - width/2, center.x + width/2):
			if x >= 0 and x < ICON_SIZE and y >= 0 and y < ICON_SIZE:
				image.set_pixel(x, y, color)

	# Crack lines
	_draw_line(image, Vector2i(center.x, center.y - 12), Vector2i(center.x - 4, center.y + 4), COLOR_BLACK, 1)
	_draw_line(image, Vector2i(center.x - 4, center.y + 4), Vector2i(center.x + 2, center.y + 10), COLOR_BLACK, 1)

static func _draw_wisp(image: Image, center: Vector2i, color: Color) -> void:
	## Draw a shadow wisp
	var wisp_color = Color(color.r, color.g, color.b, 0.6)
	for i in range(6):
		var x = center.x + i
		var y = center.y - int(sin(i * 0.5) * 3)
		if x >= 0 and x < ICON_SIZE and y >= 0 and y < ICON_SIZE:
			image.set_pixel(x, y, wisp_color)

static func _draw_mini_skull(image: Image, center: Vector2i, color: Color) -> void:
	## Draw a small skull for poison vapor
	_draw_circle(image, center, 6, color)
	_draw_circle(image, Vector2i(center.x - 2, center.y - 1), 2, COLOR_BLACK)
	_draw_circle(image, Vector2i(center.x + 2, center.y - 1), 2, COLOR_BLACK)
	_draw_rect(image, Rect2i(center.x - 1, center.y + 2, 2, 2), COLOR_BLACK)

static func _draw_dagger_vertical(image: Image, center: Vector2i, color: Color) -> void:
	## Draw a vertical dagger
	# Blade
	for i in range(20):
		var y = center.y + i
		var half_width = 3 - i / 8
		if half_width < 1:
			half_width = 1
		for x in range(center.x - half_width, center.x + half_width + 1):
			if x >= 0 and x < ICON_SIZE and y >= 0 and y < ICON_SIZE:
				image.set_pixel(x, y, color)
	# Handle
	_draw_rect(image, Rect2i(center.x - 2, center.y + 20, 4, 8), COLOR_DARK)

static func _draw_poison_drip(image: Image, center: Vector2i, color: Color) -> void:
	## Draw poison dripping on blade
	var drip_color = Color(color.r, color.g, color.b, 0.7)
	for i in range(12):
		var y = center.y + i
		var x_offset = int(sin(i * 0.5) * 2)
		for dx in range(-1, 2):
			var x = center.x + dx + x_offset
			if x >= 0 and x < ICON_SIZE and y >= 0 and y < ICON_SIZE:
				image.set_pixel(x, y, drip_color)

static func _draw_ghost_figure(image: Image, center: Vector2i, color: Color, alpha: float) -> void:
	## Draw a ghostly figure
	var ghost_color = Color(color.r, color.g, color.b, alpha)
	_draw_rounded_rect(image, Rect2i(center.x - 6, center.y, 12, 20), ghost_color, 3)
	_draw_circle(image, Vector2i(center.x, center.y - 4), 5, ghost_color)

static func _draw_shadow_trails(image: Image, center: Vector2i, color: Color) -> void:
	## Draw shadow trail effect
	for i in range(8):
		var x = center.x + i - 4
		var y = center.y + int(sin(i * 0.8) * 2)
		if x >= 0 and x < ICON_SIZE and y >= 0 and y < ICON_SIZE:
			image.set_pixel(x, y, color)

static func _draw_sun(image: Image, center: Vector2i, color: Color) -> void:
	## Draw sun symbol
	_draw_circle(image, center, 5, color)
	for i in range(8):
		var angle = i * PI / 4
		var end_x = center.x + int(cos(angle) * 10)
		var end_y = center.y + int(sin(angle) * 10)
		_draw_line(image, center, Vector2i(end_x, end_y), color, 1)

static func _draw_blessed_figure(image: Image, center: Vector2i, color: Color) -> void:
	## Draw a small blessed figure
	_draw_rect(image, Rect2i(center.x - 3, center.y, 6, 10), color)
	_draw_circle(image, Vector2i(center.x, center.y - 2), 3, color)
	# Up arrow above
	_draw_arrow_indicator(image, Vector2i(center.x, center.y - 8), Vector2i(0, -1), COLOR_GREEN)

static func _draw_heart(image: Image, center: Vector2i, color: Color) -> void:
	## Draw a heart shape
	_draw_circle(image, Vector2i(center.x - 4, center.y - 2), 5, color)
	_draw_circle(image, Vector2i(center.x + 4, center.y - 2), 5, color)
	# Bottom triangle
	for y in range(center.y, center.y + 10):
		var row = y - center.y
		var half_width = 8 - row
		if half_width > 0:
			for x in range(center.x - half_width, center.x + half_width + 1):
				if x >= 0 and x < ICON_SIZE and y >= 0 and y < ICON_SIZE:
					image.set_pixel(x, y, color)

static func _draw_plus(image: Image, center: Vector2i, color: Color) -> void:
	## Draw a plus sign
	_draw_horizontal_line(image, Vector2i(center.x - 4, center.y), 8, color, 2)
	_draw_vertical_line(image, Vector2i(center.x, center.y - 4), 8, color, 2)

static func _draw_open_hand(image: Image, center: Vector2i, color: Color) -> void:
	## Draw an open hand
	_draw_rounded_rect(image, Rect2i(center.x - 5, center.y, 10, 12), color, 2)
	# Fingers
	for i in range(4):
		_draw_rect(image, Rect2i(center.x - 4 + i * 3, center.y - 6, 2, 6), color)

static func _draw_wave(image: Image, center: Vector2i, color: Color) -> void:
	## Draw a wavy line
	for i in range(8):
		var x = center.x + i - 4
		var y = center.y + int(sin(i * 0.8) * 2)
		if x >= 0 and x < ICON_SIZE and y >= 0 and y < ICON_SIZE:
			image.set_pixel(x, y, color)

static func _draw_sparkle(image: Image, center: Vector2i, color: Color) -> void:
	## Draw a sparkle/star
	image.set_pixel(center.x, center.y, color)
	image.set_pixel(center.x - 2, center.y, color)
	image.set_pixel(center.x + 2, center.y, color)
	image.set_pixel(center.x, center.y - 2, color)
	image.set_pixel(center.x, center.y + 2, color)

static func _draw_bow_shape(image: Image, start: Vector2i, color: Color) -> void:
	## Draw a bow curve
	for i in range(40):
		var y = start.y + i
		var curve = int(6 * sin(i * PI / 40))
		var x = start.x + curve
		if x >= 0 and x < ICON_SIZE and y >= 0 and y < ICON_SIZE:
			image.set_pixel(x, y, color)
			if x + 1 < ICON_SIZE:
				image.set_pixel(x + 1, y, color)

static func _draw_arrow_head(image: Image, tip: Vector2i, color: Color) -> void:
	## Draw an arrow head pointing right
	for i in range(6):
		var x = tip.x - i
		for dy in range(-i/2, i/2 + 1):
			var y = tip.y + dy
			if x >= 0 and x < ICON_SIZE and y >= 0 and y < ICON_SIZE:
				image.set_pixel(x, y, color)

static func _draw_fletching(image: Image, start: Vector2i, color: Color) -> void:
	## Draw arrow fletching
	for i in range(3):
		var x = start.x + i * 2
		_draw_line(image, Vector2i(x, start.y - 3), Vector2i(x, start.y + 3), color, 1)
