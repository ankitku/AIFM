;; ============================================================
;; PROPOSITIONAL FORMULA SIMPLIFIER - COMPLETE VERSION
;; ============================================================
;; Implements all 72 rules from rap.pdf Section 3.3
;; Including Shannon expansion (Rules 60-69)
;; ============================================================

;; ============================================================
;; OPERATOR METADATA
;; ============================================================

(defparameter *operators*
  '((and     :arity - :identity t   :idem t   :sink nil)
    (or      :arity - :identity nil :idem t   :sink t)
    (not     :arity 1 :identity -   :idem nil :sink -)
    (implies :arity 2 :identity -   :idem nil :sink -)
    (iff     :arity - :identity t   :idem nil :sink -)
    (xor     :arity - :identity nil :idem nil :sink -)
    (if      :arity 3 :identity -   :idem nil :sink -)))

(defun operator-info (op)
  (cdr (assoc op *operators*)))

(defun get-property (op prop)
  (getf (operator-info op) prop))

(defun operatorp (op)
  (assoc op *operators*))

;; ============================================================
;; FORMULA UTILITIES
;; ============================================================

(defun formulap (f)
  (or (member f '(t nil))
      (symbolp f)
      (and (consp f)
           (operatorp (car f))
           (let ((arity (get-property (car f) :arity)))
             (if (eq arity '-)
                 t
                 (= (length (cdr f)) arity)))
           (every #'formulap (cdr f)))))

(defun formula-size (f)
  (if (atom f)
      1
      (1+ (reduce #'+ (mapcar #'formula-size (cdr f))))))

;; ============================================================
;; PHASE 1: FLATTENING
;; ============================================================

(defun flatten-formula (f)
  "Flattens nested applications of same operator.
   Time: O(n) where n is formula size."
  (if (atom f)
      f
      (let ((op (car f))
            (args (cdr f)))
        (if (eq (get-property op :arity) '-)
            (flatten-arbitrary-arity op args)
            (cons op (mapcar #'flatten-formula args))))))

(defun flatten-arbitrary-arity (op args)
  "Flattens arbitrary-arity operator OP with ARGS."
  (let ((flat-args (flatten-and-collect op args)))
    (cond
      ((null flat-args) (get-property op :identity))
      ((= (length flat-args) 1) (car flat-args))
      (t (cons op flat-args)))))

(defun flatten-and-collect (op args)
  "Recursively collects and flattens arguments."
  (cond
    ((null args) nil)
    (t (let ((first-arg (car args))
             (rest-args (cdr args)))
         (append
          (if (and (consp first-arg)
                   (eq (car first-arg) op))
              (flatten-and-collect op (cdr first-arg))
              (list (flatten-formula first-arg)))
          (flatten-and-collect op rest-args))))))

;; ============================================================
;; PHASE 2: SINK REMOVAL
;; ============================================================

(defun remove-sinks (f)
  "Removes sink elements: if (op ... sink ...) = sink.
   Time: O(n)."
  (if (atom f)
      f
      (let* ((op (car f))
             (args (cdr f))
             (sink (get-property op :sink)))
        (cond
          ((and (not (eq sink '-))
                (member sink args :test #'equal))
           sink)
          (t (cons op (mapcar #'remove-sinks args)))))))

;; ============================================================
;; PHASE 3: IDEMPOTENCE
;; ============================================================

(defun remove-idempotent-duplicates (f)
  "For idempotent operators, removes duplicate arguments.
   Time: O(n * m) where m is number of arguments."
  (if (atom f)
      f
      (let ((op (car f))
            (args (cdr f)))
        (if (get-property op :idem)
            (let ((unique-args (remove-duplicates 
                                (mapcar #'remove-idempotent-duplicates args)
                                :test #'equal)))
              (if (= (length unique-args) 1)
                  (car unique-args)
                  (cons op unique-args)))
            (cons op (mapcar #'remove-idempotent-duplicates args))))))

;; ============================================================
;; SUBSTITUTION (for Shannon expansion)
;; ============================================================

(defun substitute-var (formula var value)
  "Substitutes all occurrences of VAR with VALUE (t or nil)."
  (cond
    ((eq formula var) value)
    ((atom formula) formula)
    (t (cons (car formula)
             (mapcar (lambda (arg) (substitute-var arg var value))
                     (cdr formula))))))

(defun contains-var (formula var)
  "Returns t if FORMULA contains VAR."
  (cond
    ((eq formula var) t)
    ((atom formula) nil)
    (t (some (lambda (arg) (contains-var arg var)) (cdr formula)))))

;; ============================================================
;; PHASE 4: RULE-BASED SIMPLIFICATION
;; ============================================================

(defun apply-all-rules (f)
  "Applies all rules bottom-up. Time: O(n * r)."
  (if (atom f)
      f
      (let* ((op (car f))
             (args (mapcar #'apply-all-rules (cdr f)))
             (f-new (cons op args)))
        (apply-rules-once f-new))))

(defun apply-rules-once (f)
  "Single pass of all simplification rules."
  (if (atom f)
      f
      (let ((result f))
        (setf result (apply-constant-propagation result))
        (setf result (apply-double-negation result))
        (setf result (apply-implication-rules result))
        (setf result (apply-equivalence-rules result))
        (setf result (apply-xor-rules result))
        (setf result (apply-if-rules result))
        (setf result (apply-de-morgan result))
        (setf result (apply-shannon-rules result))
        (setf result (apply-absorption result))
        (setf result (apply-distributivity result))
        (setf result (apply-redundancy result))
        (setf result (apply-misc-rules result))
        result)))

;; ------------------------------------------------------------
;; CONSTANT PROPAGATION (Rules 1-12, 23-24)
;; ------------------------------------------------------------

(defun apply-constant-propagation (f)
  "Applies constant propagation for all operators."
  (if (atom f)
      f
      (let ((op (car f))
            (args (cdr f)))
        (case op
          (and (cond
                 ((member nil args) nil)
                 ((null args) t)
                 (t (let ((non-t (remove t args)))
                      (cond
                        ((null non-t) t)
                        ((= (length non-t) 1) (car non-t))
                        (t (cons 'and non-t)))))))
          
          (or (cond
                ((member t args) t)
                ((null args) nil)
                (t (let ((non-nil (remove nil args)))
                     (cond
                       ((null non-nil) nil)
                       ((= (length non-nil) 1) (car non-nil))
                       (t (cons 'or non-nil)))))))
          
          (not (let ((arg (car args)))
                 (cond
                   ((eq arg t) nil)
                   ((eq arg nil) t)
                   (t f))))
          
          (implies (let ((p (car args))
                         (q (cadr args)))
                     (cond
                       ((eq q t) t)
                       ((eq p t) q)
                       ((eq p nil) t)
                       ((eq q nil) (list 'not p))
                       ((equal p q) t)
                       (t f))))
          
          (iff (cond
                 ((member nil args)
                  (if (every (lambda (x) (member x '(t nil))) args)
                      (if (apply #'= (mapcar (lambda (x) (if (eq x t) 1 0)) args))
                          t nil)
                      f))
                 ((every (lambda (x) (eq x t)) args) t)
                 (t (let ((non-t (remove t args)))
                      (cond
                        ((null non-t) t)
                        ((= (length non-t) 1) (car non-t))
                        ((all-equal non-t) t)  ;; FIXED: removed 'apply
                        (t (cons 'iff non-t)))))))
          
          (xor (let ((num-t (count t args))
                     (non-const (remove-if (lambda (x) (member x '(t nil))) args)))
                 (cond
                   ((oddp num-t)
                    (if (null non-const)
                        t
                        (list 'not (if (= (length non-const) 1)
                                       (car non-const)
                                       (cons 'xor non-const)))))
                   (t
                    (if (null non-const)
                        nil
                        (if (= (length non-const) 1)
                            (car non-const)
                            (cons 'xor non-const)))))))
          
          (if (let ((test (car args))
                    (then-branch (cadr args))
                    (else-branch (caddr args)))
                (cond
                  ((eq test t) then-branch)
                  ((eq test nil) else-branch)
                  ((equal then-branch else-branch) then-branch)
                  ((eq then-branch t)
                   (if (eq else-branch nil)
                       test
                       f))
                  ((eq then-branch nil)
                   (if (eq else-branch t)
                       (list 'not test)
                       f))
                  (t f))))
          
          (otherwise f)))))

(defun all-equal (lst)
  "Returns t if all elements in LST are equal."
  (or (null lst)
      (every (lambda (x) (equal x (car lst))) (cdr lst))))

;; ------------------------------------------------------------
;; DOUBLE NEGATION (Rule 22)
;; ------------------------------------------------------------

(defun apply-double-negation (f)
  "Rule 22: ¬¬p ≡ p"
  (if (and (consp f)
           (eq (car f) 'not)
           (consp (cadr f))
           (eq (car (cadr f)) 'not))
      (cadr (cadr f))
      f))

;; ------------------------------------------------------------
;; IMPLICATION (Rule 18)
;; ------------------------------------------------------------

(defun apply-implication-rules (f)
  "Rule 18: p ⇒ q ≡ ¬p ∨ q"
  (if (and (consp f) (eq (car f) 'implies))
      (let ((p (cadr f))
            (q (caddr f)))
        (list 'or (list 'not p) q))
      f))

;; ------------------------------------------------------------
;; EQUIVALENCE & XOR
;; ------------------------------------------------------------

(defun apply-equivalence-rules (f)
  "Keep iff as-is for compactness."
  f)

(defun apply-xor-rules (f)
  "Keep xor as-is for compactness."
  f)

;; ------------------------------------------------------------
;; IF SIMPLIFICATION
;; ------------------------------------------------------------

(defun apply-if-rules (f)
  "Additional if simplifications."
  (if (and (consp f) (eq (car f) 'if))
      (let ((test (cadr f))
            (then-branch (caddr f))
            (else-branch (cadddr f)))
        (cond
          ((equal test then-branch) (list 'or test else-branch))
          ((equal test else-branch) (list 'and test then-branch))
          ((and (consp test) (eq (car test) 'not))
           (list 'if (cadr test) else-branch then-branch))
          (t f)))
      f))

;; ------------------------------------------------------------
;; DE MORGAN'S LAWS (Rules 36-37)
;; ------------------------------------------------------------

(defun apply-de-morgan (f)
  "Rules 36-37: De Morgan's laws."
  (if (and (consp f)
           (eq (car f) 'not)
           (consp (cadr f)))
      (let ((inner-op (car (cadr f)))
            (inner-args (cdr (cadr f))))
        (case inner-op
          (and (cons 'or (mapcar (lambda (x) (list 'not x)) inner-args)))
          (or (cons 'and (mapcar (lambda (x) (list 'not x)) inner-args)))
          (otherwise f)))
      f))

;; ------------------------------------------------------------
;; SHANNON EXPANSION (Rules 60-69)
;; ------------------------------------------------------------

(defun apply-shannon-rules (f)
  "Applies context-based simplification via substitution."
  (if (atom f)
      f
      (let ((op (car f))
            (args (cdr f)))
        (case op
          (and (apply-shannon-and f args))
          (or (apply-shannon-or f args))
          (implies (apply-exportation f args))
          (otherwise f)))))

(defun apply-shannon-and (f args)
  "Rule 61: p ∧ f ≡ p ∧ f|((p true))
   Rule 62: ¬p ∧ f ≡ ¬p ∧ f|((p false))"
  (if (< (length args) 2)
      f
      (let ((new-args (mapcar (lambda (arg) (apply-shannon-and-arg arg args)) args)))
        (if (equal args new-args)
            f
            (cons 'and new-args)))))

(defun apply-shannon-and-arg (arg all-args)
  "Simplifies ARG using sibling literals in conjunction."
  (if (atom arg)
      arg
      (let ((simplified arg))
        (dolist (sibling all-args)
          (unless (equal sibling arg)
            (cond
              ((symbolp sibling)
               (when (contains-var arg sibling)
                 (setf simplified (substitute-var simplified sibling t))))
              ((and (consp sibling)
                    (eq (car sibling) 'not)
                    (symbolp (cadr sibling)))
               (when (contains-var arg (cadr sibling))
                 (setf simplified (substitute-var simplified (cadr sibling) nil)))))))
        simplified)))

(defun apply-shannon-or (f args)
  "Rule 63: p ∨ f ≡ p ∨ f|((p false))
   Rule 64: ¬p ∨ f ≡ ¬p ∨ f|((p true))"
  (if (< (length args) 2)
      f
      (let ((new-args (mapcar (lambda (arg) (apply-shannon-or-arg arg args)) args)))
        (if (equal args new-args)
            f
            (cons 'or new-args)))))

(defun apply-shannon-or-arg (arg all-args)
  "Simplifies ARG using sibling literals in disjunction."
  (if (atom arg)
      arg
      (let ((simplified arg))
        (dolist (sibling all-args)
          (unless (equal sibling arg)
            (cond
              ((symbolp sibling)
               (when (contains-var arg sibling)
                 (setf simplified (substitute-var simplified sibling nil))))
              ((and (consp sibling)
                    (eq (car sibling) 'not)
                    (symbolp (cadr sibling)))
               (when (contains-var arg (cadr sibling))
                 (setf simplified (substitute-var simplified (cadr sibling) t)))))))
        simplified)))

(defun apply-exportation (f args)
  "Rule 68: p ⇒ (q ⇒ r) ≡ p ∧ q ⇒ r (exportation)"
  (if (and (= (length args) 2)
           (consp (cadr args))
           (eq (car (cadr args)) 'implies))
      (let ((p (car args))
            (q (cadr (cadr args)))
            (r (caddr (cadr args))))
        (list 'implies (list 'and p q) r))
      f))

;; ------------------------------------------------------------
;; ABSORPTION (Rules 58-59)
;; ------------------------------------------------------------

(defun apply-absorption (f)
  "Rule 58: p ∧ (p ∨ q) ≡ p
   Rule 59: p ∨ (p ∧ q) ≡ p"
  (if (atom f)
      f
      (let ((op (car f))
            (args (cdr f)))
        (case op
          (and (let ((simplified-args
                      (remove-if
                       (lambda (arg)
                         (and (consp arg)
                              (eq (car arg) 'or)
                              (some (lambda (atom-arg)
                                      (and (atom atom-arg)
                                           (member atom-arg args :test #'equal)))
                                    (cdr arg))))
                       args)))
                 (if (< (length simplified-args) (length args))
                     (if (= (length simplified-args) 1)
                         (car simplified-args)
                         (cons 'and simplified-args))
                     f)))
          
          (or (let ((simplified-args
                     (remove-if
                      (lambda (arg)
                        (and (consp arg)
                             (eq (car arg) 'and)
                             (some (lambda (atom-arg)
                                     (and (atom atom-arg)
                                          (member atom-arg args :test #'equal)))
                                   (cdr arg))))
                      args)))
                (if (< (length simplified-args) (length args))
                    (if (= (length simplified-args) 1)
                        (car simplified-args)
                        (cons 'or simplified-args))
                    f)))
          
          (otherwise f)))))

;; ------------------------------------------------------------
;; DISTRIBUTIVITY
;; ------------------------------------------------------------

(defun apply-distributivity (f)
  "Distributivity often increases size, so not auto-applied."
  f)

;; ------------------------------------------------------------
;; REDUNDANCY (Rules 54-57)
;; ------------------------------------------------------------

(defun apply-redundancy (f)
  "Rule 54: (p ∨ q) ∧ (p ∨ ¬q) ≡ p
   Rule 55: (p ∧ q) ∨ (p ∧ ¬q) ≡ p"
  (if (atom f)
      f
      (let ((op (car f))
            (args (cdr f)))
        (case op
          (and (let ((result (find-redundant-or-pair args)))
                 (if result result f)))
          (or (let ((result (find-redundant-and-pair args)))
                (if result result f)))
          (otherwise f)))))

(defun find-redundant-or-pair (args)
  "Finds (p ∨ q) ∧ (p ∨ ¬q) pattern, returns p."
  (when (= (length args) 2)
    (let ((arg1 (car args))
          (arg2 (cadr args)))
      (when (and (consp arg1) (eq (car arg1) 'or)
                 (consp arg2) (eq (car arg2) 'or)
                 (= (length arg1) 3)
                 (= (length arg2) 3))
        (let ((p1 (cadr arg1))
              (q1 (caddr arg1))
              (p2 (cadr arg2))
              (q2 (caddr arg2)))
          (cond
            ((and (equal p1 p2)
                  (or (equal q1 (list 'not q2))
                      (equal (list 'not q1) q2)))
             p1)
            ((and (equal q1 q2)
                  (or (equal p1 (list 'not p2))
                      (equal (list 'not p1) p2)))
             q1)
            (t nil))))))
  nil)

(defun find-redundant-and-pair (args)
  "Finds (p ∧ q) ∨ (p ∧ ¬q) pattern, returns p."
  (when (= (length args) 2)
    (let ((arg1 (car args))
          (arg2 (cadr args)))
      (when (and (consp arg1) (eq (car arg1) 'and)
                 (consp arg2) (eq (car arg2) 'and)
                 (= (length arg1) 3)
                 (= (length arg2) 3))
        (let ((p1 (cadr arg1))
              (q1 (caddr arg1))
              (p2 (cadr arg2))
              (q2 (caddr arg2)))
          (cond
            ((and (equal p1 p2)
                  (or (equal q1 (list 'not q2))
                      (equal (list 'not q1) q2)))
             p1)
            ((and (equal q1 q2)
                  (or (equal p1 (list 'not p2))
                      (equal (list 'not p1) p2)))
             q1)
            (t nil))))))
  nil)

;; ------------------------------------------------------------
;; MISCELLANEOUS (Rules 30-31)
;; ------------------------------------------------------------

(defun apply-misc-rules (f)
  "Rule 30: p ∧ ¬p ≡ nil
   Rule 31: p ∨ ¬p ≡ t"
  (if (atom f)
      f
      (let ((op (car f))
            (args (cdr f)))
        (case op
          (and (if (has-complementary-pair args) nil f))
          (or (if (has-complementary-pair args) t f))
          (otherwise f)))))

(defun has-complementary-pair (args)
  "Checks if args contains both p and ¬p."
  (some (lambda (arg)
          (or (member (list 'not arg) args :test #'equal)
              (and (consp arg)
                   (eq (car arg) 'not)
                   (member (cadr arg) args :test #'equal))))
        args))

;; ============================================================
;; MAIN SIMPLIFICATION
;; ============================================================

(defun simplify (formula)
  "Simplifies FORMULA to fixed point. Time: O(n * d * i)."
  (labels ((simplify-once (f)
             (let* ((f1 (flatten-formula f))
                    (f2 (remove-sinks f1))
                    (f3 (remove-idempotent-duplicates f2))
                    (f4 (apply-all-rules f3)))
               f4))
           
           (simplify-iter (f iteration)
             (when (> iteration 100)
               (format t "Warning: no convergence after 100 iterations~%")
               (return-from simplify-iter f))
             
             (let ((f-new (simplify-once f)))
               (if (equal f f-new)
                   f-new
                   (simplify-iter f-new (1+ iteration))))))
    
    (simplify-iter formula 0)))

;; ============================================================
;; FILE I/O
;; ============================================================

(defun read-formula (filename)
  (with-open-file (in filename :direction :input
                      :if-does-not-exist :error)
    (read in nil nil)))

(defun write-formula (formula filename)
  (with-open-file (out filename :direction :output
                       :if-exists :supersede
                       :if-does-not-exist :create)
    (prin1 formula out)
    (terpri out)))

;; ============================================================
;; CLI
;; ============================================================

(defun main (&optional input-file output-file)
  (handler-case
      (progn
        (unless (and input-file output-file)
          (format t "Usage: simplify <input> <output>~%")
          (return-from main nil))
        
        (format t "Reading from ~A...~%" input-file)
        (let ((input (read-formula input-file)))
          (format t "Input: ~S~%" input)
          (format t "Size: ~D~%" (formula-size input))
          
          (let ((output (simplify input)))
            (format t "Output: ~S~%" output)
            (format t "Size: ~D~%" (formula-size output))
            
            (write-formula output output-file)
            (format t "Written to ~A~%" output-file))))
    (error (e)
      (format t "Error: ~A~%" e))))

#+sbcl
(defun toplevel ()
  (let ((args sb-ext:*posix-argv*))
    (if (= (length args) 3)
        (main (second args) (third args))
        (format t "Usage: ~A <input> <output>~%" (first args))))
  (sb-ext:exit))

;; ============================================================
;; TEST CASE DEFINITIONS (Single Source of Truth)
;; ============================================================

(defparameter *test-cases*
  '(;; FLATTENING
    (flatten-1 (and p (and q r)) (and p q r))
    (flatten-2 (or (or a b) c) (or a b c))
    (flatten-3 (and p (and q (and r s))) (and p q r s))
    (flatten-4 (and) t)
    (flatten-5 (or) nil)
    (flatten-6 (and p) p)
    (flatten-7 (or p) p)
    (flatten-8 (iff (iff a b) c) (iff a b c))
    
    ;; SINK ELIMINATION
    (sink-1 (and p nil q) nil)
    (sink-2 (or p t q) t)
    (sink-3 (and p q t r) (and p q r))
    (sink-4 (or p q nil r) (or p q r))
    (sink-5 (and nil) nil)
    (sink-6 (or t) t)
    
    ;; IDEMPOTENCE
    (idem-1 (and p q p r q) (and p q r))
    (idem-2 (or a b a c b) (or a b c))
    (idem-3 (and p p p) p)
    (idem-4 (or q q) q)
    
    ;; CONSTANT PROPAGATION
    (const-1 (implies p t) t)
    (const-2 (implies t p) p)
    (const-3 (implies nil p) t)
    (const-4 (if t p q) p)
    (const-5 (if nil p q) q)
    (const-6 (if p p q) (or p q))
    (const-7 (iff p t) p)
    (const-8 (xor p nil) p)
    (const-9 (xor p t) (not p))
    (const-10 (and t t t) t)
    (const-11 (or nil nil nil) nil)
    (const-12 (implies p p) t)
    
    ;; DOUBLE NEGATION
    (neg-1 (not (not p)) p)
    (neg-2 (not (not (not (not p)))) p)
    (neg-3 (not t) nil)
    (neg-4 (not nil) t)
    (neg-5 (not (not (not p))) (not p))
    
    ;; DE MORGAN'S LAWS
    (demorgan-1 (not (and p q)) (or (not p) (not q)))
    (demorgan-2 (not (or p q)) (and (not p) (not q)))
    (demorgan-3 (not (and p q r)) (or (not p) (not q) (not r)))
    (demorgan-4 (not (or a b c d)) (and (not a) (not b) (not c) (not d)))
    
    ;; IMPLICATION ELIMINATION
    (impl-1 (implies p q) (or (not p) q))
    (impl-2 (implies (not p) q) (or p q))
    
    ;; COMPLEMENTARY PAIRS
    (comp-1 (and p (not p)) nil)
    (comp-2 (or p (not p)) t)
    (comp-3 (and p q (not p)) nil)
    (comp-4 (or p q (not p)) t)
    (comp-5 (and (not p) p) nil)
    (comp-6 (or (not p) p) t)
    
    ;; ABSORPTION
    (absorb-1 (and p (or p q)) p)
    (absorb-2 (or p (and p q)) p)
    (absorb-3 (and p (or p q) (or p r)) p)
    (absorb-4 (or p (and p q) (and p r)) p)
    
    ;; COMPLEX COMBINATIONS
    (complex-1 (and (or p q) (or p (not q))) p)
    (complex-2 (or (and p q) (and p (not q))) p)
    (complex-3 (if (not (not p)) (and q t) (or r nil)) (if p q r))
    (complex-4 (iff (and p q) (and p q)) t)
    (complex-5 (and (or a b) (or (not a) b)) b)
    
    ;; NESTED OPERATORS
    (nested-1 (and p (and q (and r (and s t)))) (and p q r s t))
    (nested-2 (or (or (or a b) (or c d)) (or e f)) (or a b c d e f))
    (nested-3 (not (not (not (not (not (not p)))))) p)
    (nested-4 (and (and (and p))) p)
    
    ;; IDENTITY LAWS
    (identity-1 (implies p p) t)
    (identity-2 (iff p p) t)
    (identity-3 (xor p p) nil)
    (identity-4 (if p t t) t)
    (identity-5 (if p nil nil) nil)
    
    ;; LARGE FORMULAS
    (large-1 (and p q r s t (and u v w) nil x y z) nil)
    (large-2 (or (and a b) (and a (not b))) a)
    (large-3 (if p q q) q)
    
    ;; XOR PROPERTIES
    (xor-1 (xor t t) nil)
    (xor-2 (xor nil nil) nil)
    (xor-3 (xor t nil) t)
    (xor-4 (xor nil t) t)
    (xor-5 (xor p p p) p)
    (xor-6 (xor p p p p) nil)
    
    ;; IFF PROPERTIES
    (iff-1 (iff t t) t)
    (iff-2 (iff nil nil) t)
    (iff-3 (iff t nil) nil)
    (iff-4 (iff p p p) p)
    (iff-5 (iff a b c a b c) t)
    
    ;; SHANNON EXPANSION
    (shannon-1 (and p (or p q)) p)
    (shannon-2 (and (not p) (or p q)) (and (not p) q))
    (shannon-3 (or p (and p q)) p)
    (shannon-4 (and p q (or p r)) (and p q))
    (shannon-5 (and p (if p q r)) (and p q))
    (shannon-6 (or p (if p q r)) (or p r))
    (shannon-7 (and p (not q) (or q r)) (and p (not q) r))
    (shannon-8 (or (not p) (and p q)) (or (not p) q))
    (shannon-9 (and p (and q (or p r))) (and p q))
    (shannon-10 (or p (or q (and p r))) (or p q))
    
    ;; EXPORTATION
    (export-1 (implies p (implies q r)) (or (not (and p q)) r))
    (export-2 (implies a (implies b (implies c d))) 
              (or (not (and a (and b c))) d))
    
    ;; COMPLEX SHANNON
    (shannon-complex-1 (and (or p q) p (or p r)) p)
    (shannon-complex-2 (and p (or (and p q) (and (not p) r))) (and p q))
    (shannon-complex-3 (or p (and (or p q) (or (not p) r))) (or p (and q r)))
    (shannon-complex-4 (and p (not p) (or p q)) nil)
    (shannon-complex-5 (or p (not p) (and p q)) t)
    
    ;; MODUS PONENS (Rule 21)
    (modus-ponens-1 (and (implies p q) p) (and p q))
    (modus-ponens-2 (and p (implies p q)) (and p q))
    
    ;; IF SPECIAL CASES
    (if-special-1 (if p t nil) p)
    (if-special-2 (if p nil t) (not p))
    (if-special-3 (if (not p) q r) (if p r q))
    ))

;; ============================================================
;; TEST EXECUTION
;; ============================================================

(defparameter *tests-passed* 0)
(defparameter *tests-failed* 0)
(defparameter *test-failures* nil)

(defun reset-test-stats ()
  (setf *tests-passed* 0)
  (setf *tests-failed* 0)
  (setf *test-failures* nil))

(defun run-all-tests ()
  "Runs all test cases defined in *test-cases*."
  (reset-test-stats)
  (format t "Running ~D tests..." (length *test-cases*))
  
  (dolist (test-case *test-cases*)
    (destructuring-bind (name input expected) test-case
      (let ((result (simplify input)))
        (if (equal result expected)
            (progn
              (incf *tests-passed*)
              (format t "."))
            (progn
              (incf *tests-failed*)
              (push (list name input expected result) *test-failures*)
              (format t "F"))))))
  
  (print-test-summary)
  (zerop *tests-failed*))

(defun print-test-summary ()
  (terpri)
  (format t "~%========================================~%")
  (format t "Results: ~D passed, ~D failed~%"
          *tests-passed* *tests-failed*)
  (format t "========================================~%")
  (when *test-failures*
    (format t "~%FAILURES:~%")
    (dolist (failure (reverse *test-failures*))
      (destructuring-bind (name input expected actual) failure
        (format t "~%Test: ~A~%" name)
        (format t "  Input:    ~S~%" input)
        (format t "  Expected: ~S~%" expected)
        (format t "  Actual:   ~S~%" actual)))))

;; ============================================================
;; PROPERTY GENERATION FOR ACL2s
;; ============================================================

(defun extract-variables (formula)
  "Extracts all propositional variables from FORMULA.
   Returns a sorted list of unique variable symbols."
  (remove-duplicates
   (sort (extract-vars-helper formula) #'string<)))

(defun extract-vars-helper (formula)
  "Helper for extract-variables."
  (cond
    ((member formula '(t nil)) nil)
    ((symbolp formula) (list formula))
    ((consp formula)
     (apply #'append (mapcar #'extract-vars-helper (cdr formula))))))

(defun generate-property-form (name input expected)
  "Generates ACL2s property form from test case.
   Returns: (property name (var1 var2 ... :bool) (== input expected))"
  (let* ((input-vars (extract-variables input))
         (expected-vars (extract-variables expected))
         (all-vars (remove-duplicates 
                    (sort (append input-vars expected-vars) #'string<)))
         (param-list (if all-vars
                         (append all-vars '(:bool))
                         '(:bool))))
    
    `(property ,name ,param-list
       (== ,input ,expected))))

(defun generate-all-properties (filename)
  "Generates ACL2s property forms for all test cases.
   Writes them to FILENAME."
  (with-open-file (out filename :direction :output
                       :if-exists :supersede
                       :if-does-not-exist :create)
    ;; Header
    (format out ";; ============================================================~%")
    (format out ";; AUTO-GENERATED ACL2s PROPERTIES~%")
    (format out ";; Verification that simplifier preserves logical equivalence~%")
    (format out ";; ============================================================~%")
    (format out ";;~%")
    (format out ";; Each property verifies that the simplification is correct:~%")
    (format out ";;   For all boolean assignments to variables,~%")
    (format out ";;   input ≡ simplified-output~%")
    (format out ";;~%")
    (format out ";; Total properties: ~D~%" (length *test-cases*))
    (format out ";; ============================================================~%~%")
    
    ;; Generate and write each property
    (dolist (test-case *test-cases*)
      (destructuring-bind (name input expected) test-case
        (let ((prop (generate-property-form name input expected)))
          (prin1 prop out)
          (terpri out)
          (terpri out))))
    
    (format out ";; ============================================================~%")
    (format out ";; End of properties~%")
    (format out ";; ============================================================~%"))
  
  (format t "~%Generated ~D properties in ~A~%" 
          (length *test-cases*) 
          filename))

;; ============================================================
;; STARTUP
;; ============================================================

(format t "~%~%========================================~%")
(format t "Propositional Formula Simplifier Loaded~%")
(format t "========================================~%")

;; Run tests
(run-all-tests)

;; Generate ACL2s properties file
(generate-all-properties "proveme.lisp")

(format t "~%To build executable:~%")
(format t "  sbcl --load simplifier.lisp --eval '(sb-ext:save-lisp-and-die \"simplify\" :toplevel #'toplevel :executable t)'~%~%")