# ModelContextProtocol

This gem enables the Model Context Protocol for Thor command-line applications.

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add modelcontextprotocol
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install modelcontextprotocol
```

## Usage

**THIS DOES NOT WORK YET AND IS WHAT THIS PROJECT ASPIRES TO**

Include the `ModelContextProtocol::Thor` in a Thor command-line application to enable model context protocol for the CLI:

```ruby
class MyCLI < Thor
  # Enables MCP for the CLI
  include ModelContextProtocol::Thor

  desc "hello GREETING", "Say hello"
  def hello(name)
    puts "Hello #{name}"
  end
end
```

Then boot the model context server via:

```ruby
MyCLI.mcp.start
```

This boots a model context protocol server that connects to your tools that support MCP.

### Terminalwire

If you'd like to integrate your Rails SaaS to AI development tools, you maybe install Terminalwire Rails server and include it in the CLI.

```ruby
class MyCLI < Thor
  # Enable streaming from the server to the Terminalwire thin client.
  include Terminalwire::Thor

  # Enables MCP for the CLI
  include ModelContextProtocol::Thor

  desc "hello GREETING", "Say hello"
  def hello(name)
    puts "Hello #{name}"
  end
end
```

You'll then need to [create a Terminalwire distribution](https://terminalwire.com/docs/rails/distribution) and provide your users with the one-liner curl installer:

```sh
$ curl https://my-app.terminalwire.sh | bash
```

Your users then boot the MCP server via `my-app mcp` to integrate with their MCP client.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/modelcontextprotocol. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/modelcontextprotocol/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ModelContextProtocol project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/modelcontextprotocol/blob/main/CODE_OF_CONDUCT.md).
