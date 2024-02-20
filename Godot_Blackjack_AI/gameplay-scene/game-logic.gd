extends Control

var card_names = []
var card_values = []
var card_images = {}

var cardsShuffled = {}

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
			"res://images/cards_pixel/" + card_names[card] + ".png"]
		
	#add the the of card image with key "back"
	card_images["back"] = [0, "res://images/cards_alternatives/card_back_pix.png"]
	
	cardsShuffled = card_names.duplicate()
	cardsShuffled.shuffle()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func generate_card(hand, back=false):
	# Assuming you have already loaded card images into the dictionary as shown in your code
	var random_card

	# if back is true assign card image to back
	if back == true:
		random_card = card_images["back"]
	else:
		# Get a random card
		var random_card_name = cardsShuffled.pop_back() #card_names[randi() % card_names.size()]
		random_card = card_images[random_card_name] 
		# random_card is an array [card value, card image path]
		
	# Create a Sprite2D node to display the card image
	var card_sprite = Sprite2D.new()
	# Load the card texture
	# Load the card texture
	var card_texture = ResourceLoader.load(random_card[1])

	# Create a new TextureRect node
	var card_texture_rect = TextureRect.new()

	# Set the texture of the TextureRect node
	card_texture_rect.texture = card_texture

	# Set the scale of the card
	card_texture_rect.set_size(Vector2(1,2))

	# Get a reference to the existing HBoxContainer
	var card_hand_container
	if hand == "player":
		card_hand_container = $MarginContainer/VBoxContainer/PlayerHand
	#elif hand == "dealer":
		#var card_hand_container = $MarginContainer/VBoxContainer/DealerHand
	else:
		return
	# Add the card as a child to the HBoxContainer
	card_hand_container.add_child(card_texture_rect)


# Called when the node enters the scene tree for the first time.
func _ready():
	# Create cards
	create_card_data()
	
	# Generate dealers cards; note how first one is true as we want to show the back
	generate_card("dealer", true)
	generate_card("dealer")
	
	# Generate player cards
	generate_card("player")
	generate_card("player")


func _on_hit_pressed():
	generate_card("player")
