#lang racket/base

;;; Priority queue

(require racket/contract srfi/214)

(provide
 (contract-out
  [priority-queue? predicate/c]
  [make-priority-queue (-> (-> any/c any/c any/c) any/c ... priority-queue?)]
  [list->priority-queue (-> (-> any/c any/c any/c) list? priority-queue?)]
  [vector->priority-queue (-> (-> any/c any/c any/c) vector? priority-queue?)]
  [priority-queue-copy (-> priority-queue? priority-queue?)]
  [priority-queue-length (-> priority-queue? exact-nonnegative-integer?)]
  [priority-queue-empty? (-> priority-queue? boolean?)]
  [priority-queue-ordering (-> priority-queue? (-> any/c any/c any/c))]
  [priority-queue-insert! (-> priority-queue? any/c void?)]
  [priority-queue-remove-max! (-> (and/c priority-queue? (not/c priority-queue-empty?)) any/c)]
  [priority-queue-peek-max (-> (and/c priority-queue? (not/c priority-queue-empty?)) any/c)]
  [priority-queue->list (-> priority-queue? list?)]
  [priority-queue->vector (-> priority-queue? vector?)]
  [priority-queue->vector! (-> priority-queue? (and/c vector? (not/c immutable?)) vector?)]
  [priority-queue->sorted-list (-> priority-queue? list?)]
  [priority-queue->sorted-vector (-> priority-queue? vector?)]
  [priority-queue->sorted-vector! (-> priority-queue? (and/c vector? (not/c immutable?)) vector?)]

  ))

(define (pq=? a b equal-wrapper?)
  (and
   (equal-wrapper? (priority-queue-ordering a) (priority-queue-ordering b))
   (= (flexvector-length (priority-queue-contents a))
      (flexvector-length (priority-queue-contents b)))
   (let ([fva (flexvector-copy (priority-queue-contents a))]
         [fvb (flexvector-copy (priority-queue-contents b))])
     (let loop ()
       (cond
         ((flexvector-empty? fva) #t)
         ((equal-wrapper? (flexvector-ref fva 0) (flexvector-ref fvb 0))
          (heap-remove-max! fva (priority-queue-ordering a))
          (heap-remove-max! fvb (priority-queue-ordering b))
          (loop))
         (else #f))))))

(struct priority-queue (contents ordering)
  #:methods gen:equal+hash
  [(define equal-proc pq=?)
   (define (hash-proc a hash-code)
     (hash-code (priority-queue->sorted-vector a)))
   (define (hash2-proc a hash-code)
     (hash-code (priority-queue->sorted-vector a)))]
  #:property prop:sequence
  (lambda (pq) (in-list (reverse (priority-queue->sorted-list pq))))
  )

(define (make-priority-queue lt? . elems)
  (list->priority-queue lt? elems))

(define (list->priority-queue lt? elems)
  (flexvector->priority-queue! lt? (list->flexvector elems)))

(define (vector->priority-queue lt? elems)
  (flexvector->priority-queue! lt? (vector->flexvector elems)))

(define (flexvector->priority-queue! lt? fv)
  (when (> (flexvector-length fv) 1)
    (for ([i (in-inclusive-range (- (quotient (flexvector-length fv) 2) 1) 0 -1)])
      (bubble-down fv i lt?)))
  (priority-queue fv lt?))
  
(define (priority-queue-length pq)
  (flexvector-length (priority-queue-contents pq)))

(define (priority-queue-empty? pq)
  (= (priority-queue-length pq) 0))

(define (priority-queue-peek-max pq)
  (flexvector-ref (priority-queue-contents pq) 0))

(define (priority-queue-copy pq)
  (struct-copy priority-queue pq [contents (flexvector-copy (priority-queue-contents pq))]))

(define (bubble-up fv i <?)
  (when (> i 0)
    (let ([j (quotient (- i 1) 2)])
      (unless (<? (flexvector-ref fv i) (flexvector-ref fv j))
        (flexvector-swap! fv i j)
        (bubble-up fv j <?)))))

(define (priority-queue-insert! pq elem)
  (let ([fv (priority-queue-contents pq)])
    (flexvector-add-back! fv elem)
    (bubble-up fv (- (flexvector-length fv) 1) (priority-queue-ordering pq))))

(define (bubble-down fv i <?)
  (let* ([left (+ (* 2 i) 1)]
         [right (+ (* 2 i) 2)]
         [largest (if (and (< left (flexvector-length fv))
                           (<? (flexvector-ref fv i) (flexvector-ref fv left)))
                      left
                      i)]
         [largest (if (and (< right (flexvector-length fv))
                           (<? (flexvector-ref fv largest) (flexvector-ref fv right)))
                      right
                      largest)])
    (unless (= i largest)
      (flexvector-swap! fv i largest)
      (bubble-down fv largest <?))))

(define (heap-remove-max! fv <?)
  (flexvector-swap! fv 0 (- (flexvector-length fv) 1))
  (flexvector-remove-back! fv)
  (bubble-down fv 0 <?))

(define (priority-queue-remove-max! pq)
  (let* ([fv (priority-queue-contents pq)]
         [max-elem (flexvector-ref fv 0)])
    (if (= (flexvector-length fv) 1)
        (flexvector-clear! fv)
        (heap-remove-max! fv (priority-queue-ordering pq)))
    max-elem))

(define (priority-queue->list pq)
  (flexvector->list (priority-queue-contents pq)))

(define (priority-queue->vector pq)
  (priority-queue->vector! pq (make-vector (flexvector-length (priority-queue-contents pq)))))

(define (priority-queue->vector! pq vec)
  (let ([fv (priority-queue-contents pq)])
    (for ([i (in-range (flexvector-length fv))])
      (vector-set! vec i (flexvector-ref fv i)))
    vec))

(define (priority-queue->sorted-list pq)
  (let ([fv (flexvector-copy (priority-queue-contents pq))])
    (let loop ([result '()])
      (if (flexvector-empty? fv)
          result
          (let ([max-elem (flexvector-ref fv 0)])
            (heap-remove-max! fv (priority-queue-ordering pq))
            (loop (cons max-elem result)))))))

(define (priority-queue->sorted-vector pq)
  (priority-queue->sorted-vector! pq (make-vector (flexvector-length (priority-queue-contents pq)))))

(define (priority-queue->sorted-vector! pq result)
  (let* ([fv (flexvector-copy (priority-queue-contents pq))])
    (let loop ([i (- (flexvector-length fv) 1)])
      (cond
        ((flexvector-empty? fv)
          result)
        (else
         (vector-set! result i (flexvector-ref fv 0))
         (heap-remove-max! fv (priority-queue-ordering pq))
         (loop (- i 1)))))))

(module+ test
  (require rackunit racket/list)

  (define p (make-priority-queue <))
  (priority-queue-insert! p 1)
  (check-equal? (priority-queue-length p) 1)
  (check-equal? (priority-queue-peek-max p) 1)
  (priority-queue-insert! p 5)
  (check-equal? (priority-queue-length p) 2)
  (check-equal? (priority-queue-peek-max p) 5)
  (priority-queue-insert! p 3)
  (check-equal? (priority-queue-length p) 3)
  (check-equal? (priority-queue->sorted-list p) '(1 3 5))
  (check-equal? (priority-queue->sorted-vector p) '#(1 3 5))
  (check-equal? (priority-queue-remove-max! p) 5)
  (check-equal? (priority-queue-length p) 2)
  (check-equal? (priority-queue-remove-max! p) 3)
  (check-equal? (priority-queue-length p) 1)
  (check-equal? (priority-queue-remove-max! p) 1)
  (check-true (priority-queue-empty? p))

  (define a (list->priority-queue < (range 1 11)))
  (define b (list->priority-queue < (range 10 0 -1)))
  (check-true (equal? a b))

  )