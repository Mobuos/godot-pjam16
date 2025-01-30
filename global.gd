extends Node


var shaker: ShakerComponent
var camera: Camera2D

var loaded_player := false
var loaded_enemy := false
var loaded_bonus := false


## Audio
enum Bangs {MEDIUM, LIGHT, HEAVY}

var bangs: AudioStreamPlayer
var bangs_light: AudioStreamPlayer
var bangs_heavy: AudioStreamPlayer

func play(type: Bangs) -> void:
	match type:
		Bangs.MEDIUM:
			bangs.play()
		Bangs.LIGHT:
			bangs_light.play()
		Bangs.HEAVY:
			bangs_heavy.play()
