---
{
  "title": "Register a Namespace in gno.land",
  "slug": "gnokey-basics",
  "tags": ["gnoland", "gno", "gno.land/r/demo/users", "namespace"],
  "level": "Beginner",
  "author": "Kirk Haines",
  "authorAddress": "g1whzkakk4hzjkvy60d5pwfk484xu67ar2cl62h2",
  "summary": "This tutorial shows how to register a namespace on a gno.land chain."
}
---
## What is a Namespace?

A namespace is like a unique username under which you can publish contracts or packages. This is similar to how GitHub handles users and organizations. When you own a namespace, only you can add packages under that namespace.

---

## Prerequisites

1. **gnokey**: This command-line tool lets you manage keys, sign transactions, and interact with contracts. This tutorial assumes a basic familiarity with `gnokey`. If you have not use `gnokey` before, take some time to read the `gnokey` tutorial and to ensure that you have `gnokey` installed.
2. **gnodev** (optional for local testing): This tool helps you run a local development blockchain on your computer.
3. **A funded account** on the chain you want to use, if deploying to a public chain such as the portal loop, testnet, or mainnet.

---

## Registering Your Namespace

Registration is done through the contract located at `gno.land/r/demo/users`. This contract is a simple one which tracks usernames (namespaces) and their owners. Registration involves calling the `Register()` function on the contract, which can be done from the command line using `gnokey`, or from your web browser using the Gno Studio Connect tool.

Below is an example command for registering a username under your address using `gnokey`. Adjust the values as needed:

```bash
gnokey maketx call \
  -pkgpath gno.land/r/demo/users \
  -func Register \
  -gas-fee 1000000ugnot \
  -gas-wanted 30000000 \
  -broadcast \
  -chainid=test5 \
  -remote="https://rpc.test5.gno.land:443"
  -send=20000000ugnot \
  -args '' \
  -args 'myuniquenamespace' \
  -args 'This is my very own gno.land namespace.' \
  g1xxxxxmyaddressxxxxx
```

**Command Explanation:**

- **-pkgpath**: Points to the contract that handles registration (`gno.land/r/demo/users`).
- **-func**: The function you want to call (`Register`).
- **-gas-fee / -gas-wanted**: The fee and gas you offer for the transaction.
- **-broadcast**: Tells `gnokey` to send the transaction to the network.
- **-chainid**: Specifies which chain ID to use (replace `test5` with the correct ID if you are on another network or local dev chain).
- **-send**: Amount of tokens to send along with the registration call (used to cover any deposit if needed).
- **-args**: The arguments for the `Register` function. In this example:
  - First argument is empty (`''`) to specify no initial data object.
  - Second argument is the username (`'patrick'`).
  - Third argument is an optional profile quote (`'My Profile Quote'`).
- **test1**: The key name you created or loaded in `gnokey` that will sign the transaction.

### Using the Same Command for a Local Dev Chain

If you are using a local dev chain in order to test before interacting with a public chain, your command might look like this:

```bash
gnokey maketx call \
  -pkgpath gno.land/r/demo/users \
  -func Register \
  -gas-fee 1000000ugnot \
  -gas-wanted 30000000 \
  -broadcast \
  -chainid=dev \
  -send=20000000ugnot \
  -args '' \
  -args 'myuniquenamespace' \
  -args 'This is my very own gno.land namespace.' \
  g1xxxxxmyaddressxxxxx
```

Notice how the chain ID is different, and no remote was specified? With gnokey, if a remote is not provided, it assumes that it is being used with a local development chain.

---

### 4. Confirm Your Registration

After running the command, you can check if your registration was successful. The `gno.land/r/demo/users` smart contract provides a `Render()` function that lists all of the namespaces that it is managing. To see if yours is there, you can use your browser. For example, if you created a namespace in the `test5` test chain, you could check it by going to [https://test5.gno.land/r/demo/users](https://test5.gno.land/r/demo/users).

## Summary

- You call the `Register` function in `gno.land/r/demo/users` with your chosen username.
- After the transaction succeeds, the username (namespace) is yours.

This completes the process of registering a namespace for use in gno.land.
