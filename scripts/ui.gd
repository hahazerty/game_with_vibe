extends CanvasLayer

# Référence au label de score
var score_label: Label

# Référence au label Game Over
var game_over_label: Label


func _ready() -> void:
    # Récupérer les références aux labels
    score_label = get_node_or_null("ScoreLabel")
    game_over_label = get_node_or_null("GameOverLabel")
    
    # Connexion aux signaux du GameManager
    GameManager.score_changed.connect(_on_score_changed)
    GameManager.game_over.connect(_on_game_over)
    
    # Initialiser l'affichage du score
    if score_label:
        score_label.text = "Score: %d" % GameManager.score


func _on_score_changed(new_score: int) -> void:
    if score_label:
        score_label.text = "Score: %d" % new_score


func _on_game_over() -> void:
    if game_over_label:
        game_over_label.visible = true
