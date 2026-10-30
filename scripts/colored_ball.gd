extends Area2D
class_name ColoredBall

# Type de couleur de cette boule (typage fort)
var color_type: GameManager.ColorType = GameManager.ColorType.RED

# Vitesse de mouvement aléatoire (optionnel)
const MOVE_SPEED: float = 50.0
var move_direction: Vector2 = Vector2.ZERO


func _ready() -> void:
    # Initialiser la direction de mouvement aléatoire
    move_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
    
    # Mettre à jour la couleur du ColorRect
    update_color()
    
    # Ajouter la boule au groupe "balls"
    add_to_group("balls")


func _process(delta: float) -> void:
    # Mouvement léger aléatoire pour plus de dynamisme
    position += move_direction * MOVE_SPEED * delta
    
    # Rebondir sur les bords de l'écran
    var viewport_size = get_viewport().size
    if position.x <= 0 or position.x >= viewport_size.x:
        move_direction.x *= -1
    if position.y <= 0 or position.y >= viewport_size.y:
        move_direction.y *= -1


# Définir le type de couleur de la boule
func set_color_type(new_color_type: GameManager.ColorType) -> void:
    color_type = new_color_type
    update_color()


# Mettre à jour la couleur visuelle
func update_color() -> void:
    var color_rect = get_node_or_null("ColorRect")
    if color_rect:
        color_rect.color = GameManager.COLOR_MAP[color_type]


# Obtenir le type de couleur
func get_color_type() -> GameManager.ColorType:
    return color_type
