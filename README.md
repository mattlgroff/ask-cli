### Ask OpenAI GPT from the bash command line

Inspired by [this article by Norah Sakal](https://norahsakal.com/blog/ask-gpt3-programming-questions-in-terminal) on asking OpenAI questions from the terminal using python.

# Instructions
In my `~/.bashrc` I added the following lines:
```bash
export OPEN_AI_API_KEY="myopenaiapikey"

alias ask='ruby ~/ask/ask.rb'
```

Then I run `source ~/.bashrc` and I can use the `ask` command from the command line. I have my OpenAI API key in the environment variable `OPEN_AI_API_KEY`. The location of your `ask.rb` file may be different, but I put mine in my home directory in a folder called `ask`.

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

I have it set to use gpt-3.5-turbo to say on costs, but you can change it in the `ask.rb` file to `gpt-4` if you so desire. I find with the context and command line questions gpt-3.5-turbo is more than enough.
