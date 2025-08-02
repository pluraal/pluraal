# Scope Viewer UI

A visual interface for the Pluraal language that allows you to:

1. **Load Scope Definitions**: Dynamically loads scope definitions from JSON files via HTTP
2. **View Scope Structure**: See the structure of a scope including its inputs, data points, and result expression
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

The application loads scope definitions from `sample-scope.json`. The JSON format uses explicit type discriminators to distinguish between literals, variables, and branches:

```json
{
  "inputs": [
    {
      "name": "customerName",
      "type": "string"
    }
  ],
  "dataPoints": [
    {
      "name": "greeting",
      "expression": {
        "type": "branch",
        "value": {
          "if": {
            "type": "variable",
            "name": "isPremium"
          },
          "then": {
            "type": "literal",
            "value": "Welcome VIP!"
          },
          "else": {
            "type": "literal",
            "value": "Welcome!"
          }
        }
      }
    }
  ],
  "result": {
    "type": "variable",
    "name": "greeting"
  }
}
```

**Expression Types:**

- `{"type": "literal", "value": <json-value>}` - Literal values (strings, numbers, booleans, null)
- `{"type": "variable", "name": "<variable-name>"}` - Variable references
- `{"type": "branch", "value": <branch-object>}` - Branching logic (if-then-else, rules, finite branches)

## Sample Scope

The current demo includes a customer order processing scope with:

- **Inputs**:
  - `customerName` (String): Customer's name
  - `orderAmount` (Number): Order total amount
  - `isPremium` (Boolean): Whether customer has premium status

- **Data Points**:
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
- Data point calculation and context building
