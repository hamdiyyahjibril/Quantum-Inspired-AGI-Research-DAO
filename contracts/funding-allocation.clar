;; Funding Allocation Contract

(define-fungible-token dao-token)

(define-map allocations
  uint  ;; proposal-id
  {
    amount: uint,
    recipient: principal,
    status: (string-ascii 20)
  }
)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u403))
(define-constant ERR_INVALID_ALLOCATION (err u404))

(define-public (allocate-funds (proposal-id uint) (amount uint))
  (let
    (
      (proposal (unwrap! (contract-call? .research-proposal get-proposal proposal-id) ERR_INVALID_ALLOCATION))
    )
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (map-set allocations
      proposal-id
      {
        amount: amount,
        recipient: (get researcher proposal),
        status: "allocated"
      }
    )
    (ok true)
  )
)

(define-public (release-funds (proposal-id uint))
  (let
    (
      (allocation (unwrap! (map-get? allocations proposal-id) ERR_INVALID_ALLOCATION))
    )
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (asserts! (is-eq (get status allocation) "allocated") ERR_NOT_AUTHORIZED)
    (try! (as-contract (ft-transfer? dao-token (get amount allocation) tx-sender (get recipient allocation))))
    (ok (map-set allocations
      proposal-id
      (merge allocation { status: "released" })
    ))
  )
)

(define-read-only (get-allocation (proposal-id uint))
  (map-get? allocations proposal-id)
)

