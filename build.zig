const std = @import("std");

pub fn build(b: *std.Build) void {
    const exe = b.addExecutable(.{
        .name = "main",
        .root_source_file = b.path("src/main.zig"),
        .target = b.graph.host,
    });
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    const run_step = b.step("run", "Run the Program");
    run_step.dependOn(&run_cmd.step);

    const test_step = b.step("test", "Run the Unit Tests");
    const main_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
    });
    const run_unit_tests = b.addRunArtifact(main_tests);
    test_step.dependOn(&run_unit_tests.step);
}
