extends Node


const AUTHORNAME_MODNAME_DIR := "Starkandco-ItemControls"
const AUTHORNAME_MODNAME_LOG_NAME := "Starkandco-ItemControls:Main"

var mod_dir_path := ""
var extensions_dir_path := ""
var translations_dir_path := ""

# Before v6.1.0
# func _init(modLoader = ModLoader) -> void:
func _init() -> void:
	mod_dir_path = ModLoaderMod.get_unpacked_dir().plus_file(AUTHORNAME_MODNAME_DIR)
#	# Add extensions
	
	ModLoaderMod.install_script_extension("res://mods-unpacked/Starkandco-ItemControls/ui/menus/run/difficulty_selection/difficulty_selection.gd")
	ModLoaderMod.install_script_extension("res://mods-unpacked/Starkandco-ItemControls/singletons/progress_data_loader_v2.gd")
	ModLoaderMod.install_script_extension("res://mods-unpacked/Starkandco-ItemControls/singletons/progress_data.gd")
	ModLoaderMod.install_script_extension("res://mods-unpacked/Starkandco-ItemControls/singletons/item_service.gd")
	
	ModLoaderMod.add_translation("res://mods-unpacked/Starkandco-ItemControls/resources/translations/item_control_translations.de.translation")
	ModLoaderMod.add_translation("res://mods-unpacked/Starkandco-ItemControls/resources/translations/item_control_translations.en.translation")
	ModLoaderMod.add_translation("res://mods-unpacked/Starkandco-ItemControls/resources/translations/item_control_translations.es.translation")
	ModLoaderMod.add_translation("res://mods-unpacked/Starkandco-ItemControls/resources/translations/item_control_translations.fr.translation")
	ModLoaderMod.add_translation("res://mods-unpacked/Starkandco-ItemControls/resources/translations/item_control_translations.it.translation")
	ModLoaderMod.add_translation("res://mods-unpacked/Starkandco-ItemControls/resources/translations/item_control_translations.ja.translation")
	ModLoaderMod.add_translation("res://mods-unpacked/Starkandco-ItemControls/resources/translations/item_control_translations.ko.translation")
	ModLoaderMod.add_translation("res://mods-unpacked/Starkandco-ItemControls/resources/translations/item_control_translations.pl.translation")
	ModLoaderMod.add_translation("res://mods-unpacked/Starkandco-ItemControls/resources/translations/item_control_translations.pt.translation")
	ModLoaderMod.add_translation("res://mods-unpacked/Starkandco-ItemControls/resources/translations/item_control_translations.ru.translation")
	ModLoaderMod.add_translation("res://mods-unpacked/Starkandco-ItemControls/resources/translations/item_control_translations.tr.translation")
	ModLoaderMod.add_translation("res://mods-unpacked/Starkandco-ItemControls/resources/translations/item_control_translations.zh.translation")
	ModLoaderMod.add_translation("res://mods-unpacked/Starkandco-ItemControls/resources/translations/item_control_translations.zh_TW.translation")

func _ready() -> void:
	ModLoaderLog.info("Ready!", AUTHORNAME_MODNAME_LOG_NAME)
