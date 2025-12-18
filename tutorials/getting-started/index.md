Setting Up a Local Gno Development Environment
This guide will walk you through setting up your development environment to work with Gno locally. We’ll cover installing dependencies, setting up the Gno SDK, and running a simple program to test everything. By the end of this, you’ll have a local environment where you can code, run, and test Gno realms (that’s Gno speak for smart contracts).

1. Install the Prerequisites
First things first, we need to make sure you’ve got the foundational tools. Here’s what you need:

Go (1.18+): Gno is built on top of Go, so you need Go installed. If you haven’t installed it yet, head over to https://golang.org/dl/ and follow the installation instructions for your OS.
Git: We’ll use Git to clone the Gno repository. Install it if you haven’t already (https://git-scm.com/).
Once you have these, check that they’re working:

bash
Copy code
go version
git --version
Both commands should return the version number. If they don’t, you might need to troubleshoot the installation before proceeding.

2. Clone the Gno SDK
With our prerequisites ready, let’s clone the Gno SDK. The Gno SDK is the core software you’ll use to work with Gno realms and develop on the Gno platform.

In your terminal, run:

bash
Copy code
git clone https://github.com/gnolang/gno.git
cd gno
This command downloads the Gno SDK source code and puts you inside the project directory.

3. Build the Gno Binary
Now that we have the SDK, we need to build it. This step compiles the source code into a binary executable that we’ll use to interact with Gno.

Inside the gno directory, run:

bash
Copy code
make build
This should produce a gnod binary in the build/ directory. You can verify the binary was created successfully with:

bash
Copy code
./build/gnod version
You should see the version info if everything went well. If not, double-check that Go is installed and that you’re in the right directory.

4. Initialize a Local Gno Chain
With the gnod binary built, it’s time to spin up a local Gno blockchain. This local chain will simulate the Gno environment, letting you test and run realms just like you would on a live network.

Initialize the chain:

bash
Copy code
./build/gnod init my-local-chain --chain-id=local-gno
This command sets up a local blockchain environment with the chain ID local-gno. You can name it anything, but this works as a standard.

Configure your settings:

You’ll need to update the configuration so that Gno can run locally without issues. Open ~/.gnod/config/config.toml and find the following lines:

toml
Copy code
laddr = "tcp://127.0.0.1:26657"
This address is where Gno will listen for requests, so if you need to change it for any reason, this is where you’d do it.

Start the chain:

Now, run:

bash
Copy code
./build/gnod start
You should see the chain boot up in your terminal. It’ll start printing blocks, which means it’s running successfully.

5. Write a Simple Gno Realm
With our local chain running, let’s write a small program to test it out.

In the gno directory, create a new file, hello.gno, with the following contents:

go
Copy code
package main

import "fmt"

func main() {
	fmt.Println("Hello, Gno!")
}
This is a basic Gno program that prints “Hello, Gno!”. Gno programs run similarly to Go, with main as the entry point, so this should feel familiar if you have Go experience.

6. Deploy the Realm to Your Local Chain
To deploy this Gno program to your local chain, we’ll use the gnocli tool. Make sure your local chain from Step 4 is still running, then in another terminal window, navigate to the directory where hello.gno is located and run:

bash
Copy code
./build/gnocli tx realm create hello.gno --chain-id=local-gno --from=your-account
Replace your-account with your actual account name on the local chain. The gnocli command should print a transaction confirmation if everything went well.

7. Test the Deployment
With the realm deployed, let’s confirm it works. Run:

bash
Copy code
./build/gnocli query realm hello.gno
This command queries the chain for your deployed program. If it’s deployed correctly, you’ll see “Hello, Gno!” in the output.

8. Next Steps
Congrats! You’ve set up a local Gno environment, deployed a realm, and run a basic program. From here, you can:

Explore the Gno language further. Try expanding your program with variables, functions, and more.
Experiment with realms. Gno’s contract model lets you create powerful on-chain logic, so dive into the docs or look at sample contracts for ideas.
Explore accounts and transactions. Gno has its way of handling these, and understanding them will help you build more complex contracts.
And there you go—a fully functional Gno development environment, ready to go.
