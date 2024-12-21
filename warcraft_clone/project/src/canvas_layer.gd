extends Node2D

var dragging = false  # are we currently dragging?
var selected = []  # array of selected units
var drag_start = Vector2.ZERO  # location where the drag begian
var select_rect = RectangleShape2D.new()

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if selected.size() == 0:
				dragging = true
				drag_start = get_global_mouse_position()  # Use global mouse position
			else:
				for item in selected:
					item.collider.target = get_global_mouse_position()  # Use global mouse position
					item.collider.selected = false
				selected = []
		elif dragging:
			dragging = false
			queue_redraw()
			var drag_end = get_global_mouse_position()  # Use global mouse position
			select_rect.extents = abs(drag_end - drag_start) / 2
			var space = get_world_2d().direct_space_state
			var q = PhysicsShapeQueryParameters2D.new()
			q.shape = select_rect
			q.collision_mask = 2
			q.transform = Transform2D(0, (drag_end + drag_start) / 2)
			selected = space.intersect_shape(q)
			for item in selected:
				item.collider.selected = true
	if event is InputEventMouseMotion and dragging:
		queue_redraw()

func _draw():
	if dragging:
		print(drag_start,"==" ,get_global_mouse_position())
		draw_rect(Rect2(drag_start, get_global_mouse_position()-drag_start),
				Color.YELLOW, true)
