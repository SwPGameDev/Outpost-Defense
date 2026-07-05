@icon("res://addons/at-icons/node3d/tower.svg")
extends Building

@export_group("Debug")
@export var debug : bool = false
@export var debug_target : Node3D

@export_group("References")
@export var turret : Node3D
@export var projectile_scene : PackedScene
@export var projectile_spawn : Node3D
var target : Node3D

@export_group("Stats")
@export var rotate_speed : float = 60
@export var launch_force : float = 10
@export var projectile_mass : float = 1
@export var targeting_range : float = 50
@export var damage : float = 1
@export var attack_cooldown : float = 1
var _attack_timer : float = 0


var can_attack : bool = false

### Trajectory
var target_last_pos : Vector3
var predicted_target_pos : Vector3
var enemy_layer_mask : int


func _ready() -> void:
	current_hp = max_hp
	
	if debug :
		target = debug_target

func _process(delta: float) -> void:
	if not can_attack :
		if _attack_timer > attack_cooldown :
			_attack_timer = 0
			can_attack = true
		else :
			_attack_timer += delta
	
	
	if target != null :
		predicted_target_pos = target.global_position + TargetTrajectory(delta) * TimeToReachTarget()
		
		RotateTurretTowardsTarget(target, rotate_speed, delta)
		
		if can_attack :
			FireProjectile()
			can_attack = false
	else :
		target = TryGetTarget()
		
		# Reset look

func TakeHit(damage_param : float) :
	current_hp -= damage_param
	
	if current_hp <= 0 :
		Die()

func Die() :
	#queue_free()
	pass

func GetColsMaskedInRange(col_mask : int) -> Array[Node3D] :
	var col_array : Array[Node3D] = []
	var max_enemies : int = 50
	
	var temp_dict : Array[Dictionary] = Utility.TrySphereCast(self.global_position, targeting_range, max_enemies, col_mask)
	for result in temp_dict :
		col_array.append(result.collider)
	
	return col_array

func TryGetTarget() -> Node3D :
	var enemies : Array[Node3D] = GetColsMaskedInRange(enemy_layer_mask)
	var closest_enemy : Node3D = null
	var shortest_distance : float = INF
	
	for guy : Node3D in enemies :
		var distance : float = self.global_position.distance_to(guy.global_position)
		
		if distance < shortest_distance :
			shortest_distance = distance
			closest_enemy = guy
		
	
	return closest_enemy

func RotateTurretTowardsTarget(target_param : Node3D, rotation_speed : float, delta : float) :
	var dir = global_position.direction_to(target_param.global_position)
	var target_angle : float = atan2(dir.x, dir.z)
	turret.rotation.y = rotate_toward(turret.rotation.y, target_angle, rotation_speed * delta)
	
	#turret.rotation.y = lerp_angle(turret.rotation.y, target_angle, rotation_speed * delta)

func FireProjectile() :
	var new_projectile : RigidBody3D = load(projectile_scene.resource_path).instantiate() # Custom class projectile?
	add_child(new_projectile)
	new_projectile.global_position = projectile_spawn.global_position
	new_projectile.rotation = turret.global_rotation
	new_projectile.apply_impulse(turret.global_basis.z * launch_force)
	
	# new_projectile.damage = damage
	
	new_projectile.reparent(get_tree().root)

func TargetTrajectory(delta : float) -> Vector3 :
	var target_trajectory = (target.global_position - target_last_pos) / delta
	target_last_pos = target.global_position
	
	return target_trajectory

func TimeToReachTarget() :
	var projectile_velocity : float = launch_force / projectile_mass
	var distance : float = turret.global_position.distance_to(target.global_position)
	return distance / projectile_velocity
