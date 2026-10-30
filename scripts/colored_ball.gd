extends Area2D

# Type de couleur de cette boule
var color_type


func _ready() -> void:
    # Mettre à jour la couleur du sprite
    update_sprite_color()
    
    # Ajouter la boule au groupe "balls"
    add_to_group("balls")


func _process(_delta: float) -> void:
    pass


# Définir le type de couleur de la boule
func set_color_type(new_color_type) -> void:
    color_type = new_color_type
    update_sprite_color()


# Mettre à jour la couleur visuelle du sprite
func update_sprite_color() -> void:
    var sprite = get_node_or_null("Sprite2D")
    if sprite:
        sprite.modulate = GameManager.COLOR_MAP[color_type]


# Obtenir le type de couleur
func get_color_type():
    return color_type
