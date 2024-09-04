class_name ItemControls
extends "res://ui/menus/run/difficulty_selection/difficulty_selection.gd"

var line_edit = null
var loadout_button = null
var delete_loadout_button = null
var filter_value_button = null
var element_list = null
var item_controls = null

var filter_type = ""

var item_controls_scene:PackedScene = preload("res://mods-unpacked/Starkandco-ItemControls/ui/menus/run/difficulty_selection/item_controls.tscn")

var _item_popup

func _ready()->void :
	item_controls = item_controls_scene.instance()
	add_child(item_controls)
	
	loadout_button = item_controls.get_node("%LoadoutButton")
	line_edit = loadout_button.get_node("LineEdit")
	delete_loadout_button = item_controls.get_node("%DeleteLoadoutButton")
	filter_value_button = item_controls.get_node("%FilterValueButton")
	element_list = item_controls.get_node("%ElementList")
	
	
	if ProgressData.loadout_names.size() == 0:
		ProgressData.loadout_names.append("DEFAULT")
		ProgressData.loadout_names.append("ADD_LOADOUT")
	
	for loadout_name in ProgressData.loadout_names:
		loadout_button.add_item(loadout_name)
	
	loadout_button.selected = ProgressData.current_loadout
	element_list.current_loadout = ProgressData.current_loadout
	ItemService.current_loadout = ProgressData.current_loadout
	
	element_list.prepare_custom_pool_and_list()
	
	if loadout_button.get_item_count() == 2 or (loadout_button.get_item_count() == element_list.MAX_LOADOUTS and not loadout_button.get_item_text(element_list.MAX_LOADOUTS) == "ADD_LOADOUT"):
		delete_loadout_button.disabled = true
	
	_item_popup = item_controls.get_node("ItemPopup")
	
#	_item_popup.set_buttons_active(false)

	var item_control_button = Button.new()
	item_control_button.text = "ITEM_CONTROLS"
	$MarginContainer/VBoxContainer.add_child(item_control_button)
	
	var _item_control_error = item_control_button.connect("pressed", self, "_on_ItemControlsButton_pressed")
	var _save_button_error = item_controls.get_node("%SaveButton").connect("pressed", self, "_on_SaveButton_pressed")
	var _pool_button_error = item_controls.get_node("%PoolButton").connect("pressed", self, "_on_PoolButton_pressed")
	var _loadout_button_error = loadout_button.connect("item_selected", self, "_on_LoadoutButton_select")
	var _delete_loadout_button_error = delete_loadout_button.connect("pressed", self, "_on_DeleteLoadoutButton_pressed")
	var _sort_button_error = item_controls.get_node("%SortButton").connect("item_selected", self, "_on_Sort_select")
	var _filter_button_error = item_controls.get_node("%FilterButton").connect("item_selected", self, "_on_Filter_select")
	var _filter_value_button_error = filter_value_button.connect("item_selected", self, "_on_FilterValue_select")
	var _asc_box_error = item_controls.get_node("%AscBox").connect("pressed", self, "reverse")
	
	var _element_hovered_error = element_list.connect("element_hovered", self, "_on_element_hovered")
	var _element_unhovered_error = element_list.connect("element_unhovered", self, "_on_element_unhovered")
	
	item_controls.get_node("%PoolButton").set_pressed_no_signal(ProgressData.use_custom_pool)
	
	_on_Sort_select(0)

func _on_ItemControlsButton_pressed()->void :
	$ItemControls.show()

func _on_SaveButton_pressed()->void :
	$ItemControls.hide()
	ProgressData.save()

func _on_PoolButton_pressed()->void :
	ProgressData.use_custom_pool = not ProgressData.use_custom_pool

func _on_Sort_select(index:int)->void :
	var selection = ""
	
	if index == 0:
		selection = "type"
	
	elif index == 1:
		selection = "tier"
	
	elif index == 2:
		selection = "name"
	
	var children_ref = element_list.get_children()
	children_ref.sort_custom(self, "sort_" + selection)
	
	if not item_controls.get_node("%AscBox").pressed:
		children_ref.invert()
	
	for child in children_ref:
		element_list.remove_child(child)
		element_list.add_child(child)


const TYPE_PRIORITY = {
	"WeaponData": 1,
	"ItemData": 2,
	"UpgradeData": 3,
	"ConsumableData": 4
}

func get_priority(item)->int :
	if item is WeaponData:
		return TYPE_PRIORITY["WeaponData"]
	
	elif item is ItemData and not item is UpgradeData and not item is ConsumableData:
		return TYPE_PRIORITY["ItemData"]
	
	elif item is UpgradeData:
		return TYPE_PRIORITY["UpgradeData"]
	
	elif item is ConsumableData:
		return TYPE_PRIORITY["ConsumableData"]
	
	return 10

func sort_type(a, b)->bool :
	var priority_a = get_priority(a.item)
	var priority_b = get_priority(b.item)
	
	if priority_a == priority_b:
		if a.item.name.split("_", true, 1)[1] == b.item.name.split("_", true, 1)[1]:
			return a.item.tier < b.item.tier
		
		return a.item.name.split("_", true, 1)[1] < b.item.name.split("_", true, 1)[1]
	
	else:
		return priority_a < priority_b 

func sort_tier(a, b)->bool :
	if a.item.tier == b.item.tier:
		return a.item.name.split("_", true, 1)[1] < b.item.name.split("_", true, 1)[1]
	
	else:
		return a.item.tier < b.item.tier

func sort_name(a, b)-> bool :
	if a.item.name.split("_", true, 1)[1] == b.item.name.split("_", true, 1)[1]:
		return a.item.tier < b.item.tier
		
	return a.item.name.split("_", true, 1)[1] < b.item.name.split("_", true, 1)[1]

func reverse()->void :
	var children_ref = element_list.get_children()
	children_ref.invert()
	
	for child in children_ref:
		element_list.remove_child(child)
		element_list.add_child(child)

func _on_Filter_select(index)->void :
	filter_value_button.show()
	clear_filter()
	filter_value_button.clear()
	
	if index == 0:
		filter_value_button.hide()
		
	elif index == 1:
		filter_value_button.add_item("")
		filter_value_button.add_item("WEAPONS")
		filter_value_button.add_item("ITEMS")
		filter_value_button.add_item("UPGRADES")
		filter_value_button.add_item("CONSUMABLES")
		filter_type = "type"
		
	elif index == 2:
		filter_value_button.add_item("")
		filter_value_button.add_item("COMMON")
		filter_value_button.add_item("UNCOMMON")
		filter_value_button.add_item("RARE")
		filter_value_button.add_item("LEGENDARY")
		filter_type = "tier"

func _on_FilterValue_select(index)->void :
	clear_filter()
	
	var children_ref = element_list.get_children()
	
	for child in children_ref:
		if filter_type == "tier":
			if not child.item.tier == index - 1 :
				child.hide()
		
		else:
			if index == 1:
				if not child.item.name.begins_with("WEAPON"):
					child.hide()
			
			elif index == 2:
				if not child.item.name.begins_with("ITEM"):
					child.hide()
			
			elif index == 3:
				if not child.item.name.begins_with("UPGRADE"):
					child.hide()
			
			elif index == 4:
				if not child.item.name.begins_with("CONSUMABLE"):
					child.hide()

func clear_filter()->void :
	for child in element_list.get_children():
		child.show()

func _on_element_hovered(element:InventoryElement, _inventory_player_index = 0)->void :
	_item_popup.display_element(element)

func _on_element_unhovered(_element:InventoryElement)->void :
	_item_popup.hide()

func _on_LoadoutButton_select(loadout_index:int)->void :
	
	element_list.current_loadout = loadout_index
	ItemService.current_loadout = loadout_index
	ProgressData.current_loadout = loadout_index
	
	if loadout_button.get_item_count() <= loadout_index + 1 and loadout_button.get_item_count() <= element_list.MAX_LOADOUTS and not element_list.loadouts_full:
		delete_loadout_button.disabled = true
		
		yield(loadout_button, "resized")
		
		line_edit.rect_size = line_edit.get_parent_control().rect_size
		line_edit.show()
		
		yield(line_edit, "text_entered")
		
		loadout_button.remove_item(loadout_index)
		ProgressData.loadout_names.erase("ADD_LOADOUT")
		loadout_button.add_item(line_edit.text)
		ProgressData.loadout_names.append(line_edit.text)
		loadout_button.selected = loadout_index
		
		if not loadout_index + 1 == element_list.MAX_LOADOUTS:
			loadout_button.add_item("ADD_LOADOUT")
			ProgressData.loadout_names.append("ADD_LOADOUT")
		
		else:
			element_list.loadouts_full = true
		
		line_edit.hide()
		line_edit.text = ""
		
		if loadout_button.get_item_count() > 2:
			delete_loadout_button.disabled = false
	
	element_list.prepare_custom_pool_and_list()

	_on_Sort_select(item_controls.get_node("%SortButton").selected)

func _on_DeleteLoadoutButton_pressed()->void :
	var current_position = element_list.current_loadout

	loadout_button.remove_item(current_position)
	ProgressData.custom_pool.remove(current_position)
	ProgressData.loadout_names.erase(ProgressData.loadout_names[current_position])
	
	if loadout_button.get_item_count() == 2:
		delete_loadout_button.disabled = true
		
	if element_list.loadouts_full and loadout_button.get_item_count() == current_position or not current_position == 0:
		element_list.current_loadout = current_position - 1
		ItemService.current_loadout = element_list.current_loadout
		ProgressData.current_loadout = element_list.current_loadout
		loadout_button.selected = element_list.current_loadout
	else:
		element_list.current_loadout = current_position
		ItemService.current_loadout = element_list.current_loadout
		ProgressData.current_loadout = element_list.current_loadout
		loadout_button.selected = element_list.current_loadout
	
	if element_list.loadouts_full:
		element_list.loadouts_full = false
		loadout_button.add_item("ADD_LOADOUT")
	
	
	element_list.prepare_custom_pool_and_list()
	
	_on_Sort_select(item_controls.get_node("%SortButton").selected)
