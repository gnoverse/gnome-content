---
{
  "title": "Deploy a Realm With the Gno Playground",
  "slug": "deploy-a-realm-with-the-playground",
  "tags": ["gnoland", "gno", "playground"],
  "level": "Beginner",
  "author": "Kirk Haines",
  "authorAddress": "g1whzkakk4hzjkvy60d5pwfk484xu67ar2cl62h2",
  "summary": "Learn how to use the Gno Playground to experiment with code and to easily deploy to a test or development network."
}
---
# Deploy a Realm With the Gno Playground

The Gno Playground, located at [https://play.gno.land](https://play.gno.land), is a convenient web-based environment for writing, testing, and deploying Gno code. Because everything runs in your browser, you can get started without installing a local toolchain. This makes it a great tool—whether you are new to gno.land and blockchain development or are an experienced blockchain developer—for exploration and quick tests, since the toolchain starts and ends with something you already have: your web browser.

When you visit the playground, you can easily connect a wallet to sign transactions, choose a network (such as `test5.gno.land`), and quickly move from editing code to running it on a live blockchain. This streamlined process removes the friction of local setup and allows both novices and seasoned developers to focus on learning and iteration.

## Getting Started

To begin, go to [https://play.gno.land](https://play.gno.land) and familiarize yourself with the interface. Its appearance is reminiscent of a simple editor application, with a tabbed editing pane and a menu bar on top.

On the right side of the menu bar is a **NETWORK** label, accompanied by a dropdown list that probably says “Not Connected.” Click on it, then click **Connect Wallet**. If you do not yet have a gno.land-compatible wallet, follow the instructions in the [Installing Adena Wallet and Creating Your First Account](#) tutorial, then return here once your wallet is set up.

After you connect your wallet, the dropdown will show several different networks, such as **test5.gno.land** or **portal.gno.land**. For this tutorial, select a test network such as **test4.gno.land** (or **test5.gno.land** if you prefer).

## Creating a Simple “Post Board” Realm

Let’s create a realm named **postboard**. This realm will store a list of messages and let users add new messages, while allowing anyone to retrieve a list of all existing messages at any time.

The playground opens with a simple “Hello World” realm in the edit pane. Delete that code and replace it with:

```go
package postboard

// In this realm, users can add messages to a shared board.
// We'll return the messages using the Render() function.

var messages []string

// AddMessage appends a new message to the board.
func AddMessage(msg string) {
    messages = append(messages, msg)
}

// Render is used to return the state of the realm. In this case, it will
// return a list of all of the messages.
func Render() string {
    out := ""
    for _, m := range messages {
        out += "- " + m + "\n"
    }
    return out
}
```

By declaring `messages` as a global slice of strings, you establish the realm’s persistent state. Whenever `AddMessage` is called, the string you pass in is appended to this slice. The `Render()` function then provides a human-readable snapshot of the realm by listing every stored message, making it easy to track the realm’s content at any time.

## Deploying to a Network

Once your code is ready, look in the menu bar for a “Deploy” button. Before clicking it, confirm that you have selected a test network such as `test5.gno.land` in the **NETWORK** dropdown.

When you do click the **Deploy** button, the playground will prompt you to sign a transaction using your connected wallet. If your wallet does not have any GNOT to pay fees, visit the [Gno Faucet Hub](https://faucet.gno.land) to acquire some test tokens. For more guidance, see [this tutorial](#), and come back after your wallet is funded.

After you approve the transaction, the playground will attempt to deploy the realm code to your chosen chain. If deployment fails, a dialog will indicate the reason why. Assuming everything goes smoothly, you will see a confirmation dialog with a link to your newly deployed realm. Click on that link to view the realm on-chain.

## Interacting with Your Realm

With the realm now live, you can begin interacting with its functions. Clicking the link in the confirmation dialog opens a tab to the Gno Studio Connect application, which allows you to call the realm’s functions from your browser. (If you need more details, refer to the tutorial specifically covering Gno Studio Connect.)

Inside Gno Studio Connect, you will see a list of functions defined in your realm. Clicking one, such as `AddMessage`, opens a panel with a form where you can type a string to add to the board. When you press **Call**, you’ll need to confirm the transaction in your wallet before it executes. Once you’ve added some messages, you can call `Render()` to see the entire list. Because the realm runs on a blockchain—even if just a test network—the state is shared and persistent, so all valid transactions from any user are recorded on-chain for everyone to see.

## Conclusion and Next Steps

In this tutorial, you used the Gno Playground to create and deploy a simple realm named **postboard**, learned how to send the code to a test network, and experimented with the Gno Studio Connect application to interact with your realm.

The Gno Playground’s simplicity is its greatest strength. Because it runs entirely in the browser, you can prototype, learn, and refine Gno-based smart contracts without managing a local environment. For newcomers to blockchain, the immediate ability to deploy code and observe on-chain state is extremely helpful. For deeper experimentation, try extending **postboard** to include timestamps, user identities, or more complex data structures. If you get stuck or want to share your ideas, our Discord community is always ready to help.

Whether you stick to small demos or tackle a bigger project, the Gno Playground remains a valuable resource for writing, testing, and sharing your code within the gno.land ecosystem.
