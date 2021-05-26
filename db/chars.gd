tool
extends Node

func get_all_name_hints():
	var result = []
	var properties = get_property_list()
	for i in range(properties.size()):
		if properties[i].name.ends_with("_NAME_HINT"):
			result.append(get(properties[i].name))
	return result

enum SoundId {
	SOUND_WALK_NONE,
	SOUND_WALK_SAND,
	SOUND_WALK_WATER,
	SOUND_WALK_SWIM,
	SOUND_WALK_GRASS,
	SOUND_WALK_CONCRETE,
	SOUND_WALK_SKELETON,
	SOUND_WALK_MINOTAUR,
	SOUND_ATTACK_GUNSHOT,
	SOUND_ATTACK_SWOOSH,
	SOUND_ATTACK_AXE_ON_STONE,
	SOUND_MONSTER_ROAR
}

const SOUND = {
	SoundId.SOUND_WALK_NONE : null,
	SoundId.SOUND_WALK_SAND : preload("res://sound/environment/161815__dasdeer__sand-walk.ogg"),
	SoundId.SOUND_WALK_WATER : preload("res://sound/environment/water_steps.ogg"),
	SoundId.SOUND_WALK_SWIM : preload("res://sound/environment/man_swimming.ogg"),
	SoundId.SOUND_WALK_GRASS : preload("res://sound/environment/400123__harrietniamh__footsteps-on-grass.ogg"),
	SoundId.SOUND_WALK_CONCRETE : preload("res://sound/environment/336598__inspectorj__footsteps-concrete-a.ogg"),
	SoundId.SOUND_WALK_SKELETON : preload("res://sound/environment/skeleton_walk.ogg"),
	SoundId.SOUND_WALK_MINOTAUR : preload("res://sound/environment/minotaur_walk_reverb_short.ogg"),
	SoundId.SOUND_ATTACK_GUNSHOT : preload("res://sound/environment/Labyrinth_gunshot.ogg"),
	SoundId.SOUND_ATTACK_SWOOSH : preload("res://sound/environment/sword_swing.ogg"),
	SoundId.SOUND_ATTACK_AXE_ON_STONE : preload("res://sound/environment/pickaxe3.ogg"),
	SoundId.SOUND_MONSTER_ROAR : preload("res://sound/environment/48688__sea-fury__monster-4.ogg")
}

var FATHER_NAME_HINT = "father"
var PLAYER_NAME_HINT = "player"
var FEMALE_NAME_HINT = "female"
var BANDIT_NAME_HINT = "bandit"
