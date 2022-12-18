#lang scribble/manual
@require[@for-label[data/priority-queue
                    racket/base]]

@title{Priority Queues}
@author[@author+email["Shawn Wagner" "shawnw.mobile@gmail.com"]]

@defmodule[data/priority-queue]

Imperative max priority queues. Currently implemented with a binary heap, but that is an internal detail that is subject to change in the future.

 Two priority queues are @code{equal?} if they have @code{equal?} comparison functions, contain the same number of elements and when sorted by priority each corresponding pair of elements are @code{equal?}. This can be an expensive operation.

@section{Predicates}

@defproc[(priority-queue? [obj any/c]) boolean?]{

 Tests if the given value is a priority queue or not.

}

@defproc[(priority-queue-empty? [pq priority-queue?]) boolean?]{

 Return true if the queue has no elements currently in it.

}

@section{Constructors}

@defproc[(make-priority-queue [< (-> any/c any/c any/c)] [elem any/c] ...) priority-queue?]{

 Create a new priority queue object using the given ordering function to determine if one object has lower priority than another, populated with the initial elements given, if any.

}

@defproc[(list->priority-queue [< (-> any/c any/c any/c)] [elems list?]) priority-queue?]{

 Create a new priority queue using the given ordering function, populated by the elements of @code{elems}.

}

@defproc[(vector->priority-queue [< (-> any/c any/c any/c)] [elems vector?]) priority-queue?]{

 Create a new priority queue using the given ordering function, populated by the elements of @code{elems}.

}

@defproc[(priority-queue-copy [pq priority-queue?]) priority-queue?]{

 Return a copy of the given priority queue.

}

@section{Mutating the queue}

@defproc[(priority-queue-insert! [pq priority-queue?] [elem any/c]) void?]{

 Insert a new element into the queue.

 }

@defproc[(priority-queue-remove-max! [pq (and/c priority-queue? (not/c priority-queue-empty?))]) any/c]{

 Remove and return the element with the highest priority. It is an error to call on an empty priority queue.

}

@defproc[(in-priority-queue! [pq priority-queue?]) sequence?]{

 Returns a sequence that destructively returns the elements of the queue in order from highest priority to lowest. After the sequence is consumed, the priority queue will be empty.

A priority queue can be used directly as a @code{sequence?} with the same effect.

}

@section{Other operations}

@defproc[(priority-queue-peek-max [pq (and/c priority-queue? (not/c priority-queue-empty?))]) any/c]{

 Return the element with the highest priority without removing it from the queue. It is an error to call on an empty priority queue.

}

@defproc[(priority-queue-length [pq priority-queue?]) exact-nonnegative-integer?]{

 Return the number of elements in the queue.

}

@defproc[(priority-queue-ordering [pq priority-queue?]) (-> any/c any/c any/c)]{

 Return the less-than ordering function used by the queue.

}

@defproc[(priority-queue->list [pq priority-queue?]) list?]{

 Return a list of the elements of the queue in an unspecified order.

}

@defproc[(priority-queue->vector [pq priority-queue?]) vector?]{

 Return a newly allocated vector of the elements of the queue in an unspecified order.

}

@defproc[(priority-queue->vector! [pq priority-queue?] [vec (and/c vector? (not/c immutable?))]) vector?]{

 Fills @code{vec} with the elements of the queue in an unspecified order and returns it. @code{vec} must have a length at least equal to the number of elements currently in the queue.

}

@defproc[(priority-queue->sorted-list [pq priority-queue?]) list?]{

 Return a list of the elements of the queue in order from lowest to highest priority.

}

@defproc[(priority-queue->sorted-vector [pq priority-queue?]) vector?]{

 Return a newly allocated vector of the elements of the queue in order from lowest to highest priority.

}

@defproc[(priority-queue->sorted-vector! [pq priority-queue?] [vec (and/c vector? (not/c immutable?))]) vector?]{

 Fills @code{vec} with the elements of the queue in order from lowest to highest priority and returns it. @code{vec} must have a length at least equal to the number of elements currently in the queue.

}