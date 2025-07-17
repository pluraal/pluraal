#!/usr/bin/env node
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { z } from 'zod';
// Create server instance
const server = new McpServer({
    name: 'pluraal',
    version: '1.0.0',
    capabilities: {
        resources: {},
        tools: {},
    },
});
// Example tool: Echo
server.tool('echo', 'Echo back the provided message', {
    message: z.string().describe('The message to echo back'),
}, async ({ message }) => {
    return {
        content: [
            {
                type: 'text',
                text: `Echo: ${message}`,
            },
        ],
    };
});
// Example tool: Get current time
server.tool('get_time', 'Get the current time', {}, async () => {
    const now = new Date();
    return {
        content: [
            {
                type: 'text',
                text: `Current time: ${now.toISOString()}`,
            },
        ],
    };
});
async function main() {
    const transport = new StdioServerTransport();
    await server.connect(transport);
    // Log to stderr (not stdout which is used for MCP communication)
    console.error('Pluraal MCP Server running on stdio');
}
main().catch((error) => {
    console.error('Fatal error in main():', error);
    process.exit(1);
});
//# sourceMappingURL=index.js.map