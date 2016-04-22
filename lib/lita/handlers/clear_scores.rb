module Lita
  module Handlers
    class ClearScores < Handler
      include TeamHelpers
      namespace :team
      template_root File.expand_path("../../../../templates", __FILE__)

      route(
        /(\S*) team clear (my|\S*)[ score| scores]*$/i,
        :clear_score,
        command: true,
        help: {
          "<name> team clear <member> score" => "Clear the score for a member in the team.",
          "<name> team clear my score" => "Clear my score in the given team.",
          "<name> team clear scores" => "Clear the score for all the given team."
        }
      )

      def clear_score(response)
      	team_name = response.match_data[1]
        if get_team(team_name)
          if response.match_data[2].downcase == 'scores'
            clear_all_scores(team_name, response)
          else
            clear_single_score(team_name, response)
          end          
        else
          response.reply(render_template(:team_not_found, team_name: team_name))
        end
      end

      def clear_single_score(team_name, response)
        member_name = get_member_name(
          response.match_data[2], response.user.mention_name
        )

        score_key = 'scores:' + team_name + ':' + member_name
        score_value = get_score_in_words(redis.get(score_key).to_i)
        if score_value.nil?
          response.reply(render_template(:score_not_found, team_name: team_name, member_name: member_name)) 
        else
          redis.del(score_key)
          response.reply(
            render_template(:clear_score,
                            team_name: team_name,
                            member_name: member_name,
                            score: score_value,
                            single: true
                          )
          )
        end
      end

      def clear_all_scores(team_name, response)
        score_keys = 'scores:soccer:*'
        all_keys = redis.keys(score_keys)
        if all_keys.any?
          redis.del(all_keys)
          response.reply(
            render_template(:clear_score,
                            team_name: team_name,
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