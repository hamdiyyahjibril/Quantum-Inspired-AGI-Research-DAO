import { describe, it, expect, beforeEach } from 'vitest';

// Simulated contract state
const milestones = new Map();

// Simulated contract functions
function addMilestone(proposalId: number, milestoneId: number, description: string, dueDate: number, adder: string) {
  const key = `${proposalId}-${milestoneId}`;
  milestones.set(key, {
    description,
    dueDate,
    status: 'pending'
  });
  return true;
}

function updateMilestoneStatus(proposalId: number, milestoneId: number, newStatus: string, updater: string) {
  if (updater !== 'CONTRACT_OWNER') throw new Error('Not authorized');
  const key = `${proposalId}-${milestoneId}`;
  const milestone = milestones.get(key);
  if (!milestone) throw new Error('Invalid milestone');
  milestone.status = newStatus;
  milestones.set(key, milestone);
  return true;
}

describe('Milestone Tracking Contract', () => {
  beforeEach(() => {
    milestones.clear();
  });
  
  it('should add a new milestone', () => {
    expect(addMilestone(1, 1, 'Complete initial research', 1625097600, 'researcher1')).toBe(true);
    const milestone = milestones.get('1-1');
    expect(milestone.description).toBe('Complete initial research');
    expect(milestone.status).toBe('pending');
  });
  
  it('should update milestone status', () => {
    addMilestone(2, 1, 'Develop prototype', 1627776000, 'researcher2');
    expect(updateMilestoneStatus(2, 1, 'completed', 'CONTRACT_OWNER')).toBe(true);
    const milestone = milestones.get('2-1');
    expect(milestone.status).toBe('completed');
  });
  
  it('should not allow unauthorized status updates', () => {
    addMilestone(3, 1, 'Publish research paper', 1630454400, 'researcher3');
    expect(() => updateMilestoneStatus(3, 1, 'completed', 'unauthorized_user')).toThrow('Not authorized');
  });
  
  it('should handle multiple milestones for a single proposal', () => {
    addMilestone(4, 1, 'Phase 1: Research', 1633046400, 'researcher4');
    addMilestone(4, 2, 'Phase 2: Development', 1635724800, 'researcher4');
    addMilestone(4, 3, 'Phase 3: Testing', 1638316800, 'researcher4');
    expect(milestones.get('4-1')).toBeDefined();
    expect(milestones.get('4-2')).toBeDefined();
    expect(milestones.get('4-3')).toBeDefined();
  });
});

