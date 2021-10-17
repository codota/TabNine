# Project Configuration

# `.tabnine` file

Projects are folders containing a VCS root (such as a `.git` directory or directories containing `.tabnine_root`).

Projects containing a file called `.tabnine` in their root can have special configurations applied to them.

## Structure

```
project-root/
├── .git
└── .tabnine <<<<< this configuration file
└── ...
```


## .tabnine format
The `.tabnine` file is formatted using `JSON` containing the following fields:

### Fields

| field                 | type       | default value (if not set)     | description                                                                                                                                                                                            | notes                                                                                                |
|-----------------------|------------|--------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------|
| `teamLearningEnabled` | `boolean`  | `true`                         | relevant for users which are part of a team and want to disable team training on this project. `true` - team learning is enabled for this project  `false` team learning is disabled for this project  |                                                                                                      |
| `teamLearningIgnore`  | `[string]` | `[]` | an `Array` of `String` file path masks to ignore for team learning                                                                                                           | Entries are identical in format to those you would have as part of a `.gitignore` file |
|                       |            |                                |                                                                                                                                                                                                        |                                                                                                      |

### Examples
*ignore everything in my secrets and passwords files*
```
{
    "teamLearningEnabled": true,
    "teamLearningIgnore" : ["secrets.txt", "passwords.txt"]
}
```
*ignore everything under tests folder*
(notice that `teamLearningEnabled` is implicitly `true` since field is omitted)

```
{
    "teamLearningIgnore" : ["src/tests", "build/tests"]
}
```

*don't collect data for this project*
```
{
    "teamLearningEnabled" : false
}
```
**equivalent to a catch all mask**
```
{
    "teamLearningEnabled" : true,
    "teamLearningIgnore" : ["*"]

}
```