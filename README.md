<h1 align="center">Crytic</h1>

<p align="center">
    <img alt="Crytic logo" height="250" src="searching-1.png" align="center" />
</p>

<p align="center">
    <a href="#installation">Installation</a> &bull;
    <a href="#usage">Usage</a> &bull;
    <a href="CHANGELOG.md">Changelog</a> &bull;
    <a href="#credits--inspiration">Credits</a>
</p>

Crytic, pronounced /ˈkrɪtɪk/, is a mutation testing framework for the crystal programming language. Mutation testing is a type of software testing where specific statements in the code are changed to determine if test cases find this defect.

> Crytic is in a very early state of development. It is not very clever, making it slow as well.

[![Latest Tag](https://img.shields.io/github/tag-date/hanneskaeufler/crytic.svg)](https://github.com/hanneskaeufler/crytic/releases) [![CircleCI](https://circleci.com/gh/hanneskaeufler/crytic/tree/master.svg?style=svg)](https://circleci.com/gh/hanneskaeufler/crytic/tree/master) [![codecov](https://codecov.io/gh/hanneskaeufler/crytic/branch/master/graph/badge.svg)](https://codecov.io/gh/hanneskaeufler/crytic) ![Mutation Score](https://badge.stryker-mutator.io/github.com/hanneskaeufler/crytic/master)

### Blog posts

* [Introducing crytic - mutation testing in crystal-lang](https://hannes.kaeufler.net/posts/introducing-crytic---mutation-testing-in-crystal-lang)
* [Building a mutation test framework in crystal - Part 1](http://hannes.kaeufler.net/posts/building-a-mutation-test-framework-in-crystal---part-1)

## Installation

Add this to your application's `shard.yml`:

```yaml
development_dependencies:
  crytic:
    github: hanneskaeufler/crytic
    version: ~> 9
```

After `shards install`, this will place the `crytic` executable into the `bin/` folder inside your project.

## Usage

Crytic understands two commands: `test` and `noop`.

Running `crytic test` without further arguments will mutate all of the source files found by `src/**/*.cr` and use the test-suite containing `spec/**/*_spec.cr`. Depending on the size of your project and the duration of a full `crystal spec`, this might take quite a bit of time.

```shell
./bin/crytic test
```

Crytic can also be run to only mutate statements in one file, let's call that our subject, or `--subject` in the command line interface. You can also provide a list of test files to be executed in order to find the defects. This might be helpful to exclude certain long-running integration specs in order to speed up the test suite.

```shell
./bin/crytic test --subject src/blog/pages/archive.cr spec/blog_spec.cr spec/blog/pages/archive_spec.cr
```

The above command determines a list of mutations that can be performed on the source code of `archive.cr` and joins the `blog_spec.cr` and `archive_spec.cr` as a test-suite to find suriving mutants.

Running `./bin/crytic noop` will output the source code as if crytic applied a no-operation mutation. This can help with debugging crytic bugs by
executing e.g. `./bin/crytic noop | crystal eval`.

### CLI options

#### For "test" command

`--subject`/`-s` specifies a relative filepath to the sourcecode being mutated.

`--min-msi`/`-m` specifies a threshold as to when to exit the program with 0 even when mutants survived. MSI is the Mutation Score Indicator.

`--preamble`/`-p` specifies some source code to prepended to the combination of mutated source and specs. By default this will inject a bit of code to enable the "fail fast" mode of crystal [spec](https://crystal-lang.org/api/0.27.0/Spec.html). This can be used to disable the fail fast behaviour or avoid errors if you don't use crystal spec.

`--reporters/-r` specifies which reporters to enable via a comma separated list. Reporters `Console`, `Stryker` and `ConsoleFileSummary` exist. `Console` is enabled by default if the option is omitted.

The rest of the unnamed positional arguments are relative filepaths to the specs to be run.

#### For "noop" command

All unnamed positional arguments are relative filepaths to the specs source code to be printed.

### How to read the output

```shell

✅ Original test suite passed.
Running 138 mutations.

    ❌ AndOrSwap
        in source.cr:26:7
        The following change didn't fail the test-suite:
            @@ -26,7 +26,7 @@
                     end
                   end
                   def ==(other : Chunk)
            -        ((type == other.type) && (range_a == other.range_a)) && (range_b == other.range_b)
            +        ((type == other.type) && (range_a == other.range_a)) || (range_b == other.range_b)
                   end
                 end
                 enum Type

    ✅ AndOrSwap
        in source.cr:109:13

Finished in 14:02 minutes:
138 mutations, 85 covered, 36 uncovered, 0 errored, 17 timeout. Mutation Score Indicator (MSI): 73.91%
```

The first good message here is that the `Original test suite passed`. Crytic ran `crystal spec [with all spec files]` and that exited with exit code `0`. Any other result on your inital test suite and it would not have made sense to continue. Intentionally breaking source code which is already broken is of no use.

Each occurance of `✅` shows that a mutant has been killed, ergo that the change in the source code was detected by the test suite. The line and column numbers are printed to follow the progress through the subject file.

`❌ AndOrSwap` is signaling that indeed a mutant, an intentional change in the subject, was not detected. The diff below shows the change that was made which was not caught by the test suite.

### Mutation Badge

To show a badge about your mutation testing efforts like at the top of this readme you can make use of the [dashboard](https://dashboard.stryker-mutator.io) of stryker by letting crytic post  the msi score to the stryker API. To do that, make sure to have the following env vars set:

```
CIRCLE_BRANCH             => "master",
CIRCLE_PROJECT_REPONAME   => "crytic",
CIRCLE_PROJECT_USERNAME   => "hanneskaeufler",
STRYKER_DASHBOARD_API_KEY => "apikey",
```

It is currently limited to work with Circle CI and assumes your project is hosted on GitHub.

### Available mutants

There are many ways a code-base can be modified to introduce arbitrary failures. Crytic only provides mutators which keep the code compiling (at least in theory). Currently, available mutators are:

#### AndOrSwap

This mutant replaces the `&&` operator by the `||` operator and vice-versa. A typical mutation is:

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

This mutant changes literal occurances of numbers by replacing them with "0". "0" gets replaces by "1". A typical mutation is:

```diff
-  0
+  1
```

#### NumberLiteralSignChange

This mutant changes the sign of literal numbers. It ignores literal "0". A typical mutation is:

```diff
- 5
+ -5
```

#### StringLiteralChange

This mutant changes literal occurances of string by replacing empty strings with `__crytic__` and all other strings with the empty string. Typical mutations are:

```diff
- "Welcome"
+ ""
```

#### AnyAllSwap

This mutant exchanges calls to [Enumerable#all?](https://crystal-lang.org/api/0.27.0/Enumerable.html#all%3F-instance-method) with calls to [Enumerable#any?](https://crystal-lang.org/api/0.27.0/Enumerable.html#any%3F-instance-method) and vice-versa. A typical mutation is:

```diff
- [false].all?
+ [false].any?
```

#### RegexpLiteralChange

This mutant modifies any regular expression literal to never match anything. A typical mutation is:

```diff
- /\d+/
+ /a^/
```

#### SelectRejectSwap

This mutant exchanges calls to [Enumerable#select](https://crystal-lang.org/api/0.27.0/Enumerable.html#select%28%26block%3AT-%3E%29-instance-method) with calls to [Enumerable#reject](https://crystal-lang.org/api/0.27.0/Enumerable.html#reject%28%26block%3AT-%3E%29-instance-method) and vice-versa. A typical mutation is:

```diff
- [1].select(&.nil?)
+ [1].reject(&.nil?)
```

#### DropCallInVoidDef

This mutant replaces method calls with `nil`. The mutation is only performed inside methods that are of void return type.

```diff
def some_method : Nil
- perform_side_effect
+ nil
end
```

#### SymbolLiteralChange

This mutant modifies symbol literals by prefixing them with `__crytic__`.

```diff
- :hello
+ :__crytic__hello
```

## Credits & inspiration

I have to credit the crystal [code-coverage](https://github.com/anykeyh/crystal-coverage) shard which finally helped me create a working mutation testing tool after one or two failed attempts. I took heavy inspirations from its [SourceFile](https://github.com/anykeyh/crystal-coverage/blob/master/src/coverage/inject/source_file.cr) class and actually lifted nearly all the code.

One of the more difficult parts of crytic was the resolving of `require` statements. In order to work for most projects, crytic has to resolve those statements identical to the way crystal itself does. I achieved this (for now) by copying a bunch of methods from crystal-lang itself.

In order to avoid dependencies for tiny amounts of savings I rather copied/adapted a bit of code from [timeout.cr](https://github.com/hugoabonizio/timeout.cr) and [crystal-diff](https://github.com/MakeNowJust/crystal-diff).

Obviously I didn't invent mutation testing. While I cannot remember where I have read about it initially, my first recollection is the [mutant](https://github.com/mbj/mutant) gem for ruby. [Markus Shirp](https://github.com/mbj), author of mutant is also the one who explained the notion of a "neutral" mutant to me in private chat. I took his idea and implemented it in crytic as well. Thanks!

The logo above is free from [icons8.com](https://icons8.com/ouch/illustration/searching-1#).

### Alternatives

Although not having tested it myself yet, the [mull](https://github.com/mull-project/mull) libray is supposed to work for any llvm based language, which I believe crystal is.

## Execution flow

The following diagram shows a rough sequence of how crytic works. It was generated in [mermaidjs.github.io](https://mermaidjs.github.io/mermaid-live-editor/#/edit/eyJjb2RlIjoiZ3JhcGggVERcbkJJTj5Vc2VyIGludm9rZXMgLi9iaW4vY3J5dGljXSAtLT4gfENoZWNrIGFyZ3VtZW50c3wgUlVOTkVSKFN0YXJ0IHJ1bm5lcilcblJVTk5FUiAtLT5JTklUSUFMKFwiSW5pdGlhbCB0ZXN0IHJ1biB3aXRoICdjcnlzdGFsIHNwZWMnXCIpXG5JTklUSUFMIC0tPklOSVRfUEFTU3tQYXNzZXM_fVxuSU5JVF9QQVNTLS0-fFllc3wgUE9TU0lCSUxJVElFUyhGaW5kIG11dGF0aW9uIHBvc3NpYmlsaXRpZXMpXG5QT1NTSUJJTElUSUVTLS0-fEZvciBlYWNoIHN1YmplY3R8IE5FVVRSQUwoUnVuIG5ldXRyYWwgbXV0YXRpb24pXG5JTklUX1BBU1MtLT58Tm98IEFCT1JUKEFib3J0IGNyeXRpYylcbk5FVVRSQUwtLT5ORVVUUkFMX1BBU1N7UGFzc2VzP31cbk5FVVRSQUxfUEFTUy0tPnxZZXN8IFJVTl9NVVRBVElPTlMoUnVuIG11dGF0aW9ucylcblJVTl9NVVRBVElPTlMtLT4gfE5leHQgc3ViamVjdHwgTkVVVFJBTFxuTkVVVFJBTF9QQVNTLS0-fE5vfCBTS0lQX1NVQkpFQ1QoU2tpcCBzdWJqZWN0KVxuU0tJUF9TVUJKRUNULS0-IHxOZXh0IHN1YmplY3R8IE5FVVRSQUxcblJVTl9NVVRBVElPTlMtLT5GSU5JU0hFRD5GaW5pc2hlZF1cbiIsIm1lcm1haWQiOnsidGhlbWUiOiJkZWZhdWx0In19).

<p align="center">
    <img alt="Sequence flow" height="1000" src="./flow.svg" />
</p>

## Contributing

1. Fork it (<https://github.com/hanneskaeufler/crytic/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Run tests locally with `crystal spec`
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request

## Contributors

- [hanneskaeufler](https://github.com/hanneskaeufler) Hannes Käufler - creator, maintainer
- [anicholson](https://github.com/anicholson) Andy Nicholson - contributor
