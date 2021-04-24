module Fastlane
  module Actions

    class MergeScreenshotsAction < Action
      def self.run(params)
        project_path = Dir.pwd + '/'
        config_path = project_path + params[:config]
        
        require_relative 'merge_screenshots/images_processor.rb'
        
        ip = ImagesProcessor.new project_path
        ip.run config_path
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Merge screenshots with design specified in config.yml"
      end

      def self.available_options
        [FastlaneCore::ConfigItem.new(key: :config,
                                      env_name: "CONFIG",
                                      is_string: true,
                                      description: "The file describes manipulations with images and text to generate designed screenshots")]
      end

      def self.output
        []
      end

      def self.return_value
        "The result was saved in screenshots dir, in project root"
      end

      def self.authors
        ["Alexander Dittner"]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end
      
      def self.category
          :screenshots
      end
    end
  end
end
