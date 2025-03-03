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

func _popup_menu(paths: PackedStringArray) -> void:
	add_context_menu_item('Create OvaniSong', create_song, song_icon)
	add_context_menu_item('Create OvaniPlayer', create_player, player_icon)

func create_song(paths: PackedStringArray) -> void:
	var directory_path: String = paths[0]
	var regex: RegEx = RegEx.new()
	
	# Get song's title
	regex.compile("([^/]+) \\(RT (\\d+\\.\\d+|\\d+)\\)")
	var name_result: RegExMatch = regex.search(directory_path)
	
	if (!name_result):
		printerr('No song name found in path: ', directory_path)
		
		return
	
	var song_name: String = name_result.get_string(1).to_lower()
	var reverb_tail: float = name_result.get_string(2).to_float()
	
	# Replace all groups of non-alphanumeric values with underscore
	regex.compile("[^a-zA-Z0-9]+")
	song_name = regex.sub(song_name, '_', true)
	
	var ovani_song: OvaniSong = _build_ovani_song_resource(directory_path, reverb_tail)
	var target_path: String = directory_path.path_join(song_name + '.' + EXTENSION_RESOURCE)
	
	_save_song_resource(ovani_song, target_path)

# Create an OvaniPlayer as a child of current scene
func create_player(paths: PackedStringArray) -> void:
	var edited_scene: Node = EditorInterface.get_edited_scene_root()
	var ovani_player: OvaniPlayer = OvaniPlayer.new()
	
	if (edited_scene):
		edited_scene.add_child(ovani_player)
		ovani_player.set_owner(edited_scene)
		ovani_player.set_name('OvaniPlayer')
	
	# Reset songs_collection before recursive search
	# so we don't get duplicated results.
	songs_collection.clear()
	
	# Add all the OvaniSong resources found under given directory
	for song in _get_songs_recursively(paths[0]):
		ovani_player.QueuedSongs.append(song)

# Get all the OvaniSong resources recursively for a given directory
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

# Get all the files in given directory
func _get_files_in_directory(path: String) -> PackedStringArray:
	var dir: DirAccess = DirAccess.open(path)
	
	if (!dir):
		printerr('Directory at ', path, ' could not be opened.')
		
		return []
	
	return dir.get_files()

# Build OvaniSong resource for given config
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
	
	return ovani_song

# Save an OvaniSong resource
func _save_song_resource(ovani_song: OvaniSong, full_path: String) -> void:
	if ResourceSaver.save(ovani_song, full_path) == OK:
		print_rich('[color=green][b]SUCCESS:[/b] OvaniSong saved successfully.[/color]')
	else:
		printerr('Failed to save OvaniSong.')
