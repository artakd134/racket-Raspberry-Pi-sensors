#lang racket

(require "raspi-gpio2.rkt")
(require "lsm303d.rkt")
(gpio-setup)
(define fd (gpio-i2c-setup #x1d))
(lsm303d-setup fd)

(define xM (gpio-i2c-read-reg8 fd LSM303D_OUT_X_H_A))
(define xL (gpio-i2c-read-reg8 fd LSM303D_OUT_X_L_A))
(define yM (gpio-i2c-read-reg8 fd LSM303D_OUT_Y_H_A))
(define yL (gpio-i2c-read-reg8 fd LSM303D_OUT_Y_L_A))
(define zM (gpio-i2c-read-reg8 fd LSM303D_OUT_Z_H_A))
(define zL (gpio-i2c-read-reg8 fd LSM303D_OUT_Z_L_A))

(define (x)
(cond ((not (zero? xM))
(set! xM 0) (set! xL (- xL 256))))
(bitwise-ior (arithmetic-shift xM 8) xL))
(define (y)
(cond ((not (zero? yM))
(set! yM 0) (set! yL (- yL 256))))
(bitwise-ior (arithmetic-shift yM 8) yL))
(define (z)
(cond ((not (zero? zM))
(set! zM 0) (set! zL (- zL 256))))
(bitwise-ior (arithmetic-shift zM 8) zL))

(define (versnelling) (list (expt (x) 1/16) (expt (y) 1/16) (expt (z) 1/16)))

(versnelling)