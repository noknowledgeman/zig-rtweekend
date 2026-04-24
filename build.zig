const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    
    const exe = b.addExecutable(.{
        .name = "rtweekend",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    b.installArtifact(exe);
    
    const raytracer = b.addModule("raytracer", .{
        .root_source_file = b.path("src/root.zig"),
        .optimize = optimize,
        .target = target,
    });
    exe.root_module.addImport("raytracer", raytracer);

    
    const run_cmd = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run the Program");
    run_step.dependOn(&run_cmd.step);

    const wasm = b.addExecutable(.{
        .name = "WasmRenderer",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/WasmRenderer.zig"),
            .target = b.resolveTargetQuery(.{
                .cpu_arch = .wasm32,
                .os_tag = .freestanding,
            }),
            .optimize = .ReleaseFast,
        }),
    });
    wasm.root_module.addImport("raytracer", raytracer);
    wasm.entry = .disabled;
    wasm.rdynamic = true;

    const wasm_step = b.step("wasm", "Build the WASM renderer");
    wasm_step.dependOn(&b.addInstallArtifact(wasm, .{}).step);
}
