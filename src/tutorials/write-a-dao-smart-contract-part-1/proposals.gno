package mydao

import (
	gnome "gno.land/p/gnome/dao/v2"
)

var (
	// proposals stores all DAO proposals
	proposals []*gnome.Proposal

	// lastProposalID keeps track of the last created proposal ID
	lastProposalID gnome.ID
)

// generateProposalID generates proposal ID incrementally
func generateProposalID() gnome.ID {
	lastProposalID += 1
	return lastProposalID
}

// mustGetProposal returns a proposal or panics if it doesn't exist
func mustGetProposal(id gnome.ID) *gnome.Proposal {
	for _, p := range proposals {
		if p.ID() == id {
			return p
		}
	}

	panic("proposal not found")
}
