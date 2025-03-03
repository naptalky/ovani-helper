# OVANI Helper

Addon to simplify use of Ovani Plugin from https://ovanisound.com.

This plugin is **not** provided by OVANI.
<img width="400" alt="ovani_song_multiple" src="https://github.com/user-attachments/assets/ed9e2de8-edd5-4e25-bff1-0d30eb10b0b0" />

## Requirements

1. Godot 4.4+.
2. Ovani Plugin (you can buy it here https://ovanisound.com/products/godot-audio-plugin or you can get it sometimes from bundles for example Humble Bundle)
3. Folders with Ovani sound files must retain pattern '[Name] (RT [some number])' as plugin works on such directories.

## Usage
To create song right click on folder with music files and choose 'Create New -> Create OvaniSong'. This will create resource with all all music files and RT.

![ovani_song_new](https://github.com/user-attachments/assets/4ccf22d6-b048-4997-9bda-b4ae9dd1926a)


To create player click on folder with all Ovani Songs and choose 'Create New -> Create OvaniPlayer' and it will search for that resoure files and create a new player in opened scene.

![ovani_player_new](https://github.com/user-attachments/assets/6380552b-1ffa-444f-9122-7666908d9c78)

You can create multiple ObaniSong files with 'Create New -> Create OvaniSong (multiple)'. This will search inside picked folder for ovani music directory and create inside OvaniSong if that doesn't exist.

<img width="400" alt="ovani_song_multiple" src="https://github.com/user-attachments/assets/be44950a-b886-4a8b-af27-07fafbe27aac" />
