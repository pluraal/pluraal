/**
 * Built-in operations keyed by the URL fragment used in markdown links.
 * e.g. `../language/number.md#multiplication` → key is `multiplication`.
 */
export const OPERATIONS = {
    // Number type class
    addition: (a, b) => a + b,
    subtraction: (a, b) => a - b,
    multiplication: (a, b) => a * b,
    division: (a, b) => a / b,
    negation: (a) => -a,
    "absolute-value": (a) => Math.abs(a),
    // Ordering type class
    compare: (a, b) => a < b
        ? "Less"
        : a > b
            ? "Greater"
            : "Equal",
    "less-than": (a, b) => a < b,
    "greater-than": (a, b) => a > b,
    "less-than-or-equal": (a, b) => a <= b,
    "greater-than-or-equal": (a, b) => a >= b,
    // Equality type class
    equals: (a, b) => a === b,
    "not-equals": (a, b) => a !== b,
};
/**
 * Extracts the operation key from a markdown link URL.
 * e.g. `../language/number.md#multiplication` → `multiplication`
 */
export function resolveOp(url) {
    const hash = url.lastIndexOf("#");
    if (hash === -1) {
        throw new Error(`Operation link has no anchor fragment: ${url}`);
    }
    return url.slice(hash + 1);
}
//# sourceMappingURL=operations.js.map