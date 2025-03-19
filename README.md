# OVANI Helper

Addon to simplify use of Ovani Plugin from https://ovanisound.com.

This plugin is **not** provided by OVANI.

## Requirements

1. Godot 4.4+.
2. Ovani Plugin (you can buy it here https://ovanisound.com/products/godot-audio-plugin or you can get it sometimes from bundles for example Humble Bundle)
3. Folders with Ovani sound files must retain pattern '[Name] (RT [some number])' as plugin works on such directories.

## Setup

No additional steps are required for plugin to work on default but there is a section in Project Settings that can control some behaviours.

![Screenshot 2025-03-19 at 16 01 10](https://github.com/user-attachments/assets/f6270c09-f51c-430b-9d39-46fd9198a148)

Name Delimiter: this will be used to change every special character in OvaniSong when creating resource file.

Mode: this corresponds to 'Song Mode' in OvaniSong and will be used everytime a song file is created.

On Create: 
  - Update existing one : if in opened scene is already OvaniPlayer it will only update songs queue (if there is none a new one will be created).
  - Create new : everytime new OvaniPlayer node will be created 

Options Volume, Intensity, Play In Editor, Bus, Loop Queue are corresponding to options in OvaniPlayer and will be set on creating it.

## Usage
To create song right click on folder with music files and choose 'Create New -> Create OvaniSong'. Depending on what folder is picked it will create only one song file (ovani folder wit (RT...) in name) or traverse and create multiple files.

![ovani_song_new](https://github.com/user-attachments/assets/4ccf22d6-b048-4997-9bda-b4ae9dd1926a)


To create player click on folder with all Ovani Songs and choose 'Create New -> Create OvaniPlayer' and it will search for that resource files and create a new player (or update existing one) in opened scene.

![ovani_player_new](https://github.com/user-attachments/assets/6380552b-1ffa-444f-9122-7666908d9c78)


