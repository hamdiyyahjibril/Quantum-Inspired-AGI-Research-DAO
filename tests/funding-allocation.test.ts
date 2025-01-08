import { describe, it, expect, beforeEach } from 'vitest';

// Simulated contract state
const allocations = new Map();
const tokenBalances = new Map();

// Simulated contract functions
function allocateFunds(proposalId: number, amount: number, allocator: string) {
  if (allocator !== 'CONTRACT_OWNER') throw new Error('Not authorized');
  allocations.set(proposalId, {
    amount,
    recipient: `researcher${proposalId}`,
    status: 'allocated'
  });
  return true;
}

function releaseFunds(proposalId: number, releaser: string) {
  if (releaser !== 'CONTRACT_OWNER') throw new Error('Not authorized');
  const allocation = allocations.get(proposalId);
  if (!allocation) throw new Error('Invalid allocation');
  if (allocation.status !== 'allocated') throw new Error('Funds already released');
  allocation.status = 'released';
  tokenBalances.set(allocation.recipient, (tokenBalances.get(allocation.recipient) || 0) + allocation.amount);
  allocations.set(proposalId, allocation);
  return true;
}

describe('Funding Allocation Contract', () => {
  beforeEach(() => {
    allocations.clear();
    tokenBalances.clear();
  });
  
  it('should allocate funds to a proposal', () => {
    expect(allocateFunds(1, 1000000, 'CONTRACT_OWNER')).toBe(true);
    const allocation = allocations.get(1);
    expect(allocation.amount).toBe(1000000);
    expect(allocation.status).toBe('allocated');
  });
  
  it('should release funds to the researcher', () => {
    allocateFunds(2, 500000, 'CONTRACT_OWNER');
    expect(releaseFunds(2, 'CONTRACT_OWNER')).toBe(true);
    const allocation = allocations.get(2);
    expect(allocation.status).toBe('released');
    expect(tokenBalances.get('researcher2')).toBe(500000);
  });
  
  it('should not allow unauthorized fund allocation', () => {
    expect(() => allocateFunds(3, 250000, 'unauthorized_user')).toThrow('Not authorized');
  });
  
  it('should not allow unauthorized fund release', () => {
    allocateFunds(4, 750000, 'CONTRACT_OWNER');
    expect(() => releaseFunds(4, 'unauthorized_user')).toThrow('Not authorized');
  });
  
  it('should not allow double release of funds', () => {
    allocateFunds(5, 100000, 'CONTRACT_OWNER');
    releaseFunds(5, 'CONTRACT_OWNER');
    expect(() => releaseFunds(5, 'CONTRACT_OWNER')).toThrow('Funds already released');
  });
});

