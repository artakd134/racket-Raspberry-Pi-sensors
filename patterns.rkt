#lang racket

(require "raspi-gpio.rkt")

(gpio-setup)

(gpio-mcp23017-setup 100 #x20)
(define k1 110)
(define k2 109)
(define k3 108)
(define r1 107)
(define r2 106)
(define r3 105)

(gpio-set-pin-mode r1 'output)
(gpio-set-pin-mode r2 'output)
(gpio-set-pin-mode r3 'output)
(gpio-set-pin-mode k1 'output)
(gpio-set-pin-mode k2 'output)
(gpio-set-pin-mode k3 'output)

(define patroon
(vector
1 0 1
1 1 1
1 0 1))

(define (patroon! new-vector)
(set! patroon new-vector))

(define patroon-number 1)

(define (patroon-number! x)
  (set! patroon-number x))

(define (v number)
(if (zero? (vector-ref patroon number)) 1
0))

(define (loop)

(gpio-digital-write k1 (v 0))
(gpio-digital-write k2 (v 1))
(gpio-digital-write k3 (v 2))
(gpio-digital-write r1 1)
(gpio-digital-write r2 0)
(gpio-digital-write r3 0)


(gpio-delay-seconds 0.02)

(gpio-digital-write k1 (v 3))
  (gpio-digital-write k2 (v 4))
(gpio-digital-write k3 (v 5))
(gpio-digital-write r1 0)
(gpio-digital-write r2 1)
(gpio-digital-write r3 0)

(gpio-delay-seconds 0.02)

(gpio-digital-write k1 (v 6))
(gpio-digital-write k2 (v 7))
(gpio-digital-write k3 (v 8))
(gpio-digital-write r1 0)
(gpio-digital-write r2 0)
(gpio-digital-write r3 1)

(gpio-delay-seconds 0.02)

(if (< (gpio-elapsed-seconds) (* patroon-number 5))
(loop)

(cond ((= patroon-number 1)
       (patroon-number! 2)
       (patroon! (vector 0 1 0
                         1 1 1
                         0 1 0))
       (loop))

      ((= patroon-number 2)
       (patroon-number! 3)
       (patroon! (vector 1 0 1
                         1 0 1
                         1 0 1))
       (loop))
      ((= patroon-number 3)
       (gpio-digital-write r1 0)
       (gpio-digital-write r2 0)
       (gpio-digital-write r3 0)
       (gpio-digital-write k1 0)
       (gpio-digital-write k2 0)
       (gpio-digital-write k3 0)))))

(loop)