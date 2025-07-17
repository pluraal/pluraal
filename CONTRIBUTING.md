# Contributing to Pluraal MCP Server

Welcome to the Pluraal MCP server project! This guide will help you understand the project structure and get you up and running for development.

## 🏗️ Project Structure

```
pluraal/
├── src/                    # Source code
│   ├── index.ts           # Main MCP server implementation
│   └── *.test.ts          # Unit tests
├── build/                 # Compiled JavaScript output
├── .vscode/              # VS Code configuration
│   ├── settings.json     # Editor settings
│   ├── extensions.json   # Recommended extensions
│   └── mcp.json         # MCP server configuration for debugging
├── package.json          # Dependencies and scripts
├── tsconfig.json         # TypeScript configuration
├── eslint.config.js      # ESLint configuration
├── .prettierrc           # Prettier formatting rules
└── vitest.config.ts      # Vitest testing configuration
```

## 🚀 Getting Started

### Prerequisites

- **Node.js** 18+
- **npm** (comes with Node.js)
- **VS Code** (recommended) with the suggested extensions

### Setup

1. **Clone and install dependencies:**

   ```bash
   npm install
   ```

2. **Build the project:**

   ```bash
   npm run build
   ```

3. **Run tests to verify setup:**
   ```bash
   npm test
   ```

## 🛠️ Development Workflow

### Available Scripts

| Command                 | Description                              |
| ----------------------- | ---------------------------------------- |
| `npm run dev`           | Start development server with hot reload |
| `npm run build`         | Compile TypeScript to JavaScript         |
| `npm test`              | Run unit tests                           |
| `npm run test:watch`    | Run tests in watch mode                  |
| `npm run test:coverage` | Run tests with coverage report           |
| `npm run lint`          | Check code quality with ESLint           |
| `npm run lint:fix`      | Auto-fix ESLint issues                   |
| `npm run format`        | Format code with Prettier                |
| `npm run typecheck`     | Check TypeScript types                   |

### Development Process

1. **Start development server:**

   ```bash
   npm run dev
   ```

2. **Make your changes** in `src/index.ts` or create new files

3. **Run tests** to ensure everything works:

   ```bash
   npm test
   ```

4. **Check code quality:**

   ```bash
   npm run lint
   npm run format
   ```

5. **Build for production:**
   ```bash
   npm run build
   ```

## 🔧 MCP Server Architecture

### Core Components

The MCP server is built using the official Anthropic MCP SDK:

```typescript
// Main server instance
const server = new McpServer({
  name: 'pluraal',
  version: '1.0.0',
  capabilities: {
    resources: {},
    tools: {},
  },
});

// Example tool definition
server.tool(
  'tool_name',
  'Tool description',
  {
    // Zod schema for parameters
    param: z.string().describe('Parameter description'),
  },
  async ({ param }) => {
    // Tool implementation
    return {
      content: [
        {
          type: 'text',
          text: `Result: ${param}`,
        },
      ],
    };
  }
);
```

### Adding New Tools

1. **Define the tool** in `src/index.ts`:

   ```typescript
   server.tool(
     'my_new_tool',
     'Description of what the tool does',
     {
       // Define parameters with Zod validation
       input: z.string().describe('Input parameter'),
       count: z.number().optional().describe('Optional count'),
     },
     async ({ input, count = 1 }) => {
       // Your tool logic here
       return {
         content: [
           {
             type: 'text',
             text: `Processed: ${input} (${count} times)`,
           },
         ],
       };
     }
   );
   ```

2. **Write tests** for your tool in `src/index.test.ts`:

   ```typescript
   describe('my_new_tool', () => {
     it('should process input correctly', async () => {
       // Test implementation
     });
   });
   ```

3. **Test locally:**
   ```bash
   npm run dev
   ```

## 🧪 Testing

### Test Structure

- **Unit tests**: Test individual tools and functions
- **Integration tests**: Test MCP protocol communication
- **Coverage**: Aim for >80% test coverage

### Writing Tests

```typescript
import { describe, it, expect } from 'vitest';

describe('Tool Name', () => {
  it('should handle valid input', async () => {
    // Arrange
    const input = 'test input';

    // Act
    const result = await myTool(input);

    // Assert
    expect(result.content[0].text).toContain('test input');
  });

  it('should handle edge cases', async () => {
    // Test edge cases and error conditions
  });
});
```

### Running Tests

```bash
# Run all tests
npm test

# Watch mode for development
npm run test:watch

# Coverage report
npm run test:coverage
```

## 🔍 Debugging

### VS Code Debugging

The project is configured for debugging with VS Code:

1. Open the project in VS Code
2. Install recommended extensions
3. Use the MCP configuration in `.vscode/mcp.json`
4. Set breakpoints in your code
5. Run the debug configuration

### Manual Testing

Test your MCP server manually:

```bash
# Start the server
npm run dev

# In another terminal, send MCP messages
echo '{"jsonrpc": "2.0", "id": 1, "method": "tools/list"}' | node build/index.js
```

## 📝 Code Style

### ESLint Rules

- Use TypeScript strict mode
- Prefer `const` over `let`
- Use async/await over Promises
- Add JSDoc comments for public APIs

### Prettier Formatting

- 2-space indentation
- Single quotes for strings
- Trailing commas where valid
- Semi-colons required

### Type Safety

- Enable strict TypeScript mode
- Use Zod for runtime validation
- Prefer explicit types over `any`
- Handle errors properly

## 🚢 Production Deployment

### Build Process

```bash
# Clean build
rm -rf build/
npm run build

# Verify build works
node build/index.js
```

### MCP Client Configuration

Add to your MCP client configuration:

```json
{
  "mcpServers": {
    "pluraal": {
      "command": "node",
      "args": ["/path/to/pluraal/build/index.js"],
      "env": {}
    }
  }
}
```

## 🐛 Troubleshooting

### Common Issues

1. **TypeScript errors**: Run `npm run typecheck`
2. **ESLint errors**: Run `npm run lint:fix`
3. **Test failures**: Check test output and fix failing tests
4. **MCP communication issues**: Ensure you're logging to stderr, not stdout

### Getting Help

- Check the [MCP documentation](https://modelcontextprotocol.io/)
- Review existing tests for examples
- Open an issue if you find bugs

## 📋 Pull Request Guidelines

1. **Fork the repository** and create a feature branch
2. **Write tests** for your changes
3. **Ensure all tests pass** (`npm test`)
4. **Check code quality** (`npm run lint`)
5. **Format your code** (`npm run format`)
6. **Update documentation** if needed
7. **Submit a pull request** with a clear description

Thank you for contributing to Pluraal MCP Server! 🎉
