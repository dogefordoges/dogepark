require 'dogecoin_client'

class Dogecoin
  
  def initialize
    @client = DogecoinClient.new(user: 'dogecoinrpc', password: 'rpcpassword')
  end

  def doge(&block)
    if @client.valid?
      block.call
    else
      throw 'Dogecoin is not connected'
    end
  end

  def client
    @client
  end

  def balance(address)
    doge do
      @client.get_balance address
    end
  end

  def new_address
    doge do
      @client.get_new_address
    end
  end

  def get_private_key(address)
    doge do
      @client.dump_priv_key address
    end
  end

  def block_count
    doge do
      @client.get_block_count
    end
  end

  def block_number
    doge do
      @client.get_block_number
    end
  end

  def get_block_hash(index)
    doge do
      @client.get_block_hash index
    end
  end

  def get_block(hash)
    doge do
      @client.get_block(hash)
    end
  end

  def send(from, to, amount)
    doge do
      @client.send_from(from, to, amount)
    end
  end

  def send_batch(from, to_addresses, amount)
    doge do
      @client.send_many(from, to_addresses, amount)
    end
  end
  
end
