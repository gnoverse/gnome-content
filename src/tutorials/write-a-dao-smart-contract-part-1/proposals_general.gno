package mydao

import (
	"time"

	gnome "gno.land/p/gnome/dao/v2"
)

func newGeneralStrategy() generalStrategy {
	return generalStrategy{}
}

type generalStrategy struct{}

func (generalStrategy) Name() string {
	return "general"
}

func (generalStrategy) Quorum() float64 {
	return 0.51
}

func (generalStrategy) VotingPeriod() time.Duration {
	// TODO: Replace by a smaller time frame if you want to try or demo general proposals
	return time.Hour * 24 * 2
}

func (generalStrategy) VoteChoices() []gnome.VoteChoice {
	return []gnome.VoteChoice{gnome.ChoiceYes, gnome.ChoiceNo}
}

func (generalStrategy) Tally(dao *gnome.DAO, r gnome.VotingRecord) gnome.VoteChoice {
	// Count all members vs the votes to consider abstentions to make the majority absolute
	abstentions := len(dao.Members()) - r.VoteCount()

	if choice, ok := gnome.SelectChoiceByMajority(r, abstentions); ok {
		return choice
	}
	return gnome.ChoiceNone
}
