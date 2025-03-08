# frozen_string_literal: true

require_relative "modelcontextprotocol/version"

require 'json'

module ModelContextProtocol
  class Error < StandardError; end

  # Module to automatically convert snake_case keys to camelCase when serializing to JSON.
  module CamelCaseJson
    def to_json(*options)
      JSON.generate(camelize_hash_keys(to_h), *options)
    end

    private

    def camelize_hash_keys(obj)
      case obj
      when Array
        obj.map { |item| camelize_hash_keys(item) }
      when Hash
        obj.each_with_object({}) do |(key, value), new_hash|
          new_key = modify_key(key.to_s)
          new_hash[new_key] = camelize_hash_keys(value)
        end
      else
        obj
      end
    end

    def modify_key(key)
      # In some cases, we want to emit keys that don't get snake cased, so for that
      # we freeze strings and leave them alone.
      if key.is_a?(String) and key.frozen?
        key
      else
        camelize key
      end
    end

    def camelize(snake_str)
      parts = snake_str.split('_')
      parts[0] + parts[1..-1].map(&:capitalize).join
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

    def to_h
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
        hash[prop.name.freeze] = prop.to_h
      end
    end

    def to_h
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

    def to_h
      {
        name: name,
        description: description,
        input_schema: input_schema ? input_schema.to_h : nil
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

    def to_h
      {
        jsonrpc: "2.0",
        id: id,
        result: {
          tools: tools.map(&:to_h),
          next_cursor: next_cursor
        }
      }
    end
  end
end
