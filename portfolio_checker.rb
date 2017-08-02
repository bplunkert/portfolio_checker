#!/usr/bin/env ruby

require 'net/http'
require 'json'

balances = JSON.parse(File.read('balances.json'))

def fetch_and_parse(url)
  JSON.parse(Net::HTTP.get(URI(url)))
end

usd_prices = {
  'BCH'  => fetch_and_parse('https://api.cryptowat.ch/markets/kraken/bchusd/price').to_s)['result']['price'],
  'BTC'  => fetch_and_parse('https://apiv2.bitcoinaverage.com/exchanges/gdax')['symbols']['BTCUSD']['last'],
  'DASH' => fetch_and_parse('https://api.cryptowat.ch/markets/kraken/dashusd/price')['result']['price'],
  'ETH'  => fetch_and_parse('https://apiv2.bitcoinaverage.com/exchanges/gdax')['symbols']['ETHUSD']['last'],
  'LTC'  => fetch_and_parse('https://api.cryptowat.ch/markets/kraken/ltcusd/price')['result']['price'],
  'XMR'  => fetch_and_parse('https://api.cryptowat.ch/markets/kraken/xmrusd/price')['result']['price']
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
