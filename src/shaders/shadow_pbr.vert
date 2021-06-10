#version 450

// reflects the constants defined bevy_pbr/src/render_graph/mod.rs
const int MAX_POINT_LIGHTS = 10;
const int MAX_DIRECTIONAL_LIGHTS = 1;

struct PointLight {
    vec4 pos;
    vec4 color;
    vec4 lightParams;
};

struct DirectionalLight {
    vec4 direction;
    vec4 color;
};

struct ShadowDirectionalLight {
    uint textureIndex;
    vec3 pos;
    vec2 shadow_bias_min_max;
    vec2 _padding;
    mat4 viewProj;
};

layout(location = 0) in vec3 Vertex_Position;
layout(location = 1) in vec3 Vertex_Normal;
layout(location = 2) in vec2 Vertex_Uv;

#ifdef STANDARDMATERIAL_NORMAL_MAP
layout(location = 3) in vec4 Vertex_Tangent;
#endif

layout(location = 0) out vec3 v_WorldPosition;
layout(location = 1) out vec3 v_WorldNormal;
layout(location = 2) out vec2 v_Uv;

#ifdef STANDARDMATERIAL_NORMAL_MAP
layout(location = 3) out vec4 v_WorldTangent;
#endif

layout(location = 4) out vec3 v_LightSpacePosition;

layout(set = 0, binding = 0) uniform CameraViewProj {
    mat4 ViewProj;
};

layout(std140, set = 1, binding = 0) uniform Lights {
    vec4 AmbientColor;
    uvec4 NumLights; // x = point lights, y = directional lights
    PointLight PointLights[MAX_POINT_LIGHTS];
    DirectionalLight DirectionalLights[MAX_DIRECTIONAL_LIGHTS];
};

layout(set = 1, binding = 1) uniform ShadowLights {
    ShadowDirectionalLight shadow_directional_lights[MAX_DIRECTIONAL_LIGHTS];
};

layout(set = 2, binding = 0) uniform Transform {
    mat4 Model;
};

void main() {
    vec4 world_position = Model * vec4(Vertex_Position, 1.0);
    v_WorldPosition = world_position.xyz;
    for (int i = 0; i < int(NumLights.y) && i < MAX_DIRECTIONAL_LIGHTS; ++i) {
        ShadowDirectionalLight shadow_light = shadow_directional_lights[i];

        vec4 p = shadow_light.viewProj * world_position;
        v_LightSpacePosition = p.xyz;
    }
    v_WorldNormal = mat3(Model) * Vertex_Normal;
    v_Uv = Vertex_Uv;
#ifdef STANDARDMATERIAL_NORMAL_MAP
    v_WorldTangent = vec4(mat3(Model) * Vertex_Tangent.xyz, Vertex_Tangent.w);
#endif
    gl_Position = ViewProj * world_position;
}