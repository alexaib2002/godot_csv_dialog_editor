tool
extends Control

enum Delimiter {
	COMMA,
	SEMICOLON,
	TAB
}

const SlotScene: = preload("res://addons/dialog_editor/slot/slot.tscn")
const Slot: = preload("res://addons/dialog_editor/slot/slot.gd")

var csv_path: String
var csv_table: Array
var id_ref: Dictionary
var load_csv_file_explorer: = FileDialog.new()
var load_res_file_explorer: = FileDialog.new()
var save_res_file_explorer: = FileDialog.new()

export(NodePath) var grid_container: NodePath


func _ready():
	$MarginContainer/TopMenu/LoadMenu.get_popup().connect("id_pressed", 
			self, "_on_LoadMenu_id_selection")
	$CenterContainer.add_child(load_csv_file_explorer)
	$CenterContainer.add_child(load_res_file_explorer)
	load_res_file_explorer.connect("file_selected", 
			self, "_load_dialog_resource")
	$CenterContainer.add_child(save_res_file_explorer)
	$MarginContainer/TopMenu/LocaleSelector.clear()
	if ProjectSettings.get("locale/locale_filter")[1].empty():
		print_debug("You don't have any translation defined")
	for locale in ProjectSettings.get("locale/locale_filter")[1]:
		$MarginContainer/TopMenu/LocaleSelector.add_item(locale)
	for node in get_tree().get_nodes_in_group("FileInterface"):
		node.hide()


func find_key(key: String) -> String:
	for row in csv_table:
		if row[0] == key:
			return row[$MarginContainer/TopMenu/LocaleSelector.get_selected_id() + 1]
	return ""


func request_value(val: int, slot: Slot):
	var container = get_node(grid_container)
	slot.get_node("HBoxContainer/SID").set_max(container.get_child_count())
	if val > slot.get_node("HBoxContainer/SID").get_max():
		return # Reject change if max hasn't been updated before call
	var target_node = container.get_child(val - 1)
	target_node.sid = slot.sid
	container.move_child(slot, val - 1)


func _on_LoadMenu_id_selection(id):
	match id:
		0:
			_file_explorer_load_csv()
		1:
			_file_explorer_load_resource()


func _file_explorer_load_csv():
	load_csv_file_explorer.set_filters(PoolStringArray(["*.csv ; CSV Translation Files"]))
	load_csv_file_explorer.get_line_edit().clear()
	load_csv_file_explorer.set_mode(FileDialog.MODE_OPEN_FILE)
	load_csv_file_explorer.popup_centered(Vector2(650,500))
	var line_dir: String = $MarginContainer/TopMenu/FileDescriptor/FileLineEdit.get_text()
	var path = yield(load_csv_file_explorer, "file_selected")
	load_csv_file_explorer.clear_filters()
	csv_path = path
	_load_csv(path)


func _file_explorer_load_resource():
	load_res_file_explorer.set_filters(PoolStringArray(["*.tres ; Text Dialog File",
			"*.res ; Dialog File"]))
	load_res_file_explorer.get_line_edit().clear()
	load_res_file_explorer.set_mode(FileDialog.MODE_OPEN_FILE)
	load_res_file_explorer.popup_centered(Vector2(650,500))


func _load_dialog_resource(path):
	var container = get_node(grid_container)
	for child in container.get_children():
		child.queue_free()
		yield(child, "tree_exited")
	var load_res: Dialog = ResourceLoader.load(path)
	_load_csv(load_res.csv_source)
	for i in load_res.story:
		var did = i.split("_")
		var slot = instance_slot(container)
		slot.set_idx(did[0], did[1])


func _on_AddDialogButton_button_up():
	instance_slot(get_node(grid_container))


func instance_slot(parent: Node) -> Slot:
	var node = SlotScene.instance()
	parent.add_child(node)
	node.set_owner(self)
	node.update_items()
	node.sid = node.get_position_in_parent() + 1
	node.get_node("HBoxContainer/SID").connect(
			"value_changed", self, "request_value", [node])
	node.get_node("HBoxContainer/RemoveButton").connect(
		"tree_exited", self, "update_sid")
	node.connect("did_changed", self, "update_preview")
	return node


func update_sid() -> void:
	for node in get_node(grid_container).get_children():
		node.sid = node.get_position_in_parent() + 1


func update_preview(did) -> void:
	var preview = find_key(did)
	print(str(did))
	$CenterContainer/CenterSeparator/PreviewPanel/MarginContainer/ \
			VBoxContainer/HBoxContainer/CurrentDID.set_text(did)
	get_node("CenterContainer/CenterSeparator/PreviewPanel/MarginContainer/VBoxContainer/Preview"
			).set_text(preview)


func _on_LocaleSelector_item_selected(index):
	for slot in get_node(grid_container).get_children():
		slot.get_node("CenterContainer/CenterSeparator/PreviewPanel/MarginContainer/VBoxContainer/Preview").set_text(find_key(slot.did))


func _on_SaveButton_button_up():
	var save_res: Dialog = Dialog.new()
	var save_story: PoolStringArray = []
	for slot in get_node(grid_container).get_children():
		save_story.append(slot.did)
	save_res.csv_source = csv_path
	save_res.story = save_story
	# Save dialog
	save_res_file_explorer.set_filters(PoolStringArray(["*.tres ; Text Dialog File",
			"*.res ; Dialog File"]))
	save_res_file_explorer.get_line_edit().clear()
	save_res_file_explorer.set_mode(FileDialog.MODE_SAVE_FILE)
	save_res_file_explorer.popup_centered(Vector2(650,500))
	var path = yield(save_res_file_explorer, "file_selected")
	assert(ResourceSaver.save(path, save_res) == OK)
	save_res_file_explorer.clear_filters()


static func get_delimiter() -> String:
	var delimiter = ProjectSettings.get(
			"importer_defaults/csv_translation").get("delimiter")
	var csv_delimiter: String
	match delimiter:
		Delimiter.COMMA:
			csv_delimiter = ","
		Delimiter.SEMICOLON:
			csv_delimiter = ";"
		Delimiter.TAB:
			csv_delimiter = "	"
	return csv_delimiter


static func get_csv_data(path: String) -> Array:
	var dialog_file = File.new()
	dialog_file.open(path, File.READ)
	var dialog: Array = []
	var row: int = 0
	while !dialog_file.eof_reached():
		var line = dialog_file.get_csv_line(get_delimiter())
		if !line[0].empty() and row != 0:
			dialog.append(line)
		row += 1
	dialog_file.close()
	return dialog


static func make_relations(table) -> Dictionary:
	var relations: Dictionary = {}
	for column in table:
		var cell = column[0]
		var data = cell.split("_")
		var interactable_name: String = data[0]
		if !relations.has(interactable_name): # Initialize key
			relations[interactable_name] = []
		relations.get(interactable_name).append(data[1])
	return relations


func _load_csv(csv_path):
	csv_table = get_csv_data(csv_path)
	id_ref = make_relations(csv_table)
	for slot in get_node(grid_container).get_children():
		slot.update_items()
	for item in get_tree().get_nodes_in_group("FileInterface"):
		item.show()
	$MarginContainer/TopMenu/FileDescriptor/FileLineEdit.set_text(csv_path)
