const Camera = @This();
const std = @import("std");
const Ray = @import("Ray.zig");
const color = @import("color.zig");
const Color = @import("color.zig").Color;
const Hittable = @import("hittable.zig").Hittable;
const HitRecord = @import("hittable.zig").HitRecord;
const Interval = @import("Interval.zig");
const Vec3 = @import("vec3.zig").Vec3;
const Point = @import("vec3.zig").Point;
const util = @import("util.zig");

aspect_ratio: f64 = 1.0,
image_width: u32 = 100,
samples_per_pixel: u32 = 10,
max_depth: u32 = 10,

vfov: f64 = 90.0,
lookfrom: Point = Point.init(0.0, 0.0, 0.0),
lookat: Point = Point.init(0.0, 0.0, -1.0),
vup: Vec3 = Vec3.init(0.0, 1.0, 0.0),

defocus_angle: f64 = 0.0,
focus_dist: f64 = 10.0,

_image_height: u32,
_pixel_samples_scale: f64,
_center: Point,
_pixel00_loc: Point,
_pixel_delta_u: Vec3,
_pixel_delta_v: Vec3,
_u: Vec3,
_v: Vec3,
_w: Vec3,
_defocus_disc_u: Vec3,
_defocus_disc_v: Vec3,

// FIXME: Followign the tutorial in idiomatic c++, convert to idiomatic zig
// NOTE: The public fields have  to be defined.
pub fn init(self: *Camera) void {
    self._pixel_samples_scale = 1.0 / @as(f64, @floatFromInt(self.samples_per_pixel));

    self._image_height = @intFromFloat(@as(f64, @floatFromInt(self.image_width)) / self.aspect_ratio);
    self._image_height = if (self._image_height < 1) 1 else self._image_height;

    self._center = self.lookfrom;

    const theta = util.degreesToRadians(self.vfov);
    const h = @tan(theta/2);
    const viewport_height: f64 = 2.0 * h * self.focus_dist;

    const viewport_width: f64 = viewport_height * (@as(f64, @floatFromInt(self.image_width))/@as(f64, @floatFromInt(self._image_height)));

    self._w = self.lookfrom.sub(self.lookat).unitVector();
    self._u = self.vup.cross(self._w);
    self._v = self._w.cross(self._u);

    // Calcute the vectors across the horizontal and down the vertical
    const viewport_u = self._u.scale(viewport_width);
    const viewport_v = self._v.scale(-viewport_height);

    // Calculate the horizontal and vertical data vectors from pixel to pixel
    self._pixel_delta_u = viewport_u.scale(1.0/@as(f64, @floatFromInt(self.image_width)));
    self._pixel_delta_v = viewport_v.scale(1.0/@as(f64, @floatFromInt(self._image_height)));

    // Callculate the loation of the upper left corner 
    const viewport_upper_left = self._center
        .sub(self._w.scale(self.focus_dist))
        .sub(viewport_u.scale(0.5))
        .sub(viewport_v.scale(0.5));
    self._pixel00_loc = viewport_upper_left.add(self._pixel_delta_u.add(self._pixel_delta_v).scale(0.5));

    const defocus_radius = self.focus_dist * @tan(util.degreesToRadians(self.defocus_angle/2.0));
    self._defocus_disc_u = self._u.scale(defocus_radius);
    self._defocus_disc_v = self._v.scale(defocus_radius);
}

pub fn render(self: Camera, world: Hittable) !void {
    // initialize writers 
    const stderr = std.io.getStdErr().writer();
    const stdout = std.io.getStdOut().writer();
    _ = stdout;

    // TODO: make the file an input, Could be by implementing a surface and then a some rendering target.
    const output_file = try std.fs.cwd().createFile("output.ppm", .{});
    defer output_file.close();

    // TODO: Make the file buffer and binary ppm file
    try std.fmt.format(output_file.writer(), "P3\n{}\n{}\n255\n", .{self.image_width, self._image_height});

    for (0..@as(usize, self._image_height)) |j_usize| {
        try stderr.print("\rScanlines remaining: {} ", .{self._image_height - j_usize});
        for (0..@as(usize, self.image_width)) |i_usize| {
            const i: f64 = @floatFromInt(i_usize);
            const j: f64 = @floatFromInt(j_usize);

            var pixel_color = Color.init(0, 0, 0);
            for (0..self.samples_per_pixel) |_| {
                const r = self.getRay(i, j);

                pixel_color = pixel_color.add(self.rayColor(r, self.max_depth, world));
            }
            

            // const pixel_center = self._pixel00_loc.add(self._pixel_delta_u.scale(fi)).add(self._pixel_delta_v.scale(fj));
            // const ray_direction = pixel_center.sub(self._center);
            // const ray = Ray.init(self._center, ray_direction);
            //
            // const col = self.rayColor(ray, world);

            try color.writeColor(output_file.writer(), pixel_color.scale(self._pixel_samples_scale));
        }
    }

    try stderr.print("\rDone.                           \n", .{});
}

/// Construct camera ray originating from the origin and directed at a randomly sampled point around i j.
fn getRay(self: Camera, i: f64, j: f64) Ray {
    const offset = sampleSquare();

    const pixel_sample = self._pixel00_loc
        .add(self._pixel_delta_u.scale(i + offset.x()))
        .add(self._pixel_delta_v.scale(j + offset.y()));

    const ray_origin = if (self.defocus_angle <= 0) self._center else self.defocusDiskSample();
    const ray_direction = pixel_sample.sub(ray_origin);

    return Ray.init(ray_origin, ray_direction);
}

fn sampleSquare() Vec3 {
    return Vec3.init(util.randomDouble() - 0.5, util.randomDouble() - 0.5, 0.0);
}

fn defocusDiskSample(self: Camera) Point {
    const p = Vec3.randomVectorInUnitDisc();
    return self._center.add(self._defocus_disc_u.scale(p.x())).add(self._defocus_disc_v.scale(p.y()));
}

fn rayColor(self: Camera, r: Ray, depth: u32, world: Hittable) Color {
    if (depth <= 0) {
        return Color.init(0, 0, 0);
    }

    var rec: HitRecord = undefined;
    if (world.hit(r, Interval{ .min=0.001, .max=std.math.inf(f64) }, &rec)) {
        var scattered: Ray = undefined;
        var attenuation: Color = undefined;
        if (rec.mat.scatter(r, rec, &attenuation, &scattered)) {
            return attenuation.mul(self.rayColor(scattered, depth-1, world));
        }
        return Color.init(0, 0, 0);
    }

    const unit_direction = r.dir.unitVector();
    const a = 0.5*(unit_direction.data[1] + 1.0);
    return Color.init(1.0, 1.0, 1.0).scale(1.0 - a).add(Color.init(0.5, 0.7, 1.0).scale(a));
}
