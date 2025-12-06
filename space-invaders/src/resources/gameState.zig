pub const GameState = struct {
    playerScore: u32 = 0,
    totalInvaders: u32 = 0,
    remainingInvaders: u32 = 0,
    totalFiredRockets: u32 = 0,

    pub fn init(totalInvaders: u32) GameState {
        return GameState{
            .playerScore = 0,
            .totalInvaders = totalInvaders,
            .remainingInvaders = totalInvaders,
            .totalFiredRockets = 0,
        };
    }

    pub fn reset(self: *@This()) void {
        self.playerScore = 0;
        self.remainingInvaders = 0;
        self.totalFiredRockets = 0;
        self.totalInvaders = 0;
    }
};
