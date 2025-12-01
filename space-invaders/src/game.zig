const config = @import("config.zig");
const GameConfig = config.GameConfig;
const Player = @import("entities/player.zig").Player;
const Rocket = @import("entities/rocket.zig").Rocket;
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

    pub fn init(gameConfig: GameConfig) @This() {
        var game = Game{
            .config = gameConfig,
            .player = Player.init(
                .{ .x = gameConfig.screenSize.width / 2 - gameConfig.playerSize.width / 2, .y = gameConfig.screenSize.height - gameConfig.playerSize.height * 2 },
                gameConfig.playerSize,
            ),
            .rockets = undefined,
        };

        for (&game.rockets) |*rocket| {
            rocket.* = Rocket.init(.{ .x = 0, .y = 0 }, gameConfig.rocketSize);
        }

        return game;
    }

    fn shoot(self: *@This()) void {
        for (&self.rockets) |*rocket| {
            if (!rocket.active) {
                rocket.position.x = self.player.position.x + self.player.size.width / 2 - rocket.size.width / 2;
                rocket.position.y = self.player.position.y;
                rocket.active = true;
                break;
            }
        }
    }

    pub fn update(self: *@This()) void {
        self.player.update();

        if (rl.isKeyPressed(rl.KeyboardKey.space)) {
            self.shoot();
        }

        for (&self.rockets) |*rocket| {
            rocket.update();
        }
    }

    pub fn draw(self: @This()) void {
        self.player.draw();

        for (&self.rockets) |*rocket| {
            rocket.draw();
        }
    }
};
