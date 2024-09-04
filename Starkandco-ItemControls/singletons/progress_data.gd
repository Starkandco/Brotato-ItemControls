extends "res://singletons/progress_data.gd"

var custom_pool = []
var loadout_names = []
var current_loadout = 0
var use_custom_pool = false

# Code for working with ProgressDataLoaderVItemControls
#func init_save_paths(user_dir_override: = "user://")->void :
#	var dir = Directory.new()
#	var dir_path = user_dir_override + _get_user_id()
#	var directory_exists = dir.dir_exists(dir_path)
#	if not directory_exists:
#		var err = dir.make_dir(dir_path)
#		if err != OK:
#			printerr("Could not create the directory %s. Error code: %s" % [dir_path, err])
#			return 
#	SAVE_DIR = dir_path
#	SAVE_PATH = ProgressDataLoaderVItemControls.new(dir_path).save_path
#	LOG_PATH = dir_path + "/log.txt"
#	print("LOG_PATH: " + LOG_PATH)
#
#
#func load_game_file()->void :
#	if DebugService.reinitialize_save:
#		save()
#		return 
#	var loader_v_item_controls = ProgressDataLoaderVItemControls.new(SAVE_DIR)
#	load_with_generic_loader(loader_v_item_controls)
#	if load_status == LoadStatus.SAVE_OK:
#		return 
#	if load_status != LoadStatus.SAVE_MISSING:
#
#		return 
#	var loader_v1 = ProgressDataLoaderV1.new(SAVE_DIR)
#	load_with_generic_loader(loader_v1)
#	if load_status == LoadStatus.SAVE_OK:
#		print("Migrating v1 save to v2")
#	elif load_status != LoadStatus.SAVE_MISSING:
#
#		print("Migrating corrupted v1 save to v2")
#	else :
#		print("No save found, creating new save")
#		load_status = LoadStatus.SAVE_OK
#	save()
#
#
#func save()->void :
#	if DebugService.disable_saving:
#		return 
#	if load_status == LoadStatus.CORRUPTED_ALL_SAVES_NO_STEAM:
#		printerr("Aborting save due to unrecoverable corruption")
#		return 
#	var loader_v_item_controls = ProgressDataLoaderVItemControls.new(SAVE_DIR)
#	_set_loader_properties_item_controls(loader_v_item_controls, saved_run_state)
#	loader_v_item_controls.save()
#
#
#
#func get_current_save_object()->Dictionary:
#	var loader_v_item_controls = ProgressDataLoaderVItemControls.new(SAVE_DIR)
#	_set_loader_properties_item_controls(loader_v_item_controls, _get_current_run_state())
#	return loader_v_item_controls.get_save_object()
#
#
#func _set_loader_properties_item_controls(loader_v_item_controls:ProgressDataLoaderVItemControls, run_state:Dictionary)->void :
#	loader_v_item_controls.zones_unlocked = zones_unlocked.duplicate()
#	loader_v_item_controls.characters_unlocked = characters_unlocked.duplicate()
#	loader_v_item_controls.upgrades_unlocked = upgrades_unlocked.duplicate()
#	loader_v_item_controls.consumables_unlocked = consumables_unlocked.duplicate()
#	loader_v_item_controls.weapons_unlocked = weapons_unlocked.duplicate()
#	loader_v_item_controls.items_unlocked = items_unlocked.duplicate()
#	loader_v_item_controls.challenges_completed = challenges_completed.duplicate()
#	loader_v_item_controls.difficulties_unlocked_serialized.clear()
#	for difficulty_unlocked in difficulties_unlocked:
#		loader_v_item_controls.difficulties_unlocked_serialized.push_back(difficulty_unlocked.serialize())
#	loader_v_item_controls.inactive_mods = inactive_mods.duplicate()
#	loader_v_item_controls.run_state_deserialized = run_state.duplicate()
#	loader_v_item_controls.settings = settings.duplicate()
#	loader_v_item_controls.data = data.duplicate()
#	loader_v_item_controls.custom_pool = custom_pool.duplicate()
#	loader_v_item_controls.loadout_names = loadout_names.duplicate()
#	loader_v_item_controls.current_loadout = current_loadout
#	loader_v_item_controls.use_custom_pool = use_custom_pool
