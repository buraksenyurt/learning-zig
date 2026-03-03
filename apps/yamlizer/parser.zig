const std = @import("std");
const models = @import("models.zig");
const utility = @import("utility.zig");

const LINE_ENDING = " \r\n";

pub fn deserialize(filePath: []const u8) !models.service {
    const content = try utility.readFileContent(
        std.heap.page_allocator,
        filePath,
    );
    var service = models.service.init(std.heap.page_allocator);
    var lines = std.mem.splitAny(
        u8,
        content,
        "\r\n",
    );

    while (lines.next()) |line| {
        const trimmedLine = std.mem.trim(
            u8,
            line,
            LINE_ENDING,
        );
        if (trimmedLine.len == 0) continue;

        if (std.mem.startsWith(u8, trimmedLine, "service_name:")) {
            const value = std.mem.trim(
                u8,
                trimmedLine["service_name:".len..],
                LINE_ENDING,
            );
            service.serviceName = value;
        } else if (std.mem.startsWith(u8, trimmedLine, "domain:")) {
            const value = std.mem.trim(
                u8,
                trimmedLine["domain:".len..],
                LINE_ENDING,
            );
            service.domain = value;
        } else if (std.mem.startsWith(u8, trimmedLine, "version:")) {
            const value = std.mem.trim(
                u8,
                trimmedLine["version:".len..],
                LINE_ENDING,
            );
            service.version = try utility.parseVersion(value);
        } else if (std.mem.startsWith(u8, trimmedLine, "network:")) {
            var protocol: ?models.Protocol = null;
            var host: []const u8 = "";
            var port: u16 = 0;
            var environment: models.Environment = .Development;

            while (lines.next()) |networkLine| {
                const trimmedNetworkLine = std.mem.trim(u8, networkLine, LINE_ENDING);
                if (trimmedNetworkLine.len == 0) continue;

                if (networkLine.len > 0 and networkLine[0] != ' ' and networkLine[0] != '\t') break;

                if (std.mem.startsWith(u8, trimmedNetworkLine, "- ")) {
                    if (protocol != null) {
                        try service.network.append(models.network{
                            .host = host,
                            .port = port,
                            .protocol = protocol.?,
                            .environment = environment,
                        });
                        host = "";
                        port = 0;
                        environment = .Development;
                        protocol = null;
                    }

                    const fieldStr = std.mem.trim(u8, trimmedNetworkLine[2..], LINE_ENDING);
                    if (std.mem.startsWith(u8, fieldStr, "protocol:")) {
                        const val = std.mem.trim(u8, fieldStr["protocol:".len..], LINE_ENDING);
                        protocol = models.Protocol.fromString(val);
                    }
                } else if (std.mem.startsWith(u8, trimmedNetworkLine, "protocol:")) {
                    const val = std.mem.trim(u8, trimmedNetworkLine["protocol:".len..], LINE_ENDING);
                    protocol = models.Protocol.fromString(val);
                } else if (std.mem.startsWith(u8, trimmedNetworkLine, "host:")) {
                    host = std.mem.trim(u8, trimmedNetworkLine["host:".len..], LINE_ENDING);
                } else if (std.mem.startsWith(u8, trimmedNetworkLine, "port:")) {
                    const portStr = std.mem.trim(u8, trimmedNetworkLine["port:".len..], LINE_ENDING);
                    port = try std.fmt.parseInt(u16, portStr, 10);
                } else if (std.mem.startsWith(u8, trimmedNetworkLine, "environment:")) {
                    const envStr = std.mem.trim(u8, trimmedNetworkLine["environment:".len..], LINE_ENDING);
                    environment = models.Environment.fromString(envStr) orelse .Development;
                }
            }

            if (protocol != null) {
                try service.network.append(models.network{
                    .host = host,
                    .port = port,
                    .protocol = protocol.?,
                    .environment = environment,
                });
            }
        }
    }
    return service;
}
