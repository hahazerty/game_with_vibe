extends Node

# Couleurs disponibles pour les boules
const COLOR_LIST = [Color.RED, Color.GREEN, Color.BLUE, Color.YELLOW, Color.PURPLE, Color.CYAN]

# Taille initiale du joueur
const INITIAL_PLAYER_RADIUS = 30.0
const MIN_PLAYER_RADIUS = 20.0
const MAX_PLAYER_RADIUS = 100.0

# Vitesse de spawn des boules (en secondes)
const SPAWN_INTERVAL = 2.0
const SPAWN_COUNT = 3
const MAX_SPAWN_ATTEMPTS = 100
const MIN_SPAWN_DISTANCE = 100.0

# Rayon minimal pour déclencher le Game Over
const MIN_RADIUS_FOR_GAME_OVER = 15.0

# Signal émis quand le jeu commence
signal game_started

# Signal émis quand le jeu se termine
signal game_over

# Signal émis quand le score change
signal score_changed(new_score)

# Couleur actuelle du joueur (index dans COLOR_LIST)
var current_player_color = 0

# Score du joueur
var score = 0

# Timer pour le spawn des boules
var spawn_timer = 0.0

# Référence au joueur
var player = null

# Scène pré-chargée pour les boules
var ball_scene = null

# Liste des boules colorées actives
var active_balls = []


func _ready():
    # Pré-charger la scène des boules
    ball_scene = preload("res://scenes/colored_ball.tscn")


func init_game():
    # Récupérer le joueur depuis la scène
    player = get_tree().get_first_node_in_group("player")
    
    if player:
        # Définir la couleur initiale du joueur
        update_player_color(current_player_color)
        
        # Démarrer le timer de spawn
        spawn_timer = SPAWN_INTERVAL
        
        # Émettre le signal de début de jeu
        game_started.emit()
    else:
        push_error("Player node not found!")


func _process(delta):
    # Si le joueur n'est pas encore trouvé, essayer à chaque frame
    if player == null:
        player = get_tree().get_first_node_in_group("player")
        if player:
            init_game()
        return
    
    # Mettre à jour le timer de spawn
    spawn_timer -= delta
    
    if spawn_timer <= 0.0:
        spawn_random_balls()
        spawn_timer = SPAWN_INTERVAL


func spawn_random_balls():
    if ball_scene == null:
        push_error("Ball scene not loaded!")
        return
    
    var viewport = get_viewport()
    if viewport == null:
        return
    
    var screen_size = viewport.size
    
    for i in range(SPAWN_COUNT):
        spawn_single_ball(screen_size)


func spawn_single_ball(screen_size):
    # Choisir une couleur aléatoire (index dans COLOR_LIST)
    var random_color_type = randi() % COLOR_LIST.size()
    
    # Position aléatoire
    var spawn_position
    var attempts = 0
    
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
        var new_ball = ball_scene.instantiate()
        if new_ball:
            new_ball.position = spawn_position
            if new_ball.has_method("set_color_type"):
                new_ball.set_color_type(random_color_type)
            get_tree().current_scene.add_child(new_ball)
            active_balls.append(new_ball)


func update_player_color(new_color):
    current_player_color = new_color
    
    if player:
        var sprite = player.get_node_or_null("Sprite2D")
        if sprite and new_color < COLOR_LIST.size():
            sprite.modulate = COLOR_LIST[new_color]


func increase_player_size(amount):
    if player:
        var collision_shape = player.get_node_or_null("CollisionShape2D")
        if collision_shape:
            var shape = collision_shape.shape
            if shape:
                shape.radius = min(shape.radius + amount, MAX_PLAYER_RADIUS)


func decrease_player_size(amount):
    if player:
        var collision_shape = player.get_node_or_null("CollisionShape2D")
        if collision_shape:
            var shape = collision_shape.shape
            if shape:
                shape.radius = max(shape.radius - amount, MIN_PLAYER_RADIUS)


func add_score(points):
    score += points
    score_changed.emit(score)


func remove_score(points):
    score = max(score - points, 0)
    score_changed.emit(score)


func remove_ball(ball):
    if ball and active_balls.has(ball):
        active_balls.erase(ball)
        ball.queue_free()


func trigger_game_over():
    game_over.emit()


func get_color_list():
    return COLOR_LIST


func get_current_player_color():
    return current_player_color
