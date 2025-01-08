;; Tokenized Voting System Contract

(define-fungible-token vote-token)

(define-map votes
  { proposal-id: uint, voter: principal }
  { amount: uint }
)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u403))
(define-constant ERR_INVALID_VOTE (err u404))

(define-public (vote (proposal-id uint) (amount uint))
  (let
    (
      (proposal (unwrap! (contract-call? .research-proposal get-proposal proposal-id) ERR_INVALID_VOTE))
    )
    (try! (ft-transfer? vote-token amount tx-sender (as-contract tx-sender)))
    (map-set votes
      { proposal-id: proposal-id, voter: tx-sender }
      { amount: amount }
    )
    (ok (map-set proposals
      proposal-id
      (merge proposal { votes: (+ (get votes proposal) amount) })
    ))
  )
)

(define-public (withdraw-vote (proposal-id uint))
  (let
    (
      (vote (unwrap! (map-get? votes { proposal-id: proposal-id, voter: tx-sender }) ERR_INVALID_VOTE))
      (proposal (unwrap! (contract-call? .research-proposal get-proposal proposal-id) ERR_INVALID_VOTE))
    )
    (try! (as-contract (ft-transfer? vote-token (get amount vote) tx-sender tx-sender)))
    (map-delete votes { proposal-id: proposal-id, voter: tx-sender })
    (ok (map-set proposals
      proposal-id
      (merge proposal { votes: (- (get votes proposal) (get amount vote)) })
    ))
  )
)

(define-read-only (get-vote (proposal-id uint) (voter principal))
  (map-get? votes { proposal-id: proposal-id, voter: voter })
)

