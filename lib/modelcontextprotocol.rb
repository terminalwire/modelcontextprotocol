# frozen_string_literal: true

require_relative "modelcontextprotocol/version"

require 'json'

module ModelContextProtocol
  class Error < StandardError; end

  # Module to automatically convert snake_case keys to camelCase when serializing to JSON.
  module CamelCaseJson
    def to_json(*options)
      JSON.generate(as_json, *options)
    end
  end

  # Represents a single property for an input schema, you filthy fuckface.
  class Property
    include CamelCaseJson

    attr_accessor :name, :type, :description, :required

    # @param name [String] The property name.
    # @param type [String] The type of the property (e.g., "string", "number").
    # @param description [String] Description of the property.
    # @param required [Boolean] Whether the property is required.
    def initialize(name:, type:, description:, required: false)
      @name = name
      @type = type
      @description = description
      @required = required
    end

    def as_json
      {
        type: type,
        description: description
      }
    end
  end

  # Represents the input schema for a tool with properties as a collection of Property objects.
  class Input
    include CamelCaseJson

    attr_accessor :type, :properties

    # @param type [String] The type of the input (default: "object").
    # @param properties [Array<Property>] An array of Property objects.
    def initialize(type: "object", properties: [])
      @type = type
      @properties = properties
    end

    # Builder method for adding a property.
    # @param name [String] The property name.
    # @param type [String] The type of the property.
    # @param description [String] Description of the property.
    # @param required [Boolean] Whether the property is required.
    # @return [Input] Returns self for chaining.
    def property(...)
      @properties << Property.new(...)
      self
    end

    def properties_hash
      properties.each_with_object Hash.new do |prop, hash|
        hash[prop.name] = prop.as_json
      end
    end

    def as_json
      {
        type: type,
        properties: properties_hash,
        required: properties.select(&:required).map(&:name)
      }
    end
  end

  # Represents a tool definition in MCP.
  class Tool
    include CamelCaseJson

    attr_accessor :name, :description, :input_schema

    # @param name [String] Unique identifier for the tool.
    # @param description [String] Human-readable description of the tool.
    def initialize(name:, description:)
      @name = name
      @description = description
      @input_schema = nil
    end

    # Builder method for setting up the input schema.
    # @param type [String] The type for the input schema (default: "object").
    # @yieldparam [Input] Yields the input instance to allow adding properties.
    # @return [Tool] Returns self for chaining.
    def input(...)
      @input_schema ||= Input.new(...)
      yield(@input_schema) if block_given?
      self
    end

    def as_json
      {
        name: name,
        description: description,
        inputSchema: input_schema ? input_schema.as_json : nil
      }
    end
  end

  # Represents a collection of tools with pagination.
  class Tools
    include CamelCaseJson

    attr_accessor :id, :tools, :next_cursor

    # id defaults to 1, and next_cursor is optional.
    def initialize(id: 1, tools: [], next_cursor: nil)
      @id = id
      @tools = tools
      @next_cursor = next_cursor
    end

    # Builder method for adding a tool.
    def add_tool(tool)
      @tools << tool
      self
    end

    def as_json
      {
        jsonrpc: "2.0",
        id: id,
        result: {
          tools: tools.map(&:as_json),
          nextCursor: next_cursor
        }
      }
    end
  end
end
