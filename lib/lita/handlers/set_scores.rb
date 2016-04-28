module Lita
  module Handlers
    class SetScores < Handler
      include TeamHelpers
      namespace :team
      template_root File.expand_path("../../../../templates", __FILE__)

      route(
        /(\S*) team set (my|\S*) score ([1-9]|10)$/i,
        :set_score,
        command: true,
        help: {
          "<name> team set <member> score <value(1-10)>" => "Set the score for a member in the team",
          "<name> team set my score <value(1-10)>" => "Set my score in the given team."
        }
      )

      def set_score(response)
      	team_name = response.match_data[1]
        if get_team(team_name)
          member_name = get_member_name(
            response.match_data[2], response.user.mention_name
          )

          if member_is_admin?(response.user.id)
            score_value = response.match_data[3]
            score_key = 'scores:' + team_name + ':' + member_name
            redis.set(score_key, score_value)

            response.reply(
              render_template(:set_score,
                              team_name: team_name,
                              member_name: member_name,
                              score: score_value)
            )
          else
            response.reply(render_template(:member_not_admin, admins: Lita.config.robot.admins))
          end
        else
          response.reply(render_template(:team_not_found, team_name: team_name))
        end
      end

      private

      def member_is_admin?(mention_name)
        Lita.config.robot.admins.include? mention_name
      end

      Lita.register_handler(self)
    end
  end
end