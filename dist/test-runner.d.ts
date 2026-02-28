import type { UserModule, TestResult } from "./types.js";
export interface RunOptions {
    /** Only run tests for these definition names (all if empty). */
    only?: string[];
}
export interface RunSummary {
    total: number;
    passed: number;
    failed: number;
    results: TestResult[];
}
export declare function runTests(module: UserModule, options?: RunOptions): RunSummary;
export declare function formatSummary(summary: RunSummary, verbose: boolean): string;
//# sourceMappingURL=test-runner.d.ts.map