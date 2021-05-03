tool
extends PanelContainer

var root: Node
var did: String = ""
var aid: String = "" setget _on_AIDSelector_item_selected
var lid: String = "" setget _on_LIDSelector_item_selected
var sid: int setget set_sid # SlotID


func set_sid(new):
	sid = new
	$HBoxContainer/SID.value = new


func set_idx(_aid, _lid):
	aid = _aid
	lid = _lid
	did = "%s_%s" % [aid, lid]
	
	var aid_idx = root.id_ref.keys().find(aid)
	$HBoxContainer/AIDSelector.select(aid_idx)
	$HBoxContainer/LIDSelector.select(int(lid))
	$HBoxContainer/Preview.set_text(root.find_key(did))


func update_items():
	root = self.get_owner()
	$HBoxContainer/AIDSelector.clear()
	for item in root.id_ref.keys():
		$HBoxContainer/AIDSelector.add_item(item)
	_on_AIDSelector_item_selected(0)
	_on_LIDSelector_item_selected(0)


func _on_AIDSelector_item_selected(index):
	$HBoxContainer/LIDSelector.clear()
	var lids = root.id_ref.get(root.id_ref.keys()[index])
	for lid in lids:
		$HBoxContainer/LIDSelector.add_item(lid)
	aid = $HBoxContainer/AIDSelector.get_item_text(index)
	did = "%s_%s" % [aid, lid]
	$HBoxContainer/Preview.set_text(root.find_key(did))


func _on_LIDSelector_item_selected(index):
#	did = "%s_%s" % [aid, $HBoxContainer/LIDSelector.get_item_text(index)]
	lid = $HBoxContainer/LIDSelector.get_item_text(index)
	did = "%s_%s" % [aid, lid]
	$HBoxContainer/Preview.set_text(root.find_key(did))


func _on_RemoveButton_button_up():
	self.queue_free()
