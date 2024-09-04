extends "res://singletons/progress_data_loader_v2.gd"

var custom_pool = []
var loadout_names = []
var current_loadout = 0
var use_custom_pool = false

func _init(save_dir: = "")->void :
	return

func get_save_object()->Dictionary:
	var custom_pool_data = []
	
	for loadout in custom_pool:
		var loadout_data = []
		for tier in loadout:
			var tier_data = []
			for category in tier:
				var category_data = []
				for item in category:
					if item is Resource:
						category_data.append(item.resource_path)
				tier_data.append(category_data)
			loadout_data.append(tier_data)
		custom_pool_data.append(loadout_data)
	
	
	return {
		"zones_unlocked":zones_unlocked, 
		"characters_unlocked":characters_unlocked, 
		"upgrades_unlocked":upgrades_unlocked, 
		"consumables_unlocked":consumables_unlocked, 
		"weapons_unlocked":weapons_unlocked, 
		"items_unlocked":items_unlocked, 
		"challenges_completed":challenges_completed, 
		"difficulties_unlocked":difficulties_unlocked_serialized, 
		"inactive_mods":inactive_mods, 
		"current_run_state":serialize_run_state(run_state_deserialized), 
		"settings":settings, 
		"data":data, 
		"version":2,
		"use_custom_pool":ProgressData.use_custom_pool,
		"custom_pool":custom_pool_data,
		"loadout_names":ProgressData.loadout_names,
		"current_loadout":ProgressData.current_loadout
	}


func load_game_file(path: = "")->void :
	if path.empty():
		path = save_path
	if path.empty():
		printerr(LOG_PREFIX + "Loading failed - missing save path")
		return 

	print(LOG_PREFIX + "Loading %s" % path)

	var save_file: = File.new()
	if not save_file.file_exists(path):
		print(LOG_PREFIX + "No v2 save found")
		load_status = LoadStatus.SAVE_MISSING
		return 

	var error = save_file.open(path, File.READ)
	if error != OK:
		printerr(LOG_PREFIX + "Could not open %s. Error code: %s" % [path, error])
		_close_file_and_load_backups(save_file, path)
		return 

	var parse_result: = JSON.parse(save_file.get_as_text())
	if parse_result.error != OK:
		var error_line: = parse_result.error_line
		var error_string: = parse_result.error_string
		printerr(LOG_PREFIX + "Error parsing save file (%s): %s at line %s" % [parse_result.error, error_string, error_line])
		_close_file_and_load_backups(save_file, path)
		return 

	var save_object = parse_result.result
	if typeof(save_object) != TYPE_DICTIONARY:
		printerr(LOG_PREFIX + "Save file is not a dictionary")
		_close_file_and_load_backups(save_file, path)
		return 

	for property in ["zones_unlocked", "characters_unlocked", "upgrades_unlocked", "consumables_unlocked", "weapons_unlocked", "items_unlocked", "challenges_completed", "difficulties_unlocked", "inactive_mods"]:
		if not save_object.has(property):
			printerr(LOG_PREFIX + "Save file is missing property: %s" % property)
			_close_file_and_load_backups(save_file, path)
			return 
		if typeof(save_object[property]) != TYPE_ARRAY:
			printerr(LOG_PREFIX + "Property %s is not an array" % property)
			_close_file_and_load_backups(save_file, path)
			return 

	for property in ["current_run_state", "settings", "data"]:
		if not save_object.has(property):
			printerr(LOG_PREFIX + "Save file is missing property: %s" % property)
			_close_file_and_load_backups(save_file, path)
			return 
		if typeof(save_object[property]) != TYPE_DICTIONARY:
			printerr(LOG_PREFIX + "Property %s is not a dictionary" % property)
			_close_file_and_load_backups(save_file, path)
			return 

	zones_unlocked = save_object.zones_unlocked
	characters_unlocked = save_object.characters_unlocked
	upgrades_unlocked = save_object.upgrades_unlocked
	consumables_unlocked = save_object.consumables_unlocked
	weapons_unlocked = save_object.weapons_unlocked
	items_unlocked = save_object.items_unlocked
	challenges_completed = save_object.challenges_completed
	difficulties_unlocked_serialized = save_object.difficulties_unlocked
	inactive_mods = save_object.inactive_mods
	settings = save_object.settings
	data = save_object.data
	run_state_deserialized = deserialize_run_state(save_object.current_run_state)


	if save_object.has("custom_pool"):
		ProgressData.use_custom_pool = save_object.use_custom_pool
		for loadout_data in save_object.custom_pool:
			var loadout = []
			for tier_data in loadout_data:
				var tier = []
				for category_data in tier_data:
					var category = []
					for item_data in category_data:
						if item_data is String and item_data.begins_with("res://"):
							var item = load(item_data)
							if item:
								category.append(item)
					tier.append(category)
				loadout.append(tier)
			ProgressData.custom_pool.append(loadout)
		if save_object.has("loadout_names"):
			ProgressData.loadout_names = save_object.loadout_names
			ProgressData.current_loadout = save_object.current_loadout
			ItemService.current_loadout = save_object.current_loadout
	

	save_file.close()
