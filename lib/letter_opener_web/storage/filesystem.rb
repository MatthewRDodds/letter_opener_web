module LetterOpenerWeb
  module Storage
    module Filesystem
      def self.search
        letters_path = "#{LetterOpenerWeb.config.letters_location}/*"
        letters = Dir.glob(letters_path).map do |folder|
          LetterOpenerWeb::Letter.new(id: File.basename(folder), sent_at: File.mtime(folder))
        end
        letters.sort_by(&:sent_at).reverse
      end

      def self.destroy_all
        FileUtils.rm_rf(LetterOpenerWeb.config.letters_location)
      end

      def attachments
        @attachments ||= begin
          attachment_files = Dir["#{base_dir}/attachments/*"]
          attachment_files.each_with_object({}) do |file, hash|
            hash[File.basename(file)] = File.expand_path(file)
          end
        end
      end

      def delete
        FileUtils.rm_rf("#{LetterOpenerWeb.config.letters_location}/#{id}")
      end

      def exists?
        File.exist?(base_dir)
      end

      def base_dir
        "#{LetterOpenerWeb.config.letters_location}/#{id}"
      end

      def read_file(style)
        File.read("#{base_dir}/#{style}.html")
      end

      def style_exists?(style)
        File.exist?("#{base_dir}/#{style}.html")
      end
    end
  end
end
