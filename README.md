# Propositional Formula Simplifier

**Author:** Ankit Kumar

## Table of Contents

- [Overview](#overview)
- [How to Run](#how-to-run)
- [Development Process](#development-process)
- [Implementation Highlights](#implementation-highlights)
- [What Claude Did Autonomously](#what-claude-did-autonomously)
- [Observations](#observations)
- [Appendix: Claude Interaction](#appendix-claude-interaction)

## Overview

This project implements a propositional formula simplifier in Common Lisp using SBCL. The simplifier flattens expressions, removes sinks, applies logical equivalences, and ensures the output is logically equivalent to the input. It includes formal verification using ACL2s and supports building an executable for file-based processing.

## How to Run

### Test and Generate Verification File

Run the simplifier on test cases and generate `proveme.lisp` with ACL2s properties:

```bash
sbcl --load simplifier.lisp
```

### Formally Verify with ACL2s

Prove that each test case maintains logical equivalence:

```bash
acl2s < proveme.lisp
```

### Build Executable

Create a standalone executable that reads from an input file and writes simplified output to an output file:

```bash
sbcl --load simplifier.lisp --eval '(sb-ext:save-lisp-and-die "simplify" :toplevel #'"toplevel :executable t)'
./simplify input.txt output.txt
```

## Development Process

The development involved iterative refinement using multiple LLMs, with Claude 4.5 providing the most comprehensive improvements.

### Initial Attempts

1. **x-ai/grok-code-fast-1**: Generated initial simplifier code, but had issues with unmatched parentheses and inability to self-correct.

2. **Iterative Generation**: Prompted the model to generate code one form at a time, validating each with SBCL, resulting in interpretable code.

3. **Gemini Review**: Identified that the `simplify` function was not recursive and fixed it.

### Claude 4.5 Integration

Consulted Claude 4.5 with Thinking for a thorough review. The interaction revealed several critical issues and led to significant improvements.

### Verification Setup

Developed a system to generate ACL2s properties from test cases, ensuring single-source-of-truth for both testing and formal verification.

### Final Refinements

- Fixed bugs in simplification functions (e.g., `apply-constant-propagation`).
- Consolidated test cases for reuse in testing and verification.
- Achieved comprehensive rule coverage and efficient implementation.

## Implementation Highlights

- **Single Source of Truth**: `_test-cases_` defines all tests once, used for both testing and ACL2s verification.
- **Automatic Variable Extraction**: Finds free variables in formulas for property generation.
- **Fixed-Point Iteration**: Applies simplifications until no further changes occur.
- **Modular Architecture**: Separate phases for flattening, sink removal, idempotence, and rule application.
- **Comprehensive Testing**: 100+ test cases covering all operators and complex nesting.
- **Complete Rule Coverage**: Implements all 72 rules from rap.pdf Section 3.3.

## What Claude Did Autonomously

- Implemented all 72 simplification rules systematically.
- Added Shannon expansion with proper substitution semantics.
- Created property-based verification compatible with ACL2s.
- Designed an efficient algorithm with fixed-point detection.
- Generated executable build instructions for SBCL.
- Understood the distinction between concrete testing and formal verification.

## Observations

1. **Claude 4.5 Superiority**: Claude 4.5 with Thinking could potentially complete the assignment in just 3 interactions, demonstrating advanced understanding and implementation capabilities.

2. **Minimal Follow-ups**: Only required two follow-up prompts to Claude:

   - Fix a bug in `apply-constant-propagation` (incorrect function call).
   - Consolidate test cases for dual use in testing and verification.

3. **Autonomous Understanding**: Claude independently recognized ACL2s compatibility for `proveme.lisp`.

4. **LLM Ranking**: Based on performance: x-ai/grok-code-fast-1 < Google Gemini Agent < Claude 4.5 with Thinking.

## Appendix: Claude Interaction

### Prompt to Claude

```
Here is my homework to use LLMs to write a simplifier:

Provide code that creates an executable. You can use any language. If you're not familiar with lisp, go ahead and use that. SBCL is a good option. If you want to use another language, use one that you are not an expert in. The executable should take as input a file with a propositional formula and should simplify it as per the instructions below. The simplified formula should be written to an output file.

[Full prompt content with operators, examples, and requirements...]
```

### Claude's Response

```
Code Review: Propositional Formula Simplifier
Your implementation has a solid foundation, but there are several critical issues and areas for improvement. Let me provide a detailed analysis:

Critical Issues

1. Missing Executable Infrastructure
   The assignment requires an executable that reads from a file and writes to a file. Your code has no:
   - Main function
   - File I/O
   - Command-line argument parsing
   - Build/compilation instructions

2. Incomplete Rule Coverage
   The rap.pdf Section 3.3 lists 72 propositional equalities. Your apply-constant-rules only implements a small subset. Missing examples:
   - De Morgan's laws are partially in apply-negation-rules but not complete
   - Contrapositive: (p ⇒ q) ≡ (¬q ⇒ ¬p)
   - Exportation: (p ⇒ (q ⇒ r)) ≡ ((p ∧ q) ⇒ r)
   - Absorption laws: p ∧ (p ∨ q) ≡ p
   - Many distributivity rules
   - Redundancy laws
   - Shannon expansion applications

3. Order of Operations Bug
   Your simplify function:
   (defun simplify (f)
     (apply-rules (flatten-formula (remove-sinks f))))
   This is problematic because:
   - Simplification might create new flattening opportunities
   - Sink removal before simplification might miss sinks created during simplification
   - Should iterate to a fixed point

4. Incomplete Recursive Application
   apply-implication-rules only works at the top level:
   (defun apply-implication-rules (f)
     (cond
       ((and (consp f) (eq (car f) 'implies) (= (length f) 3))
        (list 'or (list 'not (second f)) (third f)))
       (t f)))
   This won't simplify (and (implies p q) r) properly.

5. Arbitrary-Arity Operators Not Fully Handled
   For iff and xor with arity -, your code only handles binary cases:
   ((and (eq op 'iff) (= (length args) 2)) ...)
   ((and (eq op 'xor) (= (length args) 2)) ...)
   But (iff p q r s) is valid according to your spec.

6. No Documentation
   Zero comments explaining the algorithm, complexity, or design decisions.

7. No Tests
   The assignment requires 50+ test cases. You have none.

Improved Implementation Structure
Here's a better architectural approach:
....

Your code shows understanding of the core concepts, but lacks the completeness, documentation, and infrastructure required by the assignment. Focus on implementing the missing 60+ simplification rules systematically and creating the executable wrapper.
```

_Note: The full response and subsequent follow-ups have been summarized for brevity. The complete interaction led to the final implementation._
