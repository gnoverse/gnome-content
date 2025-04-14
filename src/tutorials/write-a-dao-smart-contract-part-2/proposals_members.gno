package mydao2

import (
	"time"

	gnome "gno.land/p/gnome/dao/v2"
)

func newModifyMembersStrategy(newMembers, removeMembers []gnome.Member) modifyMembersStrategy {
	// Make sure that at least a member would be added or removed
	if len(newMembers) == 0 && len(removeMembers) == 0 {
		panic("members are required")
	}

	return modifyMembersStrategy{
		newMembers:    newMembers,
		removeMembers: removeMembers,
	}
}

type modifyMembersStrategy struct {
	newMembers, removeMembers []gnome.Member
}

func (modifyMembersStrategy) Name() string {
	return "modify-members"
}

func (modifyMembersStrategy) Quorum() float64 {
	return 0.51
}

func (modifyMembersStrategy) VotingPeriod() time.Duration {
	// TODO: Replace by a smaller time frame if you want to try or demo general proposals
	return time.Hour * 24 * 7
}

func (modifyMembersStrategy) VoteChoices() []gnome.VoteChoice {
	return []gnome.VoteChoice{gnome.ChoiceYes, gnome.ChoiceNo}
}

func (modifyMembersStrategy) Tally(dao *gnome.DAO, r gnome.VotingRecord) gnome.VoteChoice {
	// Count all members vs the votes to consider abstentions to make the majority absolute
	abstentions := len(dao.Members()) - r.VoteCount()

	if choice, ok := gnome.SelectChoiceByMajority(r, abstentions); ok {
		return choice
	}
	return gnome.ChoiceNone
}

func (s modifyMembersStrategy) Execute(dao *gnome.DAO) error {
	for _, m := range s.newMembers {
		dao.AddMember(m)
	}

	for _, m := range s.removeMembers {
		dao.RemoveMember(m.Address)
	}
	return nil
}
