require "ms_paraphrase/version"
require 'uri'

module MsParaphrase

  class Configuration
    attr_accessor :token_api, :paraphrase_api, :client_id, :client_secret, :scope, :grant_type

    def initialize
      #self.log_level = 'info'
    end

  end

  class << self
    attr_accessor :configuration, :token_manager, :translator
  end

  def self.configure
    self.configuration ||= Configuration.new
    self.token_manager ||= TokenManager.new
    self.translator ||= Translator.new
    yield(configuration) if block_given?
  end

  def self.configure_token_manager
    self.token_manager ||= TokenManager.new
    yield(token_manager) if block_given?
  end

  class TokenManager

    private
    attr_accessor :token, :token_expiration
    public

    MAX_TRANSLATIONS = 20

    def initialize
      self.token = nil
    end

    def get_token
      if token.nil? || !is_token_valid?(token)

        self.token = JSON.parse(RestClient.post MsParaphrase.configuration.token_api, {:client_id => MsParaphrase.configuration.client_id,
                                                                            :client_secret => MsParaphrase.configuration.client_secret,
                                                                            :scope => MsParaphrase.configuration.scope,
                                                                            :grant_type => MsParaphrase.configuration.grant_type}) if is_credentials_provided?
      elsif is_token_valid?(token)
        return token
      end
    end

    private
    def is_credentials_provided?
      if MsParaphrase.configuration.token_api.nil?
        raise TranslateApiException.new('No token API endpoint provided.')
      elsif MsParaphrase.configuration.client_id.nil?
        raise TranslateApiException.new('No client ID was provided.')
      elsif MsParaphrase.configuration.client_secret.nil?
        raise TranslateApiException.new('No client secret was provided.')
      elsif MsParaphrase.configuration.scope.nil?
        raise TranslateApiException.new('No scope was provided.')
      elsif MsParaphrase.configuration.grant_type.nil?
        raise TranslateApiException.new('No grant type provided.')
      else
        return true
      end
    end


    def is_token_valid?(token)
       token['expires_in'].to_i < 10 ? false : true
    end

  end

  class Translator < TokenManager
    attr_accessor :result

    def translate(sentence)
      unless sentence.nil?
        v =  MsParaphrase.configuration.paraphrase_api + "?sentence=#{CGI::escape(sentence)}&language=en&Category=general"
        r = RestClient.get v, { 'Authorization' => "Bearer #{MsParaphrase.token_manager.get_token['access_token']}"}
        self.result = JSON.parse(r.force_encoding("UTF-8").gsub("\xEF\xBB\xBF", ''))
        is_translation_success?
      end
    end

    private
    def is_translation_success?
      if self.result.keys.include?('em') && self.result['em'] == 'OK' && self.result['paraphrases'].is_a?(Array)
        return true
      else
        raise TranslationException.new(self.result['em'])
      end
    end

  end

  public
  class TranslateApiException < Exception
    def initialize(data)
      @data = data
    end
  end

  class TranslationException < Exception
    def initialize(data)
      @data = data
    end
  end

end
