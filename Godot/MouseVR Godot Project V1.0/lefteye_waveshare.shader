shader_type canvas_item;

// Inspector params:
uniform float fov = 151; //FOV (in degrees) that the circular display covers 
uniform float fovmax = 151; //FOV (in degrees) that the visible area of the circular display covers 
uniform float aspect_ratio = 1; //ratio of x pixels to y pixels

void fragment(){
	float fovhalfy = (fov/2.0)*3.14159/180.0; //half of the FOV (in radians); y (the taller side) covers the FOV completely
	float sinfovhalfy = sin(fovhalfy);
	float sinfovhalfx = sin(aspect_ratio*fovhalfy); //x (the shorter side) only covers a portion of the FOV
	
	//scale and shift [x,y] so that they are in linear radians away from the center
	vec2 xy = UV;
	xy.y = (sinfovhalfy*2.0*xy.y) - sinfovhalfy;
	xy.x = (sinfovhalfx*2.0*xy.x) - sinfovhalfy; //shift x by fovhalfy_lin as well, to account for clipped edge of circular display
	float z = cos(fovhalfy); //distance of the frustum plane away from the center
	
	//calculate radians away from the center
	float rl = sqrt((xy.x*xy.x) + (xy.y*xy.y)); //linear radians away from the center
	float r = atan(rl, z); //radians from the center
	
	//calculate the rotational (CW/CCW) position
	float phi = atan(xy.y, xy.x);
	
	// shift rl to convert from flat projection to spherical projection
	rl = cos(fovhalfy)*tan(fovhalfy*rl/sinfovhalfy);
	
	//recalculate x and y
	xy.y = rl*sin(phi);
	xy.x = rl*cos(phi);
	
	//revert scale
	xy.y = (xy.y+sinfovhalfy)/(2.0*sinfovhalfy);
	xy.x = (xy.x+sinfovhalfx)/(2.0*sinfovhalfx);
	
	vec4 tex;
	tex = texture(TEXTURE, xy);
	COLOR = tex;
	
	// Apply radial crop beyond fov
	float fovhalfmax = (fovmax/2.0)*3.14159/180.0;
	if (r>=fovhalfmax){
		COLOR.a = 0.0;
	}
}
