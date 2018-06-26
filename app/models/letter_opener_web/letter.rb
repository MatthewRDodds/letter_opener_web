# frozen_string_literal: true

module LetterOpenerWeb
  class Letter
    include LetterOpenerWeb.config.storage_module
    attr_reader :id, :sent_at

    def self.letters_location
      @letters_location ||= LetterOpenerWeb.config.letters_location
    end

    def self.letters_location=(directory)
      LetterOpenerWeb.configure { |conf| conf.letters_location = directory }
      @letters_location = nil
    end

    def self.search
      storage_module.search
    end

    def self.find(id)
      new(id: id)
    end

    def self.destroy_all
      storage_module.destroy_all
    end

    def initialize(params)
      @id      = params.fetch(:id)
      @sent_at = params[:sent_at]
    end

    def plain_text
      @plain_text ||= adjust_link_targets(read_file(:plain))
    end

    def rich_text
      @rich_text ||= adjust_link_targets(read_file(:rich))
    end

    def to_param
      id
    end

    def default_style
      style_exists?('rich') ? 'rich' : 'plain'
    end

    private

    def adjust_link_targets(contents)
      # We cannot feed the whole file to an XML parser as some mails are
      # "complete" (as in they have the whole <html> structure) and letter_opener
      # prepends some information about the mail being sent, making REXML
      # complain about it
      contents.scan(%r{<a\s[^>]+>(?:.|\s)*?</a>}).each do |link|
        fixed_link = fix_link_html(link)
        xml        = REXML::Document.new(fixed_link).root
        next if xml.attributes['href'] =~ /(plain|rich).html/
        xml.attributes['target'] = '_blank'
        xml.add_text('') unless xml.text
        contents.gsub!(link, xml.to_s)
      end
      contents
    end

    def fix_link_html(link_html)
      # REFACTOR: we need a better way of fixing the link inner html
      link_html.dup.tap do |fixed_link|
        fixed_link.gsub!('<br>', '<br/>')
        fixed_link.scan(/<img(?:[^>]+?)>/).each do |img|
          fixed_img = img.dup
          fixed_img.gsub!(/>$/, '/>') unless img =~ %r{/>$}
          fixed_link.gsub!(img, fixed_img)
        end
      end
    end

    def self.storage_module
      @storage_module ||= LetterOpenerWeb.config.storage_module
    end
  end
end
