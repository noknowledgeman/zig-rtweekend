const std = @import("std");
const Hittable = @import("hittable.zig").Hittable;
const HitRecord = @import("hittable.zig").HitRecord;
const AaBb = @import("AaBb.zig");
const HittableList = @import("HittableList.zig");
const Interval = @import("Interval.zig");
const Ray = @import("Ray.zig");
const util = @import("util.zig");

pub const BVH = struct {
    bbox: AaBb,
    left: Hittable,
    right: Hittable,
    
    const vtable: Hittable.VTable = .{
        .boundingBoxFn = boundingBox,
        .hitFn = hit,
    };
    
    /// Makes a bvh from the slice of Hittables, changes the order of the Hittable slice.
    pub fn initFromHittables(arena: std.mem.Allocator, hittables: []Hittable) !*BVH {
        const bvh = try arena.create(BVH);
        
        // empty bbox
        bvh.bbox = .{};
        for (hittables) |object| {
            bvh.bbox = bvh.bbox.combine(object.boundingBox());
        }
        
        const axis = bvh.bbox.longestAxis();
        
        if (hittables.len == 1) {
            bvh.left = hittables[0];
            bvh.right = hittables[0];
        } else if (hittables.len == 2)  {
            bvh.left = hittables[0];
            bvh.right = hittables[1];
        } else {
            std.mem.sort(Hittable, hittables, axis, boxCompare);
            
            const mid = hittables.len/2;
            const left_bvh = try initFromHittables(arena, hittables[0..mid]);
            const right_bvh = try initFromHittables(arena, hittables[mid..]);
            
            bvh.left = left_bvh.hittable();
            bvh.right = right_bvh.hittable();
        }
        
        return bvh;
    }
    
    fn boundingBox(ptr: *anyopaque) AaBb {
        const self: *BVH = @ptrCast(@alignCast(ptr));
        return self.bbox;
    }
    
    fn hit(ptr: *anyopaque, ray: Ray, ray_t: Interval, rec: *HitRecord) bool {
        const self: *BVH = @ptrCast(@alignCast(ptr));
        
        if (!self.bbox.hit(ray, ray_t)) return false;
        
        const hit_left = self.left.hit(ray, ray_t, rec);
        const hit_right = self.right.hit(ray, Interval.init(ray_t.min, if (hit_left) rec.t else ray_t.max), rec);
        
        return hit_left or hit_right;
    }
    
    pub fn hittable(self: *BVH) Hittable {
        return .{
            .vtable = &vtable,
            .ptr = self,
        };
    }
};
    
fn boxCompare(axis: u32, lhs: Hittable, rhs: Hittable) bool {
    // deal with the shitty hittables
    const l_axis_interval = lhs.boundingBox().axisInterval(axis);
    const r_axis_interval = rhs.boundingBox().axisInterval(axis);
    return l_axis_interval.min < r_axis_interval.min;
}
