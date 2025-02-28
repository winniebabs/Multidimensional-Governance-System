;; Hyperdimensional Voting Contract

(define-map votes
  { proposal-id: uint, dimension-id: uint, voter: principal }
  { vote-weight: uint }
)

(define-map proposals
  { proposal-id: uint }
  {
    creator: principal,
    description: (string-utf8 256),
    status: (string-ascii 10),
    total-votes: uint
  }
)

(define-data-var next-proposal-id uint u0)

(define-public (create-proposal (description (string-utf8 256)))
  (let
    ((new-id (+ (var-get next-proposal-id) u1)))
    (var-set next-proposal-id new-id)
    (map-set proposals
      { proposal-id: new-id }
      {
        creator: tx-sender,
        description: description,
        status: "active",
        total-votes: u0
      }
    )
    (ok new-id)
  )
)

(define-public (cast-vote (proposal-id uint) (dimension-id uint) (vote-weight uint))
  (let
    ((proposal (unwrap! (map-get? proposals { proposal-id: proposal-id }) (err u404)))
     (current-votes (default-to u0 (get vote-weight (map-get? votes { proposal-id: proposal-id, dimension-id: dimension-id, voter: tx-sender })))))
    (asserts! (is-eq (get status proposal) "active") (err u403))
    (map-set votes
      { proposal-id: proposal-id, dimension-id: dimension-id, voter: tx-sender }
      { vote-weight: vote-weight }
    )
    (map-set proposals
      { proposal-id: proposal-id }
      (merge proposal { total-votes: (+ (get total-votes proposal) (- vote-weight current-votes)) })
    )
    (ok true)
  )
)

(define-read-only (get-proposal (proposal-id uint))
  (map-get? proposals { proposal-id: proposal-id })
)

(define-read-only (get-vote (proposal-id uint) (dimension-id uint) (voter principal))
  (map-get? votes { proposal-id: proposal-id, dimension-id: dimension-id, voter: voter })
)

