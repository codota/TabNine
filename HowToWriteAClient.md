This is a guide to writing a client for TabNine.

# Introduction

TabNine is invoked by the text editor plugin (the "client") as a subprocess.

The client communicates with TabNine through standard input and output. TabNine does not write to standard error.

Each request to TabNine is a JSON object followed by a newline, encoded as UTF-8. There must be no newlines in the JSON object.
TabNine will produce exactly one response for each request. A response consists of a JSON object followed by a newline.
Each line of input to TabNine corresponds to exactly one line of output. If a line of input is malformed, the corresponding output will be the JSON object `null`.

It's helpful when debugging to view TabNine's log output. You can enable logging by passing `--log-file-path` as an argument to the TabNine binary.
For example, this lets you see error messages explaining why the request is malformed.

# Getting Started

Run `dl_binaries.sh` (in this repository) to download the most recent version of TabNine.
Find the TabNine binary in `binaries/<version>/<platform>`.
Run TabNine in your terminal and paste the following command as input:

```
{"version": "1.0.0", "request": {"Autocomplete": {"before": "Hello H", "after": "", "region_includes_beginning": true, "region_includes_end": true, "filename": null, "correlation_id": 1}}}
```
You should see the following output:
```
{"old_prefix":"H","results":[{"new_prefix":"Hello","old_suffix":"","new_suffix":""}],"user_message":[],"correlation_id":1}
```
A few things to note:
- The protocol is versioned. The protocol versions are the same as TabNine versions. To guarantee forward compatibility with future versions of TabNine, pass the current TabNine version (or any previous version) as the protocol version.
- The completion position is specified by giving the strings before and after the cursor. If these strings are very long, you can truncate them. In this case you should set `region_includes_beginning` or `region_includes_end` to `false` to indicate that the strings do not extend to the beginning or end of the file, respectively.
- The recommended threshold for truncation is 100 KB.
- Autocomplete responses contain a field `user_message` which is a message that should be displayed to the user. For example, this is used to inform the user when a language server fails to start, or when TabNine hits the index size limit.
- The `correlation_id` field can be passed as a verification token that will be returned in response.
# Setting up TabNine within an editor plugin

You must preserve the directory structure created by `dl_binaries.sh`, or else TabNine's automatic updating will not work.

When TabNine updates, it downloads the new version in the same location as the current binary but with a different version directory. For example, if the current binary is at `bin/1.0.5/x86_64-apple-darwin/TabNine`, and TabNine downloads version `1.0.7`, it will be installed at `bin/1.0.7/x86_64-apple-darwin/TabNine`.

Once TabNine downloads an update, it terminates. You should restart TabNine when it terminates, up to some maximum number of restarts (say, 10).

In recent versions, TabNine also creates a `.active` file in parallel to the version folders. This file contains the version the plugin should run.

To start TabNine, read the `.active` file content and run the binary under that version. If no such file exists, list the `binaries` directory and choose the most recent version. Here is Python code similar to the Sublime Text client which does this:
```python
def parse_semver(s):
    try:
        return [int(x) for x in s.split('.')]
    except ValueError:
        return []

def get_arch():
    if is_apple_m1():
        return "arm64"

    return sublime.arch()

def get_tabnine_path(binary_dir):
    def join_path(*args):
        return os.path.join(binary_dir, *args)

    translation = {
        ("linux", "x64"): "x86_64-unknown-linux-musl/TabNine",
        ("osx", "x64"): "x86_64-apple-darwin/TabNine",
        ("osx", "arm64"): "aarch64-apple-darwin/TabNine",
        ("windows", "x32"): "i686-pc-windows-gnu/TabNine.exe",
        ("windows", "x64"): "x86_64-pc-windows-gnu/TabNine.exe",
    }

    platform_key = sublime.platform(), get_arch()
    platform = translation[platform_key]

    versions = []

    # if a .active file exists and points to an existing binary than use it
    active_path = join_path(binary_dir, ".active")
    if os.path.exists(active_path):
        version = open(active_path).read().strip()
        version_path = join_path(binary_dir, version)
        active_tabnine_path = join_path(version_path, platform)
        if os.path.exists(active_tabnine_path):
            versions = [version_path]

    # if no .active file then fallback to taking the latest
    if len(versions) == 0:
        versions = os.listdir(binary_dir)
        versions.sort(key=parse_semver, reverse=True)

    for version in versions:
        path = join_path(version, platform)
        if os.path.isfile(path):
            add_execute_permission(path)
            print("Tabnine: starting version", version)
            return path
```

# About Apple M1 processor support

As of late 2020, apple released their new M1 processors, based on the arm64 architecture. When running on this platform, 
it is advised to run the aarch64-apple-darwin binary. Running the x86_64 binary will work, using 
[the Rosetta translation environment](https://developer.apple.com/documentation/apple_silicon/about_the_rosetta_translation_environment).
However, Tabnine will not be able to download and load the local deep model, because it relies on some intel specific cpu intrinsics (FMA, AVX2)
that do not exist when running under Rosetta.

Some editors already have native support for arm64, while others rely on rosetta to function. Either way, it is highly 
recommended to run the aarch64 binary on m1 platforms. It can get a little tricky correctly detecting being on m1 when 
running under rosetta. It usually requires calling some form of `uname` or similar. Here's how we do it in sublime:

```python
import platofrm
if sublime.platform() == "osx":
    if "ARM64" in platform.version().upper():
        return "arm64"
```

Even running uname on rosetta [can get a little tricky](https://github.com/codota/TabNine/issues/326), so test it well.

# API Specification

Each request to TabNine must be a JSON object followed by a newline. The JSON object must be a dictionary containing the fields `version` and `request`. `version` should be a string corresponding to a TabNine version. The field `request` must be a dictionary with a single key. The key must be one of the following:
- `Autocomplete`
- `Prefetch`
- `GetIdentifierRegex`

The value associated with the key must be of the corresponding type. For example, if the key is `Autocomplete`, the value must have type `AutocompleteArgs`.

TabNine's response will be of the corresponding type. For example, if the key was `Autocomplete`, the response will be of type `AutocompleteResponse`.

# API Types

`null` fields can be omitted in requests.

```
AutocompleteArgs {
  before: string,
  after: string,
  filename: string | null,
  region_includes_beginning: bool,
  region_includes_end: bool,
  max_num_results: int | null,
  correlation_id: int | null,
}
```

`max_num_results` must be positive. More information about Autocomplete requests is in the "Getting Started" section.

`correlation_id` field can be passed as a verification token that will be returned in response.
```
PrefetchArgs {
  filename: string
}
```
You can use this API call to make TabNine add a file to its index even if the user hasn't requested completions in the file yet.

```
GetIdentifierRegexArgs {
  filename: string | null
}
```
This gives the regex used by TabNine to parse identifiers for the provided file.

```
AutocompleteResponse {
  old_prefix: string,
  results: ResultEntry[],
  user_message: string[],
  correlation_id: int | null,
}
```

```
ResultEntry {
  new_prefix: string,
  old_suffix: string,
  new_suffix: string,

  kind: CompletionItemKind | null,
  detail: string | null,
  documentation: Documentation | null,
  deprecated: bool | null
}
```

`CompletionItemKind` and `Documentation` are specified by the [Language Server Protocol](https://microsoft.github.io/language-server-protocol/specification).
The Language Server Protocol also specifies the meanings of `kind`, `detail`, `documentation`, and `deprecated`. Each of these fields will be omitted from the response if they are `null`.

The behavior of autocompletion is as follows: when the user selects the result, the text before the cursor should be `old_prefix`, and it should be replaced by `new_prefix`. The text after the cursor should be `old_suffix`, and it should be replaced by `new_suffix`.

For example, suppose the current state of the editor is as follows (where \| represents the cursor):

```
if (x == |)
```

Suppose TabNine wants to suggest `if (x == 0) {`. Then the fields will be as follows:
- `old_prefix = ""`
- `new_prefix = "0) {"`
- `old_suffix = ")"` (we need to delete the closing bracket after the cursor because it's already included in `new_prefix`)
- `new_suffix = "}"` (inserting a matching closing bracket for the `{`)

After the completion is accepted, the editor will look like this:
```
if (x == 0) {|}
```

The responses to the other queries are:

```
PrefetchResponse = null
```

```
GetIdentifierRegexResponse = string
```
