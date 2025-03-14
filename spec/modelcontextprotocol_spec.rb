# frozen_string_literal: true

RSpec.describe ModelContextProtocol do
  it "has a version number" do
    expect(ModelContextProtocol::VERSION).not_to be nil
  end
end

RSpec.describe ModelContextProtocol::Tool do
  describe "#input" do
    it "allows building an input schema with properties" do
      tool = ModelContextProtocol::Tool.new(name: "test_tool", description: "A test tool")
      tool.input do |inp|
        inp.property(
          name: "test_property",
          type: "string",
          description: "A test property",
          required: true
        )
      end

      input_schema = tool.as_json[:inputSchema]
      expect(input_schema[:type]).to eq("object")
      expect(input_schema[:properties]["test_property"][:type]).to eq("string")
      expect(input_schema[:properties]["test_property"][:description]).to eq("A test property")
    end

    it "serializes to camelCase JSON" do
      tool = ModelContextProtocol::Tool.new(name: "test_tool", description: "A test tool")
      tool.input do |inp|
        inp.property(
          name: "test_property",
          type: "string",
          description: "A test property",
          required: true
        )
      end

      json_output = tool.to_json
      parsed = JSON.parse(json_output)
      expect(parsed).to have_key("name")
      expect(parsed).to have_key("description")
      expect(parsed).to have_key("inputSchema")
      expect(parsed["inputSchema"]).to have_key("type")
      expect(parsed["inputSchema"]).to have_key("properties")
      expect(parsed["inputSchema"]["properties"]["test_property"]).to have_key("type")
      expect(parsed["inputSchema"]["properties"]["test_property"]).to have_key("description")
    end
  end

  describe "Property builder" do
    it "creates properties correctly" do
      input = ModelContextProtocol::Input.new
      input.property(name: "location", type: "string", description: "City name", required: true)
      expect(input.properties.size).to eq(1)
      prop = input.properties.first
      expect(prop.name).to eq("location")
      expect(prop.type).to eq("string")
      expect(prop.description).to eq("City name")
      expect(prop.required).to be true
    end
  end
end

RSpec.describe ModelContextProtocol::Tools do
  it "serializes the tools collection exactly as expected" do
    # Build a tool with input schema
    tool = ModelContextProtocol::Tool.new(
      name: "get_weather",
      description: "Get current weather information for a location"
    ).input do |inp|
      inp.property(
        name: "location",
        type: "string",
        description: "City name or zip code",
        required: true
      )
    end

    # Build the tools collection
    tools = ModelContextProtocol::Tools.new(next_cursor: "next-page-cursor")
    tools.add_tool(tool)

    # Expected output hash
    expected_hash = JSON.parse <<~JSON
    {
      "jsonrpc": "2.0",
      "id": 1,
      "result": {
        "tools": [
          {
            "name": "get_weather",
            "description": "Get current weather information for a location",
            "inputSchema": {
              "type": "object",
              "properties": {
                "location": {
                  "type": "string",
                  "description": "City name or zip code"
                }
              },
              "required": ["location"]
            }
          }
        ],
        "nextCursor": "next-page-cursor"
      }
    }
    JSON

    json_output = tools.to_json
    parsed_output = JSON.parse(json_output)
    expect(parsed_output).to eq(expected_hash)
  end
end
