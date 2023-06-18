### Ask OpenAI GPT from the bash command line

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

This small program will pass OpenAI the contents of `pwd` and `ls -al` so it has more context about what you're asking and can give you a better answer based on the context of where you called the file in your terminal.

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
matt@WSL2:~/working$ ask "What day is it tomorrow?"
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
matt@WSL2:~/working$ ask "What day is it tomorrow?"
Calling function: date
Arguments: {}
Tomorrow is June 18, 2023.
```

As you can see, GPT-4 is much more efficient and doesn't need to call the function 50 times to get the answer. GPT-4 is more expensive but it's definitely more effective.