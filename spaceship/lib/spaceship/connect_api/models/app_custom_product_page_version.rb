require_relative '../model'
require_relative './app_custom_product_page_version_localization'

module Spaceship
  class ConnectAPI
    class AppCustomProductPageVersion
      include Spaceship::ConnectAPI::Model

      attr_accessor :state
      attr_accessor :app_custom_product_page_version_localizations

      module State
        APPROVED = "APPROVED"
        APPROVED_WITH_ISSUES = "APPROVED_WITH_ISSUES"
        IN_REVIEW = "IN_REVIEW"
        PREPARE_FOR_SUBMISSION = "PREPARE_FOR_SUBMISSION"
        READY_FOR_REVIEW = "READY_FOR_REVIEW"
        REJECTED = "REJECTED"
        REPLACED_WITH_NEW_VERSION = "REPLACED_WITH_NEW_VERSION"
        WAITING_FOR_REVIEW = "WAITING_FOR_REVIEW"
      end

      attr_mapping({
        "state" => "state",
        "appCustomProductPageVersionLocalizations" => "app_custom_product_page_version_localizations"
      })

      def self.type
        return "appCustomProductPageVersions"
      end

      #
      # API
      #

      def self.all(client: nil, app_custom_product_page_id: nil, filter: {}, includes: nil, limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        resps = client.get_app_custom_product_page_versions(
          app_custom_product_page_id: app_custom_product_page_id,
          filter: filter,
          includes: includes,
          limit: limit,
          sort: sort
        ).all_pages
        return resps.flat_map(&:to_models)
      end

      def self.get(client: nil, app_custom_product_page_version_id: nil, includes: nil)
        client ||= Spaceship::ConnectAPI
        resp = client.get_app_custom_product_page_version(
          app_custom_product_page_version_id: app_custom_product_page_version_id,
          includes: includes
        )
        return resp.to_models.first
      end

      def self.create(client: nil, app_custom_product_page_id: nil, attributes: {})
        client ||= Spaceship::ConnectAPI
        resp = client.post_app_custom_product_page_version(
          app_custom_product_page_id: app_custom_product_page_id,
          attributes: attributes
        )
        return resp.to_models.first
      end

      #
      # App Custom Product Page Version Localizations
      #

      def get_app_custom_product_page_version_localizations(client: nil, filter: {}, includes: nil, limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        return Spaceship::ConnectAPI::AppCustomProductPageVersionLocalization.all(
          client: client,
          app_custom_product_page_version_id: id,
          filter: filter,
          includes: includes,
          limit: limit,
          sort: sort
        )
      end

      def create_app_custom_product_page_version_localization(client: nil, attributes: nil)
        client ||= Spaceship::ConnectAPI
        resp = client.post_app_custom_product_page_version_localization(
          app_custom_product_page_version_id: id,
          attributes: attributes
        )
        return resp.to_models.first
      end
    end
  end
end