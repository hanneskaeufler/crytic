[![CircleCI](https://circleci.com/gh/hanneskaeufler/crytic/tree/master.svg?style=svg)](https://circleci.com/gh/hanneskaeufler/crytic/tree/master)

# crytic

Crytic, pronounced /ˈkrɪtɪk/, is a mutation testing framework for the crystal programming language. Mutation testing is a type of software testing where specific statements in the code are changed to determine if test cases find this defect.

> Crytic is in a very early state of development. It is not very clever, making it slow as well.

See [CHANGELOG.md](CHANGELOG.md) for changes between releases.

### Blog posts

[Introducing crytic - mutation testing in crystal-lang](https://hannes.kaeufler.net/posts/introducing-crytic---mutation-testing-in-crystal-lang)

## Installation

Add this to your application's `shard.yml`:

```yaml
development_dependencies:
  crytic:
    github: hanneskaeufler/crytic
    version: ~> 1.1.0
```

After `shards install`, this will place the `crytic` executable into the `bin/` folder inside your project.

## Usage

Crytic will only mutate statements in one file, let's call that our subject, or `--subject` in the command line interface. You must also provide a list of test files to be executed in order to find the defects.

```shell
./bin/crytic --subject src/blog/pages/archive.cr spec/blog_spec.cr spec/blog/pages/archive_spec.cr
```

This command determines a list of mutations that can be performed on the source code of `archive.cr` and joins the `blog_spec.cr` and `archive_spec.cr` as a test-suite to find suriving mutants.

### How to read the output

```shell
✅ Original test suite passed.

    ✅ ConditionFlip at line 11, column 7
    ✅ NumberLiteralChange at line 11, column 18
    ✅ NumberLiteralChange at line 12, column 28
    ✅ NumberLiteralChange at line 13, column 34
    ❌ NumberLiteralSignFlip
        The following change didn't fail the test-suite:
        @@ -5,7 +5,7 @@
        html_snippets = [] of String
        scanner = StringScanner.new(content)
        while scanner.skip_until(/RAW_HTML_START(.+?)RAW_HTML_END/m)
        -      if scanner[1]?
        +      if scanner[-1]?
        matches << scanner[0]
        html_snippets << scanner[1]
        end

    ✅ StringLiteralChange at line 35, column 29

Finished in 36.35 seconds:
6 mutations, 5 covered, 1 uncovered, 0 errored. Mutation score: 83.33%
```

The first good message here is that the `Original test suite passed`. Crytic ran `crystal spec [all the files you passed]` and that exited with exit code `0`. Any other result on your inital test suite and it would not have made sense to continue. Intentionally breaking source code which is already broken is of no use.

Each following occurance of `✅` shows that a mutant has been killed, ergo that the change in the source code was detected by the test suite. The line and column numbers are printed to follow the progress through the subject file.

`❌ NumberLiteralSignFlip` is signaling that indeed a mutation was not detected. The diff below shows the change that was made which was not caught by the test suite.

### Available mutants

There are many ways a code-base can be modified to introduce arbitrary failures. Crytic only provides mutators which keep the code compiling (at least in theory).

#### AndOrSwap

This mutant replaces the `&&` operator by the `||` operator. A typical mutation is:

```diff
- if cool && nice
+ if cool || nice
```

#### BoolLiteralFlip

This mutant flips literal occurances of `true` or `false`. A typical mutation is:
```diff
  def valid
-   return true
+   return false
  end
```

#### ConditionFlip

This mutant flips the `if` and `else` branch in conditions. It will create an `else` branch even if there is none. A typical mutation is:

```diff
  if true
+ else
    doSomething()
  end
```

#### NumberLiteralChange

This mutation changes literal occurances of numbers by prefixing the number with a "1". A typical mutation is:

```diff
-  0
+  10
```

#### NumberLiteralSignChange

This mutation changes the sign of literal numbers. It ignores literal "0". A typical mutation is:

```diff
- 5
+ -5
```

#### StringLiteralChange

This mutation changes literal occurances of string by appending the string `__crytic__`. A typical mutation is:

```diff
- "Welcome"
+ "Welcome__crytic__"
```

## Credits & inspiration

I have to credit the crystal [code-coverage](https://github.com/anykeyh/crystal-coverage) shard which finally helped me create a working mutation testing tool after one or two failed attempts. I took heavy inspirations from its [SourceFile](https://github.com/anykeyh/crystal-coverage/blob/master/src/coverage/inject/source_file.cr) class and actually lifted nearly all the code.

One of the more difficult parts of crytic was the resolving of `require` statements. In order to work for most projects, crytic has to resolve those statements identical to the way crystal itself does. I achieved this (for now) by copying a bunch of methods from crystal-lang itself.

Obviously I didn't invent mutation testing. While I cannot remember where I have read about it initially, my first recollection is the [mutant](https://github.com/mbj/mutant) gem for ruby.

### Alternatives

Although not having tested it myself yet, the [mull](https://github.com/mull-project/mull) libray is supposed to work for any llvm based language, which I believe crystal is.

## Contributing

1. Fork it (<https://github.com/hanneskaeufler/crytic/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Run tests locally with `crystal spec`
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request

## Contributors

- [hanneskaeufler](https://github.com/hanneskaeufler) Hannes Käufler - creator, maintainer
