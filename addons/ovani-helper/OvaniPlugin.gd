@tool

extends EditorPlugin

var pluginScript: Resource = preload('OvaniContextMenu.gd')
var plugin: EditorContextMenuPlugin

func _enter_tree() -> void:
	var plugin: EditorContextMenuPlugin = pluginScript.new()
	
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_FILESYSTEM_CREATE, plugin)

func _exit_tree() -> void:
	remove_context_menu_plugin(plugin)
