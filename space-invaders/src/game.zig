const config = @import("config.zig");
const GameConfig = config.GameConfig;
const Player = @import("entities/player.zig").Player;
const Rocket = @import("entities/rocket.zig").Rocket;
const Invader = @import("entities/invader.zig").Invader;
const Vector2D = @import("geometry.zig").Vector2D;
const Systems = @import("systems.zig");
const rl = @import("raylib");

/// Game structure encapsulating the main components of the game.
/// Fields:
/// - config: The game configuration settings.
/// - player: The player entity.
/// - rockets: An array of rocket entities.
/// Methods:
/// - init: Initializes a new game instance with the provided configuration.
/// - shoot: Handles the shooting mechanism for the player.
/// - update: Updates the game state, including player and rockets.
/// - draw: Renders the game entities on the screen.
pub const Game = struct {
    config: GameConfig,
    player: Player,
    rockets: [config.MAX_ROCKETS]Rocket = undefined,
    invaders: [config.INVADER_ROWS][config.INVADER_COLUMNS]Invader = undefined,
    moveTimer: f32 = 0.0,
    invaderDirection: Vector2D = undefined,
    score: u32 = 0,
    invadersCount: u32 = 0,

    pub fn init(gameConfig: GameConfig) @This() {
        var game = Game{
            .config = gameConfig,
            .player = Player.init(
                .{ .x = gameConfig.screenSize.width / 2 - gameConfig.playerSize.width / 2, .y = gameConfig.screenSize.height - gameConfig.playerSize.height * 2 },
                gameConfig.playerSize,
            ),
            .rockets = undefined,
            .moveTimer = 0.0,
            .invaderDirection = Vector2D{ .x = 1.0, .y = 0.0 },
        };
        game.invadersCount = game.invaders.len * game.invaders[0].len;

        Systems.rocketsInitSystem(&game);
        Systems.invadersInitSystem(&game);

        return game;
    }

    pub fn update(self: *@This()) void {
        self.player.update();
        Systems.collisionDetectionSystem(self);
        Systems.playerShootSystem(self);
        Systems.rocketMoveSystem(self);
        Systems.updateInvadersMovesSystem(self);
    }

    pub fn draw(self: @This()) void {
        self.player.draw();
        Systems.rocketsDrawSystem(self);
        Systems.invadersDrawSystem(self);

        self.drawHud();
    }

    fn drawHud(self: @This()) void {
        const scoreText = rl.textFormat("Score: %d Invaders: %d", .{ self.score, self.invadersCount });
        rl.drawText(scoreText, 20, @intFromFloat(self.config.screenSize.height - 20.0), 20, rl.Color.white);

        const titleText = rl.textFormat("Space Invaders", .{});
        const sizeOfTitle: f32 = @floatFromInt(rl.measureText(titleText, 20));
        rl.drawText(titleText, @intFromFloat(self.config.screenSize.width / 2 - sizeOfTitle / 2), 0, 20, rl.Color.white);

        rl.drawText("Press SPACE to shoot, ESC to quit...", 20, 25, 20, rl.Color.yellow);
    }
};
