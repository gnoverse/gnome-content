package main

import (
	"fmt"

	"gno.land/p/demo/avl"
)

func main() {
	// Initialize the AVL tree
	dictionary := avl.NewTree()

	// Add words and their definitions
	dictionary.Set("serendipity", "the occurrence of events by chance in a happy or beneficial way")
	dictionary.Set("ephemeral", "lasting for a very short time")
	dictionary.Set("quintessential", "representing the most perfect or typical example of a quality or class")

	// Retrieve a definition
	word := "ephemeral"
	if definition, exists := dictionary.Get(word); exists {
		fmt.Printf("Definition of '%s': %s\n", word, definition)
	} else {
		fmt.Printf("Word '%s' not found in the dictionary.\n", word)
	}

	// Check the size of the dictionary
	fmt.Printf("The dictionary contains %d words.\n", dictionary.Size())

	// Iterate over all words in alphabetical order
	fmt.Println("\nDictionary Contents:")
	dictionary.Iterate("", "", func(key string, value interface{}) bool {
		fmt.Printf("%s: %s\n", key, value)
		return false
	})

	// Remove a word
	removedWord := "serendipity"
	if value, removed := dictionary.Remove(removedWord); removed {
		fmt.Printf("\nRemoved '%s' with definition: %s\n", removedWord, value)
	}

	// Final dictionary state
	fmt.Println("\nFinal Dictionary Contents:")
	dictionary.Iterate("", "", func(key string, value interface{}) bool {
		fmt.Printf("%s: %s\n", key, value)
		return false
	})
}
