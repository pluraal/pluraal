import type { Value, UserModule } from "./types.js";
export declare class Interpreter {
    private readonly module;
    constructor(module: UserModule);
    /**
     * Evaluate a definition by name with the provided input bindings.
     * Intermediate definitions declared earlier in the module are available
     * as derived variables (computed lazily on first use per evaluation call).
     */
    evaluate(definitionName: string, inputs: Record<string, Value>): Value;
}
//# sourceMappingURL=interpreter.d.ts.map