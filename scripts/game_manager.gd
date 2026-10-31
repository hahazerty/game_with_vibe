extends Node

const COLOR_LIST = [Color.RED, Color.GREEN, Color.BLUE, Color.YELLOW, Color.PURPLE, Color.CYAN]

const INITIAL_PLAYER_RADIUS = 30.0
const MIN_PLAYER_RADIUS = 20.0
const MAX_PLAYER_RADIUS = 100.0
const SPAWN_INTERVAL = 2.0
const SPAWN_COUNT = 3
const MAX_SPAWN_ATTEMPTS = 100
const MIN_SPAWN_DISTANCE = 100.0
const MIN_RADIUS_FOR_GAME_OVER = 15.0

signal game_started
signal game_over
signal score_changed(new_score)

var current_player_color = 0
var score = 0
var spawn_timer = 0.0
var player = null
var ball_scene = null
var active_balls = []

func _ready():
    ball_scene = preload("res://scenes/colored_ball.tscn")

func init_game():
    player = get_tree().get_first_node_in_group("player")
    if player:
        update_player_color(current_player_color)
        spawn_timer = SPAWN_INTERVAL
        game_started.emit()
    else:
        push_error("Player node not found!")

func _process(delta):
    if player == null:
        player = get_tree().get_first_node_in_group("player")
        if player:
            init_game()
        return
    
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
    var random_color_type = randi() % COLOR_LIST.size()
    var spawn_position
    var attempts = 0
    
    while attempts < MAX_SPAWN_ATTEMPTS:
        spawn_position = Vector2(randf() * screen_size.x, randf() * screen_size.y)
        if player == null or spawn_position.distance_to(player.position) >= MIN_SPAWN_DISTANCE:
            break
        attempts += 1
    
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
