extends RigidBody3D

# Damage is set by firing tower/unit
var damage : float

@export var col : CollisionShape3D

@export var smart_tracking : bool = false

@export var lifespan : float = 5
var life_timer : float = 0

func _process(delta: float) -> void:
	if life_timer > lifespan :
		queue_free()
	else :
		life_timer += delta
	
	
	#get_colliding_bodies()

func SetDamage(_damage : float) :
	damage = _damage

func _on_body_entered(body: Node) -> void:
	print("COLLIDED WITH: " + str(body.name))
	
	if body is Worker :
		var _worker : Worker = body
		_worker.TakeHit(damage)
		print("WORKER!!!")
	
	StickToCol(body)

func StickToCol(body : Node3D) :
	angular_velocity = Vector3.ZERO
	linear_velocity = Vector3.ZERO
	gravity_scale = 0
	self.reparent.call_deferred(body)
	
	call_deferred("ToggleCol")

func ToggleCol() :
	col.disabled = !col.disabled




#
