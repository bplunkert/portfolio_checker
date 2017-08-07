#!/usr/bin/env ruby

require 'net/http'
require 'json'

balances = JSON.parse(File.read('balances.json'))

def fetch_and_parse(exchange, symbol)
  answer = JSON.parse(Net::HTTP.get(URI("https://api.cryptowat.ch/markets/#{exchange}/#{symbol}usd/price")))
  abort "don't spam cryptowatch" if answer['error']
  answer['result']['price']
end

usd_prices = {
  'BCH'  => fetch_and_parse('kraken', 'bch'),
  'BTC'  => fetch_and_parse('gdax', 'btc'),
  'DASH' => fetch_and_parse('kraken', 'dash'),
  'ETH' => fetch_and_parse('gdax', 'eth'),
  'LTC'  => fetch_and_parse('kraken', 'ltc'),
  'NMC'  => fetch_and_parse('btce', 'nmc'),
  'PPC'  => fetch_and_parse('btce', 'ppc'),
  'XMR'  => fetch_and_parse('kraken', 'xmr')
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

puts "BTC+BCH = #{usd_prices['BTC'] + usd_prices['BCH']}"
