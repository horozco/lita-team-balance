module TeamHelpers
	def get_team(team_name)
    data = redis.get(team_name)
    MultiJson.load(data, symbolize_keys: true) if data
  end
end