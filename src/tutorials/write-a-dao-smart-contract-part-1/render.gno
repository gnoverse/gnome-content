package mydao

import (
	"strconv"
	"strings"

	gnome "gno.land/p/gnome/dao/v2"
)

// Render returns the Markdown for the corresponding view path.
func Render(path string) string {
	// When the path is empty render the DAO view
	if path == "" {
		return renderDAO()
	}

	// Otherwise the path must contain a number with a proposal ID
	proposalID, err := strconv.Atoi(path)
	if err != nil {
		panic("invalid proposal ID")
	}

	return renderProposal(gnome.ID(proposalID))
}

func renderDAO() string {
	var output strings.Builder

	// Use the DAO name as title
	output.WriteString("# " + myDAO.Title() + "\n")

	// Add the list of DAO member addresses
	output.WriteString("## Members\n")
	for _, m := range myDAO.Members() {
		output.WriteString("- " + m.Address.String() + "\n")
	}

	return output.String()
}

func renderProposal(id gnome.ID) string {
	var (
		output strings.Builder
		p      = mustGetProposal(id)
	)

	// Use the proposal title and ID as title
	output.WriteString("# Proposal #" + p.ID().String() + ": " + p.Title() + "\n")

	// Add important proposal values
	output.WriteString("- Type: " + p.Strategy().Name() + "\n")
	output.WriteString("- Created: " + p.CreatedAt().UTC().Format("2006-01-02 15:04 MST") + "\n")
	output.WriteString("- Proposer: " + p.Proposer().String() + "\n")
	output.WriteString("- Status: " + p.Status().String() + "\n")
	output.WriteString("\n" + p.Description() + "\n")

	// Add the number of votes for each one of the voted choices
	output.WriteString("\n## Votes\n")
	record := p.VotingRecord()
	if record.VoteCount() == 0 {
		output.WriteString("Proposal has no votes\n")
	} else {
		record.Iterate(func(c gnome.VoteChoice, count uint) bool {
			output.WriteString("- " + string(c) + ": " + strconv.FormatUint(uint64(count), 10) + "\n")
			return false
		})
	}

	return output.String()
}
