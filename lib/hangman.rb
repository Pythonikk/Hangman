# frozen_string_literal: true

require 'yaml'

# defines the course of the game.
class Game
  attr_reader :incorrect_guesses, :word, :correct_guesses, :guess

  def initialize(word: SecretWord.new.word, incorrect_guesses: [], correct_guesses: [])
    @word = word
    @incorrect_guesses = incorrect_guesses
    @correct_guesses = correct_guesses
  end

  def play
    loop do
      SecretWord.display(word, correct_guesses)

      @guess = Guess.new
      letter = guess.letter

      guess.correct?(word, letter) ? correct_guesses << letter : incorrect_guesses << letter

      guess.display_incorrect(incorrect_guesses)

      prompt_save

      end_game = EndGame.new
      if end_game.win?(correct_guesses, word)
        end_game.display_win
        break
      elsif end_game.loss?(incorrect_guesses)
        end_game.display_loss(word)
        break
      end
    end
  end

  def self.prompt_load
    puts 'Do you want to load a game y/n?'
    input = gets.chomp
    load_game if input == 'y'
    input
  end

  def prompt_save
    puts 'Do you want to save your game and exit?'
    input = gets.chomp
    save_game and exit if input == 'y'
  end

  def save_game
    File.open('obj_data.yml', 'w') { |fe| fe.write(to_yaml) }
  end

  def self.load_game
    load = File.open('obj_data.yml', 'r') { |fe| YAML.safe_load(fe, permitted_classes: [Game, Guess]) }
    game = Game.new(
      word: load.word,
      incorrect_guesses: load.incorrect_guesses,
      correct_guesses: load.correct_guesses
    )
    puts "Incorrect Guesses: #{game.incorrect_guesses}"
    game.play
  end
end

# defines the word to be guessed.
class SecretWord
  attr_reader :word
  def initialize
    @word = selector
  end

  def selector
    dictionary = File.open('dictionary.txt', 'r')
    words = []
    until dictionary.eof?
      word = dictionary.readline
      words << word.chomp.downcase if (5..12).include?(word.chomp.length)
    end
    words.sample
  end

  def self.display(word, correct_guesses)
    arr = word.split('').each do |letter|
      letter.replace(' _ ') unless correct_guesses.include?(letter)
    end
    puts arr.join + "\n\n"
  end
end

# defines the players guesses
class Guess
  attr_reader :letter
  def initialize
    @letter = make_guess
  end

  def make_guess
    loop do
      puts "\n\nGuess a letter: \n\n"
      letter = gets.chomp.downcase
      break letter if valid_guess?(letter)
    end
  end

  def valid_guess?(letter)
    letter.length == 1 &&
      ('a'..'z').include?(letter)
  end

  def display_incorrect(incorrect_guesses)
    puts "\n\nIncorrect Guesses:  #{incorrect_guesses.length}/6  #{incorrect_guesses}\n\n"
  end

  def correct?(word, letter)
    word.include?(letter) == true
  end
end

# defines the end of the game.
class EndGame
  def initialize; end

  def loss?(incorrect_guesses)
    incorrect_guesses.length >= 6
  end

  def win?(correct_guesses, word)
    word.split('').all? { |letter| correct_guesses.include?(letter) }
  end

  def display_win
    puts 'You got it!'
  end

  def display_loss(word)
    puts "You lose. The word was #{word}."
  end
end

if Game.prompt_load == 'y'
  Game.load_game
else
  game = Game.new
  game.play
end
