extends Panel
class_name SelectionPanel

signal on_selection_completed

@export var players: Array[UnitStats]
@export var start_weapons: Array[ItemWeapon]
@export var start_item:Array[BoneItem]##chose initial skull
@export var equip_panel:EquipPanel

@onready var player_container: HBoxContainer = %PlayerContainer
@onready var weapon_container: HBoxContainer = %WeaponContainer
@onready var item_container: HBoxContainer = %ItemContainer

@onready var player_icon: TextureRect = %PlayerIcon
@onready var player_name: Label = %PlayerName
@onready var player_title: Label = %PlayerTitle
@onready var player_description: RichTextLabel = %PlayerDescription

func _ready() -> void:
	initialize()

func initialize()->void:
	for child in player_container.get_children(): child.queue_free()
	for child in weapon_container.get_children(): child.queue_free()
	for child in item_container.get_children(): child.queue_free()
	
	show_player_info(false)
	load_players()
	load_weapons()
	load_items()

func load_players() -> void:
	if players.is_empty():
		return
	
	for player: UnitStats in players:
		var card: SelectionCard = Global.SELECTION_CARD_SCENE.instantiate()
		card.pressed.connect(_on_player_selected.bind(player))
		player_container.add_child(card)
		card.set_icon(player.icon)

func load_weapons() -> void:
	if start_weapons.is_empty():
		return
	
	for weapon: ItemWeapon in start_weapons:
		var card: SelectionCard = Global.SELECTION_CARD_SCENE.instantiate()
		card.pressed.connect(_on_weapon_selected.bind(weapon))
		weapon_container.add_child(card)
		card.icon = weapon.item_icon
		
func load_items():
	if start_item.is_empty():
		return
	
	for item: BoneItem in start_item:
		var card: SelectionCard = Global.SELECTION_CARD_SCENE.instantiate()
		card.pressed.connect(_on_item_selected.bind(item))
		item_container.add_child(card)
		card.icon = item.item_icon

func show_player_info(value: bool) -> void:
	player_icon.visible = value
	player_name.visible = value
	player_title.visible = value
	player_description.visible = value

func _on_player_selected(player: UnitStats) -> void:
	Global.main_player_selected = player
	show_player_info(true)
	
	player_icon.texture = player.icon
	player_name.text = player.name
	player_description.text = "[code]Health: [color=green]%s[/color]\nDamage: [color=green]%s[/color]\nSpeed: [color=green]%s[/color]\nLuck: [color=green]%s[/color]\nBlock Chance: [color=green]%s%%[/color][/code]" % [player.health, player.damage, player.speed, player.luck, player.block_chance]

func _on_item_selected(item:BoneItem):
	Global.main_skull_item_selected = item

func _on_weapon_selected(weapon: ItemWeapon) -> void:
	Global.main_weapon_selected = weapon
	

func _on_continue_button_pressed() -> void:
	print(Global.main_player_selected,Global.main_weapon_selected,Global.equiped_bones[Global.BoneSlot.head])
	if not( Global.main_player_selected \
		and  Global.main_weapon_selected \
		and Global.main_weapon_selected):
		return
	
	on_selection_completed.emit()
	hide()
