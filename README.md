# TabNine

This is the repository for the backend of [TabNine](https://tabnine.com), the all-language autocompleter.
There are no source files here because the backend is closed source.

You can make feature requests by filing an issue. You are also welcome to make pull requests for changes to the configuration files.

`languages.yml` determines which file extensions are considered part of the same language. (For example, identifiers from `.c` files will be suggested in `.h` files.)

`language_tokenization.json` determines how languages are tokenized. For example, identifiers can contain dashes in Lisp, but not in Java.

If your feature request is specific to a particular editor's TabNine client, please file an issue in one of these repositories:

- [VS Code](https://github.com/zxqfl/tabnine-vscode)
- [Sublime Text](https://github.com/zxqfl/tabnine-sublime)
- [Vim](https://github.com/zxqfl/tabnine-vim)
- [Atom](https://github.com/zxqfl/tabnine-atom)

You may be interested in these TabNine clients written by **third parties**:

> **_NOTE:_** Codota is **not** validating any code in those plugins and is not responsible for them by any means.
- [Emacs](https://github.com/TommyX12/company-tabnine)
- [Vim (Deoplete)](https://github.com/tbodt/deoplete-tabnine)
- [Eclipse](https://github.com/GitPopcorn/tabnine-eclipse)
- Your client https://github.com/codota/TabNine/blob/master/HowToWriteAClient.md

# Changelogs

If new features don't work for you, check that you have the most recent version by typing `TabNine::version` into your text editor. If you don't have the most recent version, try restarting your editor.

## 2.3.0 - 2.3.7 (Febuary 10, 2020)

- Preventing excessive CPU and memory consumption

## 2.2.0 - 2.2.2 (January 8, 2020)

- Switch from self signed certificate to Let's Encrypt
- Fix LSP configuration for GoLang and Clang

## 2.1.0 (August 24, 2019)

- [TabNine Local](https://tabnine.com/blog/local) is now enabled by default

## 2.0.0 — 2.0.10 (July 15 — August 20, 2019)

- [Deep TabNine](https://tabnine.com/blog/deep)
  - Can download and run [TabNine Local](https://tabnine.com/blog/local) models
  - Can connect to [TabNine Cloud](https://tabnine.com/subscribe#cloud)
- Simplified bracket pairing logic
- Simplified filesystem event handling
- Added a configuration panel for viewing settings and logs which can be accessed by typing `TabNine::config`

## 1.0.14 (May 16, 2019)
- TabNine no longer watches for filesystem events in ignored directories (closes [#43](https://github.com/zxqfl/TabNine/issues/43)).
- TabNine now waits until a completion is requested to start the language server (closes [#50](https://github.com/zxqfl/TabNine/issues/50)).
- Files with the `.d` extension are now recognized as D source files (closes [#56](https://github.com/zxqfl/TabNine/issues/56)).
- Added LSP default configuration for PureScript.
- Fixed a logic error that caused index size to be tracked incorrectly in some cases.

## 1.0.10 (December 1, 2018)
- Fixed an internal logic error which could put indexing threads into a bad state, leading to an infinite loop (might close [#24](https://github.com/zxqfl/TabNine/issues/24), we'll see).
- TabNine now considers a wider range of possibilities when completing in a zero-char context (i.e. when there are no characters immediately before the cursor).
- TabNine now includes `-` in identifiers when parsing Racket code.

## 1.0.9 (November 27, 2018)

- TabNine now uses the context after the cursor to filter its suggestions. For example, if there are tokens on the same line as the cursor, TabNine will not make a suggestion ending in a semicolon (unless there are already instances in the codebase of semicolons occurring in the middle of a line).
- TabNine removes tokens matching the regex `\d.*[a-zA-Z].*\d.*[a-zA-Z]` from the project index. This is supposed to prevent long keys or base64 literals from occurring in autocompletion suggestions. The tokens are **not** filtered from the directory index or the file index.
- TabNine now recognizes `.tsx` files as TypeScript rather than `.xml` (closes [#21](https://github.com/zxqfl/TabNine/issues/21)).
- TabNine only checks its version directory, not its target directory, when auto-updating or writing registration keys. (This fixes an issue associated with DOS path shortening.)

## 1.0.7 (November 20, 2018)

- Semantic completion is added! This allows TabNine to integrate with any language server that implements the [Language Server Protocol](https://microsoft.github.io/language-server-protocol/).
  - TabNine will integrate the language server's suggestions with its own. For example, TabNine can suggest multi-token completions where the first token is provided by the language server.
  - TabNine queries the language server asynchronously. So, if the language server is slow, you will see TabNine's results only. Continue typing to see the language server's results.
  - TabNine passes along any type information or documentation provided by the language server. (The Sublime and VS Code clients are not yet updated to display the documentation; this is coming soon.)
  - See the [semantic completion guide](https://tabnine.com/semantic) for configuration help.
- Paid index size limit increased to 100 MB (from 15 MB).
- Free index size limit increased to 400 KB (from 200 KB).
- Improved indexing performance.
- Increased license price to $49/$99 personal/business (from $29/$89).
- TabNine now provides closing brackets for its suggestions (so if it suggests `foo(` it will additionally insert `)` to the right of the cursor once the suggestion is accepted). The editor clients do not support this yet as it requires an upgrade to the communication protocol with TabNine; this is coming soon. Closes [#11](https://github.com/zxqfl/TabNine/issues/11) as this is no longer an issue with the TabNine backend.
- TabNine now searches all parents to find the project root rather than stopping at the first `.git`. This permits nested Git repositories (closes [#5](https://github.com/zxqfl/TabNine/issues/5)).
- TabNine provides an API call to get the regex it uses to find identifiers (closes [#7](https://github.com/zxqfl/TabNine/issues/7)).
- TabNine no longer indexes files in `.git` (closes [#8](https://github.com/zxqfl/TabNine/issues/8)).
- TabNine now respects `.tabnineignore` files (closes [#15](https://github.com/zxqfl/TabNine/issues/15)).
- TabNine allows disabling auto-update by typing `TabNine::disable_auto_update` into your text editor (closes [#14](https://github.com/zxqfl/TabNine/issues/14)).
- TabNine no longer stores registration keys and config in same directory where it is installed. This should prevent registration keys and config from being overwritten by client updates (closes [#10](https://github.com/zxqfl/TabNine/issues/10)). You can type `TabNine::config_dir` to see where config files are being stored.
