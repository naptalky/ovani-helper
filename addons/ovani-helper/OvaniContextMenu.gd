extends EditorContextMenuPlugin

const NAME_SUFFIX_LOOP_30: String = 'Cut 30'
const NAME_SUFFIX_LOOP_60: String = 'Cut 60'
const NAME_SUFFIX_INTENSITY_1: String = 'Intensity 1'
const NAME_SUFFIX_INTENSITY_2: String = 'Intensity 2'
const NAME_SUFFIX_INTENSITY_3: String = 'Main'
const EXTENSION_RESOURCE: String = 'tres'
const EXTENSION_IMPORT: String = 'import'

var song_icon: Resource = preload('OvaniSongIcon.png')
var player_icon: Resource = preload('OvaniPlayerIcon.png')

var songs_collection: Array[OvaniSong] = []
var folders_with_songs: Array[String] = []

var regex: RegEx = RegEx.new()

func _popup_menu(paths: PackedStringArray) -> void:
	add_context_menu_item('Create OvaniSongs', create_songs, song_icon)
	add_context_menu_item('Create OvaniPlayer', create_player, player_icon)


## Create multiple OvaniSong resources based on folder names in picked folder
func create_songs(paths: PackedStringArray) -> void:
	folders_with_songs.clear()
	
	if _check_if_ovani_song_directory(paths[0]):
		_create_song(paths[0])
		folders_with_songs.append(paths[0])
	else:
		for song_directory in _get_songs_folders_recursively(paths[0]):
			_create_song(song_directory)
	
	if folders_with_songs.size() == 0:
		print_rich('[color=yellow][b]WARNING:[/b] Didn\'t create any songs sorry. No correct folders found or all folders has songs in them.[/color]')

## Create an OvaniPlayer as a child of current scene
func create_player(paths: PackedStringArray) -> void:
	var edited_scene: Node = EditorInterface.get_edited_scene_root()
	var ovani_player: OvaniPlayer = OvaniPlayer.new()
	
	if (edited_scene):
		match(ProjectSettings.get_setting("Ovani Helper/Settings/Player/On create")):
			"Update existing one":
				var find_one: bool = false
				for child in edited_scene.find_children("*"):
					if child is OvaniPlayer:
						ovani_player = child
						ovani_player.QueuedSongs.clear()
						find_one = true
				if(!find_one):
					ovani_player.Volume = ProjectSettings.get_setting("Ovani Helper/Settings/Player/Volume")
					ovani_player.Intensity = ProjectSettings.get_setting("Ovani Helper/Settings/Player/Intensity")
					ovani_player.PlayInEditor = ProjectSettings.get_setting("Ovani Helper/Settings/Player/Play In Editor")
					ovani_player.Bus = ProjectSettings.get_setting("Ovani Helper/Settings/Player/Bus")
					ovani_player.LoopQueue = ProjectSettings.get_setting("Ovani Helper/Settings/Player/Loop Queue")
					edited_scene.add_child(ovani_player)
					ovani_player.set_owner(edited_scene)
					ovani_player.set_name('OvaniPlayer')
			"Create new":
				# zmienic na pobrane z settingsow
				ovani_player.Volume = ProjectSettings.get_setting("Ovani Helper/Settings/Player/Volume")
				ovani_player.Intensity = ProjectSettings.get_setting("Ovani Helper/Settings/Player/Intensity")
				ovani_player.PlayInEditor = ProjectSettings.get_setting("Ovani Helper/Settings/Player/Play In Editor")
				ovani_player.Bus = ProjectSettings.get_setting("Ovani Helper/Settings/Player/Bus")
				ovani_player.LoopQueue = ProjectSettings.get_setting("Ovani Helper/Settings/Player/Loop Queue")
				edited_scene.add_child(ovani_player)
				ovani_player.set_owner(edited_scene)
				ovani_player.set_name('OvaniPlayer')
	
	# Reset songs_collection before recursive search
	# so we don't get duplicated results.
	songs_collection.clear()
	
	# Add all the OvaniSong resources found under given directory
	for song in _get_songs_recursively(paths[0]):
		ovani_player.QueuedSongs.append(song)
	ovani_player.notify_property_list_changed()


## Create OvaniSong resource from selected folder
func _create_song(directory_path: String) -> void:
	# Get song's title
	var name_result: RegExMatch = _check_if_ovani_song_directory(directory_path)
	
	var song_name: String = name_result.get_string(1).to_lower()
	var reverb_tail: float = name_result.get_string(2).to_float()
	
	# Replace all groups of non-alphanumeric values with underscore
	regex.compile("[^a-zA-Z0-9]+")
	var delimiter: String = ""
	match(ProjectSettings.get_setting("Ovani Helper/Settings/Song/Name delimiter")):
		"dash":
			delimiter = "-"
		"space":
			delimiter = " "
		"underscore": 
			delimiter = "_"
	
	song_name = regex.sub(song_name, delimiter, true)
	
	var ovani_song: OvaniSong = _build_ovani_song_resource(directory_path, reverb_tail)
	var target_path: String = directory_path.path_join(song_name + '.' + EXTENSION_RESOURCE)
	
	_save_song_resource(ovani_song, target_path)

## Get all the OvaniSong resources recursively for a given directory
func _get_songs_recursively(path: String) -> Array[OvaniSong]:
	var dir: DirAccess = DirAccess.open(path)
	
	if (!dir):
		printerr('Directory at ', path, ' could not be opened. Error code: ', dir.get_open_error())
		
		return []
	
	dir.list_dir_begin()
	
	var file_name: String = dir.get_next()
	
	while (!file_name.is_empty()):
		var full_path: String = dir.get_current_dir().path_join(file_name)
		
		# If directory, dive deeper
		if (dir.current_is_dir()):
			_get_songs_recursively(full_path)
		# If resource, check if it's OvaniSong and add it to the list
		elif (file_name.get_extension() == EXTENSION_RESOURCE):
			var resource: Resource = load(full_path)
			
			if (resource is OvaniSong):
				songs_collection.append(resource)
		
		file_name = dir.get_next()
	
	return songs_collection

## Get all folders that are probably the Ovani folder with music
func _get_songs_folders_recursively(path: String) -> Array[String]:
	var regex: RegEx = RegEx.new()
	regex.compile("([^/]+) \\(RT (\\d+\\.\\d+|\\d+)\\)")
	var dir: DirAccess = DirAccess.open(path)
	
	if !dir:
		printerr('Directory at ', path, ' could not be opened. Error code: ', dir.get_open_error())
		return []
	
	dir.list_dir_begin()
	
	var directory_name: String = dir.get_next()
	while (!directory_name.is_empty()):
		var full_path: String = dir.get_current_dir().path_join(directory_name)
		if dir.current_is_dir() and regex.search(directory_name):
			# Check if OvaniSong exists
			var ovani_song_exists: bool = false
			
			for file in _get_files_in_directory(full_path):
				if file.get_extension() == EXTENSION_RESOURCE:
					var song_resource: Resource = load(full_path.path_join(file))
					
					if song_resource is OvaniSong:
						ovani_song_exists = true
			
			if not ovani_song_exists:
				folders_with_songs.append(full_path)
		
		elif dir.current_is_dir() and not regex.search(directory_name):
			_get_songs_folders_recursively(full_path)
		
		directory_name = dir.get_next()
	

	return folders_with_songs	

## Get all the files in given directory
func _get_files_in_directory(path: String) -> PackedStringArray:
	var dir: DirAccess = DirAccess.open(path)
	
	if (!dir):
		printerr('Directory at ', path, ' could not be opened.')
		
		return []
	
	return dir.get_files()

## Build OvaniSong resource for given config
func _build_ovani_song_resource(path: String, reverb_tail: float) -> OvaniSong:
	var ovani_song: OvaniSong = OvaniSong.new()
	
	ovani_song.ReverbTail = reverb_tail
	
	# Scan files for song parts
	for file in _get_files_in_directory(path):
		# Skip Godot's import files
		if (file.get_extension() == EXTENSION_IMPORT):
			continue
		
		var song_resource: Resource = load(path.path_join(file))
		
		# Assign song_resource to corresponding OvaniSong property
		if file.contains(NAME_SUFFIX_LOOP_30):
			ovani_song.Loop30 = song_resource
		elif file.contains(NAME_SUFFIX_LOOP_60):
			ovani_song.Loop60 = song_resource
		elif file.contains(NAME_SUFFIX_INTENSITY_1):
			ovani_song.Intensity1 = song_resource
		elif file.contains(NAME_SUFFIX_INTENSITY_2):
			ovani_song.Intensity2 = song_resource
		elif file.contains(NAME_SUFFIX_INTENSITY_3):
			ovani_song.Intensity3 = song_resource
	
	match(ProjectSettings.get_setting("Ovani Helper/Settings/Song/Mode")):
		"Intensities":
			ovani_song.SongMode = ovani_song.OvaniMode.Intensities
		"Loop 30":
			ovani_song.SongMode = ovani_song.OvaniMode.Loop30
		"Loop 60":
			ovani_song.SongMode = ovani_song.OvaniMode.Loop60
	
	return ovani_song

## Save an OvaniSong resource
func _save_song_resource(ovani_song: OvaniSong, full_path: String) -> void:
	if ResourceSaver.save(ovani_song, full_path) == OK:
		print_rich('[color=green][b]SUCCESS:[/b] OvaniSong saved successfully.[/color]')
	else:
		printerr('Failed to save OvaniSong.')

## Checks if folder is in Ovani name style
func _check_if_ovani_song_directory(path: String) -> RegExMatch:
	regex.compile("([^/]+) \\(RT (\\d+\\.\\d+|\\d+)\\)")
	return regex.search(path)
