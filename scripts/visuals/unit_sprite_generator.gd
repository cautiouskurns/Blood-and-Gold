## UnitSpriteGenerator - Generates unit sprites programmatically
## Part of: Blood & Gold Prototype
## Spec: docs/features/5.1-programmatic-visual-assets.md
class_name UnitSpriteGenerator
extends RefCounted

# ===== CONSTANTS =====
const SPRITE_SIZE: int = 48

# ===== COLOR PALETTES =====
# Player - Mercenary Captain
const PLAYER_PRIMARY: Color = Color("#5d6d7e")  # Steel Gray
const PLAYER_SECONDARY: Color = Color("#2980b9")  # Royal Blue (cape)
const PLAYER_ACCENT: Color = Color("#f1c40f")  # Gold
const PLAYER_SKIN: Color = Color("#d4a574")  # Tan

# Thorne - Fighter
const THORNE_PRIMARY: Color = Color("#34495e")  # Dark Steel
const THORNE_SECONDARY: Color = Color("#2980b9")  # Royal Blue (shield)
const THORNE_ACCENT: Color = Color("#f1c40f")  # Gold

# Lyra - Rogue
const LYRA_PRIMARY: Color = Color("#2c2c2c")  # Charcoal
const LYRA_SECONDARY: Color = Color("#6c3483")  # Deep Purple
const LYRA_ACCENT: Color = Color("#bdc3c7")  # Silver
const LYRA_EYES: Color = Color("#9b59b6")  # Violet Glow

# Matthias - Cleric
const MATTHIAS_PRIMARY: Color = Color("#ecf0f1")  # Pure White
const MATTHIAS_SECONDARY: Color = Color("#f1c40f")  # Holy Gold
const MATTHIAS_ACCENT: Color = Color("#f39c12")  # Warm Glow
const MATTHIAS_SKIN: Color = Color("#c4a574")  # Aged Tan
const MATTHIAS_BEARD: Color = Color("#95a5a6")  # Gray

# Infantry Soldier
const INFANTRY_PRIMARY: Color = Color("#7f8c8d")  # Chainmail Gray
const INFANTRY_SECONDARY: Color = Color("#27ae60")  # Forest Green
const INFANTRY_WOOD: Color = Color("#8b4513")  # Wood Brown
const INFANTRY_STEEL: Color = Color("#95a5a6")  # Steel

# Archer Soldier
const ARCHER_PRIMARY: Color = Color("#6d4c41")  # Leather Brown
const ARCHER_SECONDARY: Color = Color("#27ae60")  # Forest Green
const ARCHER_TAN: Color = Color("#d4a574")  # Tan
const ARCHER_BOW: Color = Color("#8b4513")  # Wood

# Bandit Enemy
const ENEMY_PRIMARY: Color = Color("#5d4e37")  # Dirty Brown
const ENEMY_SECONDARY: Color = Color("#c0392b")  # Crimson Red
const ENEMY_RUST: Color = Color("#d35400")  # Rust Orange
const ENEMY_SKIN: Color = Color("#b8a088")  # Sickly Tan

# ===== STATIC GENERATION METHODS =====

static func generate_sprite(unit_type: int) -> ImageTexture:
	## Generate sprite based on unit type enum
	match unit_type:
		0:  # PLAYER
			return generate_player_sprite()
		1:  # THORNE
			return generate_thorne_sprite()
		2:  # LYRA
			return generate_lyra_sprite()
		3:  # MATTHIAS
			return generate_matthias_sprite()
		4:  # ENEMY
			return generate_enemy_sprite()
		5:  # INFANTRY
			return generate_infantry_sprite()
		6:  # ARCHER
			return generate_archer_sprite()
		_:
			return generate_player_sprite()  # Default

static func generate_player_sprite() -> ImageTexture:
	## Creates the Mercenary Captain sprite
	## Steel armor with gold trim, blue cape, gold helm crest
	var image = Image.create(SPRITE_SIZE, SPRITE_SIZE, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)

	# Body - Steel armor (main rectangle)
	_draw_rounded_rect(image, Rect2i(10, 18, 28, 26), PLAYER_PRIMARY, 3)

	# Cape - Blue triangle on left
	_draw_cape(image, Vector2i(6, 20), PLAYER_SECONDARY)

	# Gold trim on armor
	_draw_horizontal_line(image, Vector2i(12, 24), 24, PLAYER_ACCENT, 2)
	_draw_horizontal_line(image, Vector2i(12, 34), 24, PLAYER_ACCENT, 2)

	# Pauldrons (shoulder guards)
	_draw_rounded_rect(image, Rect2i(6, 18, 8, 8), PLAYER_PRIMARY, 2)
	_draw_rounded_rect(image, Rect2i(34, 18, 8, 8), PLAYER_PRIMARY, 2)

	# Helm - Steel with gold crest
	_draw_rounded_rect(image, Rect2i(16, 6, 16, 14), PLAYER_PRIMARY, 2)
	_draw_horizontal_line(image, Vector2i(18, 4), 12, PLAYER_ACCENT, 3)  # Gold crest

	# Face opening
	_draw_rect(image, Rect2i(18, 10, 12, 6), PLAYER_SKIN)

	# Legs
	_draw_rect(image, Rect2i(16, 44, 6, 4), PLAYER_PRIMARY)
	_draw_rect(image, Rect2i(26, 44, 6, 4), PLAYER_PRIMARY)

	# Letter overlay "P"
	_draw_letter_p(image, Vector2i(20, 26), Color.WHITE)

	return ImageTexture.create_from_image(image)

static func generate_thorne_sprite() -> ImageTexture:
	## Creates Thorne's Fighter sprite
	## Massive armored tank with shield and lion emblem
	var image = Image.create(SPRITE_SIZE, SPRITE_SIZE, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)

	# Body - Dark steel armor (widest of all)
	_draw_rounded_rect(image, Rect2i(8, 16, 32, 28), THORNE_PRIMARY, 4)

	# Shield on left side - Kite shape
	_draw_kite_shield(image, Vector2i(2, 18), THORNE_SECONDARY, THORNE_ACCENT)

	# Great helm
	_draw_rounded_rect(image, Rect2i(14, 4, 20, 14), THORNE_PRIMARY, 2)
	# Eye slit
	_draw_horizontal_line(image, Vector2i(18, 10), 12, Color(0.1, 0.1, 0.1), 2)

	# Massive pauldrons
	_draw_rounded_rect(image, Rect2i(4, 14, 10, 10), THORNE_PRIMARY, 2)
	_draw_rounded_rect(image, Rect2i(34, 14, 10, 10), THORNE_PRIMARY, 2)

	# Gold trim
	_draw_horizontal_line(image, Vector2i(10, 22), 28, THORNE_ACCENT, 1)
	_draw_horizontal_line(image, Vector2i(10, 36), 28, THORNE_ACCENT, 1)

	# Legs
	_draw_rect(image, Rect2i(14, 44, 8, 4), THORNE_PRIMARY)
	_draw_rect(image, Rect2i(26, 44, 8, 4), THORNE_PRIMARY)

	# Letter overlay "T"
	_draw_letter_t(image, Vector2i(26, 26), THORNE_ACCENT)

	return ImageTexture.create_from_image(image)

static func generate_lyra_sprite() -> ImageTexture:
	## Creates Lyra's Rogue sprite
	## Lithe assassin with purple hood and glowing eyes
	var image = Image.create(SPRITE_SIZE, SPRITE_SIZE, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)

	# Body - Narrow charcoal (smallest width)
	_draw_rounded_rect(image, Rect2i(14, 20, 20, 22), LYRA_PRIMARY, 3)

	# Hood - Purple pointed top
	_draw_hood(image, Vector2i(24, 4), LYRA_SECONDARY)

	# Glowing violet eyes
	_draw_circle(image, Vector2i(19, 12), 2, LYRA_EYES)
	_draw_circle(image, Vector2i(28, 12), 2, LYRA_EYES)
	# Eye glow effect
	_draw_glow_pixel(image, Vector2i(19, 12), LYRA_EYES)
	_draw_glow_pixel(image, Vector2i(28, 12), LYRA_EYES)

	# Daggers at sides - Silver
	_draw_dagger(image, Vector2i(8, 26), LYRA_ACCENT, true)  # Left dagger
	_draw_dagger(image, Vector2i(36, 26), LYRA_ACCENT, false)  # Right dagger

	# Shoulders (subtle)
	_draw_rounded_rect(image, Rect2i(10, 20, 6, 6), LYRA_PRIMARY, 2)
	_draw_rounded_rect(image, Rect2i(32, 20, 6, 6), LYRA_PRIMARY, 2)

	# Crouched legs (shorter)
	_draw_rect(image, Rect2i(16, 42, 5, 4), LYRA_PRIMARY)
	_draw_rect(image, Rect2i(26, 42, 5, 4), LYRA_PRIMARY)

	# Letter overlay "L"
	_draw_letter_l(image, Vector2i(20, 28), LYRA_SECONDARY)

	return ImageTexture.create_from_image(image)

static func generate_matthias_sprite() -> ImageTexture:
	## Creates Matthias's Cleric sprite
	## Elderly priest in white robes with golden staff
	var image = Image.create(SPRITE_SIZE, SPRITE_SIZE, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)

	# Robes - Wide flowing white shape
	_draw_robes(image, Vector2i(24, 18), MATTHIAS_PRIMARY, MATTHIAS_SECONDARY)

	# Gold staff on right side
	_draw_vertical_line(image, Vector2i(40, 2), 42, MATTHIAS_SECONDARY, 2)
	# Sun symbol at staff top
	_draw_sun_symbol(image, Vector2i(40, 2), MATTHIAS_SECONDARY)

	# Head - Bald with gray beard
	_draw_circle(image, Vector2i(24, 10), 6, MATTHIAS_SKIN)
	# Beard
	_draw_rounded_rect(image, Rect2i(20, 12, 8, 6), MATTHIAS_BEARD, 2)

	# Gold trim on robes
	_draw_horizontal_line(image, Vector2i(10, 24), 28, MATTHIAS_SECONDARY, 2)
	_draw_horizontal_line(image, Vector2i(12, 32), 24, MATTHIAS_SECONDARY, 2)

	# Holy symbol pendant
	_draw_circle(image, Vector2i(24, 22), 2, MATTHIAS_SECONDARY)

	# Subtle yellow glow aura (modulate effect simulated)
	_draw_aura(image, MATTHIAS_ACCENT)

	# Letter overlay "M"
	_draw_letter_m(image, Vector2i(18, 36), MATTHIAS_SECONDARY)

	return ImageTexture.create_from_image(image)

static func generate_infantry_sprite() -> ImageTexture:
	## Creates Infantry Soldier sprite
	## Chainmail with green tabard, spear, round shield
	var image = Image.create(SPRITE_SIZE, SPRITE_SIZE, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)

	# Body - Chainmail gray
	_draw_rounded_rect(image, Rect2i(12, 18, 24, 24), INFANTRY_PRIMARY, 3)

	# Green tabard overlay in center
	_draw_rect(image, Rect2i(16, 20, 16, 20), INFANTRY_SECONDARY)

	# Round wooden shield on left
	_draw_circle(image, Vector2i(8, 28), 8, INFANTRY_WOOD)
	_draw_circle(image, Vector2i(8, 28), 6, INFANTRY_STEEL)  # Metal boss

	# Spear extending above
	_draw_vertical_line(image, Vector2i(36, 0), 20, INFANTRY_WOOD, 2)
	_draw_spear_point(image, Vector2i(36, 0), INFANTRY_STEEL)

	# Open helm
	_draw_rounded_rect(image, Rect2i(16, 6, 16, 12), INFANTRY_STEEL, 2)
	_draw_rect(image, Rect2i(18, 10, 12, 6), INFANTRY_PRIMARY)  # Open face

	# Legs
	_draw_rect(image, Rect2i(16, 42, 6, 4), INFANTRY_PRIMARY)
	_draw_rect(image, Rect2i(26, 42, 6, 4), INFANTRY_PRIMARY)

	# Letter overlay "I"
	_draw_letter_i(image, Vector2i(22, 28), INFANTRY_SECONDARY)

	return ImageTexture.create_from_image(image)

static func generate_archer_sprite() -> ImageTexture:
	## Creates Archer Soldier sprite
	## Leather armor with green hood, bow drawn
	var image = Image.create(SPRITE_SIZE, SPRITE_SIZE, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)

	# Body - Leather brown (narrow)
	_draw_rounded_rect(image, Rect2i(14, 18, 20, 24), ARCHER_PRIMARY, 3)

	# Green hood
	_draw_hood(image, Vector2i(24, 4), ARCHER_SECONDARY)

	# Face visible under hood
	_draw_rect(image, Rect2i(18, 10, 12, 8), ARCHER_TAN)

	# Bow on right side (arc shape)
	_draw_bow(image, Vector2i(38, 14), ARCHER_BOW)

	# Arrow nocked
	_draw_horizontal_line(image, Vector2i(26, 28), 14, ARCHER_BOW, 1)
	_draw_arrow_point(image, Vector2i(40, 28), INFANTRY_STEEL)

	# Quiver on back (arrows visible)
	_draw_quiver(image, Vector2i(10, 20), ARCHER_PRIMARY)

	# Legs
	_draw_rect(image, Rect2i(16, 42, 5, 4), ARCHER_PRIMARY)
	_draw_rect(image, Rect2i(26, 42, 5, 4), ARCHER_PRIMARY)

	# Letter overlay "A"
	_draw_letter_a(image, Vector2i(20, 28), ARCHER_SECONDARY)

	return ImageTexture.create_from_image(image)

static func generate_enemy_sprite() -> ImageTexture:
	## Creates Bandit Enemy sprite
	## Ragged outlaw with red bandana, rusty sword
	var image = Image.create(SPRITE_SIZE, SPRITE_SIZE, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)

	# Body - Dirty brown with tears
	_draw_rounded_rect(image, Rect2i(12, 18, 24, 24), ENEMY_PRIMARY, 3)
	# Patches/tears
	_draw_rect(image, Rect2i(14, 24, 4, 4), Color(ENEMY_PRIMARY.r * 0.7, ENEMY_PRIMARY.g * 0.7, ENEMY_PRIMARY.b * 0.7))
	_draw_rect(image, Rect2i(28, 30, 4, 4), Color(ENEMY_PRIMARY.r * 0.7, ENEMY_PRIMARY.g * 0.7, ENEMY_PRIMARY.b * 0.7))

	# Head with messy hair
	_draw_rounded_rect(image, Rect2i(16, 4, 16, 14), ENEMY_SKIN, 2)
	# Messy hair
	_draw_rect(image, Rect2i(16, 2, 16, 4), Color(0.3, 0.2, 0.15))

	# Red bandana across face
	_draw_rect(image, Rect2i(16, 12, 16, 4), ENEMY_SECONDARY)

	# Angry eyes
	_draw_rect(image, Rect2i(18, 8, 4, 2), Color(0.1, 0.1, 0.1))
	_draw_rect(image, Rect2i(26, 8, 4, 2), Color(0.1, 0.1, 0.1))
	# Angry eyebrows
	_draw_line_diagonal(image, Vector2i(17, 6), Vector2i(22, 8), Color(0.3, 0.2, 0.15))
	_draw_line_diagonal(image, Vector2i(31, 6), Vector2i(26, 8), Color(0.3, 0.2, 0.15))

	# Rusty sword extending from side
	_draw_horizontal_line(image, Vector2i(36, 30), 10, ENEMY_RUST, 3)
	_draw_rect(image, Rect2i(34, 28, 4, 6), ENEMY_PRIMARY)  # Handle

	# Legs
	_draw_rect(image, Rect2i(16, 42, 6, 4), ENEMY_PRIMARY)
	_draw_rect(image, Rect2i(26, 42, 6, 4), ENEMY_PRIMARY)

	# Red outline indicator (enemy glow)
	_draw_enemy_outline(image, ENEMY_SECONDARY)

	# Letter overlay "E"
	_draw_letter_e(image, Vector2i(20, 26), ENEMY_SECONDARY)

	return ImageTexture.create_from_image(image)

# ===== DRAWING HELPER METHODS =====

static func _draw_rect(image: Image, rect: Rect2i, color: Color) -> void:
	## Fill a rectangle with color
	for x in range(rect.position.x, rect.position.x + rect.size.x):
		for y in range(rect.position.y, rect.position.y + rect.size.y):
			if x >= 0 and x < SPRITE_SIZE and y >= 0 and y < SPRITE_SIZE:
				image.set_pixel(x, y, color)

static func _draw_rounded_rect(image: Image, rect: Rect2i, color: Color, radius: int) -> void:
	## Fill a rectangle with rounded corners
	for x in range(rect.position.x, rect.position.x + rect.size.x):
		for y in range(rect.position.y, rect.position.y + rect.size.y):
			if x >= 0 and x < SPRITE_SIZE and y >= 0 and y < SPRITE_SIZE:
				# Check if in corner region
				var in_corner = false
				var local_x = x - rect.position.x
				var local_y = y - rect.position.y

				# Top-left corner
				if local_x < radius and local_y < radius:
					var dist = Vector2(local_x - radius, local_y - radius).length()
					in_corner = dist > radius
				# Top-right corner
				elif local_x >= rect.size.x - radius and local_y < radius:
					var dist = Vector2(local_x - (rect.size.x - radius - 1), local_y - radius).length()
					in_corner = dist > radius
				# Bottom-left corner
				elif local_x < radius and local_y >= rect.size.y - radius:
					var dist = Vector2(local_x - radius, local_y - (rect.size.y - radius - 1)).length()
					in_corner = dist > radius
				# Bottom-right corner
				elif local_x >= rect.size.x - radius and local_y >= rect.size.y - radius:
					var dist = Vector2(local_x - (rect.size.x - radius - 1), local_y - (rect.size.y - radius - 1)).length()
					in_corner = dist > radius

				if not in_corner:
					image.set_pixel(x, y, color)

static func _draw_circle(image: Image, center: Vector2i, radius: int, color: Color) -> void:
	## Draw a filled circle
	for x in range(center.x - radius, center.x + radius + 1):
		for y in range(center.y - radius, center.y + radius + 1):
			if x >= 0 and x < SPRITE_SIZE and y >= 0 and y < SPRITE_SIZE:
				var dist = Vector2(x - center.x, y - center.y).length()
				if dist <= radius:
					image.set_pixel(x, y, color)

static func _draw_horizontal_line(image: Image, start: Vector2i, length: int, color: Color, width: int = 1) -> void:
	## Draw a horizontal line
	for x in range(start.x, start.x + length):
		for w in range(width):
			var y = start.y + w
			if x >= 0 and x < SPRITE_SIZE and y >= 0 and y < SPRITE_SIZE:
				image.set_pixel(x, y, color)

static func _draw_vertical_line(image: Image, start: Vector2i, length: int, color: Color, width: int = 1) -> void:
	## Draw a vertical line
	for y in range(start.y, start.y + length):
		for w in range(width):
			var x = start.x + w
			if x >= 0 and x < SPRITE_SIZE and y >= 0 and y < SPRITE_SIZE:
				image.set_pixel(x, y, color)

static func _draw_line_diagonal(image: Image, from: Vector2i, to: Vector2i, color: Color) -> void:
	## Draw a diagonal line using Bresenham's algorithm
	var dx = abs(to.x - from.x)
	var dy = abs(to.y - from.y)
	var sx = 1 if from.x < to.x else -1
	var sy = 1 if from.y < to.y else -1
	var err = dx - dy
	var x = from.x
	var y = from.y

	while true:
		if x >= 0 and x < SPRITE_SIZE and y >= 0 and y < SPRITE_SIZE:
			image.set_pixel(x, y, color)
		if x == to.x and y == to.y:
			break
		var e2 = 2 * err
		if e2 > -dy:
			err -= dy
			x += sx
		if e2 < dx:
			err += dx
			y += sy

static func _draw_glow_pixel(image: Image, center: Vector2i, color: Color) -> void:
	## Add a subtle glow effect around a pixel
	var glow_color = Color(color.r, color.g, color.b, 0.4)
	for dx in range(-2, 3):
		for dy in range(-2, 3):
			if dx == 0 and dy == 0:
				continue
			var x = center.x + dx
			var y = center.y + dy
			if x >= 0 and x < SPRITE_SIZE and y >= 0 and y < SPRITE_SIZE:
				var existing = image.get_pixel(x, y)
				if existing.a < 0.1:  # Only apply to transparent pixels
					image.set_pixel(x, y, glow_color)

# ===== SPECIAL SHAPE METHODS =====

static func _draw_cape(image: Image, start: Vector2i, color: Color) -> void:
	## Draw a flowing cape shape
	for y in range(start.y, start.y + 20):
		var row_y = y - start.y
		var width = 4 + row_y / 3
		for x in range(start.x - width / 2, start.x + width / 2):
			if x >= 0 and x < SPRITE_SIZE and y >= 0 and y < SPRITE_SIZE:
				image.set_pixel(x, y, color)

static func _draw_hood(image: Image, center: Vector2i, color: Color) -> void:
	## Draw a pointed hood shape
	# Pointed top
	for y in range(center.y - 4, center.y + 12):
		var row = y - (center.y - 4)
		var half_width = min(row, 10)
		for x in range(center.x - half_width, center.x + half_width + 1):
			if x >= 0 and x < SPRITE_SIZE and y >= 0 and y < SPRITE_SIZE:
				image.set_pixel(x, y, color)

static func _draw_kite_shield(image: Image, start: Vector2i, fill_color: Color, emblem_color: Color) -> void:
	## Draw a kite shield with lion emblem
	# Shield outline (kite shape)
	for y in range(start.y, start.y + 20):
		var row = y - start.y
		var width: int
		if row < 10:
			width = 10
		else:
			width = 10 - (row - 10)
		for x in range(start.x, start.x + width):
			if x >= 0 and x < SPRITE_SIZE and y >= 0 and y < SPRITE_SIZE:
				image.set_pixel(x, y, fill_color)

	# Simple lion emblem (gold cross pattern)
	_draw_vertical_line(image, Vector2i(start.x + 4, start.y + 4), 10, emblem_color, 2)
	_draw_horizontal_line(image, Vector2i(start.x + 2, start.y + 8), 6, emblem_color, 2)

static func _draw_dagger(image: Image, start: Vector2i, color: Color, point_left: bool) -> void:
	## Draw a dagger pointing outward
	var direction = -1 if point_left else 1
	# Blade
	for i in range(8):
		var x = start.x + (i * direction)
		var y1 = start.y - i / 3
		var y2 = start.y + i / 3
		if x >= 0 and x < SPRITE_SIZE:
			if y1 >= 0 and y1 < SPRITE_SIZE:
				image.set_pixel(x, y1, color)
			if y2 >= 0 and y2 < SPRITE_SIZE:
				image.set_pixel(x, y2, color)
			if y1 != y2:
				for y in range(y1 + 1, y2):
					if y >= 0 and y < SPRITE_SIZE:
						image.set_pixel(x, y, color)

static func _draw_robes(image: Image, center: Vector2i, color: Color, trim_color: Color) -> void:
	## Draw flowing robes shape
	# Upper body
	_draw_rounded_rect(image, Rect2i(center.x - 14, center.y, 28, 12), color, 3)
	# Lower robes (flared)
	for y in range(center.y + 12, center.y + 26):
		var row = y - (center.y + 12)
		var half_width = 14 + row / 2
		for x in range(center.x - half_width, center.x + half_width):
			if x >= 0 and x < SPRITE_SIZE and y >= 0 and y < SPRITE_SIZE:
				image.set_pixel(x, y, color)

static func _draw_sun_symbol(image: Image, center: Vector2i, color: Color) -> void:
	## Draw a sun symbol (circle with rays)
	_draw_circle(image, center, 3, color)
	# Rays
	for i in range(8):
		var angle = i * PI / 4
		var dx = int(cos(angle) * 5)
		var dy = int(sin(angle) * 5)
		var end_x = center.x + dx
		var end_y = center.y + dy
		if end_x >= 0 and end_x < SPRITE_SIZE and end_y >= 0 and end_y < SPRITE_SIZE:
			image.set_pixel(end_x, end_y, color)

static func _draw_aura(image: Image, color: Color) -> void:
	## Draw a subtle aura effect around the sprite
	var aura_color = Color(color.r, color.g, color.b, 0.15)
	for x in range(SPRITE_SIZE):
		for y in range(SPRITE_SIZE):
			var existing = image.get_pixel(x, y)
			if existing.a > 0.5:
				# Add glow to adjacent transparent pixels
				for dx in range(-2, 3):
					for dy in range(-2, 3):
						var nx = x + dx
						var ny = y + dy
						if nx >= 0 and nx < SPRITE_SIZE and ny >= 0 and ny < SPRITE_SIZE:
							var neighbor = image.get_pixel(nx, ny)
							if neighbor.a < 0.1:
								image.set_pixel(nx, ny, aura_color)

static func _draw_spear_point(image: Image, tip: Vector2i, color: Color) -> void:
	## Draw a spear point
	for i in range(6):
		var y = tip.y + i
		var half_width = i / 2
		for x in range(tip.x - half_width, tip.x + half_width + 1):
			if x >= 0 and x < SPRITE_SIZE and y >= 0 and y < SPRITE_SIZE:
				image.set_pixel(x, y, color)

static func _draw_bow(image: Image, center: Vector2i, color: Color) -> void:
	## Draw a curved bow
	for i in range(20):
		var y = center.y + i
		var curve = int(4 * sin(i * PI / 20))
		var x = center.x + curve
		if x >= 0 and x < SPRITE_SIZE and y >= 0 and y < SPRITE_SIZE:
			image.set_pixel(x, y, color)
			if x + 1 < SPRITE_SIZE:
				image.set_pixel(x + 1, y, color)

static func _draw_arrow_point(image: Image, tip: Vector2i, color: Color) -> void:
	## Draw an arrow point
	_draw_rect(image, Rect2i(tip.x, tip.y - 1, 3, 3), color)

static func _draw_quiver(image: Image, start: Vector2i, color: Color) -> void:
	## Draw a quiver with arrows
	_draw_rounded_rect(image, Rect2i(start.x, start.y, 6, 16), color, 2)
	# Arrow fletching
	for i in range(4):
		var x = start.x + 1 + i
		if x < SPRITE_SIZE:
			image.set_pixel(x, start.y - 2, Color(0.8, 0.8, 0.8))

static func _draw_enemy_outline(image: Image, color: Color) -> void:
	## Draw a red outline around the sprite to indicate enemy
	var outline_color = Color(color.r, color.g, color.b, 0.6)
	for x in range(SPRITE_SIZE):
		for y in range(SPRITE_SIZE):
			var pixel = image.get_pixel(x, y)
			if pixel.a > 0.5:
				# Check if this is an edge pixel
				var is_edge = false
				for dx in [-1, 0, 1]:
					for dy in [-1, 0, 1]:
						if dx == 0 and dy == 0:
							continue
						var nx = x + dx
						var ny = y + dy
						if nx >= 0 and nx < SPRITE_SIZE and ny >= 0 and ny < SPRITE_SIZE:
							var neighbor = image.get_pixel(nx, ny)
							if neighbor.a < 0.1:
								is_edge = true
								break
					if is_edge:
						break

				if is_edge:
					# Apply red tint to edge pixels
					image.set_pixel(x, y, outline_color.blend(pixel))

# ===== LETTER DRAWING METHODS =====

static func _draw_letter_p(image: Image, start: Vector2i, color: Color) -> void:
	## Draw letter P
	_draw_vertical_line(image, start, 10, color, 2)
	_draw_horizontal_line(image, start, 6, color, 2)
	_draw_horizontal_line(image, Vector2i(start.x, start.y + 4), 6, color, 2)
	_draw_vertical_line(image, Vector2i(start.x + 4, start.y), 6, color, 2)

static func _draw_letter_t(image: Image, start: Vector2i, color: Color) -> void:
	## Draw letter T
	_draw_horizontal_line(image, start, 8, color, 2)
	_draw_vertical_line(image, Vector2i(start.x + 3, start.y), 10, color, 2)

static func _draw_letter_l(image: Image, start: Vector2i, color: Color) -> void:
	## Draw letter L
	_draw_vertical_line(image, start, 10, color, 2)
	_draw_horizontal_line(image, Vector2i(start.x, start.y + 8), 6, color, 2)

static func _draw_letter_m(image: Image, start: Vector2i, color: Color) -> void:
	## Draw letter M
	_draw_vertical_line(image, start, 8, color, 2)
	_draw_vertical_line(image, Vector2i(start.x + 8, start.y), 8, color, 2)
	# Middle peaks
	_draw_line_diagonal(image, Vector2i(start.x + 1, start.y), Vector2i(start.x + 4, start.y + 4), color)
	_draw_line_diagonal(image, Vector2i(start.x + 7, start.y), Vector2i(start.x + 4, start.y + 4), color)

static func _draw_letter_i(image: Image, start: Vector2i, color: Color) -> void:
	## Draw letter I
	_draw_horizontal_line(image, start, 6, color, 2)
	_draw_vertical_line(image, Vector2i(start.x + 2, start.y), 10, color, 2)
	_draw_horizontal_line(image, Vector2i(start.x, start.y + 8), 6, color, 2)

static func _draw_letter_a(image: Image, start: Vector2i, color: Color) -> void:
	## Draw letter A
	_draw_vertical_line(image, start, 10, color, 2)
	_draw_vertical_line(image, Vector2i(start.x + 6, start.y), 10, color, 2)
	_draw_horizontal_line(image, start, 8, color, 2)
	_draw_horizontal_line(image, Vector2i(start.x, start.y + 4), 8, color, 2)

static func _draw_letter_e(image: Image, start: Vector2i, color: Color) -> void:
	## Draw letter E
	_draw_vertical_line(image, start, 10, color, 2)
	_draw_horizontal_line(image, start, 6, color, 2)
	_draw_horizontal_line(image, Vector2i(start.x, start.y + 4), 5, color, 2)
	_draw_horizontal_line(image, Vector2i(start.x, start.y + 8), 6, color, 2)
