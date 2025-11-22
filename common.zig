const std = @import("std");

pub fn ping() []const u8 {
    return "Pong!";
}

// pub fn print_file() !void {
//     var file = try std.fs.cwd().openFile("games.data", .{});
//     defer file.close();

//     std.debug.print("Contents of games.data:\n", .{});
// }
