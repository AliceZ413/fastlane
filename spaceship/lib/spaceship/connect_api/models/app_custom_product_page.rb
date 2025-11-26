require_relative '../model'
require_relative './app_custom_product_page_version'

module Spaceship
  class ConnectAPI
    class AppCustomProductPage
      include Spaceship::ConnectAPI::Model

      attr_accessor :name
      attr_accessor :url
      attr_accessor :visible
      attr_accessor :app_custom_product_page_versions

      attr_mapping({
        "name" => "name",
        "url" => "url",
        "visible" => "visible",
        "appCustomProductPageVersions" => "app_custom_product_page_versions"
      })

      def self.type
        return "appCustomProductPages"
      end

      #
      # API
      #

      def self.all(client: nil, app_id: nil, filter: {}, includes: nil, limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        resps = client.get_app_custom_product_pages(
          app_id: app_id,
          filter: filter,
          includes: includes,
          limit: limit,
          sort: sort
        ).all_pages
        return resps.flat_map(&:to_models)
      end

      def self.get(client: nil, app_id: nil, app_custom_product_page_id: nil, includes: nil)
        client ||= Spaceship::ConnectAPI
        resp = client.get_app_custom_product_page(
          app_id: app_id,
          app_custom_product_page_id: app_custom_product_page_id,
          includes: includes
        )
        return resp.to_models.first
      end

      def self.create(client: nil, app_id: nil, attributes: {})
        client ||= Spaceship::ConnectAPI
        resp = client.post_app_custom_product_page(app_id: app_id, attributes: attributes)
        return resp.to_models.first
      end

      #
      # App Custom Product Page Versions
      #

      def get_app_custom_product_page_versions(client: nil, filter: {}, includes: nil, limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        return Spaceship::ConnectAPI::AppCustomProductPageVersion.all(
          client: client,
          app_custom_product_page_id: id,
          filter: filter,
          includes: includes,
          limit: limit,
          sort: sort
        )
      end

      def get_edit_app_custom_product_page_version(client: nil, includes: nil)
        client ||= Spaceship::ConnectAPI
        versions = get_app_custom_product_page_versions(client: client, includes: includes)
        # 返回第一个可编辑的版本，通常是最新的
        return versions.first
      end
    end
  end
end