extends Panel

var head=Global.BoneSlot.head
var lhand=Global.BoneSlot.lhand
var lrib=Global.BoneSlot.lrib
var spine=Global.BoneSlot.spine
var rrib=Global.BoneSlot.rrib
var rhand=Global.BoneSlot.rhand
var lleg=Global.BoneSlot.lleg
var rleg=Global.BoneSlot.rleg


@export var items_in_pack:Array[ItemBase]

@onready var item_card_scene:PackedScene = preload("res://scenes/ui/item_card/item_card.tscn")
@onready var display_card_scene:PackedScene = preload("res://scenes/ui/display_card/display_card.tscn")

@onready var equip_slots_ui:Dictionary[int,ItemCard] = {
	head:%head,
	lhand:%hand0,
	lrib:%rib0,
	spine:%spine,
	rrib:%rib1,
	rhand:%hand1,
	lleg:%leg0,
	rleg:%leg1
}
@onready var item_description: RichTextLabel = %ItemDescription
@onready var equipments: GridContainer = %Equipments
@onready var summons: GridContainer = %Summons
@onready var equip_button: Button = %EquipButton
@onready var take_off_button: Button = %TakeOffButton


var card_to_packindex:Dictionary[ItemCard,int]
var current_selct_card:ItemCard
var current_slot:Global.BoneSlot = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	item_description.text = "[color=red]aaaaa[color=red]"
	set_equipments()
	for slot in equip_slots_ui:
		equip_slots_ui[slot].on_item_card_selected.connect(_on_slot_selected)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_equipments():
	# Rebuild inventory grid from resource list.
	for c in equipments.get_children():
		c.queue_free()
	for i in items_in_pack.size():
		var item_card := item_card_scene.instantiate() as ItemCard
		if not item_card:
			continue
		item_card.item = items_in_pack[i]
		equipments.add_child(item_card)
		card_to_packindex[item_card] = i
		item_card.on_item_card_selected.connect(_on_item_card_selected)
		
		
func _on_item_card_selected(card: ItemCard):
	# Selecting inventory item prepares a valid target slot for equip action.
	current_selct_card = card
	item_description.text = card.item.get_description()
	take_off_button.disabled = true
	
	var can_equip:bool
	var item = card.item
	if item:
		item_description.text  =item.get_description()
	if item is BoneItem:
		for slot in item.item_vaild_slot:
			if item.item_vaild_slot[slot] and not Global.equiped_bones[slot]:
				equip_button.disabled = false
				current_slot = slot
				return
	equip_button.disabled = true
	
func _on_slot_selected(card: ItemCard):
	# Selecting an occupied slot enables unload action.
	current_selct_card =card
	if not card.item:
		take_off_button.disabled = true
		return
	item_description.text = card.item.get_description()
	equip_button.disabled = true
	take_off_button.disabled = false
	
func _on_equip_button_button_down() -> void:
	if not (current_selct_card and (current_slot>=0)):
		push_error("aaaaaa")
		return
	# Move selected inventory item into chosen body slot.
	equip_slots_ui[current_slot].item = current_selct_card.item
	current_selct_card.queue_free()
	
	current_selct_card = null
	current_slot = -1
	equip_button.disabled = true


func _on_take_off_button_button_down() -> void:
	if not current_selct_card and current_selct_card.item:
		push_error("aaaaaa")
		return
	# Move equipped item back to inventory list.
	var item := current_selct_card.item
	current_selct_card.item = null
	var item_card = item_card_scene.instantiate() as ItemCard
	item_card.item = item
	equipments.add_child(item_card)
	
	current_selct_card = null
	current_slot = -1
	take_off_button.disabled = true
