---
{
  "title": "Write a DAO Smart Contract - Part 1",
  "slug": "write-a-dao-smart-contract-part-1",
  "tags": ["gnoland", "gno", "dao"],
  "level": "Intermediate",
  "author": "Jerónimo Albi",
  "authorAddress": "g1hy6zry03hg5d8le9s2w4fxme6236hkgd928dun",
  "summary": "In this two parts tutorial we explore one way to write a DAO smart contract. The tutorial will guide you though creating a DAO and a general proposal."
}
---
## Overview

This two parts tutorial explores one way to create a non-token based DAO that allows the creation of
general proposals, also known as text proposals, where the initial set of DAO members are defined
within the realm source code. The second part of this tutorial will explore how to add and remove
members by using a different type of proposal.

Tutorial uses the pure [gno.land/p/gnome/dao] package to define the DAO and the different types
or proposals. This package already define for us the types and features needed to create tree based
DAOs.

The final DAO implementation aims to be as simple as possible to give you a example or starting
point to help you build your own tree based DAO.

While going though the tutorial try to find the places that you could improve or where you could
extend the DAO functionality with features that would be useful for your use case.

## What You'll Learn

- How to create a simple DAO
- How to create a general proposal
- How to write minimal public functions to create general proposals and vote

## What You'll Need

- Understanding of [Gno language](https://gno-by-example.com/)
- Access and familiarity with [Gno Playground]
- [Adena wallet](https://www.adena.app/) installed in your browser
- Three accounts created in Adena wallet
- Knowledge on how to deploy realms and packages using [Gno Playground] or [gnokey]
- Knowledge on how to interact with realms using [Gno Connect] or [gnokey]

## The DAO

Lets start by creating the DAO and its members. The number of DAO members is not fixed, one could
use any number of initial members depending on the implementation but for the tutorial we must add
three initial members to be able to tally votes on proposals by absolute majority, passing proposals
where 51% or more members vote "yes".

To create the DAO open [Gno Playground] and create a new `dao.gno` file:

```go
package mydao

import (
	"std"

	gnome "gno.land/p/gnome/dao/v2"
)

var myDAO = gnome.MustNew("mydao", "MyDAO", gnome.WithMembers(
	// TODO: Replace these three addresses with you account addresses
	gnome.NewMember("g1lyzcpa7duh69lk04nahxup484xrz4k6k2nqdun"),
	gnome.NewMember("g125t352u4pmdrr57emc4pe04y40sknr5ztng5mt"),
	gnome.NewMember("g1zzc479zj8taxd5e4g5mydg4rkpmujg7uflrj8p"),
))

// assertIsMember asserts that an address belongs to a DAO member
func assertIsMember(addr std.Address) {
	if !myDAO.HasMember(addr) {
		panic("caller is not a DAO member")
	}
}
```

> Gno Playground always creates an example `package.gno` file. This file **must** be deleted
> after creating the `dao.gno` file.

> Also it is recommended that you save your code using Gno Playground's save as draft feature when
> files are created or modified to avoid loosing your changes.

The DAO is created with `mydao` as identifier and "MyDAO" as name.

You should change the member addresses in the example Gno code by the three initial account
addresses that you defined in your Adena wallet, otherwise you won't be able to create proposals in
your DAO and vote on them.

## Proposals Support

The DAO could potentially define multiple types of proposals apart from the general proposal type
that is going to be defined in this tutorial, so we have to define a variable to keep track of all
these proposals. Also, each proposal must have a unique numeric idetifier that has to be
sequentially generated when new proposals are created.

To add support for proposals create a `proposals.gno` file:

```go
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

// generateProposalID generates proposal IDs incrementally
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
```

## Views

Gno.land realms optionally support rendering views by defining a public realm function called
"Render". Using this feature we can render any number of different views. For the tutorial we
are going to render two views, one to display DAO information and another to display information
for specific proposals.

The `Render(path string)` function receives a single argument called `path` which is a string
containing a path that we will use to render Markdown for the DAO or a proposal.

By default when there is no path we will render the DAO, otherwise we will expect the path to be a
number which will be used as proposal ID.

Define the `Render()` function by creating a `render.gno` file:

```go
import (
    "strconv"
    "strings"
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
```

Two private render function are also defined to simplify the `Render()` function and make it easier
to read. Each one of these two functions will focus either on the DAO view or the proposal view.

### DAO View

As mentioned before, this is the function that is called by default when visiting your realm in the
[gno.land] website. For example if yout DAO realm is deployed under the `gno.land/r/gnome/examples/mydao`
path, calling `https://gno.land/r/gnome/examples/mydao` would render the DAO view.

To implement the DAO view add the `renderDAO()` function at the end of the `render.gno` file:

```go
func renderDAO() string {
	var output strings.Builder

	// Use the DAO name as title
	output.WriteString("# " + myDAO.Title() + "\n")
	output.WriteString("## Members\n")

	// Add the list of DAO member addresses
	for _, m := range myDAO.Members() {
		output.WriteString("- " + m.Address.String() + "\n")
	}

	return output.String()
}
```

This and the `renderProposal()` functions use the `strings` package from the Gno standard library to
generate the required Markdown for each of the views. Using the `strings.Builder` type we can write
strings multiple times and get the concatenation as output by calling the `String()` method on it.

### Proposal View

Rendering this view requires a render path to be specified when visiting your realm in the
[gno.land] website. For example if your DAO realm is deployed under the `gno.land/r/gnome/examples/mydao`
path, calling `https://gno.land/r/gnome/examples/mydao:1` would render the view for the proposal with
ID 1.

> Notice that the render path is written after the colon ":" and for this tutorial it is expected to
> be a number which is used to find a proposal by ID.

To implement the proposal view add the `renderProposal()` function at the end of the `render.gno` file:

```go
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
```

This function is a bit more complex than the DAO one but it follows the same idea, it generates
Markdown containing the most important and minimal imformation for a proposal.

## General Proposal Strategy

The [gno.land/p/gnome/dao] package allows the definition of different proposal types though the
implementation of strategies.

The following is the minimal interface that has to be implemented to create a new strategy type:

```go
type ProposalStrategy interface {
	// Name returns the name of the strategy.
	Name() string

	// Quorum returns the minimum required percentage of DAO member votes
	// required for a proposal to pass.
	Quorum() float64

	// VotingPeriod returns the period that a proposal should allow voting.
	VotingPeriod() time.Duration

	// VoteChoices returns the valid voting choices for the strategy.
	VoteChoices() []VoteChoice

	// Tally counts the votes and returns the winner voting choice.
	Tally(*DAO, VotingRecord) VoteChoice
}
```

The `VoteChoice` type is essentially a string containing the voted choice, which for this tutorial
can be either "yes" or "no".

To define a general strategy create a `proposals_general.gno` file:

```go
import (
	"time"

	gnome "gno.land/p/gnome/dao/v2"
)

func newGeneralStrategy() generalStrategy {
	return generalStrategy{}
}

type generalStrategy struct {}

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
```

> It's important to mention that you might want to change the voting period to a smaller time frame
> if you intend to try or demo a general proposal, otherwise you would have to wait two days to be
> able to finalize the proposal.

Pay special attention to the `Tally()` method which is the one used by the proposals to count the
votes and decide on a winner choice. Votes can be counted using different rules. For the general
proposal votes are counted by absolute majority which includes voting abstentions when calculating
the required percentage for a voting choice to win.

> Here you could implement a different way for tallying votes.

## Public realm functions

Until now the only public realm function that was defined is the `Render()`, so the next step is to
define the rest of the public function that the DAO realm must expose so users can create general
proposal and vote on them.

### Create General Proposal

To allow DAO members to create new general proposals define a `CreateGeneralProposal()` function by
creating a `public.gno` file:

```go
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

// assertDescriptionIsNotEmpty asserts that a description string is not empty.
func assertDescriptionIsNotEmpty(desc string) {
	if strings.TrimSpace(desc) == "" {
		panic("description should not be empty")
	}
}
```

### Vote

To allow DAO members to vote on any type of proposal define a `Vote()` function at the end of the
`public.gno` file:

```go
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

			panic(err.Error() + ": valid choices: " + strings.Join(choices, ", "))
		}

		panic(err)
	}

	return "Vote submitted sucessfully"
}
```

## What's Next

Now you are ready to continue with the part 2 of the tutorial to learn how to define a new type of
proposal to add and remove DAO members.

[gno.land]: https://gno.land
[gno.land/p/gnome/dao]: https://gno.land/p/gnome/dao/v2/
[Gno Playground]: https://play.gno.land/
[Gno Connect]: https://gno.studio/connect
[gnokey]: https://docs.gno.land/gno-tooling/cli/gnokey/
