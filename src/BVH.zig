const std = @import("std");
const Hittable = @import("hittable.zig").Hittable;
const HitRecord = @import("hittable.zig").HitRecord;
const AaBb = @import("AaBb.zig");
const HittableList = @import("HittableList.zig");
const Interval = @import("Interval.zig");
const Ray = @import("Ray.zig");

const BVHNode = @This();

left: Hittable,
right: Hittable,
bbox: AaBb,

// pub fn initFromList(hittable_list: HittableList) BVHNode {
// }


pub fn hit(ptr: *anyopaque, ray: Ray, ray_t: Interval, hit_record: *HitRecord) bool {
    const self: *BVHNode = @ptrCast(@alignCast(ptr));
    
    if (!self.bbox.hit(ray, ray_t)) {
        return false;
    }
    
    const hit_left = self.left.hit(ray, ray_t, hit_record);
    // not too sure about that if statement
    const hit_right = self.left.hit(ray, Interval.init(ray_t.min, if (hit_left) hit_record.t else ray_t.max), hit_record);
    
    return hit_left or hit_right;
}

pub fn boundingBox(ptr: *anyopaque) AaBb {
    const self: *BVHNode = @ptrCast(@alignCast(ptr));
    return self.bbox;
}

pub fn hittable(self: *BVHNode) Hittable{
    return .{
        .hitFn = hit,
        .boundingBoxFn = boundingBox,
        .ptr = self,
    };
}
