import type { RunSummary } from "./test-runner.js";
import type { TestResult, Value } from "./types.js";

function formatValue(v: Value): string {
  return String(v);
}

function xmlEscape(s: string): string {
  return s
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&apos;");
}

function buildTestCaseName(result: TestResult): string {
  const inputStr = Object.entries(result.inputs)
    .map(([k, v]) => `${k}=${formatValue(v as Value)}`)
    .join(", ");
  return `case ${result.caseIndex}: ${inputStr}`;
}

function buildFailureMessage(result: TestResult): string {
  if (result.error) return result.error;
  return `expected ${formatValue(result.expected)}, got ${formatValue(result.actual)}`;
}

/**
 * Groups test results by definition name while preserving definition order.
 */
function groupByDefinition(results: TestResult[]): Map<string, TestResult[]> {
  const map = new Map<string, TestResult[]>();
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
export function formatJUnit(moduleTitle: string, summary: RunSummary): string {
  const groups = groupByDefinition(summary.results);
  const lines: string[] = [];

  lines.push('<?xml version="1.0" encoding="UTF-8"?>');
  lines.push(
    `<testsuites name="${xmlEscape(moduleTitle)}" tests="${summary.total}" failures="${summary.failed}">`,
  );

  for (const [defName, results] of groups) {
    const suiteFailed = results.filter((r) => !r.pass).length;
    lines.push(
      `  <testsuite name="${xmlEscape(defName)}" tests="${results.length}" failures="${suiteFailed}">`,
    );

    for (const result of results) {
      const caseName = buildTestCaseName(result);
      if (result.pass) {
        lines.push(
          `    <testcase classname="${xmlEscape(defName)}" name="${xmlEscape(caseName)}"/>`,
        );
      } else {
        const failureType = result.error ? "ERROR" : "FAILURE";
        const message = buildFailureMessage(result);
        lines.push(
          `    <testcase classname="${xmlEscape(defName)}" name="${xmlEscape(caseName)}">`,
        );
        lines.push(
          `      <failure type="${failureType}" message="${xmlEscape(message)}">${xmlEscape(message)}</failure>`,
        );
        lines.push(`    </testcase>`);
      }
    }

    lines.push(`  </testsuite>`);
  }

  lines.push(`</testsuites>`);
  return lines.join("\n");
}
