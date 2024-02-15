extends Control

var card_names = []
var card_images = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	create_card_data()

func create_card_data():
	# Generate card names for ranks 2 to 10
	for rank in range(2, 11):
		for suit in ["clubs", "diamonds", "hearts", "spades"]:
			card_names.append(str(rank) + "_" + suit)

	# Generate card names for face cards (jack, queen, king, ace)
	for face_card in ["jack", "queen", "king", "ace"]:
		for suit in ["clubs", "diamonds", "hearts", "spades"]:
			card_names.append(face_card + "_" + suit)
	
	
	# Load card images into the dictionary
	for name in card_names:
		var path = "res://images/cards/" + name + ".png"
		var image = ResourceLoader.load(path)
		card_images[name] = image
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func generate_card(x_percent, y_percent):
	# Assuming you have already loaded card images into the dictionary as shown in your code
	# Get a random card name
	var random_card_name = card_names[randi() % card_names.size()]

	# Get the image corresponding to the random card name
	var random_card_image = card_images[random_card_name]

	# Create a Sprite2D node to display the card image
	var card_sprite = Sprite2D.new()
	card_sprite.texture = random_card_image

	# Get the size of the viewport
	var viewport_size = get_viewport_rect().size

	# Calculate the position
	var position_x = viewport_size.x * x_percent / 100
	var position_y = viewport_size.y * y_percent / 100

	# Set the position and scale of the card
	card_sprite.scale = Vector2(0.5, 0.5)
	card_sprite.position = Vector2(position_x, position_y)

	# Add the Sprite node to the scene (assuming this code is in a Node or Control)
	add_child(card_sprite)



func _on_hit_pressed():
	generate_card(10, 70)
	generate_card(30,70)
