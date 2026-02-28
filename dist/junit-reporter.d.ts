import type { RunSummary } from "./test-runner.js";
/**
 * Renders a RunSummary as a JUnit XML string.
 *
 * Structure:
 *   <testsuites>          — one per module run
 *     <testsuite>         — one per definition
 *       <testcase>        — one per test-case row
 *         <failure>?      — present when the case fails
 */
export declare function formatJUnit(moduleTitle: string, summary: RunSummary): string;
//# sourceMappingURL=junit-reporter.d.ts.map