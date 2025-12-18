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
