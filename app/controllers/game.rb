enable 'sessions'

post '/game/select' do
  @all_decks = Deck.all
  @new_game = Round.create
  erb :'game/select'
end

get '/game/start/:id' do
  round = Round.new(user_id: session[:user_id])
  round.save
  new_deck = Card.find_all_by_deck_id(params[:id])
  @card_obj = new_deck
  # grab deck data where deck id = @card_obj.deck_id
  # and populate guess table
  new_deck.each do |card|
    Guess.create(round_id: round.id, card_id: card.id)
  end
  session[:current_round] = round.id
  # erb :'game/start_page'
  @new_card = get_cards
  @current_round = round.id
  erb :'game/question'
end


# post '/game/question' do
#   # guesses = []
#   guesses = Guess.where(round_id: session[:current_round], correct: nil)
#   if guesses.count > 0
#     @current_round = params[:round_id]
#     # @new_card = Card.find_by_id(guesses.shuffle[0].card_id)
#     @new_card = get_cards
#     erb :'game/question'
#   else
#     @current_round = params[:round_id]
#     redirect to "game/end_game/#{session[:current_round]}"
#   end
# end

post '/game/question' do
  p params
  guesses = Guess.where(round_id: session[:current_round], correct: nil)
  p guesses.count
  card_obj = Card.find(params[:card_id])
  current_round = params[:round_id]
  if params[:answer].downcase == card_obj.answer.downcase
    result_text = "That answer is correct!"
    correct = true
  else
    result_text = "That answer is incorrect."
    correct = false
  end
  current_guess = Guess.where(card_id: params[:card_id], round_id: session[:current_round])
  current_guess.first.update_attributes(correct: correct)
  result = {}
  result[:current_round] = current_round
  result[:result_text] = result_text
  if guesses.count > 0
    new_card = Card.find_by_id(guesses.shuffle[0].card_id)
  else
    result[:exit_game] = true
    p "this is result #{result}"
    return result.to_json
  end
  result[:new_card_text] = new_card.question
  result[:new_card_id] = new_card.id
  return result.to_json
end

get '/game/end_game/:id' do
  @user_id = Round.find(params[:id]).user_id
  # @user_id = params[:@round_id]
  @total_guess = Guess.where(round_id: params[:id]).length
  @correct_guess = Guess.where(round_id: params[:id], correct: true).length
  @score = @correct_guess.to_f / @total_guess.to_f * 100
  erb :'game/end_game'
end

# post '/results/:id' do
#   @card_obj = Card.find(params[:id])
#   @current_round = params[:round_id]
#   if params[:answer].downcase == @card_obj.answer.downcase
#     @result = true
#   else
#     @result = false
#   end
#   current_guess = Guess.where(card_id: params[:id], round_id: session[:current_round])
#   current_guess.first.update_attributes(correct: @result)
#   erb :"game/result"
# end




