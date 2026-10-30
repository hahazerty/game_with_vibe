extends Area2D
class_name Player

# Vitesse de déplacement
const SPEED: float = 300.0

# Rayon minimal pour déclencher le Game Over
const MIN_RADIUS_FOR_GAME_OVER: float = 15.0

# Signal émis quand le joueur fusionne avec une boule
signal fusion_occurred(ball_color: GameManager.ColorType)

# Signal émis quand le joueur touche une boule de couleur différente
signal wrong_color_touched(ball_color: GameManager.ColorType)

# Signal émis quand le joueur meurt
signal player_died


func _ready() -> void:
    # Ajouter le joueur au groupe "player" pour le GameManager
    add_to_group("player")
    
    # Mettre à jour la couleur du ColorRect
    update_color(GameManager.get_current_player_color())


func _process(delta: float) -> void:
    # Déplacement du joueur
    var velocity: Vector2 = Vector2.ZERO
    
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
    var viewport_size: Vector2 = get_viewport().size
    var radius: float = get_radius()
    position.x = clamp(position.x, radius, viewport_size.x - radius)
    position.y = clamp(position.y, radius, viewport_size.y - radius)
    
    # Vérifier si le joueur est trop petit (Game Over)
    if radius <= MIN_RADIUS_FOR_GAME_OVER:
        player_died.emit()
        GameManager.game_over()


# Connexion du signal area_entered
func _on_area_entered(area: Area2D) -> void:
    # Vérifier si la zone est dans le groupe "balls"
    if area.is_in_group("balls") and area is ColoredBall:
        var ball: ColoredBall = area as ColoredBall
        
        # Vérifier si la couleur correspond
        if ball.get_color_type() == GameManager.get_current_player_color():
            # Fusion réussie
            fusion_occurred.emit(ball.get_color_type())
            
            # Augmenter la taille du joueur
            GameManager.increase_player_size(5)
            
            # Ajouter des points
            GameManager.add_score(10)
            
            # Supprimer la boule
            GameManager.remove_ball(ball)
            
        else:
            # Mauvaise couleur
            wrong_color_touched.emit(ball.get_color_type())
            
            # Réduire la taille du joueur
            GameManager.decrease_player_size(10)
            
            # Retirer des points
            GameManager.remove_score(5)
            
            # Supprimer la boule
            GameManager.remove_ball(ball)


# Obtenir le rayon actuel du joueur
func get_radius() -> float:
    var collision_shape = get_node_or_null("CollisionShape2D")
    if collision_shape and collision_shape.shape is CircleShape2D:
        return (collision_shape.shape as CircleShape2D).radius
    return 30.0


# Mettre à jour la couleur du ColorRect
func update_color(color_type: GameManager.ColorType) -> void:
    var color_rect = get_node_or_null("ColorRect")
    if color_rect:
        color_rect.color = GameManager.COLOR_MAP[color_type]
