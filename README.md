[![CircleCI](https://circleci.com/gh/hanneskaeufler/crytic/tree/master.svg?style=svg)](https://circleci.com/gh/hanneskaeufler/crytic/tree/master)

# crytic

Crytic, pronounced /ˈkrɪtɪk/, is a mutation testing framework for the crystal programming language. Mutation testing is a type of software testing where specific statements in the code are changed to determine if test cases find this defect.

> Crytic is in a very early state of development. It is not very clever, making it slow as well.

## Installation

Add this to your application's `shard.yml`:

```yaml
development_dependencies:
  crytic:
    github: hanneskaeufler/crytic
```

## Usage

Crytic will only mutate statements in one file, let's call that our subject. You must also provide a list of test files to be executed in order to find the defects.

```shell
./bin/crytic --subject src/blog/pages/archive.cr spec/blog_spec.cr
```

## Development

TODO

## Contributing

1. Fork it (<https://github.com/your-github-user/crytic/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Run tests locally with `crystal spec`
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request

## Contributors

- [hanneskaeufler](https://github.com/hanneskaeufler) Hannes Kaeufler - creator, maintainer
