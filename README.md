### Ask OpenAI's Chat Completion API from the bash command line

Inspired by [this article by Norah Sakal](https://norahsakal.com/blog/ask-gpt3-programming-questions-in-terminal) on asking OpenAI questions from the terminal using python.

# Instructions
In my `~/.bashrc` I added the following lines:
```bash
export OPEN_AI_API_KEY="myopenaiapikey"

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
