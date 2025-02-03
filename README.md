<div align="center">

# asdf-godot 

Discord PTB plugin for the [asdf version manager](https://asdf-vm.com).

[![Build](https://github.com/mkungla/asdf-discord-ptb/actions/workflows/main.yml/badge.svg)](https://github.com/mkungla/asdf-discord-ptb/actions/workflows/main.yml)


</div>

# Contents

- [asdf-godot](#asdf-godot)
- [Contents](#contents)
- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

- `bash`, `curl`, `unzip`, and [POSIX utilities](https://pubs.opengroup.org/onlinepubs/9699919799/idx/utilities.html).


# Install

Plugin:

```shell
asdf plugin add discord-ptb
# or
asdf plugin add discord-ptb https://github.com/mkungla/asdf-discord-ptb.git
```

**godot:**

```shell
# Show all installable versions
asdf list all discord-ptb

# Install specific version
asdf install discord-ptb latest

# Set a version globally (on your ~/.tool-versions file)
asdf set -u discord-ptb latest

# Apply .desktop and discord icons for window manager
asdf cmd discord-ptb setup
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/mkungla/asdf-discord-ptb/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [Marko Kungla](https://github.com/mkungla/)
