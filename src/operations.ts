import type { Value } from "./types.js";

type Op = (...args: Value[]) => Value;

/**
 * Built-in operations keyed by the URL fragment used in markdown links.
 * e.g. `../language/number.md#multiplication` → key is `multiplication`.
 */
export const OPERATIONS: Record<string, Op> = {
  // Number type class
  addition: (a, b) => (a as number) + (b as number),
  subtraction: (a, b) => (a as number) - (b as number),
  multiplication: (a, b) => (a as number) * (b as number),
  division: (a, b) => (a as number) / (b as number),
  negation: (a) => -(a as number),
  "absolute-value": (a) => Math.abs(a as number),

  // Ordering type class
  compare: (a, b) =>
    (a as number) < (b as number)
      ? "Less"
      : (a as number) > (b as number)
        ? "Greater"
        : "Equal",
  "less-than": (a, b) => (a as number) < (b as number),
  "greater-than": (a, b) => (a as number) > (b as number),
  "less-than-or-equal": (a, b) => (a as number) <= (b as number),
  "greater-than-or-equal": (a, b) => (a as number) >= (b as number),

  // Equality type class
  equal: (a, b) => a === b,
  "not-equal": (a, b) => a !== b,

  // Boolean type
  not: (a) => !(a as boolean),
  and: (a, b) => (a as boolean) && (b as boolean),
  or: (a, b) => (a as boolean) || (b as boolean),

  // Control flow
  "if-then-else": (cond, then_, else_) => (cond as boolean) ? then_ : else_,
};

/**
 * Extracts the operation key from a markdown link URL.
 * e.g. `../language/number.md#multiplication` → `multiplication`
 */
export function resolveOp(url: string): string {
  const hash = url.lastIndexOf("#");
  if (hash === -1) {
    throw new Error(`Operation link has no anchor fragment: ${url}`);
  }
  return url.slice(hash + 1);
}
