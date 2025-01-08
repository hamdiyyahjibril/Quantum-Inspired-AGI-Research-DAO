;; Milestone Tracking Contract

(define-map milestones
  { proposal-id: uint, milestone-id: uint }
  {
    description: (string-utf8 1000),
    due-date: uint,
    status: (string-ascii 20)
  }
)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u403))
(define-constant ERR_INVALID_MILESTONE (err u404))

(define-public (add-milestone (proposal-id uint) (milestone-id uint) (description (string-utf8 1000)) (due-date uint))
  (let
    (
      (proposal (unwrap! (contract-call? .research-proposal get-proposal proposal-id) ERR_INVALID_MILESTONE))
    )
    (asserts! (or (is-eq tx-sender CONTRACT_OWNER) (is-eq tx-sender (get researcher proposal))) ERR_NOT_AUTHORIZED)
    (ok (map-set milestones
      { proposal-id: proposal-id, milestone-id: milestone-id }
      {
        description: description,
        due-date: due-date,
        status: "pending"
      }
    ))
  )
)

(define-public (update-milestone-status (proposal-id uint) (milestone-id uint) (new-status (string-ascii 20)))
  (let
    (
      (milestone (unwrap! (map-get? milestones { proposal-id: proposal-id, milestone-id: milestone-id }) ERR_INVALID_MILESTONE))
    )
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (ok (map-set milestones
      { proposal-id: proposal-id, milestone-id: milestone-id }
      (merge milestone { status: new-status })
    ))
  )
)

(define-read-only (get-milestone (proposal-id uint) (milestone-id uint))
  (map-get? milestones { proposal-id: proposal-id, milestone-id: milestone-id })
)

