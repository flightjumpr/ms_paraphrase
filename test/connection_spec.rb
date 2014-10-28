require 'rspec'
require 'rest_client'
require 'ms_paraphrase'
require 'json'

describe 'Connectivity to translation API' do
  before(:all) do
    MsParaphrase.configure do |config|
      config.token_api = 'https://datamarket.accesscontrol.windows.net/v2/OAuth2-13'
      config.paraphrase_api = 'http://api.microsofttranslator.com/v3/json/paraphrase'
      config.client_id = 'FlightJumpr'
      config.client_secret = 'N1bGd+G03SWwz0rXdpbCQ5rL3as/3H0IqfRO39sql7A='
      config.scope = 'http://api.microsofttranslator.com'
      config.grant_type = 'client_credentials'

      #Configure token manager
      MsParaphrase.configure_token_manager
    end
  end

  it 'should connect to microsoft token service and get token' do
    response = RestClient.post MsParaphrase.configuration.token_api, :client_id => MsParaphrase.configuration.client_id, :client_secret => MsParaphrase.configuration.client_secret, :scope => MsParaphrase.configuration.scope, :grant_type => MsParaphrase.configuration.grant_type
    expect(response.code).to eq(200) #check for http 200 code
  end

  it 'should return a json response' do
    response = RestClient.post MsParaphrase.configuration.token_api, :client_id => MsParaphrase.configuration.client_id, :client_secret => MsParaphrase.configuration.client_secret, :scope => MsParaphrase.configuration.scope, :grant_type => MsParaphrase.configuration.grant_type
    body = JSON.parse(response.body)
    body.should include('access_token')
  end

  describe 'token manager tests' do

    it "module should return saved or created token" do
      expect(MsParaphrase.token_manager.get_token).to_not be_nil
    end

  end

  describe 'should paraphrase submitted sentence' do
    before(:all) do
      MsParaphrase.configure_token_manager
    end

    it "should paraphrase provided sentence and produce results" do
      s = 'This is an example sentence that in an idea world should be translated by the paraphrase API.'
      expect(MsParaphrase.translator.translate(s)).equal? true
    end

    it "should produce error message due to too many sentences" do
      s = 'This is an example sentence that in an idea world should be translated by the paraphrase API. This attempt should fail'
      expect { MsParaphrase.translator.translate(s) }.to raise_error
    end

    it "should return response that contains em OK and a set of paraphrase results." do
      s = 'This is an example sentence that in an idea world should be translated by the paraphrase API.'
      MsParaphrase.translator.translate(s)
      expect(MsParaphrase.translator.result.values.include?('em')).equal? true
      expect(MsParaphrase.translator.result['em']).equal? "OK"
      expect(MsParaphrase.translator.result['paraphrases']).is_a? Array
    end

  end

end