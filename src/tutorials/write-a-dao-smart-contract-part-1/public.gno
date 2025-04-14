package mydao

import (
	"std"
	"strings"

	gnome "gno.land/p/gnome/dao/v2"
)

// CreateGeneralProposal creates a general proposal.
//
// Arguments:
// - title: A title for the proposal
// - description: A description for the proposal
func CreateGeneralProposal(title, description string) uint64 {
	// Proposal description is required, so make sure it's not empty
	assertDescriptionIsNotEmpty(description)

	// Check that the original caller is a member of the DAO
	caller := std.GetOrigCaller()
	assertIsMember(caller)

	// Create a new proposal that uses the general strategy
	id := generateProposalID()
	strategy := newGeneralStrategy()
	p, err := gnome.NewProposal(
		id,
		strategy,
		caller,
		myDAO,
		title,
		gnome.WithDescription(description),
	)
	if err != nil {
		panic(err)
	}

	// Append the new proposal to the list of proposals
	proposals = append(proposals, p)

	return uint64(p.ID())
}

// Vote allows voting on proposals.
//
// Arguments:
// - proposalID: ID of the proposal where the vote must be submitted
// - vote: A string with choice to vote
func Vote(proposalID uint64, vote string) string {
	// Check that the original caller is a member of the DAO
	caller := std.GetOrigCaller()
	assertIsMember(caller)

	p := mustGetProposal(gnome.ID(proposalID))
	choice := gnome.VoteChoice(vote)

	err := p.Vote(caller, choice, "")
	if err != nil {
		// When the voted choice is invalid use a custom error that display valid choices
		if err == gnome.ErrInvalidVoteChoice {
			var choices []string
			for _, c := range p.Strategy().VoteChoices() {
				choices = append(choices, string(c))
			}

			panic(err.Error() + ": valid choices are: " + strings.Join(choices, ", "))
		}

		panic(err)
	}

	return "Vote submitted sucessfully"
}

// Execute executes active proposals.
func Execute(proposalID uint64) string {
	caller := std.GetOrigCaller()
	assertIsMember(caller)

	p := mustGetProposal(gnome.ID(proposalID))
	if !p.HasVotingDeadlinePassed() {
		panic("proposal's voting deadline must be met before execution")
	}

	if err := p.Tally(); err != nil {
		panic(err)
	}

	if err := p.Execute(); gnome.IsExecutionError(err) {
		p.Fail("execution failed: " + err.Error())
	}

	return "Proposal executed successfully"
}

// assertDescriptionIsNotEmpty asserts that a description string is not empty.
func assertDescriptionIsNotEmpty(desc string) {
	if strings.TrimSpace(desc) == "" {
		panic("description should not be empty")
	}
}
