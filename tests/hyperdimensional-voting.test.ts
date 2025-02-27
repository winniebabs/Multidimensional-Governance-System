import { describe, it, expect, beforeEach } from "vitest"

const proposals = new Map()
const votes = new Map()
let nextProposalId = 0

describe("hyperdimensional-voting", () => {
  beforeEach(() => {
    proposals.clear()
    votes.clear()
    nextProposalId = 0
  })
  
  it("should create a new proposal", () => {
    const result = createProposal("Test proposal")
    expect(result.success).toBe(true)
    expect(result.result).toBe(1)
  })
  
  it("should cast a vote", () => {
    createProposal("Test proposal")
    const result = castVote(1, 1, 10)
    expect(result.success).toBe(true)
  })
  
  it("should retrieve a proposal", () => {
    createProposal("Test proposal")
    const proposal = getProposal(1)
    expect(proposal).toBeDefined()
    expect(proposal.description).toBe("Test proposal")
  })
  
  it("should retrieve a vote", () => {
    createProposal("Test proposal")
    castVote(1, 1, 10)
    const vote = getVote(1, 1, "tx-sender")
    expect(vote).toBeDefined()
    expect(vote.vote_weight).toBe(10)
  })
})

function createProposal(description: string) {
  const newId = ++nextProposalId
  proposals.set(newId, {
    creator: "tx-sender",
    description,
    status: "active",
    total_votes: 0,
  })
  return { success: true, result: newId }
}

function castVote(proposalId: number, dimensionId: number, voteWeight: number) {
  const proposal = proposals.get(proposalId)
  if (!proposal || proposal.status !== "active") {
    return { success: false, error: 403 }
  }
  const voteKey = `${proposalId}-${dimensionId}-tx-sender`
  const currentVote = votes.get(voteKey) || { vote_weight: 0 }
  votes.set(voteKey, { vote_weight: voteWeight })
  proposal.total_votes += voteWeight - currentVote.vote_weight
  return { success: true }
}

function getProposal(proposalId: number) {
  return proposals.get(proposalId)
}

function getVote(proposalId: number, dimensionId: number, voter: string) {
  return votes.get(`${proposalId}-${dimensionId}-${voter}`)
}

