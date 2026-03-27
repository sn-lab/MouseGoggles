extends MeshInstance

export var video_file = ""
export var screen_width = 4.0 #default
export var screen_height = 3 #default
export var transparent_black = true
export var flip_vertical = true
export var flip_horizontal = false
export var play_on_load = true
export var loop = false
export var default_screen_color = Color(0, 0, 0)

var video_player
var video_stream
var shader_material

func _ready():
	# Create VideoPlayer node
	video_player = VideoPlayer.new()
	add_child(video_player)
	
	# Set up mesh
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(screen_width, screen_height)
	mesh = plane_mesh
	
	# Create shader material
	shader_material = ShaderMaterial.new()
	var shader_code = """
	shader_type spatial;
	render_mode blend_mix;
	
	uniform sampler2D video_texture;
	uniform bool transparent_black = false;
	uniform bool flip_vertical = false;
	uniform bool flip_horizontal = false;
	
	void fragment() {
		vec2 uv = UV;
		
		if (flip_horizontal) {
			uv.x = 1.0 - uv.x;
		}
		if (flip_vertical) {
			uv.y = 1.0 - uv.y;
		}
		
		vec4 video_color = texture(video_texture, uv);
		
		if (transparent_black && video_color.rgb == vec3(0.0)) {
			ALBEDO = vec3(0.0);
			ALPHA = 0.0;
		} else {
			ALBEDO = video_color.rgb;
			ALPHA = 1.0;
		}
	}
	"""
	
	var shader = Shader.new()
	shader.set_code(shader_code)
	shader_material.shader = shader
	material_override = shader_material
	
	# Set shader parameters
	shader_material.set_shader_param("transparent_black", transparent_black)
	shader_material.set_shader_param("flip_vertical", flip_vertical)
	shader_material.set_shader_param("flip_horizontal", flip_horizontal)
	
	# Load and play video
	if video_file != "":
		video_stream = load(video_file)
		if video_stream:
			video_player.stream = video_stream
			if play_on_load:
				video_player.play()
			video_player.connect("finished", self, "_on_video_finished")


func _process(delta):
	# Update texture each frame
	if video_player and video_player.is_playing():
		var video_texture = video_player.get_video_texture()
		if video_texture and shader_material:
			shader_material.set_shader_param("video_texture", video_texture)


func set_default_color(color):
	if shader_material:
		var image = Image.new()
		image.create(screen_width, screen_height, false, Image.FORMAT_RGBA8)
		image.fill(color)
		var texture = ImageTexture.new()
		texture.create_from_image(image)
		shader_material.set_shader_param("video_texture", texture)


func start_video():
	if video_player:
		video_player.stop()
		video_player.play()


func _on_video_finished():
	if loop:
		video_player.play()
	else:
		set_default_color(default_screen_color) 
