extends Node

# Couleurs disponibles pour les boules
enum ColorType { RED, GREEN, BLUE, YELLOW, PURPLE, CYAN }

# Dictionnaire associant ColorType à une couleur Godot
const COLOR_MAP = {
    ColorType.RED: Color.RED,
    ColorType.GREEN: Color.GREEN,
    ColorType.BLUE: Color.BLUE,
    ColorType.YELLOW: Color.YELLOW,
    ColorType.PURPLE: Color.PURPLE,
    ColorType.CYAN: Color.CYAN
}

# Taille initiale du joueur
const INITIAL_PLAYER_RADIUS = 30

# Rayon minimal et maximal pour le joueur
const MIN_PLAYER_RADIUS = 20
const MAX_PLAYER_RADIUS = 100

# Vitesse de déplacement du joueur
const PLAYER_SPEED = 300.0

# Taille des boules colorées
const BALL_RADIUS = 20

# Vitesse de spawn des boules (en secondes)
const SPAWN_INTERVAL = 2.0

# Nombre de boules à spawner à chaque intervalle
const SPAWN_COUNT = 3

# Rayon de détection pour la fusion
const FUSION_DISTANCE = 40

# Signal émis quand le jeu commence
signal game_started

# Signal émis quand le jeu se termine
signal game_over

# Signal émis quand le score change
signal score_changed(new_score: int)

# Couleur actuelle du joueur
var current_player_color: ColorType = ColorType.RED

# Score du joueur
var score: int = 0

# Timer pour le spawn des boules
var spawn_timer: float = 0.0

# Référence au joueur
var player: Area2D

# Liste des boules colorées actives
var active_balls: Array[Area2D] = []


func _ready() -> void:
    # Initialiser le jeu
    init_game()


func init_game() -> void:
    # Récupérer le joueur depuis la scène
    player = get_tree().get_first_node_in_group("player")
    
    if player:
        # Définir la couleur initiale du joueur
        update_player_color(current_player_color)
        
    # Démarrer le timer de spawn
    spawn_timer = SPAWN_INTERVAL
    
    # Émettre le signal de début de jeu
    game_started.emit()


func _process(delta: float) -> void:
    # Mettre à jour le timer de spawn
    spawn_timer -= delta
    
    if spawn_timer <= 0.0:
        spawn_random_balls()
        spawn_timer = SPAWN_INTERVAL


func spawn_random_balls() -> void:
    var screen_size = get_viewport_rect().size
    
    for i in range(SPAWN_COUNT):
        # Choisir une couleur aléatoire
        var random_color_type = ColorType(randi() % ColorType.size())
        
        # Position aléatoire sur les bords de l'écran
        var spawn_position = Vector2(
            randi() % int(screen_size.x),
            randi() % int(screen_size.y)
        )
        
        # S'assurer que la boule ne spawn pas sur le joueur
        if player:
            while spawn_position.distance_to(player.position) < 100:
                spawn_position = Vector2(
                    randi() % int(screen_size.x),
                    randi() % int(screen_size.y)
                )
        
        # Créer une nouvelle boule
        var ball_scene = preload("res://scenes/colored_ball.tscn")
        var new_ball = ball_scene.instantiate()
        
        # Configurer la boule
        new_ball.position = spawn_position
        new_ball.set_color_type(random_color_type)
        
        # Ajouter la boule à la scène
        get_tree().current_scene.add_child(new_ball)
        active_balls.append(new_ball)


func update_player_color(new_color: ColorType) -> void:
    current_player_color = new_color
    
    if player:
        # Mettre à jour la couleur visuelle du joueur
        var sprite = player.get_node_or_null("Sprite2D")
        if sprite:
            sprite.modulate = COLOR_MAP[new_color]


func increase_player_size(amount: float) -> void:
    if player:
        var collision_shape = player.get_node_or_null("CollisionShape2D")
        if collision_shape:
            var circle_shape = collision_shape.shape as CircleShape2D
            if circle_shape:
                circle_shape.radius = min(circle_shape.radius + amount, MAX_PLAYER_RADIUS)


func decrease_player_size(amount: float) -> void:
    if player:
        var collision_shape = player.get_node_or_null("CollisionShape2D")
        if collision_shape:
            var circle_shape = collision_shape.shape as CircleShape2D
            if circle_shape:
                circle_shape.radius = max(circle_shape.radius - amount, MIN_PLAYER_RADIUS)


func add_score(points: int) -> void:
    score += points
    score_changed.emit(score)


func remove_score(points: int) -> void:
    score = max(score - points, 0)
    score_changed.emit(score)


func remove_ball(ball: Area2D) -> void:
    if active_balls.has(ball):
        active_balls.erase(ball)
        ball.queue_free()


func get_color_map() -> Dictionary:
    return COLOR_MAP


func get_current_player_color() -> ColorType:
    return current_player_color
