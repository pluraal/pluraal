import { OPERATIONS, resolveOp } from "./operations.js";
export class Interpreter {
    module;
    constructor(module) {
        this.module = module;
    }
    /**
     * Evaluate a definition by name with the provided input bindings.
     * Intermediate definitions declared earlier in the module are available
     * as derived variables (computed lazily on first use per evaluation call).
     */
    evaluate(definitionName, inputs) {
        const def = this.module.definitions.find((d) => d.name === definitionName);
        if (!def) {
            throw new Error(`Definition "${definitionName}" not found in module "${this.module.title}"`);
        }
        // Build an env with the provided inputs, then evaluate the expression.
        const env = new EvalEnv(inputs, this.module);
        return env.eval(def.expr);
    }
}
// ---------------------------------------------------------------------------
// Evaluation environment
// ---------------------------------------------------------------------------
class EvalEnv {
    inputs;
    module;
    /** Cache for intermediate definitions resolved during this evaluation. */
    cache = new Map();
    constructor(inputs, module) {
        this.inputs = inputs;
        this.module = module;
    }
    eval(expr) {
        switch (expr.kind) {
            case "literal":
                return expr.value;
            case "var": {
                const name = expr.name;
                // Check direct inputs first.
                if (Object.prototype.hasOwnProperty.call(this.inputs, name)) {
                    return this.inputs[name];
                }
                // Check cached intermediate definitions.
                if (this.cache.has(name)) {
                    return this.cache.get(name);
                }
                // Try to resolve as an earlier definition in the module.
                const def = this.module.definitions.find((d) => d.name === name);
                if (def) {
                    const value = this.eval(def.expr);
                    this.cache.set(name, value);
                    return value;
                }
                throw new Error(`Unresolved variable: "${name}"`);
            }
            case "call": {
                const key = resolveOp(expr.op);
                const op = OPERATIONS[key];
                if (!op) {
                    throw new Error(`Unknown operation: "${key}" (from link "${expr.op}")`);
                }
                const argValues = expr.args.map((a) => this.eval(a));
                return op(...argValues);
            }
        }
    }
}
//# sourceMappingURL=interpreter.js.map