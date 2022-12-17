#lang info
(define collection 'multi)
(define deps '("base" "extra-srfi-libs"))
(define build-deps '("scribble-lib" "racket-doc" "rackunit-lib"))
(define scribblings '(("data/scribblings/priority-queue.scrbl" () ("Data Structures"))))
(define pkg-desc "Priority Queues")
(define version "0.0")
(define pkg-authors '(shawnw))
(define license '(Apache-2.0 OR MIT))
