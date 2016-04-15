require "pry"

module Lita
  module Handlers
    class SetScore < Handler
      include TeamHelpers
      namespace :team
      template_root File.expand_path("../../../../templates", __FILE__)

      route(
        /(\S*) team set (my|\S*) score ([1..10])$/i,
        :set_score,
        command: true,
        help: {
          "<name> team set <member> score <value(1-10)>" => "Set the score for a member in the team",
          "<name> team set my score <value(1-10)>" => "Set the score for me"
        }
      )

      def set_score(response)
        binding.pry
      	team_name = response.match_data[1]
        if team = get_team(team_name)
          member_name = if response.match_data[2].downcase == 'my'
            response.user.mention_name.delete("@")
          else
            response.match_data[2].delete("@")
          end
          score_value = response.match_data[3]
          member = member_data(member_name)
          
          data = {
            member[:name] => score_value
          }

          update_score(team[:name].to_sym, data)

          response.reply(
            render_template(:score_set,
                            team_name: team_name,
                            member_name: member[:name],
                            score: score_value)
          )
        else
          response.reply(render_template(:team_not_found, team_name: team_name))
        end
      end

      private

      def member_data(member_name)
        if lita_user = Lita::User.fuzzy_find(member_name)
          {
            id: lita_user.id,
            name: lita_user.name,
            mention_name: lita_user.mention_name
          }
        else
          { name: member_name }
        end
      end

      def update_score(team, score_data)
        score_value = redis.get('scores')
        if score_value
          curret_value = MultiJson.load(score_value, symbolize_keys: true)
          if curret_value[team]
            curret_value[team].merge!(score_data)
          else
            curret_value.merge!({ team => score_data })
          end
          redis.set('scores', MultiJson.dump(curret_value))
        else
          redis.set('scores',
            MultiJson.dump( { team => score_data } )
          )
        end
      end

      Lita.register_handler(self)
    end
  end
end