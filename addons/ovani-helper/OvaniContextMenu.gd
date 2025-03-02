extends EditorContextMenuPlugin
var song_icon = preload("OvaniSongIcon.png")
var player_icon = preload("OvaniPlayerIcon.png")

var revert_tail: float
var song_name: String

var intensity_1: AudioStreamWAV
var intensity_2: AudioStreamWAV
var intensity_3: AudioStreamWAV
var loop_30: AudioStreamWAV
var loop_60: AudioStreamWAV

func _popup_menu(paths: PackedStringArray) -> void:
	add_context_menu_item("Create OvaniSong", create_song, song_icon)
	add_context_menu_item("Create OvaniPlayer", create_player, player_icon)
	
	
func create_song(path):
	print(path[0])
	var regex = RegEx.new()
	##
	## get song tilte
	##
	regex.compile("/([^/]+) \\(RT \\d+\\.\\d+\\)/")
	var name_result = regex.search(path[0])
	if name_result:
		song_name = name_result.get_string(1)
		song_name = song_name.to_lower()
		regex.compile("[^a-zA-Z0-9_]")
		song_name = regex.sub(song_name, "_", true)
	else :
		regex.compile("/([^/]+) \\(RT \\d+\\)/")
		name_result = regex.search(path[0])
		if name_result:
			song_name = name_result.get_string(1)
			song_name = song_name.to_lower()
			regex.compile("[^a-zA-Z0-9_]")
			song_name = regex.sub(song_name, "_", true)
	##
	## get RT from folder
	## 
	
	regex.compile("\\(.*? (\\d+\\.\\d+)\\)")
	var rt_result = regex.search(path[0])
	if rt_result:
		revert_tail = str_to_var(rt_result.get_string(1))
	else:
		regex.compile("\\(.*? (\\d+)\\)")
		rt_result = regex.search(path[0])
		if rt_result:
			revert_tail = str_to_var(rt_result.get_string(1))

	##
	## get files
	##
	var dir = DirAccess.open(path[0])
	if dir:
		var files = dir.get_files()
		for file in files:
			if file.contains("Cut 30") and not file.contains(".import"):
				loop_30 = load(path[0]+"/"+file)
			elif file.contains("Cut 60") and not file.contains(".import"):
				loop_60 = load(path[0]+"/"+file)
			elif file.contains("Intensity 1") and not file.contains(".import"):
				intensity_1 = load(path[0]+"/"+file)
			elif file.contains("Intensity 2") and not file.contains(".import"):
				intensity_2 = load(path[0]+"/"+file)
			elif file.contains("Main") and not file.contains(".import"):
				intensity_3 = load(path[0]+"/"+file)
	
	var ovani_song = OvaniSong.new()
	if name_result != null:
		ovani_song.Loop30 = loop_30
		ovani_song.Loop60 = loop_60
		ovani_song.Intensity1 = intensity_1
		ovani_song.Intensity2 = intensity_2
		ovani_song.Intensity3 = intensity_3
		ovani_song.ReverbTail = revert_tail
		ovani_song.resource_path = path[0]+song_name+".tres"
		
		if ResourceSaver.save(ovani_song, ovani_song.resource_path) == OK:
			print("OvaniSong saved successfully.")
		else:
			print("Failed to save OvaniSong.")
	else:
		print("Somthing went wrong:")
		print("- song name: " + str(name_result))
		print("- rt: " + str(rt_result))
	ovani_song = null

var files: Array = []

func create_player(path):
	files.clear()
	var edited_scene = EditorInterface.get_edited_scene_root()
	var ovani_player = OvaniPlayer.new()
	ovani_player.name = "OvaniPlayer"

	if edited_scene:
		edited_scene.add_child(ovani_player)
		ovani_player.set_owner(edited_scene)
		ovani_player.set_name("OvaniPlayer")
	
	files = get_all_files_recursive(path[0])
	for song in files:
		ovani_player.QueuedSongs.append(song)
	

func get_all_files_recursive(path: String) -> Array:
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				get_all_files_recursive(dir.get_current_dir()+"/"+file_name)
			else:
				if(file_name.contains(".tres")):
					var res = load(dir.get_current_dir()+"/"+file_name)
					files.append(res)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	return files
