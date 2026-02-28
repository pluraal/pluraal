import type { Value } from "./types.js";
type Op = (...args: Value[]) => Value;
/**
 * Built-in operations keyed by the URL fragment used in markdown links.
 * e.g. `../language/number.md#multiplication` → key is `multiplication`.
 */
export declare const OPERATIONS: Record<string, Op>;
/**
 * Extracts the operation key from a markdown link URL.
 * e.g. `../language/number.md#multiplication` → `multiplication`
 */
export declare function resolveOp(url: string): string;
export {};
//# sourceMappingURL=operations.d.ts.map