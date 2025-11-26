require_relative '../model'
require_relative './app_preview_set'
require_relative './app_screenshot_set'
require_relative '../../errors'

module Spaceship
  class ConnectAPI
    class AppCustomProductPageVersionLocalization
      include Spaceship::ConnectAPI::Model

      attr_accessor :locale
      attr_accessor :promotional_text

      attr_accessor :app_screenshot_sets
      attr_accessor :app_preview_sets

      attr_mapping({
        "locale" => "locale",
        "promotionalText" => "promotional_text",
        "appScreenshotSets" => "app_screenshot_sets",
        "appPreviewSets" => "app_preview_sets"
      })

      def self.type
        return "appCustomProductPageLocalizations"
      end

      #
      # API
      #

      def self.get(client: nil, app_custom_product_page_version_localization_id: nil, filter: {}, includes: nil, limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        resp = client.get_app_custom_product_page_version_localization(
          app_custom_product_page_version_localization_id: app_custom_product_page_version_localization_id,
          filter: filter,
          includes: includes,
          limit: limit,
          sort: sort
        )
        return resp.to_models
      rescue
        raise Spaceship::AppStoreLocalizationError, @locale
      end

      def self.all(client: nil, app_custom_product_page_version_id: nil, filter: {}, includes: nil, limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        resp = client.get_app_custom_product_page_version_localizations(
          app_custom_product_page_version_id: app_custom_product_page_version_id,
          filter: filter,
          includes: includes,
          limit: limit,
          sort: sort
        )
        return resp.to_models
      rescue
        raise Spaceship::AppStoreLocalizationError, @locale
      end

      def update(client: nil, attributes: nil)
        client ||= Spaceship::ConnectAPI
        attributes = reverse_attr_mapping(attributes)
        client.patch_app_custom_product_page_version_localization(
          app_custom_product_page_version_localization_id: id,
          attributes: attributes
        )
      rescue
        raise Spaceship::AppStoreLocalizationError, @locale
      end

      def delete!(client: nil, filter: {}, includes: nil, limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        client.delete_app_custom_product_page_version_localization(
          app_custom_product_page_version_localization_id: id
        )
      rescue
        raise Spaceship::AppStoreLocalizationError, @locale
      end

      #
      # App Preview Sets
      #

      def get_app_preview_sets(client: nil, filter: {}, includes: "appPreviews", limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        filter ||= {}
        filter["appCustomProductPageVersionLocalization"] = id
        return Spaceship::ConnectAPI::AppPreviewSet.all(client: client, filter: filter, includes: includes, limit: limit, sort: sort)
      rescue
        raise Spaceship::AppStoreAppPreviewError, @locale
      end

      def create_app_preview_set(client: nil, attributes: nil)
        client ||= Spaceship::ConnectAPI
        resp = client.post_app_preview_set(app_custom_product_page_version_localization_id: id, attributes: attributes)
        return resp.to_models.first
      rescue
        raise Spaceship::AppStoreAppPreviewError, @locale
      end

      #
      # App Screenshot Sets
      #

      def get_app_screenshot_sets(client: nil, filter: {}, includes: "appScreenshots", limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        return Spaceship::ConnectAPI::AppScreenshotSet.all(
          client: client,
          app_custom_product_page_version_localization_id: id,
          filter: filter,
          includes: includes,
          limit: limit,
          sort: sort
        )
      rescue
        raise Spaceship::AppStoreScreenshotError, @locale
      end

      def create_app_screenshot_set(client: nil, attributes: nil)
        client ||= Spaceship::ConnectAPI
        resp = client.post_app_screenshot_set_for_custom_product_page(
          app_custom_product_page_version_localization_id: id,
          attributes: attributes
        )
        return resp.to_models.first
      rescue
        raise Spaceship::AppStoreScreenshotError, @locale
      end
    end
  end
end