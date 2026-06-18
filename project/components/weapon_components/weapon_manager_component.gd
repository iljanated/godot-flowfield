extends Node2D
class_name WeaponManagerComponent

var weapons: Array[Weapon] = []
var active_weapon_index: int = -1

signal weapon_changed(new_weapon: Weapon)
signal weapon_fired(fire_result: FireResult)

func _ready() -> void:
	var children = get_children()
	for child in children:
		if child is Weapon:
			child.is_active = false
			child.fired.connect(weapon_fired.emit)
			weapons.append(child)
	
	if weapons.size() > 0:
		switch_weapon(0)

func get_active_weapon() -> Weapon:
	if active_weapon_index >= 0 and active_weapon_index < weapons.size():
		return weapons[active_weapon_index]
	return null

func switch_weapon(slot: int) -> void:
	if slot != active_weapon_index and slot >= 0 and slot < weapons.size():
		weapons[active_weapon_index].is_active = false
		active_weapon_index = slot
		weapons[active_weapon_index].is_active = true
		weapon_changed.emit(weapons[active_weapon_index])

func next_weapon() -> void:
	if weapons.size() == 0:
		return
	var new_index = (active_weapon_index + 1) % weapons.size()
	switch_weapon(new_index)

func previous_weapon() -> void:
	if weapons.size() == 0:
		return
	var new_index = (active_weapon_index - 1 + weapons.size()) % weapons.size()
	switch_weapon(new_index)