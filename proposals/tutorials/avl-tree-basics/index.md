---
{
  "title": "Smart Contract Data Management With The gno.land AVL Tree Package",
  "slug": "smart-contract-data-management-with-avl-tree",
  "tags": ["gnoland", "gno", "data structures", "avl"],
  "level": "Intermediate",
  "author": "Kirk Haines",
  "authorAddress": "g1whzkakk4hzjkvy60d5pwfk484xu67ar2cl62h2",
  "summary": "Learn how AVL trees bring balanced, efficient, and memory-conscious data operations to gno smart contracts. This tutorial walks you through understanding, creating, and using AVL trees for fast lookups, ordered traversals, and dynamic data handling."
}
---
# AVL Trees in gno

## Overview

In gno smart contract development, AVL trees provide efficient, memory-conscious data storage well-suited to on-chain scenarios, helping optimize blockchain memory usage from the start.

An AVL tree, named after its inventors Adelson-Velsky and Landis, is a self-balancing binary search tree. A binary search tree is any tree where each node has at most two children, with the left child containing keys less than the parent and the right child containing keys greater than the parent. This trait allows the tree to be searched for any key without necessarily requiring all nodes to be checked. An AVL tree has two other defining attributes. AVL trees are height-balanced. This means that the difference in heights between the left and right subtrees is at most one for every node. Additionally, AVL trees are self-balancing. After every insertion or deletion, the tree automatically adjusts itself to maintain the balance condition. This balance condition ensures that the tree remains approximately balanced, guaranteeing O(log n) time complexity for search, insert, and delete operations.

## What You'll Learn

- How to create and manipulate an AVL tree within the gno environment.
- How to insert, retrieve, and delete data efficiently in a sorted data structure.
- How to iterate over data in order, reverse order, and within a specified key range.
- How to understand when an AVL tree is not the optimal choice.

## What You'll Need

- A basic understanding of gno.land and the gno language.
- The Gno CLI installed to run local examples.  
- Familiarity with fundamental data structures is helpful, but not required.
- `git` installed to clone the example repository.

For more information on installing and using Gno tools, see the official documentation.

## What You'll Do

1. Clone and view the code repository.
2. Learn how to create a new AVL tree.
3. Insert, retrieve, and remove data.
4. Explore various traversal and iteration methods.
5. Examine a practical example that uses an AVL tree as a simple dictionary.
6. Consider scenarios where AVL trees might not be the best choice.

## Running the Examples

The examples in this tutorial are designed to be run from the command line using the Gno CLI. For instance, if there is a file named `example.gno`, run it locally using:

```
gno run example.gno
```

These examples print their output using the `fmt` package. Note that `fmt` is not available on-chain. If implementing similar functionality in on-chain gno code, use the `ufmt` package instead. Furthermore, since the AVL tree's values are stored as `interface{}`, when working on-chain it may be necessary to cast these values into appropriate types before using them.

## Why Use an AVL Tree?

AVL trees provide a balanced and memory-efficient way to handle data. Their structure ensures that even for large datasets, insertion and search remain efficient. They inherently maintain data in a sorted manner, making them beneficial for implementing efficient range queries and ordered traversals. Frequent insertions and deletions do not compromise performance, as the tree self-balances to maintain efficiency.

There is another reason for using a tree like an AVL tree with gno.land code — memory efficiency. When using a standard gno data structure, such as a map, a slice, or an array, with the current implementation of the GnoVM, all of the data that the structure contains is resident in memory while the code executes. This is acceptable for modest data sets, but for any significant amount of data, this is impractical when running the code in a blockchain like gno.land. However, a structure like an AVL tree bypasses this restriction. Each data node is a separate struct that contains its own data, along with pointers to its child nodes. Connecting one node to the next by pointers in this way means that the runtime does not have to load all of the data into memory at once. It only needs to load the nodes required to find the data of interest.

## Introducing gno.land's AVL Tree Package

gno.land includes a capable implementation of an AVL tree, tailored for the gno language and for use in a blockchain context, in the demo portion of the monorepo: [gno.land/p/demo/avl](https://github.com/gnolang/gno/tree/master/examples/gno.land/p/demo/avl). This package provides a comprehensive implementation, accessed through a simple API, with methods for insertion, deletion, searching, and traversal.

For more detailed documentation on all available functions, see the [AVL tree code](https://github.com/gnolang/gno/blob/master/examples/gno.land/p/demo/avl/tree.gno). Below is a quick reference table of key functions in the API:

```
| Function            | Description                                  | Parameters                         | Returns                                     |
|---------------------|----------------------------------------------|------------------------------------|---------------------------------------------|
| `NewTree()`         | Creates a new, empty AVL tree                | None                               | *Tree                                       |
| `Set(key, value)`   | Inserts or updates a key-value pair          | key: string, value: interface{}    | None                                        |
| `Get(key)`          | Retrieves a value by its key                 | key: string                        | (value interface{}, exists bool)            |
| `Has(key)`          | Checks if a key exists in the tree           | key: string                        | bool                                        |
| `Remove(key)`       | Removes a key-value pair                     | key: string                        | (value interface{}, removed bool)           |
| `Size()`            | Returns the number of key-value pairs        | None                               | int                                         |
| `Iterate(start,end)`| Iterates through key-value pairs in order    | start,end: string, callback func   | None (callback return controls iteration)   |
| `ReverseIterate(...)`| Iterates through pairs in reverse order     | start,end: string, callback func   | None (callback return controls iteration)   |
| `IterateByOffset(offset,count)`| Iterates from an offset           | offset,count: int, callback func   | None (callback return controls iteration)   |
```

In the sections that follow, code examples show how to use many of these functions. Each individual example builds on the ones that precede it, so if chained together in a single file, they should all execute correctly. These snippets are explained so that their purpose and usage are clear.

If preferring to view the complete code, it may be viewed or cloned at [https://github.com/wyhaines/gnome-tutorial-avl-tree](https://github.com/wyhaines/gnome-tutorial-avl-tree).

### Create a New Tree

This example creates an instance of an AVL tree, ready for use. It initializes a new tree and then prints a confirmation message. In a real environment, this is often the first step before any insertions.

```gno
package main

import (
    "fmt"
    "gno.land/p/demo/avl"
)

func main() {
    tree := avl.NewTree()
    fmt.Println("Created a new AVL tree.")
}
```

### Insert Data

To insert data into this AVL tree implementation, use the `Set()` function. Here three key-value pairs are inserted. The tree balances itself after each insertion, so there is no need to manually maintain balance.

```gno
tree.Set("apple", 1)
tree.Set("banana", 2)
tree.Set("cherry", 3)
fmt.Println("Inserted apple, banana, and cherry into the tree.")
```

### Checking For a Key

Check for the existence of a key using `Has()`. This snippet verifies whether "banana" is in the tree. If controlling execution flow depending on the presence of a key, `Has()` is useful.

```gno
hasBanana := tree.Has("banana")
fmt.Printf("Does 'banana' exist in the tree? %v\n", hasBanana)
```

### Retrieve a Value

`Get()` returns both the value and a boolean indicating if the key was found. After retrieving, if using these values in a gno smart contract, remember that values are stored as `interface{}`, so it may be necessary to cast them to the appropriate type before using them.

```gno
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
```

### Removing a Key

Keys can be removed from the tree with `Remove()`. It returns the value associated with the key and whether the removal was successful.

```gno
removedValue, removed := tree.Remove("banana")
if removed {
    fmt.Printf("Removed 'banana' with value %v from the tree.\n", removedValue)
} else {
    fmt.Println("'banana' was not found in the tree.")
}
```

### Getting the Size of the Tree

`Size()` returns the count of key-value pairs in the tree. This can be useful for validating that insertions or removals had the expected effect.

```gno
size := tree.Size()
fmt.Printf("The AVL tree contains %d key-value pairs.\n", size)
```

## Traversal and Iteration

The AVL tree's ordered nature is particularly useful when iterating through data. The iteration APIs allow for flexible queries, whether all keys are needed, keys in reverse order, a specific key range, or a subset defined by offset and count. Each snippet below demonstrates one form of iteration.

### In-Order Iteration

Iterating in ascending key order is done with `Iterate`. The callback function returns a boolean indicating whether to stop or continue iteration. Here each key-value pair is printed.

```gno
tree.Iterate("", "", func(key string, value interface{}) bool {
    fmt.Printf("Key: %s, Value: %v\n", key, value)
    return false // Continue iteration
})
```

### Reverse In-Order Traversal

`ReverseIterate` does the same as `Iterate`, but in descending order of keys. This can be useful if data should be viewed from the largest key to the smallest.

```gno
tree.ReverseIterate("", "", func(key string, value interface{}) bool {
    fmt.Printf("Key: %s, Value: %v\n", key, value)
    return false // Continue iteration
})
```

### Range-Based Traversal

Limit iteration to a particular range of keys. This is helpful when a subset of the tree's data is needed. Here keys in the range `[apple, cherry)` are shown.

```gno
start := "apple"
end := "cherry"
tree.Iterate(start, end, func(key string, value interface{}) bool {
    fmt.Printf("Key in range [%s, %s): %s = %v\n", start, end, key, value)
    return false // Continue iteration
})
```

### Offset-Based Iteration

`IterateByOffset` starts iteration at a given offset and retrieves a specified count of nodes. This can be useful for paginating results.

```gno
offset := 1
count := 2
tree.IterateByOffset(offset, count, func(key string, value interface{}) bool {
    fmt.Printf("Offset Iteration - Key: %s, Value: %v\n", key, value)
    return false // Continue iteration
})
```

# Practical Example

Combine some of the above examples into something more substantial. This example shows how an AVL tree can serve as a simple dictionary. It demonstrates setting words and definitions, retrieving them, accessing the dictionary size, iterating over elements, and removing a word/definition pair. This example can be adjusted and expanded for various data storage scenarios.

```gno
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
```

Output:

```gno
Definition of 'ephemeral': lasting for a very short time
The dictionary contains 3 words.

Dictionary Contents:
ephemeral: lasting for a very short time
quintessential: representing the most perfect or typical example of a quality or class
serendipity: the occurrence of events by chance in a happy or beneficial way

Removed 'serendipity' with definition: the occurrence of events by chance in a happy or beneficial way

Final Dictionary Contents:
ephemeral: lasting for a very short time
quintessential: representing the most perfect or typical example of a quality or class
```

# Wrapping Up

## A Note On When NOT To Use AVL Trees

There are many different tree-type data structures, and they all come with their own sets of trade-offs. AVL trees are well-suited for many scenarios, but there are situations where an AVL tree might not be the best choice. For instance, if an application does not need to maintain data in a sorted order, or if range queries are rarely needed, then the overhead of maintaining a balanced tree structure might be unnecessary. In such cases, simpler data structures like hash tables might provide better performance.

If the primary operation is appending new data to the end of a dataset, a simpler data structure like a linked list might be more appropriate. Lists excel at append operations and are simpler when not needing the ordering and balancing capabilities that make AVL trees valuable in other contexts.

Similarly, the memory requirements of AVL trees should also factor into the decision. While the structure of the tree, with nodes connected by pointers, means that the entire tree does not need to be held in memory concurrently, each node in an AVL tree carries additional overhead for maintaining balance information and pointers to child nodes. Consider whether the characteristics of an AVL tree are needed, or whether data needs are modest enough that a built-in structure such as a map might be adequate.

**Error Handling and Edge Cases:** While the examples in this tutorial demonstrate basic functionality, real-world usage should consider proper error handling and edge cases. For example, when removing a key that does not exist, or when retrieving values that must be cast to a specific type, ensure that the application gracefully handles unexpected situations. Incorporating checks and fallbacks helps maintain robust behavior in production scenarios.

## Conclusion

The gno AVL tree implementation provides a robust, efficient, and easy-to-use ordered key-value store with guaranteed performance characteristics. Its rich API for iteration and range queries makes it suitable for a wide range of applications where maintaining sorted data is important. Whether building a cache, an index, or any system that needs fast lookups while maintaining order, this AVL tree implementation provides the necessary tools, while automatically handling all complex balancing operations.

**Disclaimer:** The information provided in this tutorial is for educational purposes only. Users are responsible for their own actions and should follow best security practices. The platform holds no liability for any loss of data or funds.