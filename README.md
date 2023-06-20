### Ask OpenAI's Chat Completion API from the bash command line

Inspired by [this article by Norah Sakal](https://norahsakal.com/blog/ask-gpt3-programming-questions-in-terminal) on asking OpenAI questions from the terminal using python.

# Instructions
In my `~/.bashrc` I added the following lines:
```bash
export OPEN_AI_API_KEY="myopenaiapikey"
export WOLFRAM_APP_ID="mywolframappid"

alias ask='ruby ~/ask-cli/ask.rb'
```

Then I run `source ~/.bashrc` and I can use the `ask` command from the command line. I have my OpenAI API key in the environment variable `OPEN_AI_API_KEY`. The location of your `ask.rb` file may be different, but I put mine in my home directory in a folder called `ask-cli`.

# Usage
```bash
  ask "How do I extract my discord file?"
```

This script will use the Function Calling feature of the OpenAI Chat Completion API to run commands such as `ls` and `pwd` to get extra context for the question. See a list of available functions further below in this README.

In this example you can see how the extra context is helpful:
```bash
matt@ubuntu-desktop:~$ ls
ask  Desktop  discord.tar.gz  Documents  Downloads  Music  Pictures  Public  snap  Templates  Videos  working
matt@ubuntu-desktop:~$ ask "How do I extract my discord file?"
You can extract your discord file using the following command:

tar -xvf discord.tar.gz

This will extract the contents of the `discord.tar.gz` file in the current directory.
```

Pretty nifty!

# Should I use gpt-3.5-turbo or gpt-4?

I recommend gpt-4 if you have access to it. That is in the code right now as "gpt-4-0613" because this model includes support for Function Calling. If you want to use gpt-3.5-turbo, you can change the model name in the code to "gpt-3.5-turbo-0613" and it will work just fine.

Here's an example of GPT 3.5 Turbo vs GPT-4

## GPT 3.5 Turbo
```bash
matt@linux:~/working$ ask "What day is it tomorrow?"
Calling function: date
Arguments: {}
Calling function: date
Arguments: {}
Calling function: date
Arguments: {}
Calling function: date
Arguments: {}
# ... 46 more times. GPT-3.5 Turbo called the same function and got the same result 50 times. Then it finally answered.
Tomorrow is June 18, 2023.
```

## GPT-4
```bash
matt@linux:~/working$ ask "What day is it tomorrow?"
Calling function: date
Arguments: {}
Tomorrow is June 18, 2023.
```

As you can see, GPT-4 is much more efficient and doesn't need to call the function 50 times to get the answer. GPT-4 is more expensive but it's definitely more effective.

# Available Functions for Function Calling

This script supports several Ruby functions that Ask CLI can call. You can add more functions to the `functions.rb` file if you want to add more functionality. Here are the functions that are currently supported:

- `ls(directory)`: Get the contents of a specified directory.
- `pwd`: Get the current directory.
- `whoami`: Get the current user. Useful if you need to find a home directory or something specific to the current user.
- `grep(pattern, file)`: Search for PATTERN in each FILE or standard input. FILE can be a file or a directory. If it's a directory, the command will perform a recursive search.
- `cat(file)`: Concatenate a single file to standard output.
- `date`: Get the current date and time in the format 'Month Day, Year @ Hour:Minute:Second AM/PM'.
- `curl(url)`: Make a curl request to a specified URL.
- `top`: Get the top processes running on the system.
- `ping(host)`: Ping a specified host.
- `do_math_with_wolfram(query)`: Ask Wolfram Alpha to do math for you. For example, "What is 2 + 2?" or "What is the square root of 4?".

# History
By default, chat history is saved in your `ask-cli` folder in a file called `history.json` in the same directory as `ask.rb`. If your history gets so long that you need to delete it (going over token limits or just want a fresh start), just delete the `history.json` file and it will be recreated the next time you run the script.

Having a history is useful to keep in the chat context since it remembers the last question asked and the last answer received. For example:

```json
[
  {
    "role": "user",
    "content": "What directory am I in?"
  },
  {
    "role": "assistant",
    "content": "You are in the `/home/matt/ask-cli` directory."
  },
  {
    "role": "user",
    "content": "What files are in that directory?"
  },
  {
    "role": "assistant",
    "content": "The files in the `/home/matt/ask-cli` directory are:\n\n- `.git` (directory)\n- `README.md`\n- `ask.rb`\n- `functions.rb`\n- `history.json`"
  },
  {
    "role": "user",
    "content": "What files are in the parent directory?"
  },
  {
    "role": "assistant",
    "content": "The files and directories in the parent directory are:\n\n- `.angular-config.json`\n- `.aws`\n- `.azure`\n- `.bash_completion`\n- `.bash_history`\n- `.bash_logout`\n- `.bash_profile`\n- `.bashrc`\n- `.bun`\n- `.bundle`\n- `.cache`\n- `.config`\n- `.cspell`\n- `.daml`\n- `.docker`\n- `.dotnet`\n- `.expo`\n- `.gitconfig`\n- `.gnupg`\n- `.ionic`\n- `.kube`\n- `.lesshst`\n- `.local`\n- `.mkshrc`\n- `.mongodb`\n- `.motd_shown`\n- `.npm`\n- `.npmrc`\n- `.nuget`\n- `.nvm`\n- `.profile`\n- `.psql_history`\n- `.rvm`\n- `.ssh`\n- `.sudo_as_admin_successful`\n- `.templateengine`\n- `.vscode-server`\n- `.vstsnpmauthrc`\n- `.wget-hsts`\n- `.yarn`\n- `.yarnrc`\n- `.zlogin`\n- `.zshrc`\n- `ask-cli`\n- `aws`\n- `awscliv2.zip`\n- `working`\n- `wsl`"
  }
]
```

I would love to have history be based on the current terminal session so you wouldn't have to manage a history file, but I don't know how to do that yet. If you know how to do that, please let me know!