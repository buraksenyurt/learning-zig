pub const Systems = struct {
    pub const invaders = @import("invaderSystems.zig");
    pub const rocket = @import("rocketSystems.zig");
    pub const player = @import("playerSystems.zig");
    pub const collision = @import("collisionSystem.zig");
    pub const enemy = @import("enemySystems.zig");
    pub const shield = @import("shieldSystems.zig");
};
