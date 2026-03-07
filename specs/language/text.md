# Text

## Overview

Text represents a finite sequence of characters. It is the standard type for identifiers, labels, and descriptive data in relational models — analogous to `VARCHAR` in SQL and `String` / `Utf8` in Spark and Polars.

## Operations

### Concatenate

_[Required][req]._ Returns a new Text formed by appending the second operand to the end of the first.

#### Test cases

| a       | b       | Output    |
| ------- | ------- | --------- |
| "hello" | " world"| "hello world" |
| ""      | "abc"   | "abc"     |
| "abc"   | ""      | "abc"     |
| ""      | ""      | ""        |

### Length

_[Required][req]._ Returns the number of characters in the Text as an [Integer][int].

#### Test cases

| Text    | Output |
| ------- | ------ |
| "hello" | 5      |
| ""      | 0      |
| "a b c" | 5      |

### Contains

_[Required][req]._ Returns [Boolean][bool] `true` when the given substring appears anywhere within the Text.

#### Test cases

| Text        | Substring | Output |
| ----------- | --------- | ------ |
| "abcdef"    | "cde"     | true   |
| "abcdef"    | "xyz"     | false  |
| "abcdef"    | ""        | true   |
| ""          | "a"       | false  |

### Starts With

_[Required][req]._ Returns [Boolean][bool] `true` when the Text begins with the given prefix.

#### Test cases

| Text    | Prefix  | Output |
| ------- | ------- | ------ |
| "hello" | "hel"   | true   |
| "hello" | "ell"   | false  |
| "hello" | ""      | true   |
| ""      | "a"     | false  |

### Ends With

_[Required][req]._ Returns [Boolean][bool] `true` when the Text ends with the given suffix.

#### Test cases

| Text    | Suffix  | Output |
| ------- | ------- | ------ |
| "hello" | "llo"   | true   |
| "hello" | "ell"   | false  |
| "hello" | ""      | true   |
| ""      | "a"     | false  |

### Upper

_[Required][req]._ Returns a new Text with all characters converted to uppercase.

#### Test cases

| Text    | Output  |
| ------- | ------- |
| "hello" | "HELLO" |
| "Hello" | "HELLO" |
| "ABC"   | "ABC"   |
| ""      | ""      |

### Lower

_[Required][req]._ Returns a new Text with all characters converted to lowercase.

#### Test cases

| Text    | Output  |
| ------- | ------- |
| "HELLO" | "hello" |
| "Hello" | "hello" |
| "abc"   | "abc"   |
| ""      | ""      |

### Trim

_[Required][req]._ Returns a new Text with leading and trailing whitespace removed.

#### Test cases

| Text      | Output  |
| --------- | ------- |
| "  hi  "  | "hi"    |
| "hi"      | "hi"    |
| "  "      | ""      |
| ""        | ""      |

### Substring

_[Required][req]._ Returns the portion of the Text starting at a zero-based start index up to but not including an end index. Precondition: start and end indices are within bounds and start ≤ end.

#### Test cases

| Text    | Start | End | Output |
| ------- | ----- | --- | ------ |
| "hello" | 0     | 5   | "hello"|
| "hello" | 1     | 4   | "ell"  |
| "hello" | 0     | 0   | ""     |
| "hello" | 2     | 3   | "l"    |

### Replace

_[Required][req]._ Returns a new Text with all occurrences of a target substring replaced by a replacement string.

#### Test cases

| Text         | Target | Replacement | Output       |
| ------------ | ------ | ----------- | ------------ |
| "aabbcc"     | "bb"   | "XX"        | "aaXXcc"     |
| "aaa"        | "a"    | "b"         | "bbb"        |
| "hello"      | "xyz"  | "!"         | "hello"      |
| ""           | "a"    | "b"         | ""           |

## Type Class Instances

### Equality

Two Text values are [Equal][eq-equal] when they contain the same sequence of characters.

### Ordering

Text values are ordered lexicographically by character code point. [Compare](ordering.md#compare) returns [Less](ordering-relation.md#less) when the first differing character has a smaller code point, [Greater](ordering-relation.md#greater) when it has a larger code point, and [Equal](ordering-relation.md#equal) when both sequences are identical.

[bool]: boolean.md
[eq-equal]: equality.md#equal
[int]: integer.md
[req]: ../language.md#required
