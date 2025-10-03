;; ============================================================
;; AUTO-GENERATED ACL2s PROPERTIES
;; Verification that simplifier preserves logical equivalence
;; ============================================================
;;
;; Each property verifies that the simplification is correct:
;;   For all boolean assignments to variables,
;;   input ≡ simplified-output
;;
;; Total properties: 101
;; ============================================================

(PROPERTY FLATTEN-1 (P Q R :BOOL) (== (AND P (AND Q R)) (AND P Q R)))

(PROPERTY FLATTEN-2 (A B C :BOOL) (== (OR (OR A B) C) (OR A B C)))

(PROPERTY FLATTEN-3 (P Q R S :BOOL)
 (== (AND P (AND Q (AND R S))) (AND P Q R S)))

(PROPERTY FLATTEN-4 (:BOOL) (== (AND) T))

(PROPERTY FLATTEN-5 (:BOOL) (== (OR) NIL))

(PROPERTY FLATTEN-6 (P :BOOL) (== (AND P) P))

(PROPERTY FLATTEN-7 (P :BOOL) (== (OR P) P))

(PROPERTY FLATTEN-8 (A B C :BOOL) (== (IFF (IFF A B) C) (IFF A B C)))

(PROPERTY SINK-1 (P Q :BOOL) (== (AND P NIL Q) NIL))

(PROPERTY SINK-2 (P Q :BOOL) (== (OR P T Q) T))

(PROPERTY SINK-3 (P Q R :BOOL) (== (AND P Q T R) (AND P Q R)))

(PROPERTY SINK-4 (P Q R :BOOL) (== (OR P Q NIL R) (OR P Q R)))

(PROPERTY SINK-5 (:BOOL) (== (AND NIL) NIL))

(PROPERTY SINK-6 (:BOOL) (== (OR T) T))

(PROPERTY IDEM-1 (P Q R :BOOL) (== (AND P Q P R Q) (AND P Q R)))

(PROPERTY IDEM-2 (A B C :BOOL) (== (OR A B A C B) (OR A B C)))

(PROPERTY IDEM-3 (P :BOOL) (== (AND P P P) P))

(PROPERTY IDEM-4 (Q :BOOL) (== (OR Q Q) Q))

(PROPERTY CONST-1 (P :BOOL) (== (IMPLIES P T) T))

(PROPERTY CONST-2 (P :BOOL) (== (IMPLIES T P) P))

(PROPERTY CONST-3 (P :BOOL) (== (IMPLIES NIL P) T))

(PROPERTY CONST-4 (P Q :BOOL)
 (==
  (IF T
      P
      Q)
  P))

(PROPERTY CONST-5 (P Q :BOOL)
 (==
  (IF NIL
      P
      Q)
  Q))

(PROPERTY CONST-6 (P Q :BOOL)
 (==
  (IF P
      P
      Q)
  (OR P Q)))

(PROPERTY CONST-7 (P :BOOL) (== (IFF P T) P))

(PROPERTY CONST-8 (P :BOOL) (== (XOR P NIL) P))

(PROPERTY CONST-9 (P :BOOL) (== (XOR P T) (NOT P)))

(PROPERTY CONST-10 (:BOOL) (== (AND T T T) T))

(PROPERTY CONST-11 (:BOOL) (== (OR NIL NIL NIL) NIL))

(PROPERTY CONST-12 (P :BOOL) (== (IMPLIES P P) T))

(PROPERTY NEG-1 (P :BOOL) (== (NOT (NOT P)) P))

(PROPERTY NEG-2 (P :BOOL) (== (NOT (NOT (NOT (NOT P)))) P))

(PROPERTY NEG-3 (:BOOL) (== (NOT T) NIL))

(PROPERTY NEG-4 (:BOOL) (== (NOT NIL) T))

(PROPERTY NEG-5 (P :BOOL) (== (NOT (NOT (NOT P))) (NOT P)))

(PROPERTY DEMORGAN-1 (P Q :BOOL) (== (NOT (AND P Q)) (OR (NOT P) (NOT Q))))

(PROPERTY DEMORGAN-2 (P Q :BOOL) (== (NOT (OR P Q)) (AND (NOT P) (NOT Q))))

(PROPERTY DEMORGAN-3 (P Q R :BOOL)
 (== (NOT (AND P Q R)) (OR (NOT P) (NOT Q) (NOT R))))

(PROPERTY DEMORGAN-4 (A B C D :BOOL)
 (== (NOT (OR A B C D)) (AND (NOT A) (NOT B) (NOT C) (NOT D))))

(PROPERTY IMPL-1 (P Q :BOOL) (== (IMPLIES P Q) (OR (NOT P) Q)))

(PROPERTY IMPL-2 (P Q :BOOL) (== (IMPLIES (NOT P) Q) (OR P Q)))

(PROPERTY COMP-1 (P :BOOL) (== (AND P (NOT P)) NIL))

(PROPERTY COMP-2 (P :BOOL) (== (OR P (NOT P)) T))

(PROPERTY COMP-3 (P Q :BOOL) (== (AND P Q (NOT P)) NIL))

(PROPERTY COMP-4 (P Q :BOOL) (== (OR P Q (NOT P)) T))

(PROPERTY COMP-5 (P :BOOL) (== (AND (NOT P) P) NIL))

(PROPERTY COMP-6 (P :BOOL) (== (OR (NOT P) P) T))

(PROPERTY ABSORB-1 (P Q :BOOL) (== (AND P (OR P Q)) P))

(PROPERTY ABSORB-2 (P Q :BOOL) (== (OR P (AND P Q)) P))

(PROPERTY ABSORB-3 (P Q R :BOOL) (== (AND P (OR P Q) (OR P R)) P))

(PROPERTY ABSORB-4 (P Q R :BOOL) (== (OR P (AND P Q) (AND P R)) P))

(PROPERTY COMPLEX-1 (P Q :BOOL) (== (AND (OR P Q) (OR P (NOT Q))) P))

(PROPERTY COMPLEX-2 (P Q :BOOL) (== (OR (AND P Q) (AND P (NOT Q))) P))

(PROPERTY COMPLEX-3 (P Q R :BOOL)
 (==
  (IF (NOT (NOT P))
      (AND Q T)
      (OR R NIL))
  (IF P
      Q
      R)))

(PROPERTY COMPLEX-4 (P Q :BOOL) (== (IFF (AND P Q) (AND P Q)) T))

(PROPERTY COMPLEX-5 (A B :BOOL) (== (AND (OR A B) (OR (NOT A) B)) B))

(PROPERTY NESTED-1 (P Q R S :BOOL)
 (== (AND P (AND Q (AND R (AND S T)))) (AND P Q R S T)))

(PROPERTY NESTED-2 (A B C D E F :BOOL)
 (== (OR (OR (OR A B) (OR C D)) (OR E F)) (OR A B C D E F)))

(PROPERTY NESTED-3 (P :BOOL) (== (NOT (NOT (NOT (NOT (NOT (NOT P)))))) P))

(PROPERTY NESTED-4 (P :BOOL) (== (AND (AND (AND P))) P))

(PROPERTY IDENTITY-1 (P :BOOL) (== (IMPLIES P P) T))

(PROPERTY IDENTITY-2 (P :BOOL) (== (IFF P P) T))

(PROPERTY IDENTITY-3 (P :BOOL) (== (XOR P P) NIL))

(PROPERTY IDENTITY-4 (P :BOOL)
 (==
  (IF P
      T
      T)
  T))

(PROPERTY IDENTITY-5 (P :BOOL)
 (==
  (IF P
      NIL
      NIL)
  NIL))

(PROPERTY LARGE-1 (P Q R S U V W X Y Z :BOOL)
 (== (AND P Q R S T (AND U V W) NIL X Y Z) NIL))

(PROPERTY LARGE-2 (A B :BOOL) (== (OR (AND A B) (AND A (NOT B))) A))

(PROPERTY LARGE-3 (P Q :BOOL)
 (==
  (IF P
      Q
      Q)
  Q))

(PROPERTY XOR-1 (:BOOL) (== (XOR T T) NIL))

(PROPERTY XOR-2 (:BOOL) (== (XOR NIL NIL) NIL))

(PROPERTY XOR-3 (:BOOL) (== (XOR T NIL) T))

(PROPERTY XOR-4 (:BOOL) (== (XOR NIL T) T))

(PROPERTY XOR-5 (P :BOOL) (== (XOR P P P) P))

(PROPERTY XOR-6 (P :BOOL) (== (XOR P P P P) NIL))

(PROPERTY IFF-1 (:BOOL) (== (IFF T T) T))

(PROPERTY IFF-2 (:BOOL) (== (IFF NIL NIL) T))

(PROPERTY IFF-3 (:BOOL) (== (IFF T NIL) NIL))

(PROPERTY IFF-4 (P :BOOL) (== (IFF P P P) P))

(PROPERTY IFF-5 (A B C :BOOL) (== (IFF A B C A B C) T))

(PROPERTY SHANNON-1 (P Q :BOOL) (== (AND P (OR P Q)) P))

(PROPERTY SHANNON-2 (P Q :BOOL) (== (AND (NOT P) (OR P Q)) (AND (NOT P) Q)))

(PROPERTY SHANNON-3 (P Q :BOOL) (== (OR P (AND P Q)) P))

(PROPERTY SHANNON-4 (P Q R :BOOL) (== (AND P Q (OR P R)) (AND P Q)))

(PROPERTY SHANNON-5 (P Q R :BOOL)
 (==
  (AND P
       (IF P
           Q
           R))
  (AND P Q)))

(PROPERTY SHANNON-6 (P Q R :BOOL)
 (==
  (OR P
      (IF P
          Q
          R))
  (OR P R)))

(PROPERTY SHANNON-7 (P Q R :BOOL)
 (== (AND P (NOT Q) (OR Q R)) (AND P (NOT Q) R)))

(PROPERTY SHANNON-8 (P Q :BOOL) (== (OR (NOT P) (AND P Q)) (OR (NOT P) Q)))

(PROPERTY SHANNON-9 (P Q R :BOOL) (== (AND P (AND Q (OR P R))) (AND P Q)))

(PROPERTY SHANNON-10 (P Q R :BOOL) (== (OR P (OR Q (AND P R))) (OR P Q)))

(PROPERTY EXPORT-1 (P Q R :BOOL)
 (== (IMPLIES P (IMPLIES Q R)) (OR (NOT (AND P Q)) R)))

(PROPERTY EXPORT-2 (A B C D :BOOL)
 (== (IMPLIES A (IMPLIES B (IMPLIES C D))) (OR (NOT (AND A (AND B C))) D)))

(PROPERTY SHANNON-COMPLEX-1 (P Q R :BOOL) (== (AND (OR P Q) P (OR P R)) P))

(PROPERTY SHANNON-COMPLEX-2 (P Q R :BOOL)
 (== (AND P (OR (AND P Q) (AND (NOT P) R))) (AND P Q)))

(PROPERTY SHANNON-COMPLEX-3 (P Q R :BOOL)
 (== (OR P (AND (OR P Q) (OR (NOT P) R))) (OR P (AND Q R))))

(PROPERTY SHANNON-COMPLEX-4 (P Q :BOOL) (== (AND P (NOT P) (OR P Q)) NIL))

(PROPERTY SHANNON-COMPLEX-5 (P Q :BOOL) (== (OR P (NOT P) (AND P Q)) T))

(PROPERTY MODUS-PONENS-1 (P Q :BOOL) (== (AND (IMPLIES P Q) P) (AND P Q)))

(PROPERTY MODUS-PONENS-2 (P Q :BOOL) (== (AND P (IMPLIES P Q)) (AND P Q)))

(PROPERTY IF-SPECIAL-1 (P :BOOL)
 (==
  (IF P
      T
      NIL)
  P))

(PROPERTY IF-SPECIAL-2 (P :BOOL)
 (==
  (IF P
      NIL
      T)
  (NOT P)))

(PROPERTY IF-SPECIAL-3 (P Q R :BOOL)
 (==
  (IF (NOT P)
      Q
      R)
  (IF P
      R
      Q)))

;; ============================================================
;; End of properties
;; ============================================================
