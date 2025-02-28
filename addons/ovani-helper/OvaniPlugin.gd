@tool
extends EditorPlugin
var Plugin = preload("OvaniContextMenu.gd") 
var plugin:EditorContextMenuPlugin

func _enter_tree() -> void:
	var plugin = Plugin.new()
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_FILESYSTEM, plugin)

func _exit_tree() -> void:
	remove_context_menu_plugin(plugin)
