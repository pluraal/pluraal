/** A runtime value: a number, boolean, or ordering relation member. */
export type Value = number | boolean | string;

/** An expression node in the AST produced by parsing a user module. */
export type Expr =
  | { kind: "literal"; value: Value }
  | { kind: "var"; name: string }
  | { kind: "call"; op: string; args: Expr[] };

/** A single test case row: named inputs and the expected output value. */
export interface TestCase {
  inputs: Record<string, Value>;
  expected: Value;
}

/** A named definition inside a user module: its expression and test cases. */
export interface Definition {
  name: string;
  expr: Expr;
  testCases: TestCase[];
}

/** A parsed user module file. */
export interface UserModule {
  title: string;
  inputs: string[];
  definitions: Definition[];
}

/** Result of evaluating one test case against the interpreter. */
export interface TestResult {
  definitionName: string;
  caseIndex: number;
  inputs: Record<string, Value>;
  expected: Value;
  actual: Value;
  pass: boolean;
  error?: string;
}
