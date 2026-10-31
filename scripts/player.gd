extends Area2D

# Vitesse de déplacement
const SPEED = 300.0

# Rayon minimal pour déclencher le Game Over
const MIN_RADIUS_FOR_GAME_OVER = 15.0

# Signal émis quand le joueur fusionne avec une boule
signal fusion_occurred(ball_color)

# Signal émis quand le joueur touche une boule de couleur différente
signal wrong_color_touched(ball_color)

# Signal émis quand le joueur meurt
signal player_died


func _ready():
    # Ajouter le joueur au groupe "player" pour le GameManager
    add_to_group("player")
    
    # Créer la forme de collision
    var collision = CollisionShape2D.new()
    var circle = CircleShape2D.new()
    circle.radius = 30.0
    collision.shape = circle
    add_child(collision)
    
    # Mettre à jour la couleur du Sprite2D
    update_sprite_color(GameManager.get_current_player_color())


func _process(delta):
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
    var viewport = get_viewport()
    if viewport:
        var viewport_size = viewport.size
        var radius = get_radius()
        position.x = clamp(position.x, radius, viewport_size.x - radius)
        position.y = clamp(position.y, radius, viewport_size.y - radius)
        
        # Vérifier si le joueur est trop petit (Game Over)
        if radius <= MIN_RADIUS_FOR_GAME_OVER:
            player_died.emit()
            GameManager.trigger_game_over()


# Connexion du signal area_entered
func _on_area_entered(area):
    # Vérifier si la zone est dans le groupe "balls"
    if area and area.is_in_group("balls"):
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


# Obtenir le rayon actuel du joueur
func get_radius():
    var collision_shape = get_node_or_null("CollisionShape2D")
    if collision_shape:
        var shape = collision_shape.shape
        if shape:
            return shape.radius
    return 30.0


# Mettre à jour la couleur du Sprite2D
func update_sprite_color(color_index):
    var sprite = get_node_or_null("Sprite2D")
    if sprite:
        var color_list = GameManager.get_color_list()
        if color_index < color_list.size():
            sprite.modulate = color_list[color_index]
