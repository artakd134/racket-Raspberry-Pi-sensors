#lang racket

(require "raspi-gpio2.rkt")
(require "lsm303d.rkt")
(define fd (gpio-i2c-setup #x1d))
(lsm303d-setup fd)

(define LSB (gpio-i2c-read-reg8 fd LSM303D_TEMP_OUT_L))
(define MSB (gpio-i2c-read-reg8 fd LSM303D_TEMP_OUT_H))

(define new-MSB
(bitwise-and MSB #b00001111)) ; remove 4 leftmost bits of MSB

(define (check-sign)
(cond ((not (zero? MSB))
(set! MSB 0) (set! LSB (- LSB 256)))))

(check-sign)
(display "Current Temperature is ")
(/ (round (* (exact->inexact (+ (/ (bitwise-ior (arithmetic-shift new-MSB 8) LSB) 8) 25)) 100)) 100)
