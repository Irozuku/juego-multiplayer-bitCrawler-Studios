extends CanvasLayer

@onready var panel = $PanelContainer
@onready var timer = $Timer
@onready var icons_container = $PanelContainer/HFlowContainer

var current_elements = []
var text_index = 0
var word_array = []
var current_word_index = 0
var close = false

func _ready() -> void:
	if not timer.timeout.is_connected(_on_Timer_timeout):
		timer.timeout.connect(_on_Timer_timeout)
	panel.hide()

func set_text(text_elements: Array) -> void:
	clear_elements()
	current_elements = text_elements
	panel.show()
	text_index = 0
	close = false
	timer.start(0.1)

func start_text() -> void:
	text_index = 0
	close = false
	timer.start(0.1)

func hide_text() -> void:
	timer.stop()
	clear_elements()
	panel.hide()
	close = false

func _on_Timer_timeout() -> void:
	if text_index < current_elements.size():
		var element = current_elements[text_index]
		
		if typeof(element) == TYPE_STRING and element.ends_with(".png"):
			# Create a TextureRect for icons
			var icon = TextureRect.new()
			icon.texture = load(element)
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icons_container.add_child(icon)
		elif typeof(element) == TYPE_STRING:
			# Create a Label for text
			var label = Label.new()
			label.text = element
			label.add_theme_font_size_override("font_size", 32)
			icons_container.add_child(label)
		
		text_index += 1
		timer.start(0.1)
	else:
		close = true
		timer.stop()

func clear_elements() -> void:
	for child in icons_container.get_children():
		child.queue_free()
