import { describe, it, expect, beforeEach } from 'vitest';

// Simulated contract state
let lastTokenId = 0;
const tokenMetadata = new Map();
const tokenOwners = new Map();

// Simulated contract functions
function mint(name: string, description: string, breakthroughType: string, minter: string) {
  if (minter !== 'CONTRACT_OWNER') throw new Error('Not authorized');
  const tokenId = ++lastTokenId;
  tokenMetadata.set(tokenId, {
    name,
    description,
    researcher: minter,
    breakthroughType,
    timestamp: Date.now()
  });
  tokenOwners.set(tokenId, minter);
  return tokenId;
}

function transfer(tokenId: number, sender: string, recipient: string) {
  if (tokenOwners.get(tokenId) !== sender) throw new Error('Not authorized');
  tokenOwners.set(tokenId, recipient);
  return true;
}

describe('Breakthrough NFT Contract', () => {
  beforeEach(() => {
    lastTokenId = 0;
    tokenMetadata.clear();
    tokenOwners.clear();
  });
  
  it('should mint a new breakthrough NFT', () => {
    const tokenId = mint('Quantum Cognition Model', 'A novel approach to cognitive modeling using quantum principles', 'Algorithm', 'CONTRACT_OWNER');
    expect(tokenId).toBe(1);
    expect(tokenOwners.get(tokenId)).toBe('CONTRACT_OWNER');
    const metadata = tokenMetadata.get(tokenId);
    expect(metadata.name).toBe('Quantum Cognition Model');
    expect(metadata.breakthroughType).toBe('Algorithm');
  });
  
  it('should transfer an NFT', () => {
    const tokenId = mint('AGI Architecture', 'A comprehensive architecture for artificial general intelligence', 'Architecture', 'CONTRACT_OWNER');
    expect(transfer(tokenId, 'CONTRACT_OWNER', 'researcher1')).toBe(true);
    expect(tokenOwners.get(tokenId)).toBe('researcher1');
  });
  
  it('should not allow unauthorized minting', () => {
    expect(() => mint('Unauthorized Breakthrough', 'This should fail', 'Algorithm', 'unauthorized_user')).toThrow('Not authorized');
  });
  
  it('should not allow unauthorized transfer', () => {
    const tokenId = mint('Ethical AI Framework', 'A framework for ensuring ethical behavior in AGI systems', 'Research Finding', 'CONTRACT_OWNER');
    expect(() => transfer(tokenId, 'unauthorized_user', 'researcher2')).toThrow('Not authorized');
  });
});

