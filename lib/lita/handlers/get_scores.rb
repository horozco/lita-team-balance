module Lita
  module Handlers
    class GetScores < Handler
      include TeamHelpers
      namespace :team
      template_root File.expand_path("../../../../templates", __FILE__)

      route(
        /(\S*) team get (my|all|\S*)[ score| scores]*$/i,
        :get_score,
        command: true,
        help: {
          "<name> team get <member> score" => "Get the score for a member in the given team.",
          "<name> team get my score" => "Get my score in the given team.",
          "<name> team get all scores" => "Get all the scores for the given team."
        }
      )

      def get_score(response)
      	team_name = response.match_data[1]
        return response.reply(render_template(:wrong_command)) if team_name.nil?
        if get_team(team_name)
          if response.match_data[2].downcase != 'all'
            get_single_score(team_name, response)
          else
            get_all_team_scores(team_name, response)
          end
        else
          response.reply(render_template(:team_not_found, team_name: team_name))
        end
      end

      private

      def get_single_score(team_name, response)
        member_name = get_member_name(
          response.match_data[2], response.user.mention_name
        )
        
        score_key = 'scores:' + team_name + ':' + member_name
        score_value = get_score_in_words(redis.get(score_key).to_i)

        if score_value.nil?
          response.reply(render_template(:score_not_found, team_name: team_name, member_name: member_name)) 
        else
          response.reply(
            render_template(:get_score,
                            team_name: team_name,
                            member_name: member_name,
                            score: score_value,
                            single: true
                           )
          )
        end
      end

      def get_all_team_scores(team_name, response)
        all_keys = redis.keys('scores:soccer:*')
        if all_keys.any?
          all_values = redis.mget(all_keys)
          member_names = all_keys.map{|key| key.split(':').last}
          team_scores = Hash[member_names.zip( all_values.map{|score| get_score_in_words(score)} ) ]
          response.reply(
            render_template(:get_score,
                            team_name: team_name,
                            team_scores: team_scores,
                            single: false
                           )
          )
        else
          response.reply(render_template(:not_stored_scores, team_name: team_name))
        end
      end

      Lita.register_handler(self)
    end
  end
end