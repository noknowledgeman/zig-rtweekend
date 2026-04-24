pub const SceneBuilder = @import("SceneBuilder.zig");
pub const Scene = SceneBuilder.Scene;

pub const Renderer = @import("renderers/Renderer.zig");
pub const MultiThreaded = @import("renderers/MultithreadedRenderer.zig");

pub const primitives = struct {
    pub const Sphere = @import("primitives/Sphere.zig");
    pub const Triangle = @import("primitives/Triangle.zig");
};

pub const Buffer = @import("Buffer.zig");