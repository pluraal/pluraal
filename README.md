# Pluraal MCP Server

A lean TypeScript implementation of a Model Context Protocol (MCP) server with comprehensive tooling for development.

## Features

- **TypeScript**: Full type safety and modern JavaScript features
- **MCP SDK**: Built with the official Model Context Protocol SDK
- **Linting**: ESLint with TypeScript support and consistent code style rules
- **Testing**: Vitest for fast unit testing with coverage reporting
- **Formatting**: Prettier for consistent code formatting
- **Development**: Hot reload with tsx for rapid development

## Quick Start

### Prerequisites

- Node.js 16+
- npm or yarn

### Installation

```bash
npm install
```

### Development

```bash
# Start development server with hot reload
npm run dev

# Build the project
npm run build

# Run the built server
npm start
```

### Testing

```bash
# Run tests
npm test

# Run tests in watch mode
npm run test:watch

# Generate coverage report
npm run test:coverage
```

### Code Quality

```bash
# Lint code
npm run lint

# Fix linting issues
npm run lint:fix

# Format code
npm run format

# Check formatting
npm run format:check

# Type checking
npm run typecheck
```

## MCP Server Implementation

This server provides example tools demonstrating MCP capabilities:

- **echo**: Echo back a provided message
- **get_time**: Get the current timestamp

### Adding New Tools

To add new tools to your MCP server, use the `server.tool()` method in `src/index.ts`:

```typescript
server.tool(
  'tool_name',
  'Tool description',
  {
    // Zod schema for parameters
    param1: z.string().describe('Parameter description'),
  },
  async ({ param1 }) => {
    // Tool implementation
    return {
      content: [
        {
          type: 'text',
          text: `Result: ${param1}`,
        },
      ],
    };
  }
);
```

## VS Code Integration

This project includes VS Code configuration for debugging MCP servers:

1. The `.vscode/mcp.json` file configures the server for debugging
2. Use the VS Code MCP extension to test your server locally
3. Recommended extensions are configured in `.vscode/extensions.json`

## Claude for Desktop Integration

To use this server with Claude for Desktop, add the following to your Claude configuration:

### Windows

```json
{
  "mcpServers": {
    "pluraal": {
      "command": "npm",
      "args": ["start"],
      "cwd": "C:\\ABSOLUTE\\PATH\\TO\\pluraal"
    }
  }
}
```

### macOS/Linux

```json
{
  "mcpServers": {
    "pluraal": {
      "command": "npm",
      "args": ["start"],
      "cwd": "/ABSOLUTE/PATH/TO/pluraal"
    }
  }
}
```

## Project Structure

```
pluraal/
├── src/
│   ├── index.ts          # Main MCP server implementation
│   └── index.test.ts     # Example tests
├── .vscode/
│   ├── mcp.json          # MCP server configuration
│   ├── extensions.json   # Recommended VS Code extensions
│   └── settings.json     # VS Code workspace settings
├── build/                # Compiled output (generated)
├── coverage/             # Test coverage reports (generated)
├── package.json          # Dependencies and scripts
├── tsconfig.json         # TypeScript configuration
├── vitest.config.ts      # Vitest testing configuration
├── eslint.config.js      # ESLint configuration
├── .prettierrc           # Prettier formatting configuration
└── README.md             # This file
```

## MCP SDK Reference

For more information about the Model Context Protocol SDK:

- [MCP Documentation](https://modelcontextprotocol.io/)
- [TypeScript SDK](https://github.com/modelcontextprotocol/typescript-sdk)
- [Python SDK](https://github.com/modelcontextprotocol/create-python-server)

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details on:

- Setting up the development environment
- Code style and standards
- Testing requirements
- Pull request process

### CI/CD

This project uses GitHub Actions for continuous integration:

- **Pull Request Builds**: Automatically runs tests, linting, and builds on all PRs
- **Security Audits**: Regular dependency vulnerability scans
- **Dependency Updates**: Automated dependency update PRs
- **Releases**: Automated releases when tags are pushed

## License

MIT
