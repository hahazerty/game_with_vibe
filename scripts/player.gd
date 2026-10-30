extends Area2D

# Vitesse de déplacement
const SPEED = 300.0

# Signal émis quand le joueur fusionne avec une boule
signal fusion_occurred(ball_color)

# Signal émis quand le joueur touche une boule de couleur différente
signal wrong_color_touched(ball_color)


func _ready() -> void:
    # Ajouter le joueur au groupe "player" pour le GameManager
    add_to_group("player")
    
    # Mettre à jour la couleur du sprite
    update_sprite_color(GameManager.get_current_player_color())


func _process(delta: float) -> void:
    # Déplacement du joueur
    var velocity = Vector2.ZERO
    
    if Input.is_action_pressed("move_left"):
        velocity.x -= 1
    if Input.is_action_pressed("move_right"):
        velocity.x += 1
    if Input.is_action_pressed("move_up"):
        velocity.y -= 1
    if Input.is_action_pressed("move_down"):
        velocity.y += 1
    
    # Normaliser la vitesse pour un mouvement fluide
    if velocity.length() > 0:
        velocity = velocity.normalized()
    
    # Appliquer le mouvement
    position += velocity * SPEED * delta
    
    # Garder le joueur dans les limites de l'écran
    var viewport_size = get_viewport_rect().size
    position.x = clamp(position.x, 0 + get_radius(), viewport_size.x - get_radius())
    position.y = clamp(position.y, 0 + get_radius(), viewport_size.y - get_radius())


func _on_area_entered(area: Area2D) -> void:
    # Vérifier si la zone est dans le groupe "balls"
    if area.is_in_group("balls"):
        # Vérifier si la couleur correspond
        if area.get_color_type() == GameManager.get_current_player_color():
            # Fusion réussie
            fusion_occurred.emit(area.get_color_type())
            
            # Augmenter la taille du joueur
            GameManager.increase_player_size(5)
            
            # Ajouter des points
            GameManager.add_score(10)
            
            # Supprimer la boule
            GameManager.remove_ball(area)
            
        else:
            # Mauvaise couleur
            wrong_color_touched.emit(area.get_color_type())
            
            # Réduire la taille du joueur
            GameManager.decrease_player_size(10)
            
            # Retirer des points
            GameManager.remove_score(5)
            
            # Supprimer la boule
            GameManager.remove_ball(area)


func get_radius() -> float:
    var collision_shape = get_node_or_null("CollisionShape2D")
    if collision_shape and collision_shape.shape is CircleShape2D:
        return (collision_shape.shape as CircleShape2D).radius
    return 30.0


func update_sprite_color(color_type) -> void:
    var sprite = get_node_or_null("Sprite2D")
    if sprite:
        sprite.modulate = GameManager.COLOR_MAP[color_type]
