extends "res://singletons/item_service.gd"

var current_loadout = 0

func get_pool(item_tier:int, type:int)->Array:
	return _tiers_data[item_tier][type].duplicate() if not ProgressData.use_custom_pool else ProgressData.custom_pool[current_loadout][item_tier][type].duplicate()

func get_upgrade_data(level:int, player_index:int)->UpgradeData:
	var tier = get_tier_from_wave(level, player_index)

	if level == 5:
		tier = Tier.UNCOMMON
	elif level == 10 or level == 15 or level == 20:
		tier = Tier.RARE
	elif level % 5 == 0:
		tier = Tier.LEGENDARY

	var upgrade_data:UpgradeData = Utils.get_rand_element(_tiers_data[tier][TierData.UPGRADES]) if not ProgressData.use_custom_pool else Utils.get_rand_element(ProgressData.custom_pool[current_loadout][tier][TierData.UPGRADES]) 
	var stat_upgrades_gain = RunData.get_player_effect("stat_upgrades_gain", player_index)
	if stat_upgrades_gain != 0:
		upgrade_data = upgrade_data.duplicate()
		var new_effects: = []
		for effect in upgrade_data.effects:
			var new_effect = effect.duplicate()
			new_effect.value = int(effect.value * (1.0 + stat_upgrades_gain / 100.0))
			new_effects.push_back(new_effect)
		upgrade_data.effects = new_effects
	return upgrade_data


func get_consumable_for_tier(tier:int = Tier.COMMON)->ConsumableData:
	return Utils.get_rand_element(_tiers_data[tier][TierData.CONSUMABLES]) if not ProgressData.use_custom_pool else Utils.get_rand_element(ProgressData.custom_pool[current_loadout][tier][TierData.CONSUMABLES])


func _get_rand_item_for_wave(wave:int, player_index:int, type:int, args:GetRandItemForWaveArgs)->ItemParentData:
	var rand_wanted = randf()
	var item_tier = get_tier_from_wave(wave, player_index)

	if args.fixed_tier != - 1:
		item_tier = args.fixed_tier

	if type == TierData.WEAPONS:
		var min_weapon_tier = RunData.get_player_effect("min_weapon_tier", player_index)
		var max_weapon_tier = RunData.get_player_effect("max_weapon_tier", player_index)
		item_tier = clamp(item_tier, min_weapon_tier, max_weapon_tier)

	var pool = get_pool(item_tier, type)
	var backup_pool = get_pool(item_tier, type)
	var items_to_remove = []

	
	for shop_item in args.excluded_items:
		pool = remove_element_by_id(pool, shop_item[0])
		backup_pool = remove_element_by_id(pool, shop_item[0])

	if type == TierData.WEAPONS:
		var bonus_chance_same_weapon_set = max(0, (MAX_WAVE_ONE_WEAPON_GUARANTEED + 1 - RunData.current_wave) * (BONUS_CHANCE_SAME_WEAPON_SET / MAX_WAVE_ONE_WEAPON_GUARANTEED))
		var chance_same_weapon_set = CHANCE_SAME_WEAPON_SET + bonus_chance_same_weapon_set

		var no_melee_weapons:bool = RunData.get_player_effect_bool("no_melee_weapons", player_index)
		var no_ranged_weapons:bool = RunData.get_player_effect_bool("no_ranged_weapons", player_index)
		var no_duplicate_weapons:bool = RunData.get_player_effect_bool("no_duplicate_weapons", player_index)

		var player_sets:Array = RunData.get_player_sets(player_index)
		var unique_weapon_ids:Dictionary = RunData.get_unique_weapon_ids(player_index)

		for item in pool:
			if no_melee_weapons and item.type == WeaponType.MELEE:
				backup_pool.erase(item)
				items_to_remove.push_back(item)
				continue

			if no_ranged_weapons and item.type == WeaponType.RANGED:
				backup_pool.erase(item)
				items_to_remove.push_back(item)
				continue

			if no_duplicate_weapons:
				for weapon in unique_weapon_ids.values():
					
					if item.weapon_id == weapon.weapon_id and item.tier < weapon.tier:
						backup_pool.erase(item)
						items_to_remove.push_back(item)
						break

					
					elif item.my_id == weapon.my_id and weapon.upgrades_into == null:
						backup_pool.erase(item)
						items_to_remove.push_back(item)
						break

			if rand_wanted < CHANCE_SAME_WEAPON:
				if not item.weapon_id in unique_weapon_ids:
					items_to_remove.push_back(item)
					continue

			elif rand_wanted < chance_same_weapon_set:
				var remove: = true
				for set in item.sets:
					if set.my_id in player_sets:
						remove = false
				if remove:
					items_to_remove.push_back(item)
					continue

	elif type == TierData.ITEMS:
		if Utils.get_chance_success(CHANCE_WANTED_ITEM_TAG) and RunData.get_player_character(player_index).wanted_tags.size() > 0:
			for item in pool:
				var has_wanted_tag = false

				for tag in item.tags:
					if RunData.get_player_character(player_index).wanted_tags.has(tag):
						has_wanted_tag = true
						break

				if not has_wanted_tag:
					items_to_remove.push_back(item)

		var remove_item_tags:Array = RunData.get_player_effect("remove_shop_items", player_index)
		for tag_to_remove in remove_item_tags:
			for item in pool:
				if tag_to_remove in item.tags:
					items_to_remove.append(item)

	var limited_items = {}

	for item in args.owned_and_shop_items:
		if item.max_nb != - 1:
			if limited_items.has(item.my_id):
				limited_items[item.my_id][1] += 1
			else :
				limited_items[item.my_id] = [item, 1]

	for key in limited_items:
		if limited_items[key][1] >= limited_items[key][0].max_nb:
			backup_pool.erase(limited_items[key][0])
			items_to_remove.push_back(limited_items[key][0])

	for item in items_to_remove:
		pool.erase(item)

	var elt

	if pool.size() == 0:
		if backup_pool.size() > 0:
			elt = Utils.get_rand_element(backup_pool)
		else :
			elt = Utils.get_rand_element(_tiers_data[item_tier][type]) if not ProgressData.use_custom_pool else Utils.get_rand_element(ProgressData.custom_pool[current_loadout][item_tier][type])
	else :
		elt = Utils.get_rand_element(pool)

	return apply_item_effect_modifications(elt)
