#!/usr/bin/env ruby

require 'net/http'
require 'json'

balances = JSON.parse(File.read('balances.json'))

def fetch_and_parse
  answer = JSON.parse(Net::HTTP.get(URI("https://api.cryptowat.ch/markets/prices")))
  abort "don't spam cryptowatch" if answer['error']
  answer['result']
end

def extract(prices, exchange, symbol)
  prices["#{exchange}:#{symbol}usd"]
end

prices = fetch_and_parse
usd_prices = {
  'BCH'  => extract(prices, 'kraken', 'bch'),
  'BTC'  => extract(prices, 'gdax', 'btc'),
  'BTG'  => extract(prices, 'bitfinex', 'btg'),
  'DASH' => extract(prices, 'kraken', 'dash'),
  'ETH'  => extract(prices, 'gdax', 'eth'),
  'LTC'  => extract(prices, 'kraken', 'ltc'),
  'XMR'  => extract(prices, 'kraken', 'xmr'),
  'ZEC'  => extract(prices, 'kraken', 'zec')
}

usd_balances = balances.map{|coin, coin_balance| [coin, (coin_balance * usd_prices[coin])]}.to_h
btc_balances = balances.map{|coin, coin_balance| [coin, (coin_balance * usd_prices[coin] / usd_prices['BTC'])]}.to_h
bch_balances = balances.map{|coin, coin_balance| [coin, (coin_balance * usd_prices[coin] / usd_prices['BCH'])]}.to_h
total_usd_balance = usd_balances.values.reduce(0, :+)
total_btc_balance = btc_balances.values.reduce(0, :+)
total_bch_balance = bch_balances.values.reduce(0, :+)

usd_balances.each do |coin, balance|
  puts "#{coin}: $#{sprintf("%.2f", balance)} / #{sprintf("%.2f", 100*balance/total_usd_balance)}% (#{ sprintf("%.8f",  btc_balances[coin])} BTC  /  #{ sprintf("%.8f",  bch_balances[coin])} BCH)" if balance != 0
end

puts "Total Portfolio Balance: $#{sprintf("%.2f", total_usd_balance)} USD  /  #{sprintf("%.8f", total_btc_balance)} BTC  /  #{sprintf("%.8f", total_bch_balance)} BCH"
puts "BTC+BCH+BTG Combined Ticker Price = $#{sprintf("%.2f", usd_prices['BTC'] + usd_prices['BCH'] + usd_prices['BTG'])}"
