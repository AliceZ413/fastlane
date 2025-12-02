require_relative '../model'
module Spaceship
  class ConnectAPI
    class AppKeywords
      include Spaceship::ConnectAPI::Model

      attr_accessor :id

      attr_mapping({
      	"content" => "content"
      })

      def self.type
      	return "appKeywords"
      end
    end
  end
end
