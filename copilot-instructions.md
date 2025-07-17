# Copilot Instructions for Pluraal MCP Server

This project is a TypeScript-based Model Context Protocol (MCP) server implementation. Here are the key development guidelines:

## Project Overview

- **Language**: TypeScript with Node.js
- **Framework**: Model Context Protocol SDK
- **Purpose**: Lean MCP server with comprehensive development tooling

## Development Guidelines

### Code Style

- Use TypeScript strict mode
- Prefer explicit types over `any`
- Use ES modules (import/export)
- Follow Prettier formatting rules
- Use single quotes for strings
- Include trailing commas in multi-line structures

### MCP Server Development

- All tools should be defined using the `server.tool()` method
- Use Zod schemas for parameter validation
- Always return content in the MCP standard format
- Log to stderr, never stdout (breaks MCP communication)
- Handle errors gracefully with appropriate error messages

### Testing

- Write unit tests for all tools and utilities
- Use Vitest for testing framework
- Aim for high test coverage
- Test both success and error cases

### File Organization

- Keep MCP server logic in `src/index.ts`
- Separate complex tools into their own modules
- Use descriptive file and function names
- Group related functionality together

## MCP SDK Reference

For more information about implementing MCP servers:

- SDK Documentation: https://github.com/modelcontextprotocol/typescript-sdk
- Server Examples: https://github.com/modelcontextprotocol/create-python-server

## Key Commands

- `npm run dev` - Development with hot reload
- `npm run build` - Compile TypeScript
- `npm test` - Run tests
- `npm run lint` - Check code style
- `npm run format` - Format code

## Important Notes

- Never use `console.log()` in MCP servers (use `console.error()` for debugging)
- Always validate inputs with Zod schemas
- Return results in the standard MCP content format
- Handle async operations properly with try/catch blocks
