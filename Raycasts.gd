extends Node2D

var distances = [0, 0, 0, 0, 0]

func _draw():
	if Singleton.showRaycasts:
		if get_parent().engine_on:
			for child in get_children():
				draw_line(position, to_local(child.get_collision_point()), Color(225, 0, 0), 5)

func _process(_delta):
	for i in range(get_child_count()):
		var distance = global_position.distance_to(get_child(i).get_collision_point())
		distances[i] = distance
	#if get_parent().engine_on:
	update()
