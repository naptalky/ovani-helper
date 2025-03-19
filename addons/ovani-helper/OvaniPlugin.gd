@tool
extends EditorPlugin

var pluginScript: Resource = preload('OvaniContextMenu.gd')
var plugin: EditorContextMenuPlugin


func _enter_tree() -> void:
	var plugin: EditorContextMenuPlugin = pluginScript.new()
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_FILESYSTEM_CREATE, plugin)
	# option to add delimiter on special characters
	ProjectSettings.set_setting("Ovani Helper/Settings/Song/Name delimiter", "underscore")
	ProjectSettings.set_initial_value("Ovani Helper/Settings/Song/Name delimiter", "underscore")
	ProjectSettings.add_property_info({
		"name": "Ovani Helper/Settings/Song/Name delimiter",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "underscore,dash,space"
	})
	
	ProjectSettings.set_setting("Ovani Helper/Settings/Song/Mode", "Intensities")
	ProjectSettings.set_initial_value("Ovani Helper/Settings/Song/Mode", "Intensities")
	ProjectSettings.add_property_info({
		"name": "Ovani Helper/Settings/Song/Mode",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "Intensities,Loop 30,Loop 60"
	})

	# option for player to update or create new one
	ProjectSettings.set_setting("Ovani Helper/Settings/Player/On create", "Update existing one")
	ProjectSettings.set_initial_value("Ovani Helper/Settings/Player/On create", "Update existing one")
	ProjectSettings.add_property_info({
		"name": "Ovani Helper/Settings/Player/On create",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "Update existing one,Create new"
	})

	
	# DEFAULT PLAYER SETTINGS
	# Volume = 0.0
	ProjectSettings.set_setting("Ovani Helper/Settings/Player/Volume", 0.0)
	ProjectSettings.set_initial_value("Ovani Helper/Settings/Player/Volume", 0.0)
	ProjectSettings.add_property_info({
		"name": "Ovani Helper/Settings/Player/Volume",
		"type": TYPE_FLOAT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "-80,20,.001"
	})


	# Intensity = 0.0
	ProjectSettings.set_setting("Ovani Helper/Settings/Player/Intensity", 0.0)
	ProjectSettings.set_initial_value("Ovani Helper/Settings/Player/Intensity", 0.0)
	ProjectSettings.add_property_info({
		"name": "Ovani Helper/Settings/Player/Intensity",
		"type": TYPE_FLOAT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0,1,.001"
	})

	# Play In Editor false
	ProjectSettings.set_setting("Ovani Helper/Settings/Player/Play In Editor", false)
	ProjectSettings.set_initial_value("Ovani Helper/Settings/Player/Play In Editor", false)
	ProjectSettings.add_property_info({
		"name": "Ovani Helper/Settings/Player/Play In Editor",
		"type": TYPE_BOOL,
	})

	# Bus = "Master"
	#ProjectSettings.set_setting("Ovani Helper/Settings/Song name delimiter", "Master")
	ProjectSettings.set_setting("Ovani Helper/Settings/Player/Bus", "Master")
	ProjectSettings.set_initial_value("Ovani Helper/Settings/Player/Bus", "Master")
	ProjectSettings.add_property_info({
		"name": "Ovani Helper/Settings/Player/Bus",
		"type": TYPE_STRING,
	})
	# Loop Queue = false
	#ProjectSettings.set_setting("Ovani Helper/Settings/Song name delimiter", false)
	ProjectSettings.set_setting("Ovani Helper/Settings/Player/Loop Queue", false)
	ProjectSettings.set_initial_value("Ovani Helper/Settings/Player/Loop Queue", false)
	ProjectSettings.add_property_info({
		"name": "Ovani Helper/Settings/Player/Loop Queue",
		"type": TYPE_BOOL,
	})
	
	ProjectSettings.set_order("Ovani Helper/Settings/Song/Name delimiter", 1)
	ProjectSettings.set_order("Ovani Helper/Settings/Song/Mode", 2)
	ProjectSettings.set_order("Ovani Helper/Settings/Player/On create", 3)
	ProjectSettings.set_order("Ovani Helper/Settings/Player/Volume", 4)
	ProjectSettings.set_order("Ovani Helper/Settings/Player/Intensity", 5)
	ProjectSettings.set_order("Ovani Helper/Settings/Player/Play In Editor", 6)
	ProjectSettings.set_order("Ovani Helper/Settings/Player/Bus", 7)
	ProjectSettings.set_order("Ovani Helper/Settings/Player/Loop Queue", 8)
	# DEFAULT PLAYER SETTINGS
	
	ProjectSettings.save()

func _exit_tree() -> void:
	remove_context_menu_plugin(plugin)
	ProjectSettings.remove_meta("Ovani Helper/Settings/Song name delimiter")
	ProjectSettings.remove_meta("Ovani Helper/Settings/Player")
	ProjectSettings.remove_meta("Ovani Helper/Song name delimiter")
