;; Interdimensional Law Enforcement Contract

(define-map laws
  { law-id: uint }
  {
    description: (string-utf8 256),
    penalty: uint,
    enforced-dimensions: (list 20 uint)
  }
)

(define-map violations
  { violation-id: uint }
  {
    law-id: uint,
    violator: principal,
    dimension-id: uint,
    timestamp: uint
  }
)

(define-data-var next-law-id uint u0)
(define-data-var next-violation-id uint u0)

(define-public (enact-law (description (string-utf8 256)) (penalty uint) (enforced-dimensions (list 20 uint)))
  (let
    ((new-id (+ (var-get next-law-id) u1)))
    (var-set next-law-id new-id)
    (map-set laws
      { law-id: new-id }
      {
        description: description,
        penalty: penalty,
        enforced-dimensions: enforced-dimensions
      }
    )
    (ok new-id)
  )
)

(define-public (report-violation (law-id uint) (violator principal) (dimension-id uint))
  (let
    ((new-id (+ (var-get next-violation-id) u1))
     (law (unwrap! (map-get? laws { law-id: law-id }) (err u404))))
    (asserts! (is-some (index-of (get enforced-dimensions law) dimension-id)) (err u403))
    (var-set next-violation-id new-id)
    (map-set violations
      { violation-id: new-id }
      {
        law-id: law-id,
        violator: violator,
        dimension-id: dimension-id,
        timestamp: block-height
      }
    )
    (ok new-id)
  )
)

(define-read-only (get-law (law-id uint))
  (map-get? laws { law-id: law-id })
)

(define-read-only (get-violation (violation-id uint))
  (map-get? violations { violation-id: violation-id })
)

