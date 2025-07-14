@tool
extends EditorPlugin

# TODO: Maybe see if there is a better way of registering the current tab (2D,
# 3D, Script etc.)

var button
var plugin_enabled

func _enter_tree():
	print("Plugin loaded")
	button = Button.new()
	button.text = "Toggle Plugin"
	button.toggle_mode = true
	button.toggled.connect(_on_button_toggled)
	add_control_to_container(CONTAINER_TOOLBAR, button)

func _exit_tree():
	remove_control_from_container(CONTAINER_TOOLBAR, button)
	button.free()

func _on_button_toggled(enabled):
	plugin_enabled = enabled
	print("Plugin enabled = ", enabled)

func _input(event):
	if plugin_enabled:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
				var viewport = EditorInterface.get_editor_viewport_3d(0)
				var mouse_pos = viewport.get_mouse_position()
				var camera = viewport.get_camera_3d()
				if !in_3d_mode():
					print("not in 3d mode")
					return
				if !inside_viewport(mouse_pos, viewport):
					print("not in 3d viewport")
					return
				var pos3d = get_3d_position_on_y_eq_0(camera, mouse_pos)
				print("clicked ", mouse_pos, " which represents ", pos3d, " in 3d")
				viewport.set_input_as_handled()
					

func inside_viewport(position: Vector2, sub_viewport: SubViewport) -> bool:
	if position.x < 0 or position.y < 0:
		return false
	if position.x > sub_viewport.size.x or position.y > sub_viewport.size.y:
		return false
	return true
	
func get_3d_position_on_y_eq_0(camera: Camera3D, position2d: Vector2):
	var plane  = Plane(Vector3(0, 1, 0))
	var position3D = plane.intersects_ray(camera.project_ray_origin(position2d), camera.project_ray_normal(position2d))
	return position3D

func in_3d_mode() -> bool:
	return get_main_screen() == "3D"

func get_main_screen()->String:
	# Code by sandormez - https://forum.godotengine.org/t/registering-clicks-in-the-3d-viewport/53149
	var screen = "null"
	var base: Panel = get_editor_interface().get_base_control()
	var editor_head: BoxContainer = base.get_child(0).get_child(0)
	if editor_head.get_child_count() < 3:
		return screen
	var main_screen_buttons: Array = editor_head.get_child(2).get_children()
	for button in main_screen_buttons:
		if button.button_pressed:
			screen = button.text
			break
	return screen
