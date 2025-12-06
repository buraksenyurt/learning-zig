const config = @import("config.zig");
const GameConfig = config.GameConfig;
const Player = @import("entities/player.zig").Player;
const Rocket = @import("entities/rocket.zig").Rocket;
const Invader = @import("entities/invader.zig").Invader;
const EnemyBomb = @import("entities/enemyBomb.zig").EnemyBomb;
const Vector2D = @import("geometry.zig").Vector2D;
const Systems = @import("systems/mod.zig").Systems;
const GameState = @import("resources/gameState.zig").GameState;
const Shield = @import("entities/shield.zig").Shield;
const rl = @import("raylib");

pub const Game = struct {
    config: GameConfig,
    player: Player,
    rockets: [config.MAX_ROCKETS]Rocket = undefined,
    enemyBombs: [config.MAX_ENEMY_BOMBS]EnemyBomb = undefined,
    invaders: [config.INVADER_ROWS][config.INVADER_COLUMNS]Invader = undefined,
    invaderDirection: Vector2D = undefined,
    moveTimer: f32 = 0.0,
    enemyMoveTimer: f32 = 0.0,
    enemyShootDelay: f32 = 1.0,
    enemyShootChance: i32 = 5,
    shields: [config.MAX_SHIELDS]Shield = undefined,
    gameState: GameState,
    gameOver: bool = false,

    pub fn init(gameConfig: GameConfig) @This() {
        var game = Game{
            .config = gameConfig,
            .player = Player.init(
                .{ .x = gameConfig.screenSize.width / 2 - gameConfig.playerSize.width / 2, .y = gameConfig.screenSize.height - gameConfig.playerSize.height * 2 },
                gameConfig.playerSize,
            ),
            .rockets = undefined,
            .moveTimer = 0.0,
            .enemyMoveTimer = 0.0,
            .invaderDirection = Vector2D{ .x = 1.0, .y = 0.0 },
            .gameState = GameState.init(config.INVADER_ROWS * config.INVADER_COLUMNS),
        };

        Systems.rocket.initAll(&game);
        Systems.invaders.initAll(&game);
        Systems.enemy.initAllBombs(&game);
        Systems.shield.initAll(&game);

        return game;
    }

    pub fn update(self: *@This()) void {
        self.player.update();

        Systems.collision.detectRocketHitInvader(self);
        Systems.collision.detectBombHitShield(self);
        Systems.collision.detectRocketHitShield(self);
        Systems.player.fire(self);
        Systems.enemy.updateAll(self);
        Systems.player.detectHits(self);
        Systems.rocket.moveAll(self);
        Systems.invaders.updateMoves(self);
    }

    pub fn draw(self: @This()) void {
        self.player.draw();

        Systems.rocket.drawAll(self);
        Systems.invaders.drawAll(self);
        Systems.enemy.drawAllBombs(self);
        Systems.shield.drawAll(self);

        self.drawHud();
    }

    fn drawHud(self: @This()) void {
        const scoreText = rl.textFormat("Score: %d Invaders: (%d/%d) Fired Rockets: %d", .{
            self.gameState.playerScore,
            self.gameState.remainingInvaders,
            self.gameState.totalInvaders,
            self.gameState.totalFiredRockets,
        });
        rl.drawText(scoreText, 20, @intFromFloat(self.config.screenSize.height - 20.0), 20, rl.Color.white);

        const titleText = rl.textFormat("Space Invaders", .{});
        const sizeOfTitle: f32 = @floatFromInt(rl.measureText(titleText, 20));
        rl.drawText(titleText, @intFromFloat(self.config.screenSize.width / 2 - sizeOfTitle / 2), 0, 20, rl.Color.white);

        rl.drawText("Press SPACE to shoot, ESC to quit...", 20, 25, 20, rl.Color.yellow);
    }
};
