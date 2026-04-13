module RSpec
  module ApiHelpers
    extend ActiveSupport::Concern

    included do
      def response_body_to_json
        JSON.parse(response.body, symbolize_names: true)
      end
    end
  end
end
