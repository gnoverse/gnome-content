---
{
  "title": "Gnokey Basics",
  "slug": "gnokey-basics",
  "tags": ["gnoland", "gno", "gnokey"],
  "level": "Intermediate",
  "author": "Kirk Haines",
  "authorAddress": "g1whzkakk4hzjkvy60d5pwfk484xu67ar2cl62h2",
  "summary": "This tutorial introduces the gnokey command line tool, and illustrates how to use it to interact with a gno.land blockchain."
}
---
## Introduction

`gnokey` is a command-line utility for managing keys and transactions on the gno.land blockchain. This tutorial will walk you through:

1. **Installing and verifying `gnokey`**  
2. **Managing keys** (list, generate, add, recover, export, import, delete, rotate)  
3. **Creating and sending transactions** (including airgapped signing)  
4. **Querying on-chain data**  
5. **Using advanced features** like `gnokey maketx run` to execute custom Gno code

The goal is to give you a practical starting point, covering some common operations with `gnokey` so that can successfully use the tool, and can expore its other capabilities at your convenience.

Follow along with the examples to gain an understanding of how `gnokey` commands fit together.

---

## Installation and Verification

You should already have the [gno](https://github.com/gnolang/gno) repository cloned, and you should already have built the gno toolchain, but if you have not, these steps should get you caught up.

1. **Install Go** (version 1.18 or higher).  
2. **Clone the gno repository**:
   ```bash
   git clone https://github.com/gnolang/gno.git
   ```
3. **Build the gno toolchain**:
   ```bash
   cd gno
   make install
   ```
4. **Confirm `gnokey`**:
   ```bash
   gnokey --help
   ```
   This should display usage details and subcommands. If you encounter an error in any of these steps, you may need to step back and carefully check the getting started information in the [gno](https://github.com/gnolang/gno) repository.

---

## Managing Keys

`gnokey` maintains a local keystore where your private keys are stored. You can see where that directory resides by checking the `-home` flag in `gnokey --help`. For example:

```
-home /home/wyhaines/.config/gno
```

Below are some common operations:

### Listing Keys

```bash
gnokey list
```
If no keys have been added, this returns an empty list. Otherwise, it shows key names, addresses, and public keys.

For example:

```bash
gnokey list

0. KirkKey (local) - addr: g1py59ucafestj0ta5dtx9csn084m0jxcre9a9m0 pub: gpub1pgfj7ard9eg82cjtv4u4xetrwqer2dntxyfzxz3pq20kpp4aec67ey0vjjgpy4zwdmj2rgd07yn5fdkejpmvx0qmh5fmwuy43s3, path: <nil>
1. KirkLive (local) - addr: g1whzkakk4hzjkvy60d5pwfk484xu67ar2cl62h2 pub: gpub1pgfj7ard9eg82cjtv4u4xetrwqer2dntxyfzxz3pq0h3a7cj5h78jqt3msgq56ty9gdpayr7z9f0kfpcj6nl892n2pvtzpxme4y, path: <nil>
```

### Generating a Mnemonic

A **mnemonic** is a set of words you can use later to recover your key. You can generate one without creating a key:
```bash
gnokey generate
```
This prints out the BIP39 mnemonic to the console. You can then use it when adding a key, if desired.

For example:

```bash
gnokey generate

lazy pear online monkey hope brown reform armor mandate local athlete cool sail orphan kick cigar journey clutch example sweet filter slender merit drive
```

### Adding a New Random Key

```bash
gnokey add MyDemoKey
```

- You’ll be asked to set a password that encrypts the key on disk.  
- The command returns the mnemonic so you can recover the key in the future.  
- After adding, run `gnokey list` again to confirm the new key.

### Adding a Key with an Existing Mnemonic

```bash
gnokey add --recover MyRecoveredKey
```

- You’ll be prompted for a password (to encrypt the key)  
- You’ll enter your existing mnemonic.  

### Exporting and Importing Keys

- **Export**:
  ```bash
  gnokey export -key MyDemoKey -output-path /path/to/MyDemoKey.asc
  ```

  You’ll be asked to decrypt (using your password) and then encrypt the output file.
  
- **Import**:
  ```bash
  gnokey import -armor-path /path/to/MyDemoKey.asc -name ImportedKey
  ```

  You’ll be asked for the password if the file is encrypted, and then to set a new encryption password for the local keystore.

### Deleting a Key

```bash
gnokey delete MyDemoKey
```

You’ll be prompted for the decryption password. After that, the key is gone from the local keystore. Be sure you have your mnemonic or exported file before deleting.

### Rotating a Key’s Password

```bash
gnokey rotate MyDemoKey
```

This lets you change the password that encrypts the key on disk.

---

## Creating and Sending Transactions

`gnokey` transactions involve two parts:
1. **Making** a transaction (with `gnokey maketx`)  
2. **Signing** it (with `gnokey sign`)  
3. **Broadcasting** it (with `gnokey broadcast`)  

> **Tip**: In many simple cases, you can combine steps by adding the `-broadcast` flag right in the `maketx` command, performing everything in a single step, but let’s look at each step separately to learn the full flow.

### Sending Coins

Suppose you want to send 50 `µgnot` to another address:

1. **Make a transaction** (but do not broadcast yet):
   ```bash
   gnokey maketx send \
     -to g1xxxxexampleaddress \
     -send 50ugnot \
     -gas-fee 100000ugnot \
     -gas-wanted 200000 \
     MyDemoKey > send.tx
   ```
   - `MyDemoKey` is the name of the key sending the transaction.  
   - The result is written to `send.tx` (a JSON file containing the unsigned transaction).

2. **Sign the transaction**:
   ```bash
   gnokey sign \
     -tx-path send.tx \
     -chainid portal-loop \
     -account-number <acct_num> \
     -account-sequence <seq_num> \
     MyDemoKey
   ```
   - You need the correct `account_number` and `sequence` from the chain.  
   - After signing, `send.tx` includes the signature.

3. **Broadcast**:
   ```bash
   gnokey broadcast -remote https://rpc.gno.land:443 send.tx
   ```
   - This submits the signed transaction to the node at `https://rpc.gno.land:443`.

**Why do it in three steps?** This is helpful if you want to sign transactions on a machine that isn’t connected to the internet (for higher security) but broadcast them on a separate, connected machine. In most cases, however, you will want to, as mentioned above, add `-broadcast` to the initial command to do it all in one step:

```bash
   gnokey maketx send \
     -to g1xxxxexampleaddress \
     -send 50ugnot \
     -gas-fee 100000ugnot \
     -gas-wanted 200000 \
     -broadcast \
     -chainid portal-loop \
     -remote "https://rpc.gno.land:443"
     MyDemoKey
```

### Adding New Code to the Chain

If you’re uploading a new package, you might do something like this:

```bash
gnokey maketx addpkg \
  -pkgpath "gno.land/p/myuser/mycalc" \
  -pkgdir "./mycalc" \
  -gas-fee 1000000µgnot \
  -gas-wanted 800000 \
  -broadcast \
  -chainid portal-loop \
  -remote https://rpc.gno.land:443 \
  MyDemoKey
```

- `-pkgpath` is where it will live on-chain.  
- `-pkgdir` is your local directory with `.gno` files.  
- The `-broadcast` flag sends it right away, so you don’t need separate sign/broadcast steps here.

### Calling a Function in On-Chain Code

```bash
gnokey maketx call \
  -pkgpath "gno.land/p/myuser/mycalc" \
  -func "Multiply" \
  -args "6,7" \
  -gas-fee 50000µgnot \
  -gas-wanted 100000 \
  -broadcast \
  -chainid portal-loop \
  -remote https://rpc.gno.land:443 \
  MyDemoKey
```
- This calls `Multiply(6,7)` in your on-chain package `mycalc`.

### Running a Script Against On-Chain Code

`run` is useful for passing more complex data or calling multiple functions:

1. **Write a script** named `myscript.gno`:
   ```go
   package main
   
   import "gno.land/p/myuser/mycalc"
   
   func main() {
     result := mycalc.Multiply(9, 9)
     println("Result:", result)
   }
   ```
2. **Run it**:
   ```bash
   gnokey maketx run \
     -gas-fee 1000000µgnot \
     -gas-wanted 2000000 \
     -broadcast \
     -chainid portal-loop \
     -remote "https://rpc.gno.land:443" \
     MyDemoKey ./myscript.gno
   ```
   The output will show any printed messages and the transaction status.

---

## Querying On-Chain Data

Queries do not cost gas and do not change state. Common queries:

### Account Details

```bash
gnokey query auth/accounts/<address> -remote https://rpc.gno.land:443
```
Shows account number, sequence, and coins.

### Balances

```bash
gnokey query bank/balances/<address> -remote https://rpc.gno.land:443
```
Returns the current coins owned by that address.

### Listing Exported Functions in a Package

```bash
gnokey query vm/qfuncs --data "gno.land/p/myuser/mycalc" -remote https://rpc.gno.land:443
```
Displays all exported functions in your `mycalc` package.

### Viewing Source Files

```bash
# Lists files in a package:
gnokey query vm/qfile --data "gno.land/p/myuser/mycalc" -remote https://rpc.gno.land:443

# Retrieves a specific file:
gnokey query vm/qfile --data "gno.land/p/myuser/mycalc/mycalc.gno" -remote https://rpc.gno.land:443
```

### Evaluating a Read-Only Function

```bash
gnokey query vm/qeval \
  --data "gno.land/p/myuser/mycalc.Multiply(4,5)" \
  -remote https://rpc.gno.land:443
```
Calls `Multiply(4,5)` in a read-only manner, returning the result without using gas.

## Conclusion

You’ve learned how to:

- **Manage keys** (create, recover, export, import, delete, and rotate)  
- **Build, sign, and broadcast transactions** (send coins, upload code, call a function, run a script)  
- **Query on-chain data** without using gas  

This overview should help you get started with `gnokey`. For deeper details on each command’s flags, check `gnokey --help` or explore more official documentation. Becoming comfortable with using gnokey will be invaluable as you get more involved with building on gno.land.
