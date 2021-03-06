;; (prop.scm) -*- coding: utf-8; mode: scheme -*-
;; sandbox for Guile bindings

;; (c) lloda@sarc.name 2019
;; This library is free software; you can redistribute it and/or modify it under
;; the terms of the GNU Lesser General Public License as published by the Free
;; Software Foundation; either version 3 of the License, or (at your option) any
;; later version.

(import (srfi :1)  (srfi :8) (srfi :26) (srfi :71))



; -----------------------------------------
; bindings
; -----------------------------------------

; need to fix LD_LIBRARY_PATH && GUILEPATH until install
(import (prop-618 prop) (prop-618 atmospheres))


; -----------------------------------------
; spot checks
; -----------------------------------------

(p839-rain-height 0 0)
(p837-rainfall-rate 0 0)
(p1510-temp 51.5 -0.14) ; 283.61087556
(p835-ref 11.)
(p840-clouds 14.25 31.07694309 (p840-Lred 51.50 -0.14 1)) ; 0.455170459072589
(p453-Nwet 51.5 -0.14 50) ; 50.3892622222222 validation table shows (and P.618 §2.4 requires) median values.
(p618-scint 14.25 31.07694309 (sqrt 0.65) 1 (p453-Nwet 51.5 -0.14 50))
(p836-V 51.5 -0.14 1.0 (p1511-topoh 51.5 -0.14)) ; 33.3205520527569

(let* ((latdeg 51.5)
       (londeg -0.14)
       (eldeg 31.07694309)
       (deff (sqrt 0.65))
       (taudeg 0)
       (fghz 14.25)
       (p% 1)
       (hs 0.06916422)
       (temp (p1510-temp latdeg londeg))
       ((values P rho T error) (p835-ref hs)))
  (+ (pk 'As (p618-scint fghz eldeg deff p% (p453-Nwet latdeg londeg 50)))
     (pk 'Ar (p618-rain latdeg londeg hs fghz eldeg taudeg p% (p837-rainfall-rate latdeg londeg)))
     (pk 'Ac (p840-clouds fghz eldeg (p840-Lred latdeg londeg p%)))
     (pk 'Ag 0 ;; (p676-gas eldeg fghz P e temp Vt hs) ; e <- from P, Vt <- P836,
         )
     ))


; -----------------------------------------
; from \cite[\texttt{P618-13 A_Rain}]{ITU-e2s-VAL}
; -----------------------------------------

(p618-rain 51.5 -0.14 0.0691642239999998 14.25 31.0769430897284 0 1 26.48052)
(p618-rain 51.5 -0.14 0.0691642239999998 14.25 31.0769430897284 0 1 (p837-rainfall-rate 51.5 -0.14))
(p618-rain 22.9 -43.23 0 14.25 22.2783346840557 0 0.1 50.639304) ;  8.27164743807979


; -----------------------------------------
; sample figures
; FIXME uses private libraries... give something portable.
; -----------------------------------------

(import (yak yak))

(let ((h (linspace. 0 100 200))
      (loglines (array->list (ply log10 (ravel (out * #(2 3 4 5 6 7 8 9) #(1e-4 1e-3 1e-2 1e-1 1 1e1 1e2)))))))
  ((yak-graph "x.pdf" #:line-width .007 #:width 1300 #:height 1000 #:subgrid 'lines #:scale 1.5
              #:ylim '(0 100) #:yticks (iota 11 0 10)
              #:xlim '(-4 3) #:subxticks loglines
              #:xticks '(-4 -3 -2 -1 0 1 2 3) #:xticklabels '("10⁻⁴" "10⁻³" "10⁻²" "10⁻¹" "1" "10" "10²" "10³")
              #:label-bottom "Pressure (hPa)" #:label-left "Geometric height (km)"
              #:title "ITU-R P.835-6 Fig. 2")
   (yak-data (ply (lambda (h) (receive (P rho T ec) (p835-ref h) (log10 P))) h) h #:color 'steelblue)))

(let ((h (linspace. 0 100 200)))
  ((yak-graph "y.pdf" #:line-width .007 #:width 1300 #:height 1000 #:subgrid 'lines #:scale 1.5
              #:ylim '(0 100) #:yticks (iota 11 0 10)
              #:xlim '(180 300) #:xticks (iota 13 180 10)
              #:label-bottom "Temperature (K)" #:label-left "Geometric height (km)"
              #:title "ITU-R P.835-6 Fig. 1")
   (yak-data (ply (lambda (h) (receive (P rho T ec) (p835-ref h) T)) h) h #:color 'steelblue)))

(let* ((fghz (linspace. 1 1000 5000))
       (c (ply p838-coeffs fghz))
       (loglinesx (array->list (ply log10 (ravel (out * #(2 3 4 5 6 7 8 9) #(1e0 1e1 1e2 1e3))))))
       (loglinesy (array->list (ply log10 (ravel (out * #(2 3 4 5 6 7 8 9) #(1e-5 1e-4 1e-3 1e-2 1e-1 1e0 1e1)))))))
  ((yak-graph "k.pdf" #:line-width .005 #:width 1300 #:height 1000 #:subgrid 'lines #:scale 1.4 #:place-legend '(1 0)
              #:xlim '(0 3) #:xticks '(0 1 2 3)
              #:xticklabels '("1" "10" "10²" "10³") #:subxticks loglinesx
              #:ylim '(-5 1) #:yticks '(-5 -4 -3 -2 -1 0 1)
              #:yticklabels '("10⁻⁵" "10⁻⁴" "10⁻³" "10⁻²" "10⁻¹" "1" "10") #:subyticks loglinesy
              #:label-bottom "Frequency (GHz)" #:label-left "coefficients k"
              #:title "ITU-R P.838-3 Fig. 1-3")
   (yak-data (ply log10 fghz) (ply log10 (from c #t 0)) #:color 'blue #:legend "kₕ")
   (yak-data (ply log10 fghz) (ply log10 (from c #t 2)) #:color 'red #:legend "kᵥ"))
  ((yak-graph "a.pdf" #:line-width .005 #:width 1300 #:height 1000 #:subgrid 'lines #:scale 1.4
              #:xlim '(0 3) #:xticks '(0 1 2 3)
              #:xticklabels '("1" "10" "10²" "10³") #:subxticks loglinesx
              #:ylim '(.4 1.8) #:yticks '(.4 .6 .8 1. 1.2 1.4 1.6 1.8) #:subyticks (array->list (range. 0.4 1.8 0.04))
              #:label-bottom "Frequency (GHz)" #:label-left "coefficients α"
              #:title "ITU-R P.838-3 Fig. 2-4")
   (yak-data (ply log10 fghz) (from c #t 1) #:color 'blue #:legend "αₕ")
   (yak-data (ply log10 fghz) (from c #t 3) #:color 'red #:legend "αᵥ")))

(let* ((fghz (linspace. 1 350 10000))
       (T (+ 273.15 15))
       (e (p676-vapor-pressure 7.5 T))
       (gas (ply (lambda (fghz) (call-with-values (lambda () (p676-gas-specific 0 fghz 1013.25 e T)) vector)) fghz))
       (loglinesx (array->list (ply log10 (ravel (out * #(2 3 4 5 6 7 8 9) #(1e0 1e1 1e2 1e3))))))
       (loglinesy (array->list (ply log10 (ravel (out * #(2 3 4 5 6 7 8 9) #(1e-5 1e-4 1e-3 1e-2 1e-1 1e0 1e1)))))))
  ((yak-graph "p676-11-fig5.pdf" #:line-width .007 #:width 1000 #:height 1300 #:subgrid 'lines #:scale 1.4 #:place-legend '(1 0)
              #:xlim (list 0 (log10 350)) #:xticks (list 0 1 2 (log10 350))
              #:xticklabels '("1" "10" "10²" "350") #:subxticks loglinesx
              #:ylim '(-3 2) #:yticks '(-3 -2 -1 0 1 2)
              #:yticklabels '("10⁻³" "10⁻²" "10⁻¹" "1" "10" "10²") #:subyticks loglinesy
              #:label-bottom "Frequency (GHz)" #:label-left "sp. att. (dB/km)"
              #:title "ITU-R P.676-11 Fig. 5")
   (yak-data (ply log10 fghz) (ply log10 (from gas #t 0)) #:color 'darkblue #:legend "dry")
   (yak-data (ply log10 fghz) (ply log10 (from gas #t 1)) #:color 'darkgoldenrod #:legend "water vapor")
   (yak-data (ply log10 fghz) (ply log10 (ply + (from gas #t 0) (from gas #t 1))) #:color 'darkred #:legend "total")))
