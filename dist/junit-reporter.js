function formatValue(v) {
    return String(v);
}
function xmlEscape(s) {
    return s
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&apos;");
}
function buildTestCaseName(result) {
    const inputStr = Object.entries(result.inputs)
        .map(([k, v]) => `${k}=${formatValue(v)}`)
        .join(", ");
    return `case ${result.caseIndex}: ${inputStr}`;
}
function buildFailureMessage(result) {
    if (result.error)
        return result.error;
    return `expected ${formatValue(result.expected)}, got ${formatValue(result.actual)}`;
}
/**
 * Groups test results by definition name while preserving definition order.
 */
function groupByDefinition(results) {
    const map = new Map();
    for (const r of results) {
        let group = map.get(r.definitionName);
        if (!group) {
            group = [];
            map.set(r.definitionName, group);
        }
        group.push(r);
    }
    return map;
}
/**
 * Renders a RunSummary as a JUnit XML string.
 *
 * Structure:
 *   <testsuites>          — one per module run
 *     <testsuite>         — one per definition
 *       <testcase>        — one per test-case row
 *         <failure>?      — present when the case fails
 */
export function formatJUnit(moduleTitle, summary) {
    const groups = groupByDefinition(summary.results);
    const lines = [];
    lines.push('<?xml version="1.0" encoding="UTF-8"?>');
    lines.push(`<testsuites name="${xmlEscape(moduleTitle)}" tests="${summary.total}" failures="${summary.failed}">`);
    for (const [defName, results] of groups) {
        const suiteFailed = results.filter((r) => !r.pass).length;
        lines.push(`  <testsuite name="${xmlEscape(defName)}" tests="${results.length}" failures="${suiteFailed}">`);
        for (const result of results) {
            const caseName = buildTestCaseName(result);
            if (result.pass) {
                lines.push(`    <testcase classname="${xmlEscape(defName)}" name="${xmlEscape(caseName)}"/>`);
            }
            else {
                const failureType = result.error ? "ERROR" : "FAILURE";
                const message = buildFailureMessage(result);
                lines.push(`    <testcase classname="${xmlEscape(defName)}" name="${xmlEscape(caseName)}">`);
                lines.push(`      <failure type="${failureType}" message="${xmlEscape(message)}">${xmlEscape(message)}</failure>`);
                lines.push(`    </testcase>`);
            }
        }
        lines.push(`  </testsuite>`);
    }
    lines.push(`</testsuites>`);
    return lines.join("\n");
}
//# sourceMappingURL=junit-reporter.js.map