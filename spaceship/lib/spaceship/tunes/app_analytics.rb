require_relative 'tunes_base'

module Spaceship
  module Tunes
    class AppAnalytics < TunesBase
      # @return (Integer) The app ID to grab analytics for
      attr_accessor :apple_id

      class << self
        def factory(attrs)
          return self.new(attrs)
        end
      end

      # App Store / Impressions Unique Devices
      def app_impressions
        start_t, end_t = time_last_7_days

        app_impressions_interval(start_t, end_t)
      end

      # App Store / Product Page Views Unique Devices
      def app_views
        start_t, end_t = time_last_7_days

        app_views_interval(start_t, end_t)
      end

      # Sales / App Units
      def app_units
        start_t, end_t = time_last_7_days

        app_units_interval(start_t, end_t)
      end

      # Sales / In-App Purchases
      def app_in_app_purchases
        start_t, end_t = time_last_7_days

        app_in_app_purchases_interval(start_t, end_t)
      end

      # Sales / Sales
      def app_sales
        start_t, end_t = time_last_7_days

        app_sales_interval(start_t, end_t)
      end

      # Sales / Paying Users
      def app_paying_users
        start_t, end_t = time_last_7_days

        app_paying_users_interval(start_t, end_t)
      end

      # Usage / Installations
      def app_installs
        start_t, end_t = time_last_7_days

        app_installs_interval(start_t, end_t)
      end

      # Usage / Sessions
      def app_sessions
        start_t, end_t = time_last_7_days

        app_sessions_interval(start_t, end_t)
      end

      # Usage / Active Devices
      def app_active_devices
        start_t, end_t = time_last_7_days

        app_active_devices_interval(start_t, end_t)
      end

      # Usage / Active Devices 30 Days
      def app_active_last_30_days
        start_t, end_t = time_last_7_days

        app_active_last_30_days_interval(start_t, end_t)
      end

      # Usage / Crashes
      def app_crashes
        start_t, end_t = time_last_7_days

        app_crashes_interval(start_t, end_t)
      end

      def app_retention_interval(start_t, end_t, dimension_filters = [])
        client.retention_analytics([apple_id], dimension_filters, start_t, end_t)
      end

      def app_measure_interval_extend(start_t, end_t, measure, dimension_filters = [], view_by = nil)
        client.time_series_analytics_extend([apple_id], [measure], dimension_filters, start_t, end_t, "DAY", view_by)
      end

      # v2/data/time-series
      def app_measure_interval_v2(start_t, end_t, measure, frequency, dimension_filters = [])
        client.time_series_analytics_v2([apple_id], measure, dimension_filters, start_t, end_t, frequency)
      end

      # v2/data/dimension-values
      def dimension_values(start_t, end_t, measure, frequency, dimensions = [], dimension_filters = [])
        client.dimension_values([apple_id], measure, dimensions, dimension_filters, start_t, end_t, frequency)
      end

      def app_measure_interval(start_t, end_t, measure, view_by = nil)
        client.time_series_analytics([apple_id], [measure], start_t, end_t, "DAY", view_by)
      end

      def app_impressions_interval(start_t, end_t, view_by = nil)
        client.time_series_analytics([apple_id], ['impressionsTotal'], start_t, end_t, "DAY", view_by)
      end

      def app_units_interval(start_t, end_t, view_by = nil)
        client.time_series_analytics([apple_id], ['units'], start_t, end_t, "DAY", view_by)
      end

      def app_views_interval(start_t, end_t, view_by = nil)
        client.time_series_analytics([apple_id], ['pageViewCount'], start_t, end_t, "DAY", view_by)
      end

      def app_in_app_purchases_interval(start_t, end_t, view_by = nil)
        client.time_series_analytics([apple_id], ['iap'], start_t, end_t, "DAY", view_by)
      end

      def app_sales_interval(start_t, end_t, view_by = nil)
        client.time_series_analytics([apple_id], ['sales'], start_t, end_t, "DAY", view_by)
      end

      def app_paying_users_interval(start_t, end_t, view_by = nil)
        client.time_series_analytics([apple_id], ['payingUsers'], start_t, end_t, "DAY", view_by)
      end

      def app_installs_interval(start_t, end_t, view_by = nil)
        client.time_series_analytics([apple_id], ['installs'], start_t, end_t, "DAY", view_by)
      end

      def app_sessions_interval(start_t, end_t, view_by = nil)
        client.time_series_analytics([apple_id], ['sessions'], start_t, end_t, "DAY", view_by)
      end

      def app_active_devices_interval(start_t, end_t, view_by = nil)
        client.time_series_analytics([apple_id], ['activeDevices'], start_t, end_t, "DAY", view_by)
      end

      def app_active_last_30_days_interval(start_t, end_t, view_by = nil)
        client.time_series_analytics([apple_id], ['rollingActiveDevices'], start_t, end_t, "DAY", view_by)
      end

      def app_crashes_interval(start_t, end_t, view_by = nil)
        client.time_series_analytics([apple_id], ['crashes'], start_t, end_t, "DAY", view_by)
      end

      def time_last_7_days
        time = Time.now
        past = time - (60 * 60 * 24 * 7)
        end_t   = time.strftime("%Y-%m-%dT00:00:00Z")
        start_t = past.strftime("%Y-%m-%dT00:00:00Z")

        return start_t, end_t
      end

      def time_last_30_days
        time = Time.now
        past = time - (60 * 60 * 24 * 30)
        end_t   = time.strftime("%Y-%m-%dT00:00:00Z")
        start_t = past.strftime("%Y-%m-%dT00:00:00Z")

        return start_t, end_t
      end

      def time_last_90_days
        time = Time.now
        past = time - (60 * 60 * 24 * 90)
        end_t   = time.strftime("%Y-%m-%dT00:00:00Z")
        start_t = past.strftime("%Y-%m-%dT00:00:00Z")

        return start_t, end_t
      end
    end
  end
end
