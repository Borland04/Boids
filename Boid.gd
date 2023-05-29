class_name Boid
extends Polygon2D

var size: float = 10

var target: Vector2 = Vector2(0, 0)
var speed: int = 500
var boids_group: Array[Boid] = []

var steering_speed = 1

var boids_check_range = 100

var coherence_vector = Vector2(0, 0)
var coherence_factor = 0.3

var separation_vector = Vector2(0, 0)
var separation_factor = 0.3

var alignment_vector = Vector2(0, 0)
var alignment_factor = 0.8

var target_factor = 1

var direction: Vector2 = Vector2(0, 0)

var debugCanvas: CanvasItem
var highlighted = false:
	set(value):
		highlighted = value
		if value:
			debugCanvas.draw.connect(drawCoherence)
			debugCanvas.draw.connect(draw_separation)
			debugCanvas.draw.connect(draw_alignment)
		else:
			debugCanvas.draw.disconnect(drawCoherence)
			debugCanvas.draw.disconnect(draw_separation)
			debugCanvas.draw.disconnect(draw_alignment)


func _ready():
	
	updatePolygon()

func updatePolygon():
	self.polygon = [
		Vector2(size, 0),
		Vector2(-size, size/2),
		Vector2(-size/2, 0), 
		Vector2(-size, -size/2)
	]


func _process(delta):
	if highlighted:
		color = Color.RED
	else:
		color = Color.WHITE
	
	updateDirection(delta)
	if direction == null or direction == Vector2(0, 0):
		pass
	else:
		look_at(self.position + direction)
		self.position += direction * speed * delta

func updateDirection(delta):
	coherence_vector = coherence() * coherence_factor
	alignment_vector = alignment() * alignment_factor
	separation_vector = separation() * separation_factor
	
	var desired_direction = (coherence_vector + separation_vector + alignment_vector + direct_to_target()).normalized()
	direction = direction.move_toward(desired_direction, delta * steering_speed)

func coherence():
	var coherence_boids = boids_group.filter(func(b): return b != self and self.position.distance_to(b.position) < boids_check_range)
	var result = coherence_boids.reduce(func (acc, b): return acc + (b.position / coherence_boids.size()), Vector2(0, 0))
	return result.normalized() if result != Vector2(0, 0) else Vector2(0, 0)

func separation():
	return boids_group.filter(func(b): return b != self and self.position.distance_to(b.position) < boids_check_range / 2).reduce(func(acc, b): return acc - (b.position - self.position), Vector2(0, 0)).normalized()

func alignment():
	var alignment_boids = boids_group.filter(func(b): return b != self and self.position.distance_to(b.position) < boids_check_range)
	var result = alignment_boids.reduce(func (acc, b): return acc + b.direction, Vector2(0, 0))
	return result.normalized() if result != Vector2(0, 0) else Vector2(0, 0)

func direct_to_target():
	if (target == null):
		return Vector2(0, 0)
	else:
		return (target - position).normalized() * target_factor

func drawCoherence():
	debugCanvas.draw_arc(self.position, boids_check_range, 0, 2 * PI, 360, Color.GREEN)
	debugCanvas.draw_line(self.position, self.position + coherence_vector * 30, Color.YELLOW)
	var coherence_boids = boids_group.filter(func(b): return b != self and self.position.distance_to(b.position) < boids_check_range)
	if coherence_boids.size() > 0:
		var coherence_point = coherence_boids.reduce(func (acc, b): return acc + (b.position / coherence_boids.size()), Vector2(0, 0))
		debugCanvas.draw_line(self.position, coherence_point, Color.YELLOW)
		for b in coherence_boids:
			debugCanvas.draw_line(b.position, coherence_point, Color.BURLYWOOD)

func draw_separation():
	debugCanvas.draw_arc(self.position, boids_check_range / 2, 0, 2 * PI, 360, Color.RED)
	debugCanvas.draw_line(self.position, self.position + separation_vector * 30, Color.RED)
	var separation_boids = boids_group.filter(func(b): return b != self and self.position.distance_to(b.position) < boids_check_range / 2)
	if separation_boids.size() > 0:
		for b in separation_boids:
			debugCanvas.draw_line(b.position, self.position, Color.DARK_RED)

func draw_alignment():
	debugCanvas.draw_line(self.position, self.position + alignment_vector * 30, Color.BLUE)
