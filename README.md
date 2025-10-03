# Author: Ankit Kumar

# How to run:

1. sbcl --load simplifier.lisp
   This will run the simplifier on test cases, and generate a file called proveme.lisp on those same test cases.
2. acl2s < proveme.lisp
   This will prove that each of the test cases test equivalent propositional formulae.

# Approach

1. I initially used x-ai/grok-code-fast-1 to generate a simplifier.
   This first sample had several issues. First of all, parens were not matching and  
   it was not able to fix it.
2. I then asked it again to generate the solution one form at a time by using sbcl to check
   if each form is accepted. This gave me something that was interpreted by sbcl.
3. Then I asked Gemini to review this code. Gemini found an issue that simplify is not a recursive
   function, and it fixed it.
4. Finally I asked Claude 4.5 with Thinking to review this code. Claude had a lot to say about it.
   Here's my prompt to Claude:

```
Here is my homework to use llms to write a simplifier:


Provide code that creates an executable. You can use any language. If you're not familiar with lisp, go ahead and use that. SBCL is a good option. If you want to use another language, use one that you are not an expert it. The executable should take as input a file with a propositional formula and should simplify it as per the instructions below. The simplified formula should be written to an output file.
4.  We have a list of the propositional operators and information about them.
:arity can be a positive integer or - (meaning arbitrary arity) If :arity is -, there must be an identity and the function must be associative and commutative.
If :identity is non-nil, then the operator has the indicated identity.    An operator is idempotent iff :idem is t.
If :sink is not -, then it must be the case that (op ... sink ...) = sink, e.g., (and ... nil ...) = nil.
  '((and     :arity - :identity t   :idem t   :sink nil)     (or      :arity - :identity nil :idem t   :sink t)     (not     :arity 1 :identity -   :idem nil :sink -)     (implies :arity 2 :identity -   :idem nil :sink -)     (iff     :arity - :identity t   :idem nil :sink -)     (xor     :arity - :identity nil :idem nil :sink -)     (if      :arity 3 :identity -   :idem nil :sink -))   Here are some examples of propositional formulas.  Note that t, nil correspond to "true" and "false".  All other symbols correspond to variables.   (and) (and x y z) (and t nil) q (implies x y) (iff p q r s t) (xor p q r s t) (if (xor p r s) (iff q s r) t)
Define function, simplify that given a propositional formula returns an equivalent propositional formula with the following properties.
A. Flatten expressions, e.g.:
 (and p q (and r s) (or u v)) is not flat, but this is  (and p q r s (or u v))
 A formula of the form (op ...) where op is a Boolean operator of  arbitrary arity (ie, and, or, iff) applied to 0 or 1 arguments is not  flat. For example, replace (and) with t.
 A formula of the form (op ... (op ...)) where op is a Boolean  operator of arbitrary arity is not flat. For example, replace (and p  q (and r s)) with (and p q r s).
B. If there is Boolean constant s s.t. If (op ... s ...) = s, then we  say that s is a sink of op. For example t is a sink of or. A formula  is sink-free if no such subformulas remain. The returned formula  should be sink-free.
C. Simplify your formulas so that no subexpressions can be simplified  using any of the of the rules in chapter 3, section 3.3 of the  rap.pdf lecture notes. Note that there are 69 such rules. A  simplified formula is one of smaller size.
D. Make sure that your algorithm is efficient and well-documented.
E. You are not required to perform any other simplifications beyond  those specified above. If you do, your simplifier must be guaranteed  to always return something that is simpler that what would be  returned if you just implemented the simplifications explicitly  requested. Also, if you implement any other simplifications, your  algorithm must run in comparable time (eg, no validity checking).  Notice some simple consequences. You cannot transform the formula to  an equivalent formula that uses a small subset of the  connectives (such as not/and). If you do that, the formula you get  can be exponentially larger than the input formula, as we have  discussed in class. Notice that even negation normal form (NNF) can  increase the size of a formula.   F. Test your definition using at least 50 propositional formulas that  include all of the operators, deeply nested formulas, etc.

You need to read the attached rap.pdf. Now i am attaching my solution. Review and improve it with comments.
```

Claude's response:

```
Code Review: Propositional Formula Simplifier
Your implementation has a solid foundation, but there are several critical issues and areas for improvement. Let me provide a detailed analysis:
Critical Issues

1. Missing Executable Infrastructure
   The assignment requires an executable that reads from a file and writes to a file. Your code has no:

Main function
File I/O
Command-line argument parsing
Build/compilation instructions

2. Incomplete Rule Coverage
   The rap.pdf Section 3.3 lists 72 propositional equalities. Your apply-constant-rules only implements a small subset. Missing examples:

De Morgan's laws are partially in apply-negation-rules but not complete
Contrapositive: (p ⇒ q) ≡ (¬q ⇒ ¬p)
Exportation: (p ⇒ (q ⇒ r)) ≡ ((p ∧ q) ⇒ r)
Absorption laws: p ∧ (p ∨ q) ≡ p
Many distributivity rules
Redundancy laws
Shannon expansion applications

3. Order of Operations Bug
   Your simplify function:
   lisp(defun simplify (f)
   (apply-rules (flatten-formula (remove-sinks f))))
   This is problematic because:

Simplification might create new flattening opportunities
Sink removal before simplification might miss sinks created during simplification
Should iterate to a fixed point

4. Incomplete Recursive Application
   apply-implication-rules only works at the top level:
   lisp(defun apply-implication-rules (f)
   (cond
   ((and (consp f) (eq (car f) 'implies) (= (length f) 3))
   (list 'or (list 'not (second f)) (third f)))
   (t f)))
   This won't simplify (and (implies p q) r) properly.
5. Arbitrary-Arity Operators Not Fully Handled
   For iff and xor with arity -, your code only handles binary cases:
   lisp((and (eq op 'iff) (= (length args) 2)) ...)
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

I asked if Shannon is implemented, it said no. So, I asked it to include that as well.

5. Now, for verification, I gave this prompt to Claude:

```
write a function that will generate, for each test case e.g.

(test-simplification shannon-1 (and p (or p q)) p)

a property form:
(property shannon-1 (p q :bool)
   (== (and p (or p q))
            p))

where p and q are the free variables in the test and shannon-1 is the name of the test.
Each of the generated property forms should  be written to a file: proveme.lisp
```

Claude generated the function but repeated the tests again. So then I asked:

```
tests are being written twice, for testing and verification. Let the tests be defined once as pairs of formulas and then use them . Update the file.
```

6. Finally I got the version I have in this repo.

Key improvements:

Single source of truth: _test-cases_ defines all tests once
Reusable: Same data used for testing AND property generation
Automatic variable extraction: Finds all free variables in formulas
Sorted variables: Alphabetical order for consistency
Clean output: Generates properly formatted proveme.lisp

# Observations:

1. Claude 4.5 with Think is so insanely awesome that I could have just 1 shotted this assignment.
2. I only needed to follow up twice:

(i) there was an error in one of the simplifying functions:
The error is in the apply-constant-propagation function. The bug is here:
lisp((apply #'all-equal non-t) t) ; WRONG - all-equal takes 1 list arg
Should be:
lisp((all-equal non-t) t) ; CORRECT

(ii) I asked it to have a single data for test cases that can be used for testing as well as for verification using ACL2s.

(iii) Claude understood by itself that proveme.lisp is for ACL2s.
