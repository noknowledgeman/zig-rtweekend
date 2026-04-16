# Raytracing in a Weekend with Zig

This is the implementation of the book Raytracing in one Weekend in zig. 

## Benchmarks

Checking out bench for benchmarks, some issues

Laptop: 16 GB ram, 11th Gen Intel(R) Core(TM) i7-1185G7 @ 3.00GHz. Using the performance profile on my laptop

I tried with -Doptimize=Debug but that would have taken around 3 hours. Moved to -Doptimize=ReleaseFast. 

- On 4fcdc5a1 with -Doptimize=ReleaseFast and Renderer.zig it was 1661883 millis 
- With the MultithreadedRenderer.zig it was 526675 millis
- With the MultithreadedRenderer.zig and a basic BVH it is 827524
- With fix to         if (!self.bbox.hit(ray, ray_t)) return false; from         if (self.bbox.hit(ray, ray_t)) return false;
- With working BVH and multithreading 134018 millis
- With taking the longest bbox size 125502 millis

## TODOS

- [x] Multithreading
- [x] Fix the multithreading by making each thread do a different amount of work? Not sure if reasonable (used a simple atomic scheme)
- [x] BVH
- [ ] Add a scene 
- [ ] Compile to WASM
- [ ] Triangles
- [ ] Implement some sort of file format like stl for triangles
- [ ] motion blur
- [ ] serious optimization
- [ ] Implement QOI image compression
- [ ] Use external library for the PNG
- [ ] Implement the kitty terminal image (to display in the terminal)
- [ ] Use GLFW or similar to show the buffer in a window, with progress
- [ ] Raytracing next week
- [ ] GPU Renderer (Possibly Vulkan) (possibly in a separate project or fork, a lot of the code is already made for the cpu and will be hard to port to the gpu, it would be a full rewrite)
- [ ] Texture mapping
- [ ] Lights
- [ ] Volumes

- [x] Fix the Vec3 class to just const Vec3 = @Vector(3, f64); and fix the operations (Did not do Uneccessary)

## Thougths

Currently I am rendering per line, I could render per sample and average them together, i dont know if it would be faster.

## References

- [_Ray Tracing in One Weekend_](https://raytracing.github.io/books/RayTracingInOneWeekend.html)
- [_Ray Tracing: The Next Week_](https://raytracing.github.io/books/RayTracingTheNextWeek.html)
- Sebastian Lague on youtube and his raytracing series.
