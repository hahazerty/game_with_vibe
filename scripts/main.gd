extends Node2D

func _ready():
    # Attendre que le joueur soit instancié
    # Utilisation de call_deferred pour s'assurer que tout est prêt
    call_deferred("_init_game")

func _init_game():
    GameManager.init_game()
