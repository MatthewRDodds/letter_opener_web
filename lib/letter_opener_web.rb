# frozen_string_literal: true

require 'letter_opener_web/engine'
require 'letter_opener_web/errors'
require 'letter_opener_web/storage/filesystem'
require 'letter_opener_web/storage/s3'
require 'rexml/document'

module LetterOpenerWeb
  class Config
    attr_accessor :letters_location, :aws_key, :aws_secret, :s3_bucket,
                  :storage_module, :storage
  end

  def self.config
    @config ||= Config.new.tap do |conf|
      conf.letters_location = Rails.root.join('tmp', 'letter_opener')
      conf.storage = :filesystem
      conf.storage_module = storage_module(conf.storage)
      conf.aws_key = ''
      conf.aws_secret = ''
      conf.s3_bucket = ''
    end
  end

  def self.configure
    yield config if block_given?
  end

  def self.reset!
    @config = nil
  end

  def self.storage_module(storage)
    storage_class_name = storage.to_s.downcase.camelize
    begin
      storage_module = LetterOpenerWeb::Storage.const_get(storage_class_name)
    rescue NameError
      raise Errors::StorageMethodNotFound, "Cannot load storage module '#{storage_class_name}'"
    end
  end
end
