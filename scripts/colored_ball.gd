extends Area2D

# Type de couleur de cette boule (index dans COLOR_LIST)
var color_type = 0

# Vitesse de mouvement aléatoire
const MOVE_SPEED = 50.0
var move_direction = Vector2.ZERO


func _ready():
    # Créer la forme de collision
    var collision = CollisionShape2D.new()
    var circle = CircleShape2D.new()
    circle.radius = 20.0
    collision.shape = circle
    add_child(collision)
    
    # Initialiser la direction de mouvement aléatoire
    move_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
    
    # Mettre à jour la couleur
    update_sprite_color()
    
    # Ajouter la boule au groupe "balls"
    add_to_group("balls")


func _process(delta):
    # Mouvement léger aléatoire pour plus de dynamisme
    position += move_direction * MOVE_SPEED * delta
    
    # Rebondir sur les bords de l'écran
    var viewport = get_viewport()
    if viewport:
        var viewport_size = viewport.size
        if position.x <= 0 or position.x >= viewport_size.x:
            move_direction.x *= -1
        if position.y <= 0 or position.y >= viewport_size.y:
            move_direction.y *= -1


# Définir le type de couleur de la boule
func set_color_type(new_color_type):
    color_type = new_color_type
    update_sprite_color()


# Mettre à jour la couleur visuelle du Sprite2D
func update_sprite_color():
    var sprite = get_node_or_null("Sprite2D")
    if sprite:
        var color_list = GameManager.get_color_list()
        if color_type < color_list.size():
            sprite.modulate = color_list[color_type]


# Obtenir le type de couleur
func get_color_type():
    return color_type
