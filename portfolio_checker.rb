#!/usr/bin/env ruby

require 'httparty'
require 'json'

balances = JSON.parse(File.read('balances.json'))

usd_prices = {
  'BTC'  => JSON.parse(HTTParty.get('https://apiv2.bitcoinaverage.com/exchanges/gdax').to_s)['symbols']['BTCUSD']['last'],
  'DASH' => JSON.parse(HTTParty.get('https://api.cryptowat.ch/markets/kraken/dashusd/price').to_s)['result']['price'],
  'ETH'  => JSON.parse(HTTParty.get('https://apiv2.bitcoinaverage.com/exchanges/gdax').to_s)['symbols']['ETHUSD']['last'],
  'LTC'  => JSON.parse(HTTParty.get('https://api.cryptowat.ch/markets/kraken/ltcusd/price').to_s)['result']['price'],
  'XMR'  => JSON.parse(HTTParty.get('https://api.cryptowat.ch/markets/kraken/xmrusd/price').to_s)['result']['price']
}

usd_balances = balances.map{|coin, coin_balance| [coin, (coin_balance * usd_prices[coin])]}.to_h
btc_balances = balances.map{|coin, coin_balance| [coin, (coin_balance * usd_prices[coin] / usd_prices['BTC'])]}.to_h
total_usd_balance = usd_balances.values.reduce(0, :+)
total_btc_balance = btc_balances.values.reduce(0, :+)

usd_balances.each do |coin, balance|
  puts "#{coin}: $#{sprintf("%.2f", balance)} / #{sprintf("%.2f", 100*balance/total_usd_balance)}% (#{ sprintf("%.8f",  btc_balances[coin])} BTC)" if balance != 0
end

puts "Total Portfolio USD Balance: $#{sprintf("%.2f", total_usd_balance)} USD"
puts "Total Portfolio BTC Balance: #{sprintf("%.8f", total_btc_balance)} BTC"
