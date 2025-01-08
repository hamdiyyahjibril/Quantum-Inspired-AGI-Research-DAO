;; Research Proposal Management Contract

(define-data-var proposal-count uint u0)

(define-map proposals
  uint
  {
    researcher: principal,
    title: (string-ascii 100),
    description: (string-utf8 1000),
    funding-requested: uint,
    status: (string-ascii 20),
    votes: uint
  }
)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u403))
(define-constant ERR_INVALID_PROPOSAL (err u404))

(define-public (submit-proposal (title (string-ascii 100)) (description (string-utf8 1000)) (funding-requested uint))
  (let
    (
      (proposal-id (+ (var-get proposal-count) u1))
    )
    (map-set proposals
      proposal-id
      {
        researcher: tx-sender,
        title: title,
        description: description,
        funding-requested: funding-requested,
        status: "pending",
        votes: u0
      }
    )
    (var-set proposal-count proposal-id)
    (ok proposal-id)
  )
)

(define-public (update-proposal-status (proposal-id uint) (new-status (string-ascii 20)))
  (let
    (
      (proposal (unwrap! (map-get? proposals proposal-id) ERR_INVALID_PROPOSAL))
    )
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (ok (map-set proposals
      proposal-id
      (merge proposal { status: new-status })
    ))
  )
)

(define-read-only (get-proposal (proposal-id uint))
  (map-get? proposals proposal-id)
)

(define-read-only (get-proposal-count)
  (var-get proposal-count)
)

