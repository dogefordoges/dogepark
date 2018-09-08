require './app/dogecoin'

RSpec.describe Dogecoin, "Dogecoin Client Unit Tests" do

  before(:all) do
    @dogecoin = Dogecoin.new
    @default_account = nil
  end

  context 'uses saved account to send dogecoin to other people' do

    it "gets balance of default account" do
      expect(@dogecoin.balance @default_account[:address] > 0)
    end

    it "creates a new account and sends it some doge" do
      $new_account = nil

      @dogecoin.send(@default_account[:address], $new_account[:address], 100)
    end

    it "creates another account and sends doge to both addresses" do

      newest_account = nil
      
      @dogecoin.send_batch(@default_account[:address], [newest_account[:address], $new_account[:address]], 20)

      # send back the doge to original account
      @dogecoin.send(newest_account[:address], @default_account[:address], 20)
      @dogecoin.send($new_account[:address], @default_account[:address], 120)
      
    end
    
  end
end
