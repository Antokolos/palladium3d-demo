shader_type spatial;

uniform vec2 amplitude = vec2(0.1, 0.05);
uniform vec2 frequency = vec2(3.0, 2.5);
uniform vec2 time_factor = vec2(2.0, 3.0);

uniform sampler2D uv_offset_texture : hint_black;
uniform vec2 uv_offset_scale = vec2(0.2, 0.2);
uniform float uv_offset_time_scale = 0.05;
uniform float uv_offset_amplitude = 0.2;

uniform sampler2D texturemap : hint_albedo;
uniform vec2 texture_scale = vec2(8.0, 4.0);

uniform sampler2D normalmap : hint_normal;
uniform float refraction = 0.05;
uniform bool use_proximity_fade = true;
uniform float proximity_fade_distance = 1.1;

float height(vec2 pos, float time) {
	return (amplitude.x * sin(pos.x * frequency.x + time * time_factor.x)) + (amplitude.y * sin(pos.y * frequency.y + time * time_factor.y));
}

void vertex() {
	VERTEX.y += height(VERTEX.xz, TIME); // sample the height at the location of our vertex
	TANGENT = normalize(vec3(0.0, height(VERTEX.xz + vec2(0.0, 0.2), TIME) - height(VERTEX.xz + vec2(0.0, -0.2), TIME), 0.4));
	BINORMAL = normalize(vec3(0.4, height(VERTEX.xz + vec2(0.2, 0.0), TIME) - height(VERTEX.xz + vec2(-0.2, 0.0), TIME ), 0.0));
	NORMAL = cross(TANGENT, BINORMAL);
}

void fragment() {
	vec2 base_uv_offset = UV * uv_offset_scale; // Determine the UV that we use to look up our DuDv
	base_uv_offset += TIME * uv_offset_time_scale;
	
	vec2 texture_based_offset = texture(uv_offset_texture, base_uv_offset).rg; // Get our offset
	texture_based_offset = texture_based_offset * 2.0 - 1.0; // Convert from 0.0 <=> 1.0 to -1.0 <=> 1.0
	
	vec2 texture_uv = UV * texture_scale;
	texture_uv += uv_offset_amplitude * texture_based_offset;
	ALBEDO = texture(texturemap, texture_uv).rgb;
	if (ALBEDO.r > 0.9 && ALBEDO.g > 0.9 && ALBEDO.b > 0.9) {
		ALPHA = 0.9;
	} else {
		ALPHA = 0.5;
	}
	METALLIC = 0.0;
	ROUGHNESS = 0.1;
	NORMALMAP = texture(normalmap, base_uv_offset).rgb;
	
	/* It seems that refraction cannot be used together with proximity fade under GLES2 :( */
	// Refraction
	if (!OUTPUT_IS_SRGB || !use_proximity_fade) {
		vec3 ref_normal = normalize( mix(NORMAL,TANGENT * NORMALMAP.x + BINORMAL * NORMALMAP.y + NORMAL * NORMALMAP.z,NORMALMAP_DEPTH) );
		vec2 ref_ofs = SCREEN_UV - ref_normal.xy * refraction;
		EMISSION += textureLod(SCREEN_TEXTURE,ref_ofs,ROUGHNESS * 8.0).rgb * (1.0 - ALPHA);
		ALBEDO *= ALPHA;
		ALPHA = 1.0;
	}
	
	// Proximity fade
	if (use_proximity_fade) {
		float depth_tex = textureLod(DEPTH_TEXTURE,SCREEN_UV,0.0).r;
		vec4 world_pos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV*2.0-1.0,depth_tex*2.0-1.0,1.0);
		world_pos.xyz/=world_pos.w;
		ALPHA*=clamp(1.0-smoothstep(world_pos.z+proximity_fade_distance,world_pos.z,VERTEX.z),0.0,1.0);
	}
}