module Lita
  module Handlers
    class Balance < Handler
      include TeamHelpers
      namespace :team
      template_root File.expand_path("../../../../templates", __FILE__)

      route(
        /(\S*) team balance$/i,
        :balance,
        command: true,
        help: {
          "<name> team balance" => "Balance a given team."
        }
      )

      def balance(response)
      	team_name = response.match_data[1]
        if team = get_team(team_name)
          if members_even?(team, response)
            if team_scores = get_member_scores(team, response)
              ordered_scores = team_scores.sort{|a, b| b[1] <=> a[1] }.to_h
              blue_team = [] ; red_team = []

              ordered_scores.each do |score|
                blue_team_members_count = blue_team.count
                red_team_members_count = red_team.count

                blue_team_score_count = blue_team.map { |score| score[1]  }.inject(:+) || 0
                red_team_score_count = red_team.map { |score| score[1]  }.inject(:+) || 0
                
                if blue_team_members_count <= red_team_score_count
                  if blue_team_score_count <= red_team_score_count
                    blue_team.push score
                    next
                  end
                end
                red_team.push score
              end
              blue_team.map! { |member| member.first }
              red_team.map! { |member| member.first }
              response.reply(render_template(:balanced_teams, teams: blue_team.zip(red_team)))
            end
          end
        else
          response.reply(render_template(:team_not_found, team_name: team_name))
        end
      end

      private

      def get_member_scores(team, response)
        memeber_scores = {} ; missed_score = [] ; current_team_members = []
        team[:members].each_key { |key| current_team_members << key.to_s }
        current_team_members.each do |member_name|
          member_score = redis.get("scores:soccer:#{member_name}")
          if member_score
            memeber_scores[member_name] = member_score.to_i
          else
            missed_score << member_name
          end
        end
        if missed_score.any?
          response.reply(
            render_template(
              :missing_scores,
              team_name: team[:name],
              missing: missed_score
            )
          )
          return nil
        end
        return memeber_scores
      end

      def members_even?(team, response)
        if team[:members].count.odd?
          response.reply(render_template(:team_not_even, team_name: team[:name], count: team[:members].count))
          return false
        end
        true
      end

      Lita.register_handler(self)
    end
  end
end