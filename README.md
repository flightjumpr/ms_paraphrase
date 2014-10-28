# MsParaphrase

This is a rails wrapper for the Microsoft Paraphrase API. Microsoft Paraphrase API is an English-to-English machine translation system that rephrases English sentences in English.

## Installation

Add this line to your application's Gemfile:

    gem 'ms_paraphrase'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ms_paraphrase

## Usage

API access :

Subscribe to the Microsoft Translator API <a href="http://go.microsoft.com/?linkid=9782667">here.</a>

Register your application with <a href="https://datamarket.azure.com/developer/applications/">Azure DataMarket</a>.

Configuration :

The best way to configure the module is to add an initializer in config called ms_paraphrase.rb and add the following :

MsParaphrase.configure do |config|
      config.token_api = 'https://datamarket.accesscontrol.windows.net/v2/OAuth2-13'
      config.paraphrase_api = 'http://api.microsofttranslator.com/v3/json/paraphrase'
      config.client_id = 'XXXXXXXXXXX'
      config.client_secret = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
      config.scope = 'http://api.microsofttranslator.com'
      config.grant_type = 'client_credentials'

      #Configure token manager
      MsParaphrase.configure_token_manager
end


Paraphrasing

s = "This is a sentence that we are going to run through the microsoft Paraphrase API"
MsParaphrase.translator.translate(s)

Response object will be json :

Error message can be found by accessing : MsParaphrase.translator.result['em']

Array of results can be found by accessing : MsParaphrase.translator.result['paraphrases']



## Contributing

1. Fork it ( http://github.com/<my-github-username>/ms_paraphrase/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
