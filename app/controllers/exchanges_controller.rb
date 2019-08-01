class ExchangesController < ApplicationController
  @@balance = Payment.last.wallet
  @@offset = Payment.first.id
  def index
    @payments = Payment.all
    @notes = Note.all
    @balance = @@balance
    #bitcoin.confに書いたユーザとパスワード
    #
    # username password を直打ちしています，ここは攻撃しないでください
    connection = BitcoinRPC.new('http://username:password@0.0.0.0:18332')
    @height = connection.getblockcount
    @mempool = connection.getrawmempool
    @payments.each do |pay|
      if pay[:confirm] != -1
        begin
          tx = connection.gettransaction(pay[:txid])
          pay[:confirm] = @height - connection.getblock(tx["blockhash"])["height"] + 1
        rescue => error
          pay[:confirm] = 0
        end
      end

      if pay[:confirm] == 0 && @height >= pay[:height] + 10
        pay[:confirm] = -1
        @payment = Payment.new
        @payment.address = pay[:address]
        @payment.amount = pay[:amount]
        begin
          @payment.txid = connection.sendtoaddress(@payment.address, @payment.amount)
          @payment.height = connection.getblockcount
          @payment.wallet = @@balance
          @payment.save
          pay.save

          @note = Note.new
          @note.error = "#" + (pay[:id] - @@offset).to_s + "の取引は失敗したため，#" + (@payment.id - @@offset).to_s + "の取引を作成し資金を再送しました．"
          @note.save
        rescue => error
          redirect_to '/exchanges/error'
          return
        end
      end

    end 
  end

  def success
  end

  def create
	  if params[:payment][:amount].empty? || params[:payment][:address].empty? || params[:payment][:amount].to_i < 0
      redirect_to '/exchanges/empty'
      return
    end
    if params[:payment][:amount].to_i > @@balance
      redirect_to '/exchanges/fail'
      return
    end
    @payment = Payment.new
    @payment.address = params[:payment][:address]
    @payment.amount = params[:payment][:amount]
    # username password を直打ちしています，ここは攻撃しないでください
    connection = BitcoinRPC.new('http://username:password@0.0.0.0:18332')
    begin
      @payment.txid = connection.sendtoaddress(@payment.address, @payment.amount)
      @payment.height = connection.getblockcount
    rescue => error
      redirect_to '/exchanges/error'
      return
    end
    @payment.wallet = @@balance - @payment.amount
    if @payment.save
      @@balance = @payment.wallet
      redirect_to '/exchanges/success'
    else
      redirect_to '/exchanges/error'
      return
    end
  end
end
