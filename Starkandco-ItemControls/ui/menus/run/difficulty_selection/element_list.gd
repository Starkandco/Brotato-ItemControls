class_name ElementList
extends Inventory

var current_element:InventoryElement = null
var loadouts_full = false
var current_loadout: int = 0
const MAX_LOADOUTS: int = 5
var loadouts: Array = []

func _ready()->void :
	var _pressed_error = connect("element_pressed", self, "_on_element_selected")
	prepare_custom_pool_and_list()

func _on_element_selected(element:InventoryElement)->void :
	if is_instance_valid(current_element) and current_element.modulate == Color.red:
		current_element.modulate = Color.white
	current_element = element
	on_update(current_element.modulate == Color.black)

func on_update(enabled:bool)->void :
	var pool = ProgressData.custom_pool[current_loadout]

	if current_element.item is WeaponData:
		if enabled:
			pool[current_element.item.tier][ItemService.TierData.ALL_ITEMS].push_back(current_element.item)
			pool[current_element.item.tier][ItemService.TierData.WEAPONS].push_back(current_element.item)
		else:
			if pool[current_element.item.tier][ItemService.TierData.WEAPONS].size() == 1:
				current_element.modulate = Color.red
				return
			pool[current_element.item.tier][ItemService.TierData.ALL_ITEMS].erase(current_element.item)
			pool[current_element.item.tier][ItemService.TierData.WEAPONS].erase(current_element.item)
		
	elif current_element.item is UpgradeData:
		if enabled:
			pool[current_element.item.tier][ItemService.TierData.UPGRADES].push_back(current_element.item)
		else:
			if pool[current_element.item.tier][ItemService.TierData.UPGRADES].size() == 1:
				current_element.modulate = Color.red
				return
			pool[current_element.item.tier][ItemService.TierData.UPGRADES].erase(current_element.item)
	
	elif current_element.item is ConsumableData:
		if enabled:
			pool[current_element.item.tier][ItemService.TierData.CONSUMABLES].push_back(current_element.item)
		else:
			if pool[current_element.item.tier][ItemService.TierData.CONSUMABLES].size() == 1:
				current_element.modulate = Color.red
				return
			pool[current_element.item.tier][ItemService.TierData.CONSUMABLES].erase(current_element.item)
	
	elif current_element.item is ItemData:
		if enabled:
			pool[current_element.item.tier][ItemService.TierData.ALL_ITEMS].push_back(current_element.item)
			pool[current_element.item.tier][ItemService.TierData.ITEMS].push_back(current_element.item)
		else:
			if pool[current_element.item.tier][ItemService.TierData.ITEMS].size() == 1:
				current_element.modulate = Color.red
				return
			pool[current_element.item.tier][ItemService.TierData.ALL_ITEMS].erase(current_element.item)
			pool[current_element.item.tier][ItemService.TierData.ITEMS].erase(current_element.item)

	if current_element.modulate == Color.white or current_element.modulate == Color.red:
		current_element.modulate = Color.black
	else:
		current_element.modulate = Color.white
	return

func prepare_custom_pool_and_list() -> void:
	$"%ElementList".clear_elements()
	var all_elements = []

	for weapon in ItemService.weapons:
		all_elements.push_back(weapon)
	for item in ItemService.items:
		if item.tier >= 5:
			continue
		all_elements.push_back(item)
	for upgrade in ItemService.upgrades:
		all_elements.push_back(upgrade)
	for consumable in ItemService.consumables:
		all_elements.push_back(consumable)

	var pool = []
	if ProgressData.custom_pool:
		if ProgressData.custom_pool.size() >= current_loadout + 1:
			pool = ProgressData.custom_pool[current_loadout]
		
	for element in all_elements:
		$"%ElementList".add_element(element)
		if pool:
			var has_weapon = pool[element.tier][ItemService.TierData.WEAPONS].has(element)
			var has_item = pool[element.tier][ItemService.TierData.ITEMS].has(element)
			var has_consumable = pool[element.tier][ItemService.TierData.CONSUMABLES].has(element)
			var has_upgrade = pool[element.tier][ItemService.TierData.UPGRADES].has(element)

			$"%ElementList".get_child($"%ElementList".get_child_count() - 1).modulate = Color.white if has_weapon or has_item or has_consumable or has_upgrade else Color.black

	if pool:
		return

	var tiers_data = [
		[[], [], [], [], [], 0, 1.0, 0.0, 1.0], 
		[[], [], [], [], [], 0, 0.0, 0.06, 0.6], 
		[[], [], [], [], [], 2, 0.0, 0.02, 0.25], 
		[[], [], [], [], [], 6, 0.0, 0.0023, 0.08]
	]

	for item in ItemService.items:
		if ProgressData.items_unlocked.has(item.my_id):
			tiers_data[item.tier][ItemService.TierData.ALL_ITEMS].push_back(item)
			tiers_data[item.tier][ItemService.TierData.ITEMS].push_back(item)

	for weapon in ItemService.weapons:
		if ProgressData.weapons_unlocked.has(weapon.weapon_id):
			tiers_data[weapon.tier][ItemService.TierData.ALL_ITEMS].push_back(weapon)
			tiers_data[weapon.tier][ItemService.TierData.WEAPONS].push_back(weapon)

	for upgrade in ItemService.upgrades:
		if ProgressData.upgrades_unlocked.has(upgrade.upgrade_id):
			tiers_data[upgrade.tier][ItemService.TierData.UPGRADES].push_back(upgrade)

	for consumable in ItemService.consumables:
		if ProgressData.consumables_unlocked.has(consumable.my_id):
			tiers_data[consumable.tier][ItemService.TierData.CONSUMABLES].push_back(consumable)

	ProgressData.custom_pool.append(tiers_data)

	pool = ProgressData.custom_pool[current_loadout]

	for child in $"%ElementList".get_children():
		var has_weapon = pool[child.item.tier][ItemService.TierData.WEAPONS].has(child.item)
		var has_item = pool[child.item.tier][ItemService.TierData.ITEMS].has(child.item)
		var has_consumable = pool[child.item.tier][ItemService.TierData.CONSUMABLES].has(child.item)
		var has_upgrade = pool[child.item.tier][ItemService.TierData.UPGRADES].has(child.item)
		
		child.modulate = Color.white if has_weapon or has_item or has_consumable or has_upgrade else Color.black
