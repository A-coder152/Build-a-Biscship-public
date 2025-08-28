class_name Part extends Resource 
enum TYPE {ENGINE, FILLING}
@export var part_name: String

@export var image: Texture2D
@export var owned: int
@export var success: float
@export var value: int
@export var cost: int
@export var value_upgrade_cost: int
@export var success_upgrade_cost: int
@export var locked: bool
@export var blocks: Vector2
