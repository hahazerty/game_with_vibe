extends Node

# Couleurs disponibles pour les boules
enum ColorType { RED, GREEN, BLUE, YELLOW, PURPLE, CYAN }

# Dictionnaire associant ColorType à une couleur Godot
const COLOR_MAP: Dictionary = {
    ColorType.RED: Color.RED,
    ColorType.GREEN: Color.GREEN,
    ColorType.BLUE: Color.BLUE,
    ColorType.YELLOW: Color.YELLOW,
    ColorType.PURPLE: Color.PURPLE,
    ColorType.CYAN: Color.CYAN
}

# Taille initiale du joueur
const INITIAL_PLAYER_RADIUS: float = 30.0

# Rayon minimal et maximal pour le joueur
const MIN_PLAYER_RADIUS: float = 20.0
const MAX_PLAYER_RADIUS: float = 100.0

# Vitesse de spawn des boules (en secondes)
const SPAWN_INTERVAL: float = 2.0

# Nombre de boules à spawner à chaque intervalle
const SPAWN_COUNT: int = 3

# Maximum de tentatives pour éviter les boucles infinies
const MAX_SPAWN_ATTEMPTS: int = 100

# Rayon minimum pour éviter les collisions au spawn
const MIN_SPAWN_DISTANCE: float = 100.0

# Signal émis quand le jeu commence
signal game_started

# Signal émis quand le jeu se termine
signal game_over

# Signal émis quand le score change
signal score_changed(new_score: int)

# Couleur actuelle du joueur
var current_player_color: ColorType = ColorType.RED

# Score du joueur
var score: int = 0:
    set(new_score):
        score = max(new_score, 0)  # Score ne peut pas être négatif
        score_changed.emit(score)

# Timer pour le spawn des boules
var spawn_timer: float = 0.0

# Référence au joueur
var player: Player

# Scène pré-chargée pour les boules
var ball_scene: PackedScene

# Liste des boules colorées actives
var active_balls: Array[ColoredBall] = []


func _ready() -> void:
    # Initialiser le jeu
    init_game()


func init_game() -> void:
    # Pré-charger la scène des boules pour optimiser les performances
    ball_scene = preload("res://scenes/colored_ball.tscn")
    
    # Récupérer le joueur depuis la scène
    player = get_tree().get_first_node_in_group("player") as Player
    
    if player:
        # Définir la couleur initiale du joueur
        update_player_color(current_player_color)
    else:
        push_error("Player node not found!")
        return
    
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
    if ball_scene == null:
        push_error("Ball scene not loaded!")
        return
    
    var viewport = get_viewport()
    var screen_size: Vector2 = viewport.size if viewport else Vector2(1920, 1080)
    
    for i in range(SPAWN_COUNT):
        spawn_single_ball(screen_size)


func spawn_single_ball(screen_size: Vector2) -> void:
    # Choisir une couleur aléatoire
    var color_type_keys = COLOR_MAP.keys()
    var random_color_type: ColorType = color_type_keys[randi() % color_type_keys.size()]
    
    # Position aléatoire
    var spawn_position: Vector2
    var attempts: int = 0
    
    # Trouver une position valide (max 100 tentatives)
    while attempts < MAX_SPAWN_ATTEMPTS:
        spawn_position = Vector2(
            randf() * screen_size.x,
            randf() * screen_size.y
        )
        
        # Vérifier la distance avec le joueur
        if player == null or spawn_position.distance_to(player.position) >= MIN_SPAWN_DISTANCE:
            break
        
        attempts += 1
    
    # Si on a trouvé une position valide
    if attempts < MAX_SPAWN_ATTEMPTS:
        # Créer une nouvelle boule
        var new_ball: ColoredBall = ball_scene.instantiate()
        
        # Configurer la boule
        new_ball.position = spawn_position
        new_ball.set_color_type(random_color_type)
        
        # Ajouter la boule à la scène
        get_tree().current_scene.add_child(new_ball)
        active_balls.append(new_ball)
    else:
        push_warning("Failed to find valid spawn position after %d attempts" % MAX_SPAWN_ATTEMPTS)


func update_player_color(new_color: ColorType) -> void:
    current_player_color = new_color
    
    if player:
        # Mettre à jour la couleur visuelle du joueur
        player.update_sprite_color(new_color)


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


func remove_score(points: int) -> void:
    score -= points


func remove_ball(ball: ColoredBall) -> void:
    if active_balls.has(ball):
        active_balls.erase(ball)
        ball.queue_free()


func game_over() -> void:
    game_over.emit()


func get_color_map() -> Dictionary:
    return COLOR_MAP


func get_current_player_color() -> ColorType:
    return current_player_color
