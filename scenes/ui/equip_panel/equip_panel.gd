extends Panel
class_name EquipPanel

signal on_equip_panel_next_wave
signal shop_pressed

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

@onready var equip_slots_ui:Dictionary[Global.BoneSlot,ItemCard] = {
	head:%head,
	lhand:%hand0,
	lrib:%rib0,
	spine:%spine,
	rrib:%rib1,
	rhand:%hand1,
	lleg:%leg0,
	rleg:%leg1}
@onready var item_description: RichTextLabel = %ItemDescription
@onready var equipments: GridContainer = %Equipments
#@onready var summons: GridContainer = %Summons
@onready var equip_button: Button = %EquipButton
@onready var take_off_button: Button = %TakeOffButton


var current_selct_card:ItemCard
var current_slot:Global.BoneSlot = -1
var slot_card:Dictionary[Global.BoneSlot,ItemCard]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#item_description.text = "[color=red]aaaaa[color=red]"
	set_equipments()
	for slot in equip_slots_ui:
		equip_slots_ui[slot].on_item_card_selected.connect(_on_slot_selected)

func clear_slots()->void:
	slot_card.clear()
	for slot in equip_slots_ui:
		equip_slots_ui[slot].item = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_equipments():
	# Rebuild inventory grid from resource list.
	for c in equipments.get_children():
		c.queue_free()
	for i in items_in_pack.size():
		add_equipment_item_card(items_in_pack[i])

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
	for slot in equip_slots_ui:
		if card == equip_slots_ui[slot]:
			current_slot = slot
			break
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
	var item := current_selct_card.item
	#current_selct_card.queue_free()
	current_selct_card.hide()
	
	equip_item(current_slot,item)
	#equip_slots_ui[current_slot].item = item
	#Global.equiped_bones[current_slot]= item
	#item = item as BoneItem
	#var allowed_triggers:Array[Global.ItemCallBack] = [Global.ItemCallBack.ONEQUIP,Global.ItemCallBack.EQUIPORUNLOAD]
	#var equip_context:= EffectContext.new()
	#equip_context.trigger_type = Global.ItemCallBack.ONEQUIP
	## Trigger all ONEQUIP effects declared on this bone item.
	#for packed_effect:PackedItemEffect in item.effects:
		#for trigger in allowed_triggers:
			#if packed_effect.trigger == trigger:
				#packed_effect.effect(equip_context)
	
	slot_card[current_slot] = current_selct_card
	current_selct_card = null
	current_slot = -1
	equip_button.disabled = true
	SoundManager.sfx_play(["equip1","equip2"].pick_random())

func equip_item(slot:Global.BoneSlot,item:BoneItem):
	#if Global.player:
		#
		#print(Global.player.stats.damage)
		#print(Global.player.stats.speed)
	equip_slots_ui[slot].item = item
	Global.equiped_bones[slot]= item
	item = item as BoneItem
	var allowed_triggers:Array[Global.ItemCallBack] = [Global.ItemCallBack.ONEQUIP,Global.ItemCallBack.EQUIPORUNLOAD]
	var equip_context:= EffectContext.new()
	equip_context.trigger_type = Global.ItemCallBack.ONEQUIP
	# Trigger all ONEQUIP effects declared on this bone item.
	for packed_effect:PackedItemEffect in item.effects:
		for trigger in allowed_triggers:
			if packed_effect.trigger == trigger:
				packed_effect.effect(equip_context)
	#if Global.player:
		#
		#print(Global.player.stats.damage)
		#print(Global.player.stats.speed)

func equip_take_off(slot:Global.BoneSlot):
	#TODO finish slot card mapping in on_take_off..
	# TODO finsh this
	var card:= slot_card[slot]
	if not card:
		push_error("No card equiped")
		return
	if not card.item:
		push_error("Card have no item")
		return
	#移出物体
	slot_card[slot] = null
	var item = equip_slots_ui[slot].item
	equip_slots_ui[slot].item = null
	Global.equiped_bones[slot] = null
	#触发效果
	var allowed_triggers:Array[Global.ItemCallBack] = [Global.ItemCallBack.ONUNLOAD,Global.ItemCallBack.EQUIPORUNLOAD]
	var equip_context:= EffectContext.new()
	equip_context.trigger_type = Global.ItemCallBack.ONUNLOAD
	# Roll back effects that should happen on unload.
	for packed_effect:PackedItemEffect in item.effects:
		for trigger in allowed_triggers:
			if packed_effect.trigger == trigger:
				packed_effect.effect(equip_context)
	
	# inventory list中对应的卡片可见
	card.show()
	SoundManager.sfx_play(["unload1","unload2"].pick_random())

func _on_take_off_button_button_down() -> void:
	if not (current_selct_card and current_selct_card.item):
		push_error("aaaaaa")
		return
	# Move equipped item back to inventory list.
	#var item := current_selct_card.item
	#current_selct_card.item = null
	#add_equipment_item_card(item)
	
	
	#Global.equiped_bones[current_slot]= null
	#item = item as BoneItem
	#var allowed_triggers:Array[Global.ItemCallBack] = [Global.ItemCallBack.ONUNLOAD,Global.ItemCallBack.EQUIPORUNLOAD]
	#var equip_context:= EffectContext.new()
	#equip_context.trigger_type = Global.ItemCallBack.ONUNLOAD
	## Roll back effects that should happen on unload.
	#for packed_effect:PackedItemEffect in item.effects:
		#for trigger in allowed_triggers:
			#if packed_effect.trigger == trigger:
				#packed_effect.effect(equip_context)
	
	#current_selct_card = null
	#var card := slot_card[current_slot]
	#if not card:
		#push_error("equip card not found.")
		#return
	#card.show()
	equip_take_off(current_slot)
	
	current_slot = -1
	take_off_button.disabled = true

func add_equipment_item_card(item:ItemBase)-> ItemCard:
	# Shared helper used by initial fill and unload operation.
	var item_card := item_card_scene.instantiate() as ItemCard
	item_card.item = item
	equipments.add_child(item_card)
	item_card.on_item_card_selected.connect(_on_item_card_selected)
	return item_card

func _on_next_wave_button_down() -> void:
	on_equip_panel_next_wave.emit()

func _on_inventory_pressed() -> void:
	shop_pressed.emit()
