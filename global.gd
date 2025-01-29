extends Node


var shaker: ShakerComponent
var camera: Camera2D


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
