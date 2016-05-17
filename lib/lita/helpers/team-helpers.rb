module TeamHelpers
	def get_team(team_name)
    data = redis.get(team_name)
    MultiJson.load(data, symbolize_keys: true) if data
  end

  def get_member_name(matched_name, mention_name)
  	if matched_name.downcase == 'my'
      mention_name
    else
      matched_name
    end.downcase.delete("@")
  end

  def get_score_in_words(score)
  	scores_in_words = {
  		10 => ":keycap_ten:",
      9 => ":nine:",
      8 => ":eight:",
      7 => ":seven:",
      6 => ":six:",
      5 => ":five:",
      4 => ":four:",
      3 => ":three:",
      2 => ":two:",
      1 => ":one:"
  	}
  	scores_in_words[score.to_i]
  end
end