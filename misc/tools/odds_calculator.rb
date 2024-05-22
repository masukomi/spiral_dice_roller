#!/usr/bin/env ruby
# frozen_string_literal: true

#
# to invoke for 1-6 dice in fish shell, run this:
# for i in (seq 1 6); TOTAL_ROLLS=100000 NUM_DICE=$i ./odds_calculator.rb; end

num_to_stats = {
  1 => { hits: 0, spares: 0, spirals: 0 },
  2 => { hits: 0, spares: 1, spirals: 0 },
  3 => { hits: 1, spares: 0, spirals: 0 },
  4 => { hits: 2, spares: 0, spirals: 1 },
  5 => { hits: 1, spares: 0, spirals: 1 },
  6 => { hits: 0, spares: 0, spirals: 1 },
  7 => { hits: 0, spares: 2, spirals: 0 },
  8 => { hits: 0, spares: 1, spirals: 0 },
  9 => { hits: 1, spares: 1, spirals: 0 },
  10 => { hits: 2, spares: 0, spirals: 0 },
  11 => { hits: 1, spares: 0, spirals: 1 },
  12 => { hits: 0, spares: 0, spirals: 1 }
}

def get_roll_result(num_dice)
  results = []

  (1..num_dice).each do |_|
    results.push(rand(1..12))
  end
  results
end

def format_number(number)
  numerator, denominator = number.to_s.split('.')
  return format_integer(number) unless denominator

  "#{format_integer(numerator)}.#{format_integer(denominator)}" if denominator
end

def format_integer(number)
  num_groups = number.to_s.chars.to_a.reverse.each_slice(3)
  num_groups.map(&:join).join(',').reverse
end

# ############3

# puts "ENV['TOTAL_ROLLS']: #{ENV['TOTAL_ROLLS']}"
# puts "ENV['NUM_DICE']: #{ENV['NUM_DICE']}"

if ENV['TOTAL_ROLLS']
  total_rolls = ENV['TOTAL_ROLLS'].to_i
else
  puts "total rolls [10,000]\n"
  total_rolls = gets.chomp.to_i
  total_rolls = 10_000 if total_rolls.zero?
end
if ENV['NUM_DICE']
  num_dice = ENV['NUM_DICE'].to_i
else
  puts "number of dice [3]\n"
  num_dice = gets.chomp.to_i
  num_dice = 3 if num_dice.zero?
end

if ENV['INCLUDE_TOTALS'].chomp.downcase == 'true'
  include_totals = true
else
  puts "include totals [false]\n"
  include_totals = gets.chomp.downcase == 'true'
end

# puts "total rolls: #{total_rolls}"
# puts "number of dice: #{num_dice}"
# exit

all_results = []

total_rolls.times do
  all_results.push(get_roll_result(num_dice))
end

# each "result" is an array of 3 numbers
total_spares = all_results.map do |result|
  result.map do |num|
    stats = num_to_stats[num]
    stats[:spares] >= stats[:spirals] ? stats[:spares] - stats[:spirals] : 0
  end
end.flatten.reduce(:+)
total_spirals = all_results.map do |result|
  result.map do |num|
    stats = num_to_stats[num]
    stats[:spirals] >= stats[:spares] ? stats[:spirals] - stats[:spares] : 0
  end
end.flatten.reduce(:+)
total_hits = all_results.map { |result| result.map { |num| num_to_stats[num][:hits] } }.flatten.reduce(:+)

average_hits = total_hits.to_f / total_rolls
average_spares = total_spares.to_f / total_rolls
average_spirals = total_spirals.to_f / total_rolls

spares_as_percent_of_average_hits = average_spares / (average_hits * 0.01)
spirals_as_percent_of_average_hits = average_spirals / (average_hits * 0.01)

spares_as_percent_of_num_dice = average_spares / (num_dice * 0.01)
spirals_as_percent_of_num_dice = average_spirals / (num_dice * 0.01)

spares_as_a_percent_of_total_rolls = total_spares / (total_rolls * 0.01)
spirals_as_a_percent_of_total_rolls = total_spirals / (total_rolls * 0.01)

puts "--------------------------------------------------------\n"
puts "Rolling #{num_dice} dice #{format_number(total_rolls)} times.\n"
puts "On average, you will get
  #{format('%.2f', average_hits)} hits &
     #{format('%.2f', average_spares)} spares
  OR #{format('%.2f', average_spirals)} spirals.\n\n"

puts 'As a percentage of average hits:'
puts " - spares #{format('%.2f', spares_as_percent_of_average_hits)}%"
puts " - spirals are #{format('%.2f', spirals_as_percent_of_average_hits)}% of hits\n\n"

puts 'As a percentage of number of dice rolled:'
puts " - spares #{format('%.2f', spares_as_percent_of_num_dice)}%"
puts " - spirals are #{format('%.2f', spirals_as_percent_of_num_dice)}%\n\n"

puts 'As a percentage of total rolls:'
puts " - spares #{format('%.2f', spares_as_a_percent_of_total_rolls)}%"
puts " - spirals are #{format('%.2f', spirals_as_a_percent_of_total_rolls)}%\n\n"

if include_totals
  puts "Total spares: #{format_number(total_spares)}"
  puts "Total spirals: #{format_number(total_spirals)}"
end
puts "--------------------------------------------------------\n\n"

# puts "Average number of spares: #{average_spares}"
# puts " - as a percentage of average hits: #{sprintf("%.2f", spares_as_percent_of_average_hits)}"
# puts "Average number of spirals: #{average_spirals}"
# puts " - as a percentage of average hits: #{sprintf("%.2f", spirals_as_percent_of_average_hits)}"
# puts "Average number of hits: #{average_hits}"
puts "\n"

# puts all_results.map{ |result| result.map{ |num|
#                                   stats = num_to_stats[num]
#                                   stats[:spares] >= stats[:spirals] ? stats[:spares] - stats[:spirals] : 0
#                                 }}.flatten.inspect
