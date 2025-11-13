# Scope Viewer UI

A visual interface for the Pluraal language that allows you to:

1. **Load Scope Definitions**: Dynamically loads scope definitions from JSON files via HTTP
2. **View Scope Structure**: See the structure of a scope including its inputs, calculations, and result expression
3. **Provide Input Values**: Enter values for the required inputs according to their types
4. **Evaluate Scopes**: Execute the scope logic and see the results
5. **Error Handling**: Get clear feedback when scopes fail to load, inputs are missing, or invalid

## Usage

### Local Development Server

Since the application loads JSON via HTTP, you need to serve it from a web server:

```bash
# Start a local server (Python)
python -m http.server 8000

# Or using Node.js
npx http-server

# Then open http://localhost:8000/index.html
```

### JSON Scope Definition

The application loads scope definitions from `sample-scope.json`. The JSON format uses `{"ref": "name"}` for references and `{"type": ...}` objects for literals and branches:

```json
{
  "inputs": [
    {
      "name": "customerName",
      "type": "string"
    }
  ],
  "calculations": {
    "greeting": {
      "type": "branch",
      "value": {
          "if": { "ref": "isPremium" },
          "then": "Welcome VIP!",
          "else": "Welcome!"
      }
    }
  },
  "result": {
  "ref": "greeting"
  }
}
```

**Expression Types:**

- `<json primitive>` - Literal values (string, number, boolean)
- `{"ref": "<reference-name>"}` - Reference to previously defined input or calculation
- `{"type": "branch", "value": <branch-object>}` - Branching logic (if-then-else, rules, finite branches)

## Sample Scope

The current demo includes a customer order processing scope with:

- **Inputs**:
  - `customerName` (String): Customer's name
  - `orderAmount` (Number): Order total amount
  - `isPremium` (Boolean): Whether customer has premium status

- **Calculations**:
  - `discount`: Calculates discount rate (15% for premium, 5% for standard)
  - `discountCategory`: Determines customer category based on premium status
  - `greeting`: Generates personalized greeting based on customer category

- **Result**: Returns the appropriate greeting message

## Try It Out

1. Enter values in the input fields:
   - customerName: "Alice"
   - orderAmount: 150.00
   - isPremium: true

2. Click "Evaluate Scope"

3. See the result: "Thank you for being a Premium customer!"

## Development

To modify the scope or add new features:

1. Edit `src/ScopeViewer.elm`
2. Rebuild: `elm make src/ScopeViewer.elm --output=scope-viewer.js`
3. Refresh your browser

The UI demonstrates all the core Pluraal language features:

- Literal expressions
- Variable references
- If-then-else branching
- Rule chains with fallbacks
- Finite branching with case matching
- Type validation for inputs
- Calculation evaluation and context building
