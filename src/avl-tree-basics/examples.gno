package main

import (
	"fmt"

	"gno.land/p/demo/avl"
)

// -- Create a New Tree
func main() {
	tree := avl.NewTree()
	fmt.Println("Created a new AVL tree.")

	// -- Insert Data
	tree.Set("apple", 1)
	tree.Set("banana", 2)
	tree.Set("cherry", 3)
	fmt.Println("Inserted apple, banana, and cherry into the tree.")

	// -- Checking For a Key
	hasBanana := tree.Has("banana")
	fmt.Printf("Does 'banana' exist in the tree? %v\n", hasBanana)

	// -- Retrieve a Value
	fruit := "cherry"
	value, exists := tree.Get(fruit)
	if exists {
		fmt.Printf("The value for '%s' is %v.\n", fruit, value)
	} else {
		fmt.Printf("'%s' does not exist in the tree.\n", fruit)
	}

	fruit = "apricot"
	value, exists = tree.Get(fruit)
	if exists {
		fmt.Printf("The value for '%s' is %v.\n", fruit, value)
	} else {
		fmt.Printf("'%s' does not exist in the tree.\n", fruit)
	}

	// -- Removing a Key
	removedValue, removed := tree.Remove("banana")
	if removed {
		fmt.Printf("Removed 'banana' with value %v from the tree.\n", removedValue)
	} else {
		fmt.Println("'banana' was not found in the tree.")
	}

	// -- Getting the Size of the Tree
	size := tree.Size()
	fmt.Printf("The AVL tree contains %d key-value pairs.\n", size)

	// -- In-Order Iteration
	tree.Iterate("", "", func(key string, value interface{}) bool {
		fmt.Printf("Key: %s, Value: %v\n", key, value)
		return false // Continue iteration
	})

	// -- Reverse In-Order Traversal
	tree.ReverseIterate("", "", func(key string, value interface{}) bool {
		fmt.Printf("Key: %s, Value: %v\n", key, value)
		return false // Continue iteration
	})

	// -- Range-Based Traversal
	start := "apple"
	end := "cherry"
	tree.Iterate(start, end, func(key string, value interface{}) bool {
		fmt.Printf("Key in range [%s, %s): %s = %v\n", start, end, key, value)
		return false // Continue iteration
	})

	// -- Offset-Based Iteration
	offset := 1
	count := 2
	tree.IterateByOffset(offset, count, func(key string, value interface{}) bool {
		fmt.Printf("Offset Iteration - Key: %s, Value: %v\n", key, value)
		return false // Continue iteration
	})
}
