---
{
  "title": "Write a DAO Smart Contract - Part 2",
  "slug": "write-a-dao-smart-contract-part-2",
  "tags": ["gnoland", "gno", "dao"],
  "level": "Intermediate",
  "author": "Jerónimo Albi",
  "authorAddress": "g1hy6zry03hg5d8le9s2w4fxme6236hkgd928dun",
  "contributors": ["Kirk Haines"],
  "contributorAddresses": ["g1whzkakk4hzjkvy60d5pwfk484xu67ar2cl62h2"],
  "summary": "In this two parts tutorial we explore one way to write a DAO smart contract. The tutorials will guide you though creating an executable proposal to add and remove DAO members."
}
---

## Overview

This second part of the "Write a DAO Smart Contract" tutorial will explore how to add and remove
members by using a different type of proposal. It continues where the first part left off.

## What You'll Learn

- What an executable proposal is
- How to create an executable proposal that updates DAO members
- How to write a minimal public function to execute proposals

## What You'll Need

- To have read the [first part] of this tutorial
- Understanding of [Gno language](https://gno-by-example.com/)
- Knowledge on how to deploy realms and packages using [Gno Playground] or [gnokey]
- Knowledge on how to interact with realms using [Gno Connect] or [gnokey]

## Executable Proposals

It is useful to be able to change the members of the DAO by adding new members
or removing existing ones. One way to support this is though the implementation of a new type of
proposal that when approved would make the necessary changes to the DAO. This type of proposal is
called executable.

The steps needed to change DAO members using this new proposal type start by creating a new
proposal to modify the DAO members, then voting on it and waiting until the voting deadline is met.
Once that happens, the proposal could be executed at any time to modify the members.

The [gno.land/p/gnome/dao] package allows defining executable proposal types by implementing
the following interface:

```go
type Executer interface {
	// Execute executes the proposal.
	// The DAO argument is the DAO where the proposal was created.
	Execute(*DAO) error
}
```

### Executable Proposal Strategy

Proposal strategies that implement the `Execute()` method are able to modify the state after the
proposal is approved and executed when the voting deadline is met.

Let's define a new proposal strategy that adds or removes DAO members after it's approval by creating
a `proposals_members.gno` file:

```go
package mydao

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
```

> It's important to mention that you might want to change the voting period to a smaller time frame
> if you intend to try or demo the proposal, otherwise you would have to wait a week to be able to
> finalize the proposal.

Pay special attention to the `Execute()` method, which will be called after the
proposal passes. It adds or removes members from the DAO where the proposal was created.
The other strategy methods were already explained in the [first part] of the tutorial.

## Public Realm Functions

The next step is to define a new public realm function to allow the creation of member modification
proposals and a second public function to be able to execute proposals once the voting deadline
is met.

### Create Modify DAO Member Proposal

To allow DAO members to create new _modify members_ proposals, define a
`CreateModifyMembersProposal()` function at the end of the `public.gno` file:

````go
// CreateModifyMembersProposal creates a proposal to modify DAO members.
//
// Arguments:
// - title: A title for the proposal
// - description: A description for the proposal
// - newMembers: List of member addresses to add to the DAO
// - removeMembers: List of member addresses to remove from the DAO
//
// A list of members must be newline separated list of addresses,
// where each line must contain an address, for example:
// ```
// g187982000zsc493znqt828s90cmp6hcp2erhu6m
// g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5
// ```
func CreateModifyMembersProposal(title, description, newMembers, removeMembers string) uint64 {
	// Check that the original caller is a member of the DAO
	caller := std.GetOrigCaller()
	assertIsMember(caller)

	// Create a new proposal that uses the modify members strategy
	id := generateProposalID()
	strategy := newModifyMembersStrategy(
		gnome.MustParseStringToMembers(newMembers),
		gnome.MustParseStringToMembers(removeMembers),
	)
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
````

This function receives one or more member addresses that should be added or removed from the DAO
when the proposal is approved.

### Create a Public Realm Function to Execute Proposals

To allow executing proposals define an `Execute()` function at the end of the `public.gno` file:

```go
// Execute carries out an active proposal.
func Execute(proposalID uint64) string {
	// Check that the original caller is a member of the DAO
	caller := std.GetOrigCaller()
	assertIsMember(caller)

	// Get the proposal and validate that the voting deadline is met
	p := mustGetProposal(gnome.ID(proposalID))
	if !p.HasVotingDeadlinePassed() {
		panic("proposal's voting deadline must be met before execution")
	}

	// Tally votes and update proposal's status
	if err := p.Tally(); err != nil {
		panic(err)
	}

	// Execute proposal.
	// Execution detects if a proposal is executable and when it's not it skips execution.
	if err := p.Execute(); gnome.IsExecutionError(err) {
		p.Fail("execution failed: " + err.Error())
	}

	return "Proposal executed successfully"
}
```

The `Execute()` function should be called for any type of proposals, executable or non executable,
to update the proposal state to reflect the outcome of the votes once the voting deadline is met.

## What's Next

Now you can add or remove DAO members by following these steps:

- Deploy your DAO realm to **gno.land**
- Create a new member modification proposal by calling `CreateModifyMembersProposal()`
- Vote YES on the new proposal using the current DAO member accounts
- Once the voting deadline is met execute the proposal by calling `Execute()`
- Check the list of DAO members in your DAO **gno.land** realm view

From here, you can explore extending the tutorial examples with different use cases. For example, you could
improve validation. The [gno.land/p/gnome/dao] package has support for proposal
validation by implementing the `Validator` interface in the proposal strategies.

Other things to explore could be using different tallying methods to count the votes, or even
creating a tree based DAO, which is also supported by [gno.land/p/gnome/dao].

[first part]: https://gno.land/r/gnome/tutorials:write-a-dao-smart-contract-part-1
[gno.land/p/gnome/dao]: https://gno.land/p/gnome/dao/v2/
[Gno Connect]: https://gno.studio/connect
[Gno Playground]: https://play.gno.land/
[gnokey]: https://docs.gno.land/gno-tooling/cli/gnokey/
