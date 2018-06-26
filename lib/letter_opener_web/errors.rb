module LetterOpenerWeb
  class Error < StandardError
  end

  module Errors
    class StorageMethodNotFound < LetterOpenerWeb::Error
    end
  end
end
