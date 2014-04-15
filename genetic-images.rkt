;; Partea 2 - Generarea imaginilor
;; _______________________________
(require racket/list)
(require test-engine/racket-tests)
(require racket/trace)
(load "symbolic-regression.rkt")
(require 2htdp/image)

;; Dimensiunea populației
(define POPULATION-SIZE 5)

(define DEPTH 100)
;; Numărul maxim de generații de-a lungul cărora se desfășoară evoluția
(define GENERATIONS 100000)

;; Un terminal este reprezentat în forma unei liste (obiect tip)
(define TERMINALS '((. image) (. image) (. image) (. image) (. image) (. image)))
(define XS '(. . . . . .))
;; O funcție este reprezentată în forma unei liste
;; (nume tip-întors (tip-param-1 ... tip-param-n))
(define FUNCTIONS '((above image (image image))
                    (rotate image (360 image))
                    (scale image (2.0 image))))

;; Posibilă imagine model
(define SAMPLE .)

(define SAMPLE-height (image-height SAMPLE))
(define SAMPLE-width (image-height SAMPLE))
(define SAMPLE-length (length (image->color-list SAMPLE)))

;;-------------------------------------------------------------
;;REZOLVARE CERINTA

;;--------RANDOM GENERATOR---------
;;numar intreg random intre 1 si 360  
(define (random-angle)
 (random 360))

;;numar real random intre (0,2.0)
(define (random-scale)
  (* 2 (random)))

;; Inițializarea populației și generarea indivizilor


;;-------------------------GENERARE AST Aleator------------------
;; Generează un AST aleator, pe baza adâncimii maxime și a metodei furnizate,
;; 'grow' sau 'full' (vezi enunțul), pornind de la mulțimile de funcții
;; și terminali
(define (generate depth method)
  (let gen ([d depth])
    (if (or (zero? d)
            (and (eq? method 'grow)
                 (zero? (random 2))))
        (car (choose-from TERMINALS))
        (let ([function-info (choose-from FUNCTIONS)])
          (append (list(primitive-name function-info))
                (let repeat ([no_of_parameters (- (length (flatten (primitive-arity function-info))) 1)] 
                             [type (caaddr function-info)])
                  (if (eq? no_of_parameters 1)
                      (car (choose-from TERMINALS))
                      (cond 
                      [(eq? type '360) (append (list(random-angle)) (list(gen (- d 1))))]
                      [(eq? type '2.0) (append (list(random-scale)) (list (gen (- d 1))))]
                      [else (append (list(gen (- d 1)))
                                  (list(repeat (- no_of_parameters 1) 'image)))]))))))))


;; Fitness
;; _______

(define (properties ast)
  (let ([dev (deviation ast)])
    (list (max 0 (- (/ 100 (+ dev 0.1))  ; Adăugăm 0.1 pt a evita împărțirea la 0
                    (* PARSIMONY-COEFFICIENT (size ast))))
          dev)))
;;---------------
;;---DISTANTA EUCLIDIANA------------------------------------
;;deviatia este calculata pe baza distantei euclidiene intre cele 2 imagini 

(define (euclidian-image-distance image1 image2 dist)
  (cond [(or (zero? (length image1)) (zero? (length image2))) dist]
        [else (euclidian-image-distance (cdr image1) (cdr image2) (+ (+ (expt (- (color-red (car image1)) (color-red (car image2))) 2)
                                                                         (expt (- (color-blue (car image1)) (color-blue (car image2))) 2))
                                                                         (expt (- (color-green (car image1)) (color-green (car image2))) 2)))]))

;;--------------EVALUAREA TREE-ului------------------------
(define (errorS ast val_x)
  (let* [(value-function ((eval `(λ(,'image) ,ast))val_x))]
    value-function))

;;-----------------DEVIATIA IMAGINII------------------------
(define (deviation ast)
  (+ (euclidian-image-distance (image->color-list(place-image (errorS ast (car XS)) (/ SAMPLE-width 2) (/ SAMPLE-height 2) (rectangle SAMPLE-width SAMPLE-height "solid" "white"))) (image->color-list SAMPLE) 0) 
     (euclidian-image-distance (image->color-list(place-image (errorS ast (cadr XS)) (/ SAMPLE-width 2) (/ SAMPLE-height 2) (rectangle SAMPLE-width SAMPLE-height "solid" "white")))  (image->color-list SAMPLE) 0)))

(define (size ast)
  (length (flatten ast)))

;; Selecție
;; ________

(define (choose-from options)
  (if (null? options)
      'nothing
      (list-ref options (random (length options)))))


;; Recombinare
(define (crossover x y)
  (modify-random x (random-subtree y)))

;; Mutație
(define (mutate x)
  (modify-random x (generate (+ 2 (random (- DEPTH 1)))
                             (choose-from '(grow full)))))

;;------------------AST RANDOM------------------------------
;; Înlocuiește un subarbore aleator al unui AST cu un altul
(define (modify-random ast new)
  (cond [(and (not (list? ast))
         (or (and (and (number? ast) (number? new)) 
                  (or (and (exact-integer? new) (exact-integer? ast))
                      (and (not (exact-integer? new)) (not (exact-integer? ast)))))
             (and (not (number? ast)) (not (number? ast))))) new]
        [(not (list? ast)) ast]
        [else 
             (let ([index (random (length ast))])
               (if (and (zero? index) (and (not (number? ast)) (not(number? new))))
                   new
                   (modify ast index (modify-random (list-ref ast index) new))))]))

;; Întoarce un subarbore aleator al unui AST
(define (random-subtree ast)
  (if (not (list? ast))
      ast
      (let ([choice (choose-from (cons ast (cdr ast)))])
        (if (eq? choice ast)
            ast
            (random-subtree choice)))))

(define (modify ast index new)
  (if (zero? index)
      (cons new (cdr ast))
      (cons (car ast)
            (modify (cdr ast) (- index 1) new))))
