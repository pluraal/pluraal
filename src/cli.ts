#!/usr/bin/env node
import { Command } from "commander";
import { resolve } from "node:path";
import { writeFile } from "node:fs/promises";
import { parseUserModule } from "./parse.js";
import { Interpreter } from "./interpreter.js";
import { runTests, formatSummary } from "./test-runner.js";
import { formatJUnit } from "./junit-reporter.js";

const program = new Command();

program
  .name("pluraal")
  .description("Interpreter and test runner for Pluraal user modules")
  .version("0.1.0");

// ---------------------------------------------------------------------------
// `test` command
// ---------------------------------------------------------------------------

program
  .command("test <file>")
  .description("Run all test cases defined in a user module markdown file")
  .option(
    "-d, --definition <names...>",
    "Only run tests for these definition names",
  )
  .option("-v, --verbose", "Show passing test cases too", false)
  .option("-r, --reporter <format>", "Output format: text or junit", "text")
  .option("-o, --output <file>", "Write output to a file instead of stdout")
  .action(
    async (
      file: string,
      opts: {
        definition?: string[];
        verbose: boolean;
        reporter: string;
        output?: string;
      },
    ) => {
      const filePath = resolve(process.cwd(), file);

      let module;
      try {
        module = await parseUserModule(filePath);
      } catch (err) {
        console.error(
          `Failed to parse "${filePath}": ${err instanceof Error ? err.message : err}`,
        );
        process.exit(1);
      }

      const summary = runTests(module, { only: opts.definition });

      let output: string;
      const reporter = opts.reporter.toLowerCase();

      if (reporter === "junit") {
        output = formatJUnit(module.title, summary);
      } else if (reporter === "text") {
        output = `Testing: ${module.title}\n\n${formatSummary(summary, opts.verbose)}`;
      } else {
        console.error(
          `Unknown reporter: "${opts.reporter}". Supported: text, junit`,
        );
        process.exit(1);
      }

      if (opts.output) {
        const outPath = resolve(process.cwd(), opts.output);
        await writeFile(outPath, output, "utf8");
        console.log(`Report written to ${outPath}`);
      } else {
        console.log(output);
      }

      if (summary.failed > 0) process.exit(1);
    },
  );

// ---------------------------------------------------------------------------
// `eval` command
// ---------------------------------------------------------------------------

program
  .command("eval <file> <definition>")
  .description("Evaluate a single definition with given inputs")
  .option(
    "-i, --input <pairs...>",
    "Input values as key=value pairs (e.g. --input unit_price=10 quantity=3)",
  )
  .action(
    async (
      file: string,
      definitionName: string,
      opts: { input?: string[] },
    ) => {
      const filePath = resolve(process.cwd(), file);

      let module;
      try {
        module = await parseUserModule(filePath);
      } catch (err) {
        console.error(
          `Failed to parse "${filePath}": ${err instanceof Error ? err.message : err}`,
        );
        process.exit(1);
      }

      // Parse --input key=value pairs
      const inputs: Record<string, number | boolean | string> = {};
      for (const pair of opts.input ?? []) {
        const eq = pair.indexOf("=");
        if (eq === -1) {
          console.error(`Invalid input pair (expected key=value): "${pair}"`);
          process.exit(1);
        }
        const key = pair.slice(0, eq);
        const raw = pair.slice(eq + 1);
        if (raw === "true") inputs[key] = true;
        else if (raw === "false") inputs[key] = false;
        else {
          const num = Number(raw);
          inputs[key] = isNaN(num) ? raw : num;
        }
      }

      const interpreter = new Interpreter(module);
      try {
        const result = interpreter.evaluate(definitionName, inputs);
        const inputStr =
          Object.keys(inputs).length > 0
            ? " with " +
              Object.entries(inputs)
                .map(([k, v]) => `${k}=${v}`)
                .join(", ")
            : "";
        console.log(`${definitionName}${inputStr} = ${result}`);
      } catch (err) {
        console.error(`Error: ${err instanceof Error ? err.message : err}`);
        process.exit(1);
      }
    },
  );

// ---------------------------------------------------------------------------
// `list` command
// ---------------------------------------------------------------------------

program
  .command("list <file>")
  .description("List all definitions in a user module")
  .action(async (file: string) => {
    const filePath = resolve(process.cwd(), file);

    let module;
    try {
      module = await parseUserModule(filePath);
    } catch (err) {
      console.error(
        `Failed to parse "${filePath}": ${err instanceof Error ? err.message : err}`,
      );
      process.exit(1);
    }

    console.log(`Module: ${module.title}`);
    if (module.inputs.length > 0) {
      console.log(`\nInputs: ${module.inputs.join(", ")}`);
    }
    console.log(`\nDefinitions (${module.definitions.length}):`);
    for (const def of module.definitions) {
      const caseCount = def.testCases.length;
      const cases = caseCount === 1 ? "1 test case" : `${caseCount} test cases`;
      console.log(`  ${def.name}  (${cases})`);
    }
  });

program.parse(process.argv);
