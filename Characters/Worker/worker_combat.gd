@icon("res://addons/at-icons/node/sword.svg")
extends Node
class_name WorkerCombat

@export var worker : Worker

@export_category("Combat Stats")
@export var max_hp : float
@export var attack_cooldown : float = 1
@export var attack_range : float = 5
@export var attack_damage : float = 2

var _current_hp : float
var _attack_timer : float = 0

var target : Node3D

var range_check_cooldown : float = 0.2
var _range_timer : float = 0

### Flags
var can_attack : bool = false
var in_range : bool = false
var is_dead : bool = false


func _ready() -> void:
	_current_hp = max_hp

func ProcessTick(_delta: float) -> void:
	if !can_attack :
		if _attack_timer > attack_cooldown :
			can_attack = true
			_attack_timer = 0
		else :
			_attack_timer += _delta
	
	if target != null :
		
		if !in_range :
			if _range_timer > range_check_cooldown :
				in_range = CheckInRange(target, attack_range)
				_range_timer = 0
			else :
				_range_timer += _delta

func AttackTarget(_target : Node3D, _damage : float) :
	_target.TryTakeHit()

func CheckInRange(_target : Node3D, _range : float) -> bool :
	var distance : float = worker.global_position.distance_to(target.global_position)
	if distance < _range :
		return true
	else :
		return false

func SetTarget(_target : Node3D) :
	target = _target


func TryTakeHit(_damage : float) :
	_current_hp -= _damage
	if _current_hp <= 0 :
		TryDie()

func TryDie() :
	if is_dead :
		return
	
	# Fall over ragdoll type



#
