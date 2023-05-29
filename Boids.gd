extends Node2D

const Boid = preload("res://Boid.gd")

@export
var start_distance_from_center: int = 300:
	set(value):
		start_distance_from_center = value
		init_boids()

@export_range(1, 1000)
var boids_amount: int = 100:
	set(value):
		boids_amount = value
		init_boids()
		
var boids: Array[Boid] = []
var highlight_enabled = false
var highlighted_boid_index = -1:
	set(value):
		boids[highlighted_boid_index].highlighted = false
		highlighted_boid_index = value
		boids[highlighted_boid_index].highlighted = highlight_enabled

var boids_parent = Node2D.new()
var boids_target = null;


# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)
	boids_parent.reparent(self)
	init_boids()
	highlighted_boid_index = 0
	
	self.draw.connect(func(): if boids_target != null: self.draw_circle(boids_target, 5, Color.DARK_RED))


func init_boids():
	clean_boids()
	print("Init boids with params: %s %s" % [boids_amount, start_distance_from_center])
	for i in range(boids_amount):
		
		var boid = Boid.new()
		boid.position.x = randf_range(-500, 500)
		boid.position.y = randf_range(-500, 500)
		boid.target = Vector2(0, 0)
		boid.debugCanvas = self
		
		boids.push_back(boid)
		self.add_child(boid)
	
	for b in boids:
		b.boids_group = boids

func clean_boids():
	for b in boids:
		b.queue_free()
	self.boids = []


func _process(_delta):
	queue_redraw()

func _input(event):
	if event is InputEventMouseButton:
		boids_target = get_global_mouse_position()
		for b in boids:
			b.target = boids_target
	elif event is InputEventKey and event.pressed:
		if event.keycode == KEY_LEFT:
			highlighted_boid_index = boids.size() - 1 if highlighted_boid_index == 0 else highlighted_boid_index - 1
		elif event.keycode == KEY_RIGHT:
			highlighted_boid_index = (highlighted_boid_index + 1) % boids.size()


func _on_coherence_value_changed(value):
	for b in boids:
		b.coherence_factor = value


func _on_separation_value_changed(value):
	for b in boids:
		b.separation_factor = value


func _on_alignment_value_changed(value):
	for b in boids:
		b.alignment_factor = value


func _on_target_value_changed(value):
	for b in boids:
		b.target_factor = value


func _on_distance_value_changed(value):
	for b in boids:
		b.boids_check_range = value


func _on_speed_value_changed(value):
	for b in boids:
		b.speed = value


func _on_steering_speed_value_changed(value):
	for b in boids:
		b.steering_speed = value


func _on_pause_pressed():
	pass
	#boids_parent.get_tree().paused = not (boids_parent.get_tree().paused)


func _on_check_button_toggled(button_pressed):
	highlight_enabled = button_pressed
	highlighted_boid_index = highlighted_boid_index
