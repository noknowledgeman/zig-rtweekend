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
    
    pub fn initFromHittables(arena: std.mem.Allocator, hittables: []Hittable) !*BVH {
        // I dont want to mutate the input
        const hits_copy = try arena.alloc(Hittable, hittables.len);
        @memcpy(hits_copy, hittables);
        
        const bvh = try arena.create(BVH);
        
        const axis = util.randomInt(0, 2);
        
        if (hits_copy.len == 1) {
            bvh.left = hits_copy[0];
            bvh.right = hits_copy[0];
        } else if (hits_copy.len == 2)  {
            bvh.left = hits_copy[0];
            bvh.right = hits_copy[1];
        } else {
            std.mem.sort(Hittable, hits_copy, axis, boxCompare);
            
            const mid = hits_copy.len/2;
            const left_bvh = try initFromHittables(arena, hits_copy[0..mid]);
            const right_bvh = try initFromHittables(arena, hits_copy[mid..]);
            
            bvh.left = left_bvh.hittable();
            bvh.right = right_bvh.hittable();
        }
        
        bvh.bbox = AaBb.combine(bvh.left.boundingBox(), bvh.right.boundingBox());
        
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
        // makes the closest hit wins argument
        const hit_right = self.right.hit(ray, Interval.init(ray_t.min, if (hit_left) rec.t else ray_t.max), rec);
        
        return hit_left or hit_right;
    }
    
    pub fn hittable(self: *BVH) Hittable {
        return .{
            .boundingBoxFn = boundingBox,
            .hitFn = hit,
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
