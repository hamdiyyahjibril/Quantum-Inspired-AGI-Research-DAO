;; Breakthrough NFT Contract

(define-non-fungible-token breakthrough-nft uint)

(define-data-var last-token-id uint u0)

(define-map token-metadata
  uint
  {
    name: (string-ascii 100),
    description: (string-utf8 1000),
    researcher: principal,
    breakthrough-type: (string-ascii 50),
    timestamp: uint
  }
)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u403))

(define-public (mint (name (string-ascii 100)) (description (string-utf8 1000)) (breakthrough-type (string-ascii 50)))
  (let
    (
      (token-id (+ (var-get last-token-id) u1))
    )
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (try! (nft-mint? breakthrough-nft token-id tx-sender))
    (map-set token-metadata
      token-id
      {
        name: name,
        description: description,
        researcher: tx-sender,
        breakthrough-type: breakthrough-type,
        timestamp: block-height
      }
    )
    (var-set last-token-id token-id)
    (ok token-id)
  )
)

(define-public (transfer (token-id uint) (recipient principal))
  (nft-transfer? breakthrough-nft token-id tx-sender recipient)
)

(define-read-only (get-token-metadata (token-id uint))
  (map-get? token-metadata token-id)
)

(define-read-only (get-last-token-id)
  (var-get last-token-id)
)

