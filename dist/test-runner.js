import { Interpreter } from "./interpreter.js";
const TOLERANCE = 1e-9;
function valuesEqual(actual, expected) {
    if (typeof actual === "number" && typeof expected === "number") {
        return Math.abs(actual - expected) <= TOLERANCE;
    }
    return actual === expected;
}
function formatValue(v) {
    return String(v);
}
export function runTests(module, options = {}) {
    const interpreter = new Interpreter(module);
    const results = [];
    const defs = options.only && options.only.length > 0
        ? module.definitions.filter((d) => options.only.includes(d.name))
        : module.definitions;
    for (const def of defs) {
        if (def.testCases.length === 0)
            continue;
        for (let i = 0; i < def.testCases.length; i++) {
            const tc = def.testCases[i];
            let actual;
            let error;
            try {
                actual = interpreter.evaluate(def.name, tc.inputs);
            }
            catch (err) {
                actual = "";
                error = err instanceof Error ? err.message : String(err);
            }
            const pass = error === undefined && valuesEqual(actual, tc.expected);
            results.push({
                definitionName: def.name,
                caseIndex: i + 1,
                inputs: tc.inputs,
                expected: tc.expected,
                actual,
                pass,
                error,
            });
        }
    }
    const passed = results.filter((r) => r.pass).length;
    const failed = results.length - passed;
    return { total: results.length, passed, failed, results };
}
// ---------------------------------------------------------------------------
// Formatting helpers (used by the CLI reporter)
// ---------------------------------------------------------------------------
export function formatSummary(summary, verbose) {
    const lines = [];
    if (verbose || summary.failed > 0) {
        let currentDef = "";
        for (const result of summary.results) {
            if (result.definitionName !== currentDef) {
                currentDef = result.definitionName;
                lines.push(`\n  ${currentDef}`);
            }
            const status = result.pass ? "✓" : "✗";
            const inputStr = Object.entries(result.inputs)
                .map(([k, v]) => `${k}=${formatValue(v)}`)
                .join(", ");
            if (result.pass) {
                if (verbose) {
                    lines.push(`    ${status} case ${result.caseIndex}: ${inputStr} → ${formatValue(result.actual)}`);
                }
            }
            else {
                const detail = result.error
                    ? `ERROR: ${result.error}`
                    : `expected ${formatValue(result.expected)}, got ${formatValue(result.actual)}`;
                lines.push(`    ${status} case ${result.caseIndex}: ${inputStr} → ${detail}`);
            }
        }
        lines.push("");
    }
    const statusIcon = summary.failed === 0 ? "✓" : "✗";
    lines.push(`${statusIcon} ${summary.passed}/${summary.total} tests passed` +
        (summary.failed > 0 ? ` (${summary.failed} failed)` : ""));
    return lines.join("\n");
}
//# sourceMappingURL=test-runner.js.map