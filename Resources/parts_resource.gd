class_name Part extends Resource 
enum TYPE {ENGINE, FUEL, FILLING, COATING, STRUCTURE}
const SPECIAL_UPPERS = ["thrust", "fuel"]
const SPECIAL_DOWNERS = ["drag", "risk"]
var level = 0
var upgrade_counter = 0
@export var part_name: String
@export var images: Array[Texture2D] 
@export var owned: int
@export var success: float
@export var value: int
@export var cost: int
@export var value_upgrade_cost: int
@export var success_upgrade_cost: int
@export var locked: bool
@export var blocks: Vector2
@export var type: TYPE
@export var weight: float
@export var weight_upgrade_cost: int
@export var special: float
@export var special_name: String
@export var special_upgrade_cost: int
