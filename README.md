# Pluraal MCP Server & Language Library

A lean TypeScript implementation of a Model Context Protocol (MCP) server with a declarative language library implemented in Elm.

## Features

- **TypeScript MCP Server**: Full type safety and modern JavaScript features
- **Elm Language Library**: Declarative language for rules and logic
- **MCP SDK**: Built with the official Model Context Protocol SDK
- **Linting**: ESLint with TypeScript support and consistent code style rules
- **Testing**: Vitest for TypeScript and elm-test for Elm
- **Formatting**: Prettier for consistent code formatting
- **Development**: Hot reload with tsx for rapid development

## Quick Start

### Prerequisites

- Node.js 16+
- npm or yarn
- Elm 0.19.1 (installed automatically via npm)

### Installation

```bash
npm install
```

### MCP Server Development

```bash
# Start development server with hot reload
npm run dev

# Build the TypeScript project
npm run build

# Run the built server
npm start
```

### Elm Language Library Development

```bash
# Build the Elm library
npm run build:elm

# Run Elm tests
npm run test:elm

# Start Elm REPL
npm run elm:repl
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
│   ├── Pluraal/
│   │   └── Language.elm     # Elm language library
│   ├── index.ts             # Main MCP server implementation
│   └── index.test.ts        # TypeScript tests
├── tests/
│   ├── LanguageTest.elm     # Elm language tests
│   └── elm.json             # Elm test configuration
├── .vscode/
│   ├── mcp.json             # MCP server configuration
│   ├── extensions.json      # Recommended VS Code extensions
│   └── settings.json        # VS Code workspace settings
├── build/                   # Compiled output (generated)
├── coverage/                # Test coverage reports (generated)
├── elm-stuff/               # Elm dependencies (generated)
├── elm.json                 # Elm package configuration
├── package.json             # Dependencies and scripts
├── tsconfig.json            # TypeScript configuration
├── vitest.config.ts         # Vitest testing configuration
├── eslint.config.js         # ESLint configuration
├── .prettierrc              # Prettier formatting configuration
└── README.md                # This file
```

## Pluraal Language

The Pluraal language is a declarative language for defining rules and logic, implemented in Elm. It supports:

### Data Types

- **Literals**: Strings, numbers, booleans, and null
- **Variables**: Named references to values
- **Expressions**: Composable language constructs

### Logic Constructs

- **If-then-else**: Simple conditional logic
- **Rule chains**: Sequential rule evaluation with fallbacks
- **Finite branches**: Pattern matching on string values
- **Scopes**: Typed inputs with calculated data points

### Scopes

Scopes provide a powerful feature for defining typed inputs and calculated data points. A scope includes:

- **Inputs**: Named variables with specific types (string, number, bool)
- **Data Points**: Calculations derived from inputs and other data points
- **Result**: The final expression to evaluate

#### Type System

Scopes support a simple type system:
- `StringType`: String values
- `NumberType`: Numeric values  
- `BoolType`: Boolean values

#### Example Scope Usage

```elm
-- Define a scope with typed inputs and calculated data points
inputs = 
    [ { name = "radius", type_ = NumberType }
    , { name = "pi", type_ = NumberType }
    ]

dataPoints =
    [ { name = "area", expression = -- calculation expression here }
    ]

result = VariableExpr "area"

scope = { inputs = inputs, dataPoints = dataPoints, result = result }
scopeExpr = ScopeExpr scope

-- Provide input context
context = Dict.fromList 
    [ ( "radius", LiteralExpr (NumberLiteral 5.0) )
    , ( "pi", LiteralExpr (NumberLiteral 3.14159) )
    ]

-- Evaluate scope
result = evaluate context scopeExpr
```

#### JSON Representation for Scopes

```json
{
  "inputs": [
    { "name": "radius", "type": "number" },
    { "name": "pi", "type": "number" }
  ],
  "dataPoints": [
    { 
      "name": "area", 
      "expression": {
        "if": true,
        "then": { "type": "number", "value": 78.54 },
        "else": { "type": "number", "value": 0 }
      }
    }
  ],
  "result": "area"
}
```

### Example Usage

```elm
import Pluraal.Language exposing (..)
import Dict

-- Simple if-then-else
condition = LiteralExpr (BoolLiteral True)
thenBranch = LiteralExpr (StringLiteral "Success")
elseBranch = LiteralExpr (StringLiteral "Failure")
ifExpr = BranchExpr (IfThenElseBranch { condition = condition, then_ = thenBranch, else_ = elseBranch })

-- Evaluate with empty context
result = evaluate Dict.empty ifExpr
-- Result: Ok (LiteralExpr (StringLiteral "Success"))
```

### JSON Representation

The language can be serialized to/from JSON following the specification:

```json
{
  "if": { "type": "boolean", "value": true },
  "then": "Success",
  "else": "Failure"
}
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
