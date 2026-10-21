#lang racket

(require "raspi-gpio.rkt")


(define X_CH 0)
(define Y_CH 1)
(define Z_CH 2)
(gpio-setup)

;;; toegevoegd
(gpio-mcp23017-setup 100 #x20)
(define k1 110)
(define k2 109)
(define k3 108)
(define r1 107)
(define r2 106)
(define r3 105)
(define r r2)
(define k k2)

(gpio-set-pin-mode r1 'output)
(gpio-set-pin-mode r2 'output)
(gpio-set-pin-mode r3 'output)
(gpio-set-pin-mode k1 'output)
(gpio-set-pin-mode k2 'output)
(gpio-set-pin-mode k3 'output)

(gpio-digital-write k1 1)
(gpio-digital-write k2 0)
(gpio-digital-write k3 1)
(gpio-digital-write r1 0)
(gpio-digital-write r2 1)
(gpio-digital-write r3 0)

(define (current-k x)
  (set! k x)
  (gpio-digital-write k1 1)
  (gpio-digital-write k2 1)
  (gpio-digital-write k3 1)
  (gpio-digital-write x 0))

(define (current-r x)
  (set! r x)
  (gpio-digital-write r1 0)
  (gpio-digital-write r2 0)
  (gpio-digital-write r3 0)
  (gpio-digital-write x 1))

(define (move-left!)
  (cond ((eq? k k2) (current-k k1))
        ((eq? k k3) (current-k k2))))

(define (move-right!)
  (cond ((eq? k k1) (current-k k2))
        ((eq? k k2) (current-k k3))))

(define (move-up!)
  (cond ((eq? r r2) (current-r r1))
        ((eq? r r3) (current-r r2))))

(define (move-down!)
  (cond ((eq? r r1) (current-r r2))
        ((eq? r r2) (current-r r3))))

;;; tot hier
(define spi-channel 0)
(define channel-config-single 8)
(define channel-config-diff 0)
(define channel-config channel-config-single)
(gpio-mcp3008-setup spi-channel)
(define sample-size 10)

(define (read-axis ch)
(let ((reading 0))
(gpio-mcp3008-analog-read spi-channel channel-config ch)
(gpio-delay-ms 1)
(for ([i sample-size])
(set! reading
(+ reading (gpio-mcp3008-analog-read spi-channel channel-config ch))))
(/ reading (exact->inexact sample-size))))

(define x-raw-min 512)
(define y-raw-min 512)
(define z-raw-min 512)
(define x-raw-max 512)
(define y-raw-max 512)
(define z-raw-max 512)

(define (auto-calibrate x-raw y-raw z-raw)
(cond ((< x-raw x-raw-min) (set! x-raw-min x-raw)))
(cond ((> x-raw x-raw-max) (set! x-raw-max x-raw)))
(cond ((< y-raw y-raw-min) (set! y-raw-min y-raw)))
(cond ((> y-raw y-raw-max) (set! y-raw-max y-raw)))
(cond ((< z-raw z-raw-min) (set! z-raw-min z-raw)))
(cond ((> z-raw z-raw-max) (set! z-raw-max z-raw))))

(define (calibrate-loop)
(let ((x-raw (read-axis X_CH))
(y-raw (read-axis Y_CH))
(z-raw (read-axis Z_CH)))
(for ([i 400])
(set! x-raw (read-axis X_CH))
(set! y-raw (read-axis Y_CH))
(set! z-raw (read-axis Z_CH))
(auto-calibrate x-raw y-raw z-raw)
  (cond ((< x-raw 450) (move-left!)) ; toegevoegd
        ((> x-raw 550) (move-right!))
        ((< y-raw 450) (move-down!))
        ((> y-raw 550) (move-up!)))
(gpio-delay-ms 500))))

(define (show)
(displayln (format "Raw ranges: X: ~a-~a, Y: ~a-~a, Z: ~a-~a"
x-raw-min x-raw-max
y-raw-min y-raw-max
z-raw-min z-raw-max)))
(calibrate-loop)
(show)

(define (value-map x in-min in-max out-min out-max)
(/ (* (- x in-min) (- out-max out-min))
(+ (- in-max in-min) out-min)))

(define (loop)
(let* ((x-raw (read-axis X_CH))
(y-raw (read-axis Y_CH))
(z-raw (read-axis Z_CH))
; convert raw values to "milli-Gs"
(x-scaled (value-map x-raw x-raw-min x-raw-max -1000 1000))
(y-scaled (value-map y-raw y-raw-min y-raw-max -1000 1000))
(z-scaled (value-map z-raw z-raw-min z-raw-max -1000 1000))
(x-accel (/ x-scaled 1000))
(y-accel (/ y-scaled 1000))
(z-accel (/ z-scaled 1000)))
(displayln (format "~a\t~a\t~a\t~a\t~a\t~a\t~a\t~a\t~a"
x-raw y-raw z-raw
(round x-scaled) (round y-scaled) (round z-scaled)
(round x-accel) (round y-accel) (round z-accel)))
(gpio-delay-ms 100)
(loop)))

(loop)
