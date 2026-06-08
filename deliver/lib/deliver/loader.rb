require_relative 'module'
require_relative 'app_screenshot'
require_relative 'app_screenshot_validator'
require_relative 'upload_metadata'
require_relative 'languages'
require 'pp'

module Deliver
  module Loader
    # The directory 'appleTV' and `iMessage` are special folders that will cause our screenshot gathering code to iterate
    # through it as well searching for language folders.
    APPLE_TV_DIR_NAME = "appleTV".freeze
    IMESSAGE_DIR_NAME = "iMessage".freeze
    DEFAULT_DIR_NAME = "default".freeze

    EXPANDABLE_DIR_NAMES = [APPLE_TV_DIR_NAME, IMESSAGE_DIR_NAME].freeze
    SPECIAL_DIR_NAMES = [APPLE_TV_DIR_NAME, IMESSAGE_DIR_NAME, DEFAULT_DIR_NAME].freeze

    # Some exception directories may exist from other actions that should not be iterated through
    SUPPLY_DIR_NAME = "android".freeze
    FRAMEIT_FONTS_DIR_NAME = "fonts".freeze
    META_DIR_NAMES = UploadMetadata::ALL_META_SUB_DIRS.map(&:downcase)

    EXCEPTION_DIRECTORIES = (META_DIR_NAMES << SUPPLY_DIR_NAME << FRAMEIT_FONTS_DIR_NAME).freeze

    # A class that represents language folder under screenshots or metadata folder
    class LanguageFolder
      attr_reader :path

      # @return [String] A normalized language name that corresponds to the directory's name
      attr_reader :language

      def self.available_languages
        # 2020-08-24 - Available locales are not available as an endpoint in App Store Connect
        # Update with Spaceship::Tunes.client.available_languages.sort (as long as endpoint is avilable)
        Deliver::Languages::ALL_LANGUAGES
      end

      def self.available_languages_translate
        %w[阿拉伯文 加泰罗尼亚文 捷克文 丹麦文 德文 希腊文 澳大利亚英文 加拿大英文 英国英文 美国英文 西班牙文 墨西哥文 芬兰文 加拿大法文 法文 希伯来文 北印度文 克罗地亚文 匈牙利文 印尼文 意大利文 日文 韩文 马来文 荷兰文 挪威文 波兰文 巴西文 葡萄牙文 罗马尼亚文 俄文 斯洛伐克文 瑞典文 泰文 土耳其文 乌克兰文 越南文 简体中文 繁体中文 奥里亚文 古吉拉特文 坎纳达文 马拉地文 马拉雅拉姆文 孟加拉文 旁遮普文 斯洛文尼亚文 泰卢固文 泰米尔文 乌尔都文]
      end

      def self.allowed_directory_names_with_case
        available_languages + available_languages_translate + SPECIAL_DIR_NAMES
      end

      def self.allowed_language_map
        lang = {
          "美国英文"=>"en-US",
          "英国英文"=>"en-GB",
          "加拿大法文"=>"fr-CA",
          "加拿大英文"=>"en-CA",
          "澳大利亚英文"=>"en-AU",
          "法文"=>"fr-FR",
          "芬兰文"=>"fi",
          "俄文"=>"ru",
          "简体中文"=>"zh-Hans",
          "繁体中文"=>"zh-Hant",
          "丹麦文"=>"da",
          "日文"=>"ja",
          "韩文"=>"ko",
          "德文"=>"de-DE",
          "意大利文"=>"it",
          "瑞典文"=>"sv",
          "荷兰文"=>"nl-NL",
          "巴西文"=>"pt-BR",
          "葡萄牙文"=>"pt-PT",
          "西班牙文"=>"es-ES",
          "墨西哥文"=>"es-MX",
          "越南文"=>"vi",
          "希腊文"=>"el",
          "印尼文"=>"id",
          "马来文"=>"ms",
          "土耳其文"=>"tr",
          "泰文"=>"th",
          "挪威文"=>"no",
          "克罗地亚文"=>"hr",
          "捷克文"=>"cs",
          "匈牙利文"=>"hu",
          "波兰文"=>"pl",
          "罗马尼亚文"=>"ro",
          "斯洛伐克文"=>"sk",
          "乌克兰文"=>"uk",
          "北印度文"=>"hi",
          "加泰罗尼亚文"=>"ca",
          "阿拉伯文"=>"ar-SA",
          "希伯来文"=>"he",
          "奥里亚文"=>"or-IN",
          "古吉拉特文"=>"gu-IN",
          "坎纳达文"=>"kn-IN",
          "马拉地文"=>"mr-IN",
          "马拉雅拉姆文"=>"ml-IN",
          "孟加拉文"=>"bn-BD",
          "旁遮普文"=>"pa-IN",
          "斯洛文尼亚文"=>"sl-SI",
          "泰卢固文"=>"te-IN",
          "泰米尔文"=>"ta-IN",
          "乌尔都文"=>"ur-PK"
        }
      end

      # @param path [String] A directory path otherwise this initializer fails
      # @param nested [Boolan] Whether given path is nested of another special directory.
      #  This affects `expandable?` to return `false` when this set to `true`.
      def initialize(path, nested: false)
        raise(ArgumentError, "Given path must be a directory path - #{path}") unless File.directory?(path)
        @path = path
        language = self.class.available_languages_translate.find { |lang| basename.casecmp?(lang) }
        language_translate = self.class.allowed_language_map[language]
        @language = language_translate
        @nested = nested
      end

      def nested?
        @nested
      end

      def valid?
        self.class.allowed_directory_names_with_case.any? { |name| name.casecmp?(basename) }
      end

      def expandable?
        !nested? && EXPANDABLE_DIR_NAMES.any? { |name| name.casecmp?(basename) }
      end

      def skip?
        EXCEPTION_DIRECTORIES.map(&:downcase).include?(basename.downcase)
      end

      def file_paths(extensions = '{png,jpg,jpeg}')
        Dir.glob(File.join(path, "*.#{extensions}"), File::FNM_CASEFOLD).sort
      end

      def framed_file_paths(extensions = '{png,jpg,jpeg}')
        Dir.glob(File.join(path, "*_framed.#{extensions}"), File::FNM_CASEFOLD).sort
      end

      def basename
        File.basename(@path)
      end
    end

    # Returns the list of valid app screenshot. When detecting invalid screenshots, this will cause an error.
    #
    # @param root [String] A directory path
    # @param ignore_validation [String] Set false not to raise the error when finding invalid folder name
    # @return [Array<Deliver::AppScreenshot>] The list of AppScreenshot that exist under given `root` directory
    def self.load_app_screenshots(root, ignore_validation)
      screenshots = language_folders(root, ignore_validation, true).flat_map do |language_folder|
        paths = if language_folder.framed_file_paths.count > 0
                  UI.important("Framed screenshots are detected! 🖼 Non-framed screenshot files may be skipped. 🏃")
                  # watchOS screenshots can be picked up even when framed ones were found since frameit doesn't support watchOS screenshots
                  framed_or_watch, skipped = language_folder.file_paths.partition { |path| path.downcase.include?('framed') || path.downcase.include?('watch') }
                  skipped.each { |path| UI.important("🏃 Skipping screenshot file: #{path}") }
                  framed_or_watch
                else
                  language_folder.file_paths
                end
        paths.map { |path| AppScreenshot.new(path, language_folder.language) }
      end

      errors = []
      valid_screenshots = screenshots.select { |screenshot| Deliver::AppScreenshotValidator.validate(screenshot, errors) }

      errors_to_skip, errors_to_crash = errors.partition(&:to_skip)

      unless errors_to_skip.empty?
        UI.important("🏃 Screenshots to be skipped are detected!")
        errors_to_skip.each { |error| UI.message(error) }
      end

      unless errors_to_crash.empty?
        UI.important("🚫 Invalid screenshots were detected! Here are the reasons:")
        errors_to_crash.each { |error| UI.error(error) }
        UI.user_error!("Canceled uploading screenshots. Please check the error messages above and fix the screenshots.")
      end

      valid_screenshots
    end

    # Returns the list of language folders
    #
    # @param roort [String] A directory path to get the list of language folders
    # @param ignore_validation [Boolean] Set false not to raise the error when finding invalid folder name
    # @param expand_sub_folders [Boolean] Set true to expand special folders; such as "iMessage" to nested language folders
    # @return [Array<LanguageFolder>] The list of LanguageFolder whose each of them
    def self.language_folders(root, ignore_validation, expand_sub_folders = false)
      folders = Dir.glob(File.join(root, '*'))
                   .select { |path| File.directory?(path) }
                   .map { |path| LanguageFolder.new(path, nested: false) }
                   .reject(&:skip?)

      selected_folders, rejected_folders = folders.partition(&:valid?)

      if !ignore_validation && !rejected_folders.empty?
        rejected_folders = rejected_folders.map(&:basename)

        ## {TODO} 更换语言
        # UI.user_error!("Unsupported directory name(s) for screenshots/metadata in '#{root}': #{rejected_folders.join(', ')}" \
        #                "\nValid directory names are: #{LanguageFolder.allowed_directory_names_with_case}" \
        #                "\n\nEnable 'ignore_language_directory_validation' to prevent this validation from happening")

        UI.error("上传目录'#{root}'中存在错误的目录名: #{rejected_folders.join(', ')}")
        UI.error("正确的目录名应为: #{LanguageFolder.allowed_directory_names_with_case}")

      end

      # Expand selected_folders for the special directories
      if expand_sub_folders
        selected_folders = selected_folders.flat_map do |folder|
          if folder.expandable?
            Dir.glob(File.join(folder.path, '*'))
               .select { |p| File.directory?(p) }
               .map { |p| LanguageFolder.new(p, nested: true) }
               .select(&:valid?)
          else
            folder
          end
        end
      end

      selected_folders
    end
  end
end
