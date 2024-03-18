extends Node

const gameOverScreen = preload("res://Materials/GameOverScreen.tscn")
const spiderMonster = preload("res://Models/spider_2.tscn")


@onready var spawnTimer = $MonsterSpawn
@onready var spawnLocation = $PSXLayer/BlurPostProcess/Viewport/LCDOverlay/Viewport/DitherBanding/Viewport/World/Player/Head/PlayerCamera/SpiderSpawn

func _ready():
	#spiderMonster.caughtPlayer.connect(_GameOver)
	spawnTimer.timeout.connect(_SpawnSpider)

func _GameOver():
	var gameOver = gameOverScreen.instantiate()
	add_child(gameOver)
	get_tree().paused = true

func _SpawnSpider():
	var spider = spiderMonster.instantiate()
	add_child(spider)
	spider.caughtPlayer.connect(_GameOver)
	spider.movespeed = 4.5
	spider.global_position = spawnLocation.global_position
