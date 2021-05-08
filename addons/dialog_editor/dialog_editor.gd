tool
extends EditorPlugin

var main = preload("res://addons/dialog_editor/editor/editor.tscn").instance()


func _enter_tree():
	add_control_to_bottom_panel(main, "Dialog Editor")


func _exit_tree():
	remove_control_from_bottom_panel(main)
	main.queue_free()
