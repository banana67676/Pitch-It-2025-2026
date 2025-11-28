extends Resource
class_name PitchCardData

#TITLE
var title : String:
	set(value): #when this value is attempted to be changed
		title = value
		if value.is_empty(): #if the string is empty
			title = "-" #set it to a dash instead

#SLOGAN
var slogan : String:
	set(value): #when this value is attempted to be changed
		slogan = value
		if value.is_empty(): #if the string is empty
			slogan = "-" #set it to a dash instead

#Rest of the variables that don't need the set() function
var username : String
var user_id : int
var logo : Image
var who_card : String
var what_card : String
var online : bool

const WIDTH = 800
const HEIGHT = 600

enum Keys {
	TITLE,
	SLOGAN,
	LOGO,
	LOGO_SIZE,
	USERNAME,
	USER_ID,
	WHO_CARD,
	WHAT_CARD,
}

func serialize() -> PackedByteArray:
	var data = Array()
	var image_data: Array = _compress_image(logo) #returns an array with image data and byte size of the image
	data.resize(Keys.size()) #set the size of the arrya to the number of enums in the Keys enum
	
	data[Keys.TITLE] = title
	data[Keys.SLOGAN] = slogan
	data[Keys.LOGO] = image_data[0] #0 index = PackedByteArray of the image
	data[Keys.LOGO_SIZE] = image_data[1] #1 index = byte size of the compressed webp image
	data[Keys.USERNAME] = username
	data[Keys.USER_ID] = user_id
	data[Keys.WHO_CARD] = who_card
	data[Keys.WHAT_CARD] = what_card
	return var_to_bytes(data)


#keep this static
static func deserialize(packed_data: PackedByteArray) -> PitchCardData:
	var data: Array = bytes_to_var(packed_data)
	var pcData : PitchCardData = PitchCardData.new()
	pcData.title = data[Keys.TITLE]
	pcData.slogan = data[Keys.SLOGAN]
	pcData.username = data[Keys.USERNAME]
	pcData.user_id = data[Keys.USER_ID]
	pcData.who_card = data[Keys.WHO_CARD]
	pcData.what_card = data[Keys.WHAT_CARD]
	pcData.logo = _decompress_image(data[Keys.LOGO], data[Keys.LOGO_SIZE])
	return pcData


#we are compressing the image because initially it is 1.9MB, which is WAY too big to send over the internet
#sending this data literally froze the game for a solid 10 seconds for just 2 people playing
#this effectively reduces file size to the single digit KB range (which is over a thousand times smaller)
func _compress_image(image: Image, quality: float = 0.75) -> Array:
	if image == null:
		return PackedByteArray()
	#convert image to webp (to reduce file size)
	var webp_buffer: PackedByteArray = image.save_webp_to_buffer(true, quality)
	
	if webp_buffer.size() == 0: #if failed to compress
		push_error("Failed to compress image to WebP buffer.")
		return PackedByteArray()
	
	#compress the data size even further
	var compressed_data: PackedByteArray = webp_buffer.compress(FileAccess.COMPRESSION_GZIP)
	
	#this showed the changes in file size, which was HUGE size reduction
	#print("VERY original size: %d bytes" % image.get_data_size())
	#print("Original size (WebP): %d bytes" % webp_buffer.size())
	#print("Compressed size (GZIP): %d bytes" % compressed_data.size())
	
	return [compressed_data, webp_buffer.size()] #returns an array with the image data and the byte size of the image


#decompress the compressed image back to a usable image
static func _decompress_image(compressed_data: PackedByteArray, image_size: int) -> Image:
	#first undo the GZIP compression to get the webp back
	var webp_buffer: PackedByteArray = compressed_data.decompress(image_size, FileAccess.COMPRESSION_GZIP)
	
	if webp_buffer.size() == 0:
		push_error("Failed to decompress GZIP data.")
		return null
	
	#then turn the webp back into a Godot Image object
	var image = Image.new()
	var error: Error = image.load_webp_from_buffer(webp_buffer)
	
	if error != OK:
		push_error("Failed to load WebP buffer into Image: " + error_string(error))
		return null
	
	return image #return that Image object
