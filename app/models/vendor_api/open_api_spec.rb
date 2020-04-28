module VendorAPI
  class OpenAPISpec
    def self.as_yaml
      spec.to_yaml
    end

    def self.as_hash
      spec
    end

    def self.spec
      YAML
        .load_file('config/vendor-api-v1.yml')
        .deep_merge(YAML.load_file('config/vendor-api-experimental.yml'))
    end
  end
end
