use crate::shadow_pass_node::*;
use bevy::prelude::*;
use bevy::render::camera::{CameraProjection, OrthographicProjection};

pub struct ShadowDirectionalLight {
    /// Size of the area covered by the light. 
    /// Everything outside will be lit by default.
    pub size: f32,
    /// Near plane of projection.
    pub near: f32,
    /// Far plane of projection.
    pub far: f32,
}

impl Default for ShadowDirectionalLight {
    fn default() -> Self {
        Self {
            size: 50.0,
            near: -500.0,
            far: 500.0,
        }
    }
}

impl Light for DirectionalLight {
    type Config = ShadowDirectionalLight;

    fn proj_matrix(&self, config: Option<&Self::Config>) -> Mat4 {
        let dir = self.get_direction().normalize();
        let rot = Quat::from_rotation_arc(Vec3::Z, dir);

        let d = config.map_or(25.0, |config| config.size / 2.0);
        let near = config.map_or(-500.0, |config| config.near);
        let far = config.map_or(500.0, |config| config.far);

        OrthographicProjection {
            left: -d,
            right: d,
            bottom: -d,
            top: d,
            far,
            near,
            ..Default::default()
        }
        .get_projection_matrix()
            * Mat4::from_quat(rot)
    }
}
