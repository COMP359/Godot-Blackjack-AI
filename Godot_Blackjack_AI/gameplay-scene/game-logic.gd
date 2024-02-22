extends Control

var card_names = []
var card_values = []
var card_images = {}

var playerScore = 0
var dealerScore = 0
var playerCards = []
var dealerCards = []

var cardsShuffled = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	$Replay.visible = false
	$WinnerText.visible = false
	$PlayerHitMarker.visible = false
	$DealerHitMarker.visible = false
	get_tree().root.content_scale_factor
	# Create cards
	updateText()
	create_card_data()
	
	# Generate player cards	
	await get_tree().create_timer(0.7).timeout
	generate_card("player")
	updateText()
	await get_tree().create_timer(0.5).timeout
	generate_card("player")
	updateText()
	
	# Generate dealers cards; note how first one is true as we want to show the back
	await get_tree().create_timer(0.5).timeout
	generate_card("dealer", true)
	updateText()
	await get_tree().create_timer(0.5).timeout
	generate_card("dealer")
	updateText()
	await get_tree().create_timer(1).timeout
	
	if playerScore == 21:
		playerWin(true)
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
	
func _on_hit_pressed():
	$PlayerHitMarker.visible = true
	generate_card("player")
	# Play "hit!" animation
	$AnimationPlayer.play("HitAnimationP")
	updateText()
	if playerScore == 21:
		_on_stand_pressed()  # Player auto-stands on 21
	elif playerScore > 21:
		playerLose()


func _on_stand_pressed():
	"""
	Flip dealer's first card, dealer keeps hitting until score is above player.
	"""
	$Buttons/VBoxContainer/Hit.disabled = true
	$Buttons/VBoxContainer/Stand.disabled = true
	$DealerHitMarker.visible = true
	$WhoseTurn.text = "Dealer's\nTurn"
	
	await get_tree().create_timer(0.5).timeout
	var dealer_hand_container = $Cards/Hands/DealerHand
	
	# Remove the first card from the container (the back of card texture)
	var child_to_remove = dealer_hand_container.get_child(0)
	child_to_remove.queue_free()  # Remove the node from the scene
	
	# Create a new TextureRect node for the card image
	var card = dealerCards[0]
	var card_texture_rect = TextureRect.new()
	var card_texture = ResourceLoader.load(card[1])
	card_texture_rect.texture = card_texture

	# Add the card as a child to the HBoxContainer
	dealer_hand_container.add_child(card_texture_rect)
	dealer_hand_container.move_child(card_texture_rect, 0)
	
	# Add score to dealerScore
	if card[0] == 11 and dealerScore > 10:  # Aces are 1 if score is too high for 11
		dealerScore += 1
	else:
		dealerScore += card[0]
	updateText()
	
	# Dealer hits until score surpasses player or 17
	while dealerScore < playerScore and dealerScore < 17:
		await get_tree().create_timer(1.5).timeout
		# Play "hit!" animation
		$AnimationPlayer.play("HitAnimationD")
		generate_card("dealer")
		updateText()
		
	# Evaluate results
	if dealerScore > 21 or dealerScore < playerScore:  # Dealer bust or dealer less than player
		playerWin()
	elif playerScore < dealerScore and dealerScore <= 21:  # Dealer is between player score and 22
		playerLose()
	else:  # Tie
		playerDraw()
	
	
func create_card_data():
	# Generate card names for ranks 2 to 10
	for rank in range(2, 11):
		for suit in ["clubs", "diamonds", "hearts", "spades"]:
			card_names.append(str(rank) + "_" + suit)
			card_values.append(rank)

	# Generate card names for face cards (jack, queen, king, ace)
	for face_card in ["jack", "queen", "king", "ace"]:
		for suit in ["clubs", "diamonds", "hearts", "spades"]:
			card_names.append(face_card + "_" + suit)
			if face_card != "ace":
				card_values.append(10)
			else:
				card_values.append(11)	
	
	# Load card values and image paths into the dictionary
	for card in range(len(card_names)):
		card_images[card_names[card]] = [card_values[card], 
			"res://assets/images/cards_pixel/" + card_names[card] + ".png"]
		
	#add the the of card image with key "back"
	card_images["back"] = [0, "res://assets/images/cards_alternatives/card_back_pix.png"]
	
	cardsShuffled = card_names.duplicate()
	cardsShuffled.shuffle()

	
func generate_card(hand, back=false):
	# Assuming you have already loaded card images into the dictionary as shown in your code
	var random_card

	# if back is true assign card image to back
	if back:
		# We display the back of the card, but a real card needs to be pulled
		# so that it can be shown when the player Stands
		random_card = card_images["back"]
		dealerCards.append(card_images[cardsShuffled.pop_back()])
	else:
		# Get a random card
		var random_card_name = cardsShuffled.pop_back() #card_names[randi() % card_names.size()]
		random_card = card_images[random_card_name] 
		# random_card is an array [card value, card image path]

	# Create a new TextureRect node for card
	var card_texture = ResourceLoader.load(random_card[1])
	var card_texture_rect = TextureRect.new()
	card_texture_rect.texture = card_texture
	
	# Get a reference to the existing HBoxContainer
	var card_hand_container
	if hand == "player":
		card_hand_container = $Cards/Hands/PlayerHand
		if random_card[0] == 11 and playerScore > 10:  # Aces are 1 if score is too high for 11
			playerScore += 1
		else:
			playerScore += random_card[0]
		playerCards.append(random_card)
	elif hand == "dealer":
		card_hand_container = $Cards/Hands/DealerHand
		if random_card[0] == 11 and dealerScore > 10:  # Aces are 1 if score is too high for 11
			dealerScore += 1
		else:
			dealerScore += random_card[0]
		dealerCards.append(random_card)
	else:
		return
		
	# Add the card as a child to the HBoxContainer
	card_hand_container.add_child(card_texture_rect)


func updateText():
	"""
	Update the labels displayed on screen for the dealer and player scores.
	"""
	$DealerScore.text = str(dealerScore)
	$PlayerScore.text = str(playerScore)


func playerLose():
	$WinnerText.text = "DEALER\nWINS"
	$WinnerText.set("theme_override_colors/font_color", "ff5342")
	$Buttons/VBoxContainer/Hit.disabled = true
	$Buttons/VBoxContainer/Stand.disabled = true
	await get_tree().create_timer(1).timeout
	$WinnerText.visible = true
	await get_tree().create_timer(0.5).timeout
	$Replay.visible = true
	
	
func playerWin(blackjack=false):
	if blackjack:
		$WinnerText.text = "PLAYER WINS\nBY BLACKJACK"
	$Buttons/VBoxContainer/Hit.disabled = true
	$Buttons/VBoxContainer/Stand.disabled = true
	await get_tree().create_timer(1).timeout
	$WinnerText.visible = true
	await get_tree().create_timer(0.5).timeout
	$Replay.visible = true
	
	
func playerDraw():
	$WinnerText.text = "DRAW"
	$WinnerText.set("theme_override_colors/font_color", "white")
	$Buttons/VBoxContainer/Hit.disabled = true
	$Buttons/VBoxContainer/Stand.disabled = true
	await get_tree().create_timer(1).timeout
	$WinnerText.visible = true
	await get_tree().create_timer(0.5).timeout
	$Replay.visible = true


func _on_exit_pressed():
	get_tree().change_scene_to_file("res://main-scene/main_scene.tscn")


func _on_replay_pressed():
	get_tree().change_scene_to_file("res://gameplay-scene/game.tscn")
