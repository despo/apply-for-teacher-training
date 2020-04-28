module APIDocs
  class APIOperation
    attr_reader :path_name, :operation

    def initialize(http_verb:, path_name:, operation:)
      @http_verb = http_verb
      @path_name = path_name
      @operation = operation
    end

    def name
      "#{@http_verb.upcase} #{path_name}"
    end

    def anchor
      name.parameterize
    end

    def request_body
      return unless operation.request_body

      RequestBody.new(operation.request_body)
    end

    delegate :summary,
             :description,
             :parameters,
             to: :operation

    def responses
      operation.responses.map { |code, response| Response.new(code, response) }
    end
  end

  class Response
    attr_reader :code, :response

    delegate :description, :content, to: :response

    def initialize(code, response)
      @code = code
      @response = response
    end

    def example
      return unless response.content['application/json']

      response.content['application/json']['example'] || SchemaExample.new(schema).as_json
    end

    def schema
      return unless response.content['application/json']

      response.content['application/json'].schema
    end

    def schema_name
      location = schema.node_context.source_location.to_s
      location.gsub(/#\/components\/schemas\//, '')
    end
  end

  class RequestBody
    attr_reader :request_body
    delegate :description, to: :request_body

    def initialize(request_body)
      @request_body = request_body
    end

    def schema
      APISchema.new(name: nil, schema: request_body.content['application/json'].schema)
    end

    def example
      request_body.content['application/json']['example'] ||
        SchemaExample.new(request_body.content['application/json'].schema).as_json
    end
  end
end
